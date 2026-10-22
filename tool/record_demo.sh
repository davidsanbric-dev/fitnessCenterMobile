#!/usr/bin/env bash
# Records the member flow on a connected Android device/emulator by driving the
# app with the integration test while `adb screenrecord` captures the screen,
# then post-processes with ffmpeg into a short, followable clip.
#
# The same test runs in CI as a plain E2E check (DEMO_PACING=0), so the
# recording is a by-product of a real test rather than a separate script that
# can drift from the app.
#
# Usage:
#   cp tool/demo.env.example tool/demo.env   # then fill in the credentials
#   tool/record_demo.sh
#
# Requirements: adb, ffmpeg, a booted device, and a dart-defines file with
# BASE_URL. `screenrecord` caps a single capture at 180s, which is well beyond
# the 60-120s target.

set -euo pipefail

cd "$(dirname "$0")/.."

readonly OUT_DIR="${OUT_DIR:-build/demo}"
readonly DEVICE_MP4="/sdcard/fitnesscenter_demo.mp4"
readonly RAW="${OUT_DIR}/raw.mp4"
readonly FINAL="${OUT_DIR}/fitnesscenter-demo.mp4"
readonly DEFINES="${DEFINES:-.dart-defines.local.json}"
readonly ENV_FILE="${ENV_FILE:-tool/demo.env}"

log() { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
die() { printf '\033[1;31merror:\033[0m %s\n' "$*" >&2; exit 1; }

# ---------------------------------------------------------------- preflight
command -v adb >/dev/null || die "adb not found on PATH"
command -v ffmpeg >/dev/null || die "ffmpeg not found on PATH"
[[ -f "$DEFINES" ]] || die "missing $DEFINES (holds BASE_URL)"

# Credentials come from an untracked env file, never from this script.
[[ -f "$ENV_FILE" ]] || die "missing $ENV_FILE - copy tool/demo.env.example and fill it in"
# shellcheck disable=SC1090
source "$ENV_FILE"
[[ -n "${DEMO_EMAIL:-}" ]] || die "DEMO_EMAIL not set in $ENV_FILE"
[[ -n "${DEMO_PASSWORD:-}" ]] || die "DEMO_PASSWORD not set in $ENV_FILE"

mapfile -t devices < <(adb devices | awk 'NR>1 && $2=="device" {print $1}')
(( ${#devices[@]} > 0 )) || die "no device: boot the emulator or plug a phone in"
readonly SERIAL="${SERIAL:-${devices[0]}}"
log "device: $SERIAL"

mkdir -p "$OUT_DIR"

# Android 13+ gates notifications behind a runtime prompt. Pre-granting keeps
# the system dialog out of the recording without needing Patrol to tap it.
APP_ID="$(grep -oP 'applicationId\s*=\s*"\K[^"]+' android/app/build.gradle.kts || true)"
if [[ -n "$APP_ID" ]]; then
  adb -s "$SERIAL" shell pm grant "$APP_ID" android.permission.POST_NOTIFICATIONS 2>/dev/null \
    && log "granted POST_NOTIFICATIONS to $APP_ID" \
    || log "could not pre-grant notifications (app may not be installed yet)"
fi

# Keep the screen awake and hide status-bar clutter so the capture looks clean.
adb -s "$SERIAL" shell svc power stayon usb >/dev/null 2>&1 || true
adb -s "$SERIAL" shell cmd statusbar set-icon-visibility 2>/dev/null || true

# ---------------------------------------------------------------- record
log "starting screen capture"
adb -s "$SERIAL" shell rm -f "$DEVICE_MP4" 2>/dev/null || true
adb -s "$SERIAL" shell screenrecord --bit-rate 6000000 --size 720x1600 "$DEVICE_MP4" &
readonly REC_PID=$!
sleep 2  # let the encoder come up before the app launches

cleanup() {
  # Always stop the on-device recorder, even if the test fails, otherwise it
  # keeps running until its 180s cap and holds the file open.
  adb -s "$SERIAL" shell pkill -INT screenrecord 2>/dev/null || true
  wait "$REC_PID" 2>/dev/null || true
}
trap cleanup EXIT

log "running the member flow"
set +e
flutter test integration_test/member_flow_test.dart \
  -d "$SERIAL" \
  --dart-define-from-file="$DEFINES" \
  --dart-define=ENABLE_DEVICE_PREVIEW=false \
  --dart-define=DEMO_EMAIL="$DEMO_EMAIL" \
  --dart-define=DEMO_PASSWORD="$DEMO_PASSWORD"
readonly TEST_STATUS=$?
set -e

sleep 2  # trailing frames so the clip does not cut mid-animation
cleanup
trap - EXIT

if (( TEST_STATUS != 0 )); then
  log "the flow failed (exit $TEST_STATUS); pulling the capture anyway so you can see where"
fi

# ---------------------------------------------------------------- post-process
log "pulling capture"
adb -s "$SERIAL" pull "$DEVICE_MP4" "$RAW" >/dev/null
adb -s "$SERIAL" shell rm -f "$DEVICE_MP4" || true
[[ -s "$RAW" ]] || die "capture is empty"

DURATION="$(ffprobe -v error -show_entries format=duration -of csv=p=0 "$RAW" | cut -d. -f1)"
log "raw capture: ${DURATION}s"

# A Spanish title card, then the capture. `-vf` normalizes to an even width,
# which some encoders require, and keeps the phone aspect ratio intact.
log "encoding final clip"
ffmpeg -y -loglevel error \
  -f lavfi -i "color=c=0x081622:s=720x1600:d=2.5" \
  -i "$RAW" \
  -filter_complex "\
    [0:v]drawtext=text='FitnessCenter':fontcolor=0xA1D8E3:fontsize=58:x=(w-text_w)/2:y=(h/2)-90,\
         drawtext=text='Reserva de clases':fontcolor=0xECF3FA:fontsize=38:x=(w-text_w)/2:y=(h/2)-10,\
         drawtext=text='App movil Flutter':fontcolor=0x9FB4CA:fontsize=28:x=(w-text_w)/2:y=(h/2)+50[intro];\
    [1:v]scale=720:1600:force_original_aspect_ratio=decrease,\
         pad=720:1600:(ow-iw)/2:(oh-ih)/2:color=0x081622,setsar=1,fps=30[body];\
    [intro][body]concat=n=2:v=1:a=0[out]" \
  -map "[out]" -c:v libx264 -preset medium -crf 23 -pix_fmt yuv420p \
  "$FINAL"

FINAL_DURATION="$(ffprobe -v error -show_entries format=duration -of csv=p=0 "$FINAL" | cut -d. -f1)"
log "done: $FINAL (${FINAL_DURATION}s)"

if (( FINAL_DURATION > 120 )); then
  log "note: over the 120s target. Lower DEMO_PACING or trim with:"
  log "  ffmpeg -i $FINAL -ss 0 -t 120 -c copy ${FINAL%.mp4}-trimmed.mp4"
fi

exit "$TEST_STATUS"
