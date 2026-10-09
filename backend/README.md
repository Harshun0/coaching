# Backend + Admin (Next.js)

Serves the API the Flutter app talks to, and hosts the admin dashboard.

## Setup

1. Create a free [Neon](https://neon.tech) project, copy the pooled + direct connection strings.
2. `cp .env.example .env.local` and fill in every value (DB, JWT secret, Razorpay, storage — see below).
3. `npx prisma migrate dev --name init`
4. `npm run dev`

## API routes

- `POST /api/auth/signup` — create a student account.
- `POST /api/auth/login` — logs in. Single-device login applies to students only: first login claims the device, a different device is rejected with 409 until an admin resets it. Admins can log in from anywhere.
- `GET /api/courses` — published courses.
- `GET /api/courses/:id/lessons` — lessons in a course (403 unless enrolled).
- `GET /api/lessons/:id/video-url` — a signed, ~1-hour-expiring URL to stream one lesson's video (403 unless enrolled).
- `POST /api/payments/create-order` — student requests a Razorpay order for a course (rejects if already enrolled).
- `POST /api/payments/verify` — call after Razorpay checkout succeeds in the app; verifies the HMAC signature, marks the payment PAID, and enrolls the student (one DB transaction).
- `POST /api/admin/users/:id/reset-device` — admin-only, frees up a student's device slot.
- `GET/POST /api/admin/courses`, `PATCH/DELETE /api/admin/courses/:id` — course CRUD + publish toggle.
- `GET/POST /api/admin/courses/:id/lessons` — list lessons / create one and get a signed upload URL for its video.
- `GET /api/admin/users` — list all users with device-lock status.

## Video storage

Lesson videos live in a private bucket (`lesson-videos`) on **Neon's S3-compatible object storage** — no separate provider needed since Neon already hosts the DB. Nothing is ever public: the admin dashboard uploads via a short-lived signed PUT URL, and `/api/lessons/:id/video-url` hands enrolled students a short-lived signed GET URL. Direct/unsigned access to the bucket returns 403 (verified).

Env vars: `NEON_STORAGE_ENDPOINT`, `NEON_STORAGE_REGION`, `NEON_STORAGE_BUCKET`, `NEON_STORAGE_ACCESS_KEY_ID`, `NEON_STORAGE_SECRET_ACCESS_KEY` — from the Neon dashboard's Storage section.

## Payments

Needs `RAZORPAY_KEY_ID` / `RAZORPAY_KEY_SECRET` in `.env.local` — test-mode keys from the Razorpay dashboard to start, live keys before launch.

## Admin dashboard

`/admin/login` → `/admin/courses` (create/publish courses, click into a course to add lessons + upload video) and `/admin/users` (see device-lock status, reset it). Token stored in `localStorage`, not meant for the mobile app.

## Promoting the first admin

The signup route always creates `STUDENT`s. Promote the first admin directly in the DB:

```sql
UPDATE "User" SET role='ADMIN' WHERE email='you@example.com';
```

## Deploy

Push to GitHub, import the repo in [Vercel](https://vercel.com), set the same env vars there. Every push to `main` auto-deploys.
