# cloudops_frontend

Mobile frontend for the CloudOps platform (Flutter).

## Quick Start

1. Install Flutter SDK: https://docs.flutter.dev/get-started/install
2. From this directory run:

```bash
flutter pub get
flutter run
```

3. The app expects a backend API. See `docs/API.md` for the endpoints the app calls and example responses.

## Project Structure

- `lib/` — source code
	- `models/` — data models (`User`)
	- `services/` — API client (`ApiService`)
	- `screens/` — UI screens (profile)
- `docs/API.md` — API endpoint documentation and expected payloads

## Notes

- Update `lib/services/api_service.dart` and set `baseUrl` to your backend host or pass an explicit `baseUrl` when constructing `ApiService`.
- The app uses the `http` package for REST calls.


