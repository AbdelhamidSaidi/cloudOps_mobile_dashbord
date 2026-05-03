# API Endpoints for CloudOps Mobile Frontend

This document lists the backend endpoints the mobile frontend calls and the expected response payloads. Update `lib/services/api_service.dart` with your real `baseUrl`.

## Authentication
- The app currently assumes an authenticated session (e.g., bearer token). Add `Authorization` header in `ApiService._defaultHeaders()` when integrating.

## Endpoints

1) GET /api/v1/profile
- Description: Returns the currently authenticated user's profile information.
- Response (200):

```json
{
  "user": {
    "id": "123",
    "name": "Alex Rivera",
    "email": "alex.rivera@cloudops.internal",
    "role": "DevOps",
    "location": "Austin, TX (UTC-6)",
    "joined_at": "2022-01-15",
    "avatar_url": "https://.../avatar.jpg"
  }
}
```

- Fields used by the app: `user.name`, `user.email`, `user.role`, `user.location`, `user.joined_at`, `user.avatar_url`.

---

2) GET /api/v1/settings
- Description: Returns user-specific and application settings (theme, notification toggles, security settings).
- Response (200):

```json
{
  "theme": "dark", // or "light" or "system"
  "notifications": {
    "critical_incidents": true,
    "weekly_report": false
  },
  "security": {
    "two_factor_enabled": true,
    "active_sessions": 3
  }
}
```

---

3) GET /api/v1/notifications
- Description: Recent notifications/alerts for the user.
- Response (200):

```json
[
  { "id": "n1", "type": "incident", "title": "P1 - DB down", "created_at": "2026-05-01T12:34:56Z", "read": false },
  { "id": "n2", "type": "info", "title": "Weekly report ready", "created_at": "2026-04-30T09:00:00Z", "read": true }
]
```

---

4) GET /api/v1/sessions
- Description: Returns active device sessions for the user (used for Device Management UI).
- Response (200):

```json
{
  "sessions": [
    { "id": "s1", "device": "iPhone 13", "last_seen": "2026-05-02T08:12:00Z" },
    { "id": "s2", "device": "Windows Desktop", "last_seen": "2026-05-01T18:00:00Z" }
  ]
}

  ---

  ## Authentication Endpoints

  1) POST /api/v1/auth/login
  - Description: Authenticate a user and return access (and optionally refresh) tokens.
  - Request body (application/json):

  ```json
  { "email": "user@example.com", "password": "secret" }
  ```

  - Response (200):

  ```json
  {
    "access_token": "<jwt>",
    "refresh_token": "<refresh-token>",
    "expires_in": 3600
  }
  ```

  2) POST /api/v1/auth/refresh
  - Description: Exchange a refresh token for a new access token.
  - Request body:

  ```json
  { "refresh_token": "<refresh-token>" }
  ```

  - Response (200):

  ```json
  { "access_token": "<jwt>", "refresh_token": "<new-refresh>", "expires_in": 3600 }
  ```

  3) POST /api/v1/auth/logout
  - Description: Invalidate current access (and refresh) tokens.
  - Auth: Bearer token required in `Authorization` header.
  - Response: `204 No Content` or `200` on success.

  4) GET /api/v1/auth/me
  - Description: Return the authenticated user's profile.
  - Auth: Bearer token required.
  - Response (200):

  ```json
  { "id": "123", "name": "Alex Rivera", "email": "alex@cloudops.internal" }
  ```

  Notes:
  - Use standard HTTP status codes. Return `401` for invalid/expired tokens.
  - Use secure, HttpOnly cookies or Authorization headers depending on client needs. The mobile app currently expects `Authorization: Bearer <token>`.

```

---

Notes & Integration tips
- Use standard HTTP status codes. The mobile app expects `200` for success, otherwise it treats as failure.
- Implement authentication (e.g., JWT Bearer) and return the user's profile at `/api/v1/profile`.
- Return dates in ISO 8601 where possible.
- Extend endpoints as needed; update `ApiService` in the app accordingly.

Contact the frontend team if you want contract changes or additional fields.
