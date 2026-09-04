# Vendor Registration & Onboarding MVP

Flutter frontend plus a lightweight Node backend for the vendor onboarding PRD.

## Stack

- Frontend: Flutter, Material 3
- Backend: Node.js HTTP server, no external runtime dependencies
- Persistence: JSON file at `backend/data/db.json`
- Payment, OTP, verification, uploads: MVP mocks with real state transitions

## Run Backend

```bash
cd backend
npm start
```

The API starts on `http://localhost:4000`.

## Run Frontend

Install Flutter SDK first, then:

```bash
cd frontend
flutter pub get
flutter run
```

For Android emulator access to the local backend, use `http://10.0.2.2:4000`.
For iOS simulator, desktop, or web on the same machine, use `http://localhost:4000`.

## MVP Notes

- OTP is mocked. The development OTP is returned by `/auth/send-otp`.
- Verification is submitted as `UNDER_REVIEW` and can be mocked as verified through the app flow.
- File uploads are represented as uploaded file metadata for the MVP.
- Payment is mocked and activates the vendor only after a successful payment call.
- After activation, the app routes only to the dashboard and does not allow returning to onboarding.
