# Testing with Production Backend (Render)

## Quick Guide

To test your app with the **production backend** (Render) instead of local development, even when running in debug mode on an emulator:

### Method 1: Use Environment Variable (Recommended)

Stop your current Flutter run and restart with:

```powershell
flutter run --dart-define=USE_PRODUCTION=true
```

This will force the app to use `https://bridgeit-backend.onrender.com/api` even in debug mode.

### Method 2: Hot Restart

If you're already running the app:
1. Press `R` in the terminal to hot restart
2. The app will reload with the current configuration

### Verify Which Backend You're Using

The `ApiConfig.environment` property will tell you:
- `"Development (Local)"` - Using `http://192.168.29.174:8000/api`
- `"Production (Forced)"` - Using Render backend (via `--dart-define`)
- `"Production (Release)"` - Using Render backend (release build)

You can add a debug print to verify:
```dart
print('Current environment: ${ApiConfig.environment}');
print('Base URL: ${ApiConfig.baseUrl}');
```

## Commands Summary

| Command | Backend Used |
|---------|-------------|
| `flutter run` | Local development (`192.168.29.174:8000`) |
| `flutter run --dart-define=USE_PRODUCTION=true` | Production (Render) |
| `flutter build apk --release` | Production (Render) |

## Troubleshooting

**Issue:** Still connecting to local backend after using `--dart-define`

**Solution:** 
1. Stop the app completely (press `q` in terminal)
2. Run the command again with `--dart-define=USE_PRODUCTION=true`
3. Hot reload (`r`) won't pick up environment variables - you need a full restart
