# Vendor Onboarding Android App

Flutter Android frontend for the Vendor Registration & Onboarding MVP.

## Run On Android

Start the backend first:

```bash
cd ../backend
npm start
```

Then run the Android app:

```bash
flutter pub get
flutter run -d <android-device-id> --dart-define=API_BASE_URL=http://10.0.2.2:4000
```

Use `10.0.2.2` for the Android emulator to reach the backend running on your Mac.
If you run on a real phone, replace it with your Mac's local network IP address.

Development OTP:

```text
123456
```
