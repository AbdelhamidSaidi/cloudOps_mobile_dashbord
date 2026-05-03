# CloudOps Frontend — Documentation

This document describes the Flutter frontend used for the CloudOps mobile/web dashboard: architecture, important files, how to run and test locally, API contracts, and developer notes.

## Overview

- Framework: Flutter (Dart).
- Purpose: Mobile and web dashboard for CloudOps platform with glassmorphic UI.
- Main concerns: authentication, profile management (including edit & avatar upload), theme (dark/light), notification and settings UI.

## Quick start

Prerequisites:

- Flutter SDK installed and on PATH
- Chrome (for web testing) or a mobile device/emulator

Commands:

```bash
cd cloudops_frontend
flutter pub get
flutter analyze
flutter run -d chrome   # or -d <device-id>
```

If you want to use a real backend, update the `ApiService` baseUrl in `lib/services/api_service.dart`.

## Project structure (high level)

- lib/
  - main.dart — app entry, theme initialization, route hooks and `MainShell`.
  - theme.dart — glassmorphic color palette and `AppTheme` factories.
  - models/
    - user.dart — `User` model, `fromJson()` and `toJson()` used for profile updates.
  - services/
    - api_service.dart — HTTP client, `getProfile()`, `updateProfile()`, `uploadAvatarFromBytes()`, and auth-aware request helpers with 401-refresh retry.
    - auth_service.dart — login/logout/refresh; supports `mockMode` for local testing.
    - theme_service.dart — persisted dark/light theme state via secure storage.
  - screens/
    - login_screen.dart — glassmorphic login UI.
    - profile_screen.dart — profile display, `EDIT PROFILE` button that navigates to the edit screen.
    - edit_profile_screen.dart — edit profile form; calls `ApiService.updateProfile()` and returns updated `User` to the caller.
  - widgets/ — shared glassy widgets (cards, tiles, headers, etc.)

Other files:

- docs/API.md — API endpoint documentation (server contract). Use it when syncing backend endpoints.

## Architecture & Patterns

- Layered service pattern: UI screens call services in `lib/services/` which wrap HTTP calls and token handling.
- Models live in `lib/models/` and include JSON serialization methods.
- Theme is centralized: `ThemeService` exposes a `ValueNotifier` to toggle dark/light and persist choice.
- Auth flow: `AuthService` stores tokens in secure storage (or runs in `mockMode`). `ApiService` attaches bearer tokens and attempts a refresh when it receives 401 responses.

## Key flows

- Login
  - User enters credentials on `lib/screens/login_screen.dart`.
  - `AuthService.login()` is called and saves tokens. For local testing, `mockMode = true` supports a test credential pair.

- Profile view & edit
  - `lib/screens/profile_screen.dart` fetches the `User` via `ApiService.getProfile()` and displays info.
  - Tapping `EDIT PROFILE` pushes `EditProfileScreen(user: _user)` and waits for returned value. On successful save the `EditProfileScreen` pops the updated `User` and the `ProfileScreen` updates its UI.
  - `EditProfileScreen` calls `ApiService.updateProfile(Map<String, dynamic> updates)` which issues a PATCH to `/api/v1/profile`.
  - Avatar upload: `ApiService.uploadAvatarFromBytes()` performs a multipart POST to `/api/v1/profile/avatar`. The UI currently accepts an avatar URL in the edit screen; file-picker integration may be added to call `uploadAvatarFromBytes()`.

## API endpoints (frontend perspective)

Refer to [docs/API.md](docs/API.md) for the full server contract. Important endpoints used by the frontend:

- POST /api/v1/auth/login — login (returns access/refresh tokens)
- POST /api/v1/auth/refresh — refresh access token
- GET /api/v1/profile — fetch current user profile
- PATCH /api/v1/profile — update profile fields (name, role, location, avatar_url, etc.)
- POST /api/v1/profile/avatar — multipart upload for avatar image

The frontend `ApiService` implements helpers for these calls and handles bearer token management.

## Mocking & Local testing

- `AuthService` includes a `mockMode` that bypasses backend login and returns test tokens. Default test credentials in mock mode are:

  - Email: `admin@cloudops.internal`
  - Password: `Password123!`

- To test live backend flows, set `mockMode = false` and update `ApiService` baseUrl.

## Theming and UI

- The app uses a glassmorphic (frosted) UI using `BackdropFilter` and semi-transparent color layers defined in `lib/theme.dart`.
- `ThemeService` persists the user's dark/light preference using secure storage.

## Testing & Static Analysis

- Run static analysis:

```bash
flutter analyze
```

- Run unit/widget tests if present (no tests included by default in this scaffold).

## Development notes & next steps

- Avatar file-picker: `ApiService.uploadAvatarFromBytes()` exists but UI integration (image picker + file bytes) can be implemented in `edit_profile_screen.dart`.
- Replace `ApiService` baseUrl with your production/staging URL before integration testing.
- For end-to-end verification, use `flutter run -d chrome` and exercise Login → Profile → Edit → Save flows.

## References

- API contract: docs/API.md

---
If you want, I can also:

- wire an avatar file picker into `lib/screens/edit_profile_screen.dart` and call `uploadAvatarFromBytes()`; or
- generate a short CONTRIBUTING.md with steps for backend integration and release notes.

Created on: May 3, 2026
