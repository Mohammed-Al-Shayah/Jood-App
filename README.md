# Jood App

Flutter app for restaurant discovery, booking, payments, and QR validation.

## Highlights

- Browse restaurants and offers
- Booking flow with QR validation
- Phone OTP authentication (Firebase)
- Payments via Thawani

## Tech Stack

- Flutter / Dart
- Firebase (Auth, Firestore, Storage, Functions, Crashlytics)
- BLoC + GetIt

## Getting Started

1. Install dependencies:
   - `flutter pub get`
2. Run the app:
   - `flutter run`

## Environment Setup

This project depends on Firebase configuration files.

- Android: `android/app/google-services.json`
- iOS: `ios/Runner/GoogleService-Info.plist`

If you don't have them yet, create a Firebase project and download the files, then place them in the paths above.

## Project Structure

- `lib/` app source
- `assets/` images and translations
- `functions/` Firebase Cloud Functions

## Smoke Test Checklist

- Register with phone OTP
- Login with phone OTP
- Edit profile and save changes
- QR scanner flow (scan + booking details + confirm)
- Home navigation between main tabs/screens

## Contributing

Pull requests are welcome. For major changes, please open an issue first.

## License

Private project. All rights reserved.
