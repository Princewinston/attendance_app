# Web Platform Issue - sqflite Not Supported

## Problem
The app is running on **web (Chrome)** at `localhost:53020`, but **sqflite does not support web platforms**. This is why the app is stuck on the loading screen - the database initialization is failing silently.

## Solution

You have two options:

### Option 1: Run on Windows Desktop (Recommended)
Stop the current app and run it on Windows instead:

```cmd
# Stop the current app (press Ctrl+C in the terminal)
# Then run:
flutter run -d windows
```

### Option 2: Use web-compatible storage
If you must use web, you'll need to replace sqflite with a web-compatible database like:
- `shared_preferences` (for simple key-value storage)
- `indexed_db` (browser database)
- `hive` (works on all platforms including web)

## Why This Happened
- sqflite uses native SQLite which requires platform-specific code
- Web browsers don't support native code execution
- The app defaulted to running on Chrome instead of Windows

## Quick Fix
Simply run the app on Windows desktop and it will work perfectly!
