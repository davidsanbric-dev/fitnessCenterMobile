.PHONY: emu run

emu:
	flutter emulators --launch Medium_Phone_API_36.1

run:
	flutter run --dart-define-from-file=.dart-defines.local.json
