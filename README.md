# Coaching App

Client's course-selling app. Two pieces:

- **backend/** — Frappe LMS (AGPL-3.0), self-hosted via Docker, handles courses, enrollment, admin panel, and payments (via the `frappe/payments` app, Razorpay).
- **mobile/** — Flutter app that talks to Frappe's built-in REST API (`/api/resource/<doctype>`). Adds the three things Frappe LMS doesn't have: screenshot/recording block, single-device login, and signed-URL video playback.

## Why this split

Frappe LMS gives us a battle-tested backend + admin + payment flow for free (the "no bugs" requirement). We only build the thin mobile layer on top, which is where the client's actual custom requirements live.

**Known risk:** Frappe LMS is AGPL-3.0. If we modify it and run it as a paid service, we may be required to publish our modifications. Flag this to the client before going further — see conversation notes.

## Status

Nothing is running yet — this machine has no Docker or Flutter SDK installed (by choice, no local storage for it). Everything here is source/config only. Build and deploy happens on:
- A VPS or cloud host for `backend/` (anywhere Docker runs — Railway, a $5 DigitalOcean droplet, etc.)
- A CI service (Codemagic, GitHub Actions, or a machine with Flutter installed) for `mobile/`

## Next steps

1. Pick a VPS/cloud host, deploy `backend/docker-compose.yml`, confirm Razorpay works via `frappe/payments`.
2. Get Flutter building somewhere (cloud CI or another machine) — run `flutter create .` inside `mobile/` to generate the `android/`/`ios/` platform folders, then the `lib/` code here plugs in.
3. Wire device-binding into Frappe (custom doctype or field on User) and screenshot-block + video player in the app.
