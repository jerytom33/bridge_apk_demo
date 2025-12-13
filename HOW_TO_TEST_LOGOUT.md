# IMPORTANT: How to Test Logout and Clear Profile Picture

## ⚠️ The Issue

You're seeing the old profile picture because you did **HOT RELOAD** instead of actually **LOGGING OUT** through the app.

**Hot Reload (`r`)** = Reloads UI code only, doesn't execute logout logic
**Using Logout Button** = Executes the full cleanup we added

## ✅ Correct Steps to Test

### Method 1: Use the Logout Button (RECOMMENDED)

1. **Open the app** on your device/emulator
2. **Navigate to Profile screen** (tap profile icon)
3. **Scroll down** and find the **red Logout button**
4. **Tap Logout**
5. **Confirm** in the dialog
6. You should see in terminal:
   ```
   🗑️ Deleted profile image: /data/user/0/.../image.jpg
   ✅ All user data cleared from SharedPreferences
   ```
7. **Login with a different user**
8. **Go to Profile**
9. ✅ Profile picture should be **cleared** (default icon)
10. ✅ Name and email should be **new user's data**

### Method 2: Hot Restart (Alternative)

1. In terminal where `flutter run` is running
2. Press `Shift + R` (capital R)
3. This completely restarts the app
4. Login again
5. Check profile

### Method 3: Uninstall and Reinstall

1. Stop the app
2. Uninstall from device/emulator
3. Run `flutter run` again
4. Login
5. Fresh install = no cached data

## 🔍 What to Check in Terminal

After pressing the logout button, you should see:

```
🗑️ Deleted profile image: /data/user/0/com.brigeit.world/cache/image.jpg
✅ All user data cleared from SharedPreferences
```

If you DON'T see these messages, you didn't actually tap the logout button.

## 🐛 Debugging

**Check 1: Did you actually logout?**
- Look for the logout confirmation dialog
- Did you tap "Logout" in the dialog?
- Check terminal for the 🗑️ and ✅ messages

**Check 2: Is the new code running?**
- Do hot reload: `r`
- Then tap logout button
- Check terminal output

**Check 3: Profile picture cache**
- The logout code now:
  1. Clears UI state
  2. Deletes image file
  3. Removes from SharedPreferences
  4. Navigates to login

## ⚡ Quick Test Right Now

1. **DON'T** press `r` or `R`
2. **In the running app**, tap:
   - Profile icon (bottom nav or top right)
   - Scroll to Logout button
   - Tap Logout
   - Tap "Logout" in dialog
3. **Watch terminal** for:
   ```
   🗑️ Deleted profile image...
   ✅ All user data cleared...
   ```
4. **Login** with different account
5. **Check profile** - should be clear!

## 📊 Expected Behavior

### After Logout:
- ❌ No profile picture (default icon)
- ❌ No user name (shows "Student" until login)
- ❌ No email saved
- ✅ Clean login screen

### After Login with New User:
- ✅ New user's email
- ✅ New user's name (when backend returns it)
- ❌ No profile picture (user hasn't uploaded one yet)

## 🎯 Summary

**You MUST actually use the logout button in the app!**

Hot reload does NOT:
- Execute logout code
- Delete image files
- Clear SharedPreferences
- Navigate to login

Hot reload only:
- Reloads UI widgets
- Keeps all state and data

**Action Required:**
👉 **Tap the Logout button in your running app** to test the cleanup!
