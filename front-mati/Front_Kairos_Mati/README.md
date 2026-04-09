# Kairos Flutter Web

Frontend mock in Flutter Web based on the Kairos social network design.

## Scope
- Frontend-only prototype.
- Backend integration is intentionally omitted.
- Prepared to connect later with a C# backend.

## Run
1. Install Flutter SDK (stable channel).
2. Enable web support:
   - `flutter config --enable-web`
3. Install dependencies:
   - `flutter pub get`
4. Run in browser:
   - `flutter run -d chrome`

## Suggested structure for backend integration
- Replace local mock data in `lib/app/data/mock_data.dart` with HTTP services.
- Keep UI state and models in place to map API responses.
