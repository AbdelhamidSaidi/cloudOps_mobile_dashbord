# UI Documentation — CloudOps Frontend

This file documents the user interface structure, components, screen flows, visual style, and developer notes for modifying the UI.

## Visual Style & Principles

- Glassmorphism: the app uses frosted glass cards built with `BackdropFilter` blur, semi-transparent color layers, soft borders, and subtle shadows.
- Consistent spacing: base spacing is 8 / 12 / 16 px steps; use `SizedBox` for vertical rhythm.
- Accessibility: ensure contrast for text over blurred backgrounds; prefer 14–18sp for body text on mobile and 20–28sp for headings.
- Responsiveness: layouts use `Row`/`Column` with `Expanded` and `Flexible`; screens adapt between narrow (mobile) and wide (tablet/web) breakpoints.

## Screens (Top-level)

- `LoginScreen` (`lib/screens/login_screen.dart`)
  - Glass login card centered on the page.
  - Fields: email, password with visibility toggle, remember checkbox.
  - Calls `AuthService.login()` on submit.

- `ProfileScreen` (`lib/screens/profile_screen.dart`)
  - Displays avatar, name, role, location, and contact info inside a glass profile card.
  - Sections: Profile header, Notification Settings, Theme switcher, Security, Logout.
  - `EDIT PROFILE` button pushes `EditProfileScreen` and updates local state when it returns a `User`.

- `EditProfileScreen` (`lib/screens/edit_profile_screen.dart`)
  - Glass form for editing `name`, `role`, `location`, and `avatar_url`.
  - Saves via `ApiService.updateProfile()` and `Navigator.pop(updatedUser)` on success.
  - (Enhancement) Avatar file-picker may be added to call `ApiService.uploadAvatarFromBytes()`.

- `MainShell` / Navigation
  - Bottom navigation with glass background implemented in `main.dart`.
  - Tabs for Home / Profile / Settings (as applicable). Use `IndexedStack` or `PageView` for tab content to preserve state.

## Reusable Widgets

- `SettingCard` (widgets)
  - Frosted container with title header and child content.

- `SectionHeader`
  - Small header text with subtle divider spacing.

- `ThemeTile`
  - Toggle tile used inside the Theme section to pick Light/Dark.

- Common patterns
  - All cards: `ClipRRect` + `BackdropFilter` + `Container` with gradient/opacity fill and border.
  - Buttons: elevated buttons use a tinted background from `GlassColors` (defined in `theme.dart`).

## Theming

- Colors and schemes live in `lib/theme.dart`.
- Use `AppTheme.light()` and `AppTheme.dark()` theme factories when building `MaterialApp`.
- For glass layers, prefer using colors with alpha channels (for example `0x66` or `0x80` prefixes) instead of fully opaque colors to preserve blur effect.

## Layout guidelines

- Use 16px horizontal padding for main content areas on mobile. Increase to 24–32px on tablet/web widths.
- For responsive cards, limit max width to 920–1100px to maintain readable line lengths.

## UI Interaction Patterns

- Navigation:
  - Use `Navigator.push(MaterialPageRoute(...))` for modal pages like Edit Profile.
  - Use named routes for full-page flows (login, onboarding) when appropriate.

- Forms:
  - Validate fields inline; show a minimal `SnackBar` for save success/failure.
  - While saving, disable inputs and show a small `CircularProgressIndicator` inside the save button.

- Avatar upload (recommended flow):
  1. On `EditProfileScreen`, add a tappable avatar preview that opens the platform image picker (use `image_picker` package).
  2. Convert the selected file to bytes and call `ApiService.uploadAvatarFromBytes(bytes, filename)`.
  3. Update `avatar_url` field with the returned URL and save the profile.

## Accessibility & Testing

- Ensure tappable targets are at least 48x48 dp.
- Support larger fonts via `MediaQuery.textScaleFactor` and verify layout doesn't overflow.
- Test screen-reader labels for important buttons and form fields.

## Developer Notes

- Adding a new screen:
  1. Create the file under `lib/screens/`.
  2. Prefer a single `StatefulWidget` or `StatelessWidget` with small helper widgets below for clarity.
  3. Use existing `SettingCard`/`SectionHeader` styles to maintain the glass look.

- Updating theme colors:
  - Edit `GlassColors` entries in `lib/theme.dart` and update both `AppTheme.light()` and `AppTheme.dark()`.

- Image assets & icons:
  - Use vector icons (`Icons` or `CupertinoIcons`) for platform-parity. For custom images, add to `assets/` and update `pubspec.yaml`.

## Suggested Enhancements

- Integrate `image_picker` in `EditProfileScreen` and wire `ApiService.uploadAvatarFromBytes()`.
- Add unit/widget tests for `EditProfileScreen` save flow and `ProfileScreen` navigation.
- Provide a small design tokens file for spacing/typography to centralize values.

---
Created: May 3, 2026
