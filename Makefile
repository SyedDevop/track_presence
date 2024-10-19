setIcon:
	flutter pub run flutter_launcher_icons

uninstall:
	adb uninstall com.vcarehospital.vcare_attendance

install:
	adb install ./build/app/outputs/flutter-apk/app-release.apk

copy:
	adb push ./build/app/outputs/flutter-apk/app-release.apk /storage/emulated/0/
