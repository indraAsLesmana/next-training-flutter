import { Hono } from 'hono';
import { eq, and, desc, count } from 'drizzle-orm';
import { notifications } from './schema_extension';
import { users } from '../../flutter-task-api/src/db/schema';

// Helper function to create notifications for all students in a class when a task is created
export async function createNotificationsForClassTask(db: any, taskId: string, classId: string, taskDescription: String, endDateStr: string) {
  try {
    // 1. Find all students in target class
    const students = await db
      .select()
      .from(users)
      .where(and(eq(users.role, 'siswa'), eq(users.classId, classId)));

    if (students.length === 0) return;

    // 2. Batch insert notifications for each student
    const notificationRows = students.map((student: any) => ({
      userId: student.id,
      taskId: taskId,
      title: 'Tugas Baru Diberikan',
      message: `Guru telah memberikan tugas baru: "${taskDescription.substring(0, 50)}...". Tenggat: ${endDateStr.split('T')[0]}`,
      isRead: false,
    }));

    await db.insert(notifications).values(notificationRows);
  } catch (err) {
    console.error('Failed to create task notifications:', err);
  }
}

export function registerNotificationRoutes(app: Hono, getDb: () => any) {
  // 1. GET: Fetch notifications list for a student
  app.get('/api/notifications', async (c) => {
    const db = getDb();
    const userId = c.req.query('userId');

    if (!userId) {
      return c.json({ success: false, message: 'userId query parameter is required' }, 400);
    }

    try {
      const data = await db
        .select()
        .from(notifications)
        .where(eq(notifications.userId, userId))
        .orderBy(desc(notifications.createdAt));

      return c.json({ success: true, data });
    } catch (err: any) {
      return c.json({ success: false, message: err.message }, 500);
    }
  });

  // 2. GET: Unread notification count for a student
  app.get('/api/notifications/unread-count', async (c) => {
    const db = getDb();
    const userId = c.req.query('userId');

    if (!userId) {
      return c.json({ success: false, message: 'userId query parameter is required' }, 400);
    }

    try {
      const result = await db
        .select({ value: count() })
        .from(notifications)
        .where(and(eq(notifications.userId, userId), eq(notifications.isRead, false)));

      const unreadCount = result[0]?.value ?? 0;
      return c.json({ success: true, data: { unreadCount } });
    } catch (err: any) {
      return c.json({ success: false, message: err.message }, 500);
    }
  });

  // 3. PATCH: Mark single notification as read
  app.patch('/api/notifications/:id/read', async (c) => {
    const db = getDb();
    const id = c.req.param('id');

    try {
      const updated = await db
        .update(notifications)
        .set({ isRead: true })
        .where(eq(notifications.id, id))
        .returning();

      return c.json({ success: true, data: updated[0] });
    } catch (err: any) {
      return c.json({ success: false, message: err.message }, 500);
    }
  });

  // 4. PATCH: Mark all notifications as read for a user
  app.patch('/api/notifications/read-all', async (c) => {
    const db = getDb();
    const userId = c.req.query('userId');

    if (!userId) {
      return c.json({ success: false, message: 'userId is required' }, 400);
    }

    try {
      await db
        .update(notifications)
        .set({ isRead: true })
        .where(eq(notifications.userId, userId));

      return c.json({ success: true, message: 'All notifications marked as read' });
    } catch (err: any) {
      return c.json({ success: false, message: err.message }, 500);
    }
  });
}
