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

# Capture modes:
#   (default)        drive `adb shell screenrecord` on the device
#   --manual-capture guide you through the device's own screen recorder, for
#                    OEM builds that refuse to run screenrecord over adb
#   --post-only      skip capture entirely and post-process an existing file
MODE=record
case "${1:-}" in
  --post-only) MODE=post ;;
  --manual-capture) MODE=manual ;;
  "") ;;
  *) echo "unknown option: $1" >&2; exit 2 ;;
esac
POST_ONLY=false
[[ "$MODE" == post ]] && POST_ONLY=true

readonly OUT_DIR="${OUT_DIR:-build/demo}"
readonly DEVICE_MP4="/sdcard/fitnesscenter_demo.mp4"
readonly RAW="${OUT_DIR}/raw.mp4"
readonly FINAL="${OUT_DIR}/fitnesscenter-demo.mp4"
readonly DEFINES="${DEFINES:-.dart-defines.local.json}"
readonly ENV_FILE="${ENV_FILE:-tool/demo.env}"

log() { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
prompt() {
  printf '\n\033[1;33m  %s\033[0m\n' "$*"
  # Read from the terminal rather than stdin, so a piped or redirected stdin
  # does not turn the prompt into an instant EOF.
  if ! read -r _ < /dev/tty; then
    die "could not read from the terminal. Run this in an interactive shell."
  fi
}
die() { printf '\033[1;31merror:\033[0m %s\n' "$*" >&2; exit 1; }

# ---------------------------------------------------------------- preflight
command -v adb >/dev/null || die "adb not found on PATH"
command -v ffmpeg >/dev/null || die "ffmpeg not found on PATH"
[[ -f "$DEFINES" ]] || die "missing $DEFINES (holds BASE_URL)"

if [[ "$POST_ONLY" == false ]]; then
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


  # Android 13+ gates notifications behind a runtime prompt. Pre-granting keeps
  # the system dialog out of the recording without needing Patrol to tap it.
  APP_ID="$(grep -oP 'applicationId\s*=\s*"\K[^"]+' android/app/build.gradle.kts || true)"
  if [[ -n "$APP_ID" ]]; then
    adb -s "$SERIAL" shell pm grant "$APP_ID" android.permission.POST_NOTIFICATIONS 2>/dev/null \
      && log "granted POST_NOTIFICATIONS to $APP_ID" \
      || log "could not pre-grant notifications (app may not be installed yet)"
  fi

  # Some OEM builds (ColorOS/Realme among them) ship the screenrecord binary but
  # refuse to let the adb shell execute it. Only the scripted capture needs it.
  if [[ "$MODE" == record ]]; then
  # Without it the failure only surfaces later as an unexplained `adb pull`
  # error with nothing to fetch.
  if ! adb -s "$SERIAL" shell 'command -v screenrecord >/dev/null && screenrecord --help >/dev/null 2>&1; echo $?' 2>/dev/null | grep -q '^0'; then
    die "this device will not run 'adb shell screenrecord' (common on ColorOS/Realme).
    Record the screen another way, then post-process the file:

      # 1. start the phone's built-in screen recorder (Quick Settings)
      # 2. run the flow:
      flutter test integration_test/member_flow_test.dart -d $SERIAL \\
        --dart-define-from-file=$DEFINES --dart-define=ENABLE_DEVICE_PREVIEW=false \\
        --dart-define=DEMO_EMAIL=\"\$DEMO_EMAIL\" --dart-define=DEMO_PASSWORD=\"\$DEMO_PASSWORD\"
      # 3. stop the recording, pull it, and post-process:
      adb -s $SERIAL pull /sdcard/Movies/<your-recording>.mp4 $RAW
      tool/record_demo.sh --post-only

    Or record on the emulator instead, where screenrecord works.
    Guided alternative: tool/record_demo.sh --manual-capture"
  fi
  fi

  # Keep the screen awake and hide status-bar clutter so the capture looks clean.
  adb -s "$SERIAL" shell svc power stayon usb >/dev/null 2>&1 || true
  # Best effort and noisy on some builds, so both streams are discarded.
  adb -s "$SERIAL" shell cmd statusbar set-icon-visibility >/dev/null 2>&1 || true
fi

mkdir -p "$OUT_DIR"

# ---------------------------------------------------------------- record
if [[ "$POST_ONLY" == true ]]; then
  [[ -s "$RAW" ]] || die "--post-only needs an existing capture at $RAW"
  log "post-only: using the existing capture at $RAW"
  TEST_STATUS=0
elif [[ "$MODE" == manual ]]; then
  [[ -e /dev/tty ]] || die "--manual-capture needs an interactive terminal"
  # Build and install first, so the recording does not open on a Gradle wait.
  log "building and installing before you start recording"
  flutter install -d "$SERIAL" --debug \
    || die "could not install the app on $SERIAL (ColorOS needs 'Install via USB' enabled)"

  # Where a built-in recorder saves varies by OEM, and the folder often does
  # not exist until the first recording. So instead of watching one directory,
  # snapshot every video under the usual roots and diff afterwards. Failures are
  # tolerated: an `ls` on a missing folder returns non-zero, and under `set -e`
  # that used to kill the script silently, before the prompt had even printed.
  readonly RECORD_ROOTS="${RECORD_ROOTS:-/sdcard/DCIM /sdcard/Movies /sdcard/Recordings /sdcard/Pictures}"
  list_videos() {
    adb -s "$SERIAL" shell \
      "find $RECORD_ROOTS -type f \\( -iname '*.mp4' -o -iname '*.mkv' \\) 2>/dev/null" \
      2>/dev/null | tr -d '\r' | sort || true
  }
  BEFORE="$(list_videos)"

  prompt "Start the phone screen recorder now (Quick Settings), then press Enter."
  log "running the member flow - leave the phone alone until it finishes"

  set +e
  flutter test integration_test/member_flow_test.dart \
    -d "$SERIAL" \
    --dart-define-from-file="$DEFINES" \
    --dart-define=ENABLE_DEVICE_PREVIEW=false \
    --dart-define=DEMO_EMAIL="$DEMO_EMAIL" \
    --dart-define=DEMO_PASSWORD="$DEMO_PASSWORD"
  TEST_STATUS=$?
  set -e

  prompt "Stop the recording now, then press Enter."

  # Whatever video appeared while the flow ran is the take.
  AFTER="$(list_videos)"
  NEW="$(comm -13 <(echo "$BEFORE") <(echo "$AFTER") | tail -1)"
  [[ -n "$NEW" ]] || die "no new recording appeared under: $RECORD_ROOTS
  If your recorder saves elsewhere, pull the file by hand and run:
    adb -s $SERIAL pull <path-on-device> $RAW
    tool/record_demo.sh --post-only
  Or point the search at the right place with RECORD_ROOTS=..."
  log "pulling $NEW"
  adb -s "$SERIAL" pull "$NEW" "$RAW" >/dev/null
  [[ -s "$RAW" ]] || die "the pulled recording is empty"
else
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
adb -s "$SERIAL" pull "$DEVICE_MP4" "$RAW" >/dev/null \
  || die "nothing was captured on the device: screenrecord produced no file"
adb -s "$SERIAL" shell rm -f "$DEVICE_MP4" || true
[[ -s "$RAW" ]] || die "capture is empty"
fi

DURATION="$(ffprobe -v error -show_entries format=duration -of csv=p=0 "$RAW" | cut -d. -f1)"
FPS="$(ffprobe -v error -select_streams v:0 -show_entries stream=avg_frame_rate -of csv=p=0 "$RAW")"
log "raw capture: ${DURATION}s at ${FPS} fps"

# `adb screenrecord` writes a variable-frame-rate file whose nominal rate is the
# 90kHz media timebase (r_frame_rate=90000/1), not the real capture rate. Handing
# that to the `fps` filter makes it resample against 90000fps and emit frames
# without bound: the encode never finishes and the output grows past the source.
# Normalising with `-fps_mode cfr -r 30` instead uses the real timestamps.
readonly BODY="${OUT_DIR}/body.mp4"
readonly INTRO="${OUT_DIR}/intro.mp4"
readonly CONCAT_LIST="${OUT_DIR}/concat.txt"

log "normalising the capture to constant frame rate"
ffmpeg -y -hide_banner -loglevel error -stats \
  -i "$RAW" \
  -vf "scale=720:1600:force_original_aspect_ratio=decrease,pad=720:1600:(ow-iw)/2:(oh-ih)/2:color=0x081622,setsar=1" \
  -fps_mode cfr -r 30 \
  -c:v libx264 -preset veryfast -crf 23 -pix_fmt yuv420p -an \
  "$BODY"

# Encoded with the same parameters as the body so the two concatenate without
# a re-encode.
log "rendering the title card"
ffmpeg -y -hide_banner -loglevel error -stats \
  -f lavfi -i "color=c=0x081622:s=720x1600:r=30:d=2.5" \
  -vf "drawtext=text='FitnessCenter':fontcolor=0xA1D8E3:fontsize=58:x=(w-text_w)/2:y=(h/2)-90,\
drawtext=text='Reserva de clases':fontcolor=0xECF3FA:fontsize=38:x=(w-text_w)/2:y=(h/2)-10,\
drawtext=text='App movil Flutter':fontcolor=0x9FB4CA:fontsize=28:x=(w-text_w)/2:y=(h/2)+50" \
  -c:v libx264 -preset veryfast -crf 23 -pix_fmt yuv420p \
  "$INTRO"

log "joining"
printf "file '%s'\nfile '%s'\n" "$(basename "$INTRO")" "$(basename "$BODY")" > "$CONCAT_LIST"
ffmpeg -y -hide_banner -loglevel error \
  -f concat -safe 0 -i "$CONCAT_LIST" -c copy "$FINAL"
rm -f "$CONCAT_LIST"

FINAL_DURATION="$(ffprobe -v error -show_entries format=duration -of csv=p=0 "$FINAL" | cut -d. -f1)"
log "done: $FINAL (${FINAL_DURATION}s)"

if (( FINAL_DURATION > 120 )); then
  log "note: over the 120s target. Lower DEMO_PACING or trim with:"
  log "  ffmpeg -i $FINAL -ss 0 -t 120 -c copy ${FINAL%.mp4}-trimmed.mp4"
fi

exit "$TEST_STATUS"
