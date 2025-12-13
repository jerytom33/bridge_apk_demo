# Notification Navigation Implementation

## ✅ Changes Completed

### 1. Enhanced Notification Model
**File:** `lib/models/notification_model.dart`

**New Fields Added:**
- ✅ `relatedCourseId` - For course-related notifications
- ✅ `relatedExamId` - For exam-related notifications

These fields enable navigation to specific content when a notification is tapped.

---

### 2. Notifications Screen - Smart Navigation
**File:** `lib/screens/notifications_screen.dart`

**Added:** `handleNotificationTap()` method

**Supported Notification Types:**

#### Feed/Post Notifications
- `post_liked` → Navigate to Feed screen
- `post_saved` → Navigate to Feed screen  
- `new_post` → Navigate to Feed screen

#### Course Notifications
- `new_course` → Navigate to Courses screen
- `course_enrolled` → Navigate to Courses screen
- Uses `relatedCourseId` if available for future enhancement

#### Exam Notifications
- `new_exam` → Navigate to Exams screen
- `exam_reminder` → Navigate to Exams screen
- Uses `relatedExamId` if available for future enhancement

#### System Notifications
- `guide_approved`, `guide_rejected`
- `company_approved`, `company_rejected`
- `guide_registration`, `company_registration`
- These stay on notifications screen (admin/system only)

---

### 3. Firebase Push Notification Handling
**File:** `lib/services/notification_service.dart`

**Updated:** `_handleMessage()` method

**Firebase Data Payload Support:**

Backend can send notifications with these data fields:
```json
{
  "type": "new_course",
  "course_id": "123",
  "exam_id": "456"
}
```

**Navigation Logic:**
- Extracts `type`, `course_id`, `exam_id` from payload
- Routes to appropriate screen based on type
- Passes arguments for future detail screen implementation

**Supported Types:**
- ✅ Feed: `post_liked`, `post_saved`, `new_post`, `feed`
- ✅ Courses: `new_course`, `course_enrolled`, `course`
- ✅ Exams: `new_exam`, `exam_reminder`, `exam`
- ✅ System: `notification_screen`, `system`
- ✅ Profile: `profile`, `account`
- ✅ Default: Home screen

---

## 🎯 How It Works

### In-App Notification Tap
```dart
// User taps notification in NotificationsScreen
1. Mark notification as read
2. Check notification type
3. Navigate to appropriate screen
```

### Push Notification Tap (Background/Terminated)
```dart
// User taps push notification
1. Firebase extracts data payload
2. _handleMessage() processes type
3. Navigate using navigatorKey
```

---

## 📋 Usage Example

### Backend Sending Notification

**For New Course:**
```python
# Django backend sending FCM notification
send_fcm_message(
    token=user_fcm_token,
    title="New Course Available!",
    body="Check out the new Data Science course",
    data={
        "type": "new_course",
        "course_id": "123"
    }
)
```

**For Post Liked:**
```python
send_fcm_message(
    token=author_fcm_token,
    title="Someone liked your post!",
    body=f"{liker_name} liked your post",
    data={
        "type": "post_liked",
        "post_id": "456"
    }
)
```

**For Exam Reminder:**
```python
send_fcm_message(
    token=student_fcm_token,
    title="Exam Tomorrow!",
    body="JEE Main exam is scheduled tomorrow",
    data={
        "type": "exam_reminder",
        "exam_id": "789"
    }
)
```

---

## 🔄 User Flow

### Scenario 1: In-App Notification
```
User opens NotificationsScreen
    ↓
Sees "New Course Available" notification
    ↓
Taps notification
    ↓
Marked as read
    ↓
Navigates to Courses screen
```

### Scenario 2: Push Notification (App in Background)
```
Backend sends push notification
    ↓
User taps notification in notification tray
    ↓
App opens
    ↓
Firebase processes data payload
    ↓
Navigates to appropriate screen
```

---

## 🚀 Future Enhancements

### TODO: Specific Content Navigation

Currently navigates to list screens. Future enhancement to navigate to specific content:

```dart
// Example: Navigate to specific course detail
if (notification.relatedCourseId != null) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => CourseDetailScreen(
        courseId: notification.relatedCourseId!,
      ),
    ),
  );
}
```

### TODO: Post Detail Navigation

For feed notifications with `relatedPostId`:
```dart
case 'post_liked':
  if (notification.relatedPostId != null) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PostDetailScreen(
          postId: notification.relatedPostId!,
        ),
      ),
    );
  }
  break;
```

---

## 🎨 UI Indicators

Notification tiles show:
- ✅ **Icon** based on type (heart for likes, bookmark for saved, etc.)
- ✅ **Bold text** for unread notifications
- ✅ **Blue highlight** background for unread
- ✅ **Timestamp** (e.g., "5m ago", "2h ago")

---

## 🔔 Backend Integration Required

For this to work fully, the Django backend needs to:

1. **Include data payload** in FCM messages:
   ```python
   # In signals.py or wherever FCM is sent
   send_fcm_message(
       token=fcm_token,
       title="Title",
       body="Message",
       data={"type": "notification_type", "course_id": "123"}  # ← Add this
   )
   ```

2. **Store related IDs** in database:
   ```python
   # In Notification model
   class Notification(models.Model):
       # Existing fields...
       related_course_id = models.IntegerField(null=True, blank=True)
       related_exam_id = models.IntegerField(null=True, blank=True)
       related_post_id = models.IntegerField(null=True, blank=True)
   ```

---

## ✅ Testing Checklist

- [ ] Tap feed notification → Opens feed screen
- [ ] Tap course notification → Opens courses screen
- [ ] Tap exam notification → Opens exams screen
- [ ] Tap push notification (background) → Opens correct screen
- [ ] Notification marked as read after tap
- [ ] Badge count updates correctly
- [ ] Unknown notification types → Stay on notifications screen

---

## 📝 Summary

**Files Modified:**
1. ✅ `notification_model.dart` - Added course/exam ID fields
2. ✅ `notifications_screen.dart` - Added smart navigation on tap
3. ✅ `notification_service.dart` - Enhanced push notification handling

**Benefits:**
- 🎯 Users land on relevant content when tapping notifications
- 📱 Works for both in-app and push notifications
- 🔄 Extensible for future detail screen navigation
- ✅ Automatic read marking on interaction

**Ready for:** Network fix → Backend deployment → Testing! 🚀
