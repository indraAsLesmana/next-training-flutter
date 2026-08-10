# Notification Feature Draft & Integration Guide

This directory contains the standalone draft implementation for adding **Student Task Notifications** to the application.

## Directory Structure

```
scratch/
├── README.md                           # This guide
├── backend/
│   ├── schema_extension.ts             # Drizzle ORM schema for `notifications` table
│   └── notification_routes.ts          # Hono backend API endpoints for notifications
└── flutter/
    ├── models/
    │   └── notification_model.dart     # Flutter NotificationModel class
    ├── repositories/
    │   └── notification_repository.dart # Dio API client repository for notifications
    ├── providers/
    │   └── notification_provider.dart  # Provider state & 30s auto-refresh timer
    ├── screens/
    │   └── notifications_screen.dart   # UI screen for Notification Center
    └── widgets/
        └── notification_badge_icon.dart # Reusable Bell Icon with red unread badge
```

---

## How It Works

1. **Task Creation Trigger**:
   When a teacher creates a new task (`POST /api/tasks`), the backend queries all students enrolled in the target class and inserts a notification record into the `notifications` database table for each student.

2. **Frontend Synchronization**:
   - `NotificationProvider` fetches unread notifications when a student logs in.
   - It runs a lightweight background timer (every 30s) while the app is active to update the Bell badge counter (`🔔 [1]`).
   - Tapping the Bell icon opens `NotificationsScreen` where students can read messages and jump directly to assigned tasks.

---

## How to Integrate (When You're Ready)

1. **Backend**:
   - Copy `backend/schema_extension.ts` contents into `flutter-task-api/src/db/schema.ts`.
   - Run `npx drizzle-kit push` in `flutter-task-api` to create the `notifications` table in your Postgres database.
   - Import and register routes from `backend/notification_routes.ts` into `flutter-task-api/src/index.ts`.

2. **Flutter App**:
   - Copy the `flutter/` files into `flutter_training/lib/`.
   - Register `NotificationProvider` in `main.dart` `MultiProvider`.
   - Add `NotificationBadgeIcon` to the `AppBar` actions in `StudentHomeScreen`.
