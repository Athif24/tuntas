# Tuntas — Flutter App Plan

## 1. Project Structure

```
Tuntas/
├── lib/
│   ├── main.dart                          # App entry point, MaterialApp setup, theme, and route table
│   ├── models/
│   │   └── task.dart                      # Task data model class (id, title, description, date, type, isCompleted)
│   ├── database/
│   │   └── database_helper.dart           # SQLite database singleton: open, create tables, CRUD operations for tasks & users
│   ├── providers/
│   │   ├── task_provider.dart             # Manages task list state, CRUD operations, exposes tasks to UI
│   │   └── auth_provider.dart             # Manages login state, session, and password change logic
│   ├── screens/
│   │   ├── login_screen.dart              # Login page with username/password fields, validates against DB (default: user/user)
│   │   ├── beranda_screen.dart            # Home page: completed/incomplete counts, bar chart, 4 navigation buttons
│   │   ├── add_important_task_screen.dart # Add Penting task page: date picker, title, description, saves type="penting"
│   │   ├── add_regular_task_screen.dart   # Add Biasa task page: date picker, title, description, saves type="biasa"
│   │   ├── task_list_screen.dart          # Task list page: scrollable list, checkboxes, colored arrows, strikethrough
│   │   └── settings_screen.dart           # Settings page: change password (validates current), developer info (name, NIM, photo)
│   ├── widgets/
│   │   ├── task_tile.dart                 # Reusable widget for a single task row (checkbox, arrow, title, strikethrough)
│   │   ├── summary_card.dart              # Reusable card widget showing count (completed/incomplete) on Beranda
│   │   └── nav_button.dart                # Restyled navigation button widget used on Beranda
│   └── utils/
│       ├── colors.dart                    # Centralized color constants (penting, biasa, primary, accent, etc.)
│       └── app_routes.dart                # Named route string constants and onGenerateRoute handler
├── assets/
│   └── images/
│       └── developer_photo.jpg            # Developer photo for Pengaturan screen (placeholder; replace with actual image)
├── pubspec.yaml                           # Project config with all dependencies and assets declaration
└── PLAN.md                                # This file
```

---

## 2. Database Schema

### Table: `users`
| Column     | Type         | Constraints              | Description                        |
|------------|--------------|--------------------------|------------------------------------|
| id         | INTEGER      | PRIMARY KEY AUTOINCREMENT | Unique user ID                    |
| username   | TEXT         | NOT NULL, UNIQUE         | Login username                    |
| password   | TEXT         | NOT NULL                 | Login password                    |

- **Seed data**: On first app launch, insert default row: `(1, 'user', 'user')`

### Table: `tasks`
| Column        | Type         | Constraints               | Description                              |
|---------------|--------------|---------------------------|------------------------------------------|
| id            | INTEGER      | PRIMARY KEY AUTOINCREMENT | Unique task ID                           |
| title         | TEXT         | NOT NULL                  | Task title                               |
| description   | TEXT         | NOT NULL DEFAULT ''       | Task description                         |
| date          | TEXT         | NOT NULL                  | Task date in ISO format (YYYY-MM-DD)     |
| type          | TEXT         | NOT NULL CHECK(type IN ('penting', 'biasa')) | Task category |
| is_completed  | INTEGER      | NOT NULL DEFAULT 0        | 0 = incomplete, 1 = completed            |
| created_at    | TEXT         | NOT NULL DEFAULT CURRENT_TIMESTAMP | Creation timestamp              |

### Indexes
- `idx_tasks_type` on `tasks(type)` — for filtering by category
- `idx_tasks_date` on `tasks(date)` — for chart date grouping
- `idx_tasks_completed` on `tasks(is_completed)` — for filtering done/undone

### Database Helper Methods
| Method                             | Description                                              |
|------------------------------------|----------------------------------------------------------|
| `initDatabase()`                   | Opens/creates DB, runs onCreate and onUpgrade, inserts seed user |
| `insertUser(username, password)`   | Inserts a new user record                                |
| `validateUser(username, password)` | Returns true if credentials match a record               |
| `updatePassword(username, oldPassword, newPassword)` | Validates old password, then updates to new one |
| `insertTask(title, description, date, type)` | Inserts a new task, returns generated ID            |
| `getTasks()`                       | Returns all tasks ordered by created_at DESC             |
| `getTasksByType(type)`             | Returns tasks filtered by type ('penting' or 'biasa')    |
| `getCompletedCount()`              | Returns count where is_completed = 1                     |
| `getIncompleteCount()`             | Returns count where is_completed = 0                     |
| `getDailyCompletedCounts(days)`    | Returns list of {date, count} for last N days (bar chart) |
| `toggleTaskCompletion(id)`         | Flips is_completed between 0 and 1                       |
| `deleteTask(id)`                   | Deletes a task by ID                                     |

---

## 3. Dependencies

### `pubspec.yaml` — `dependencies`:
| Package              | Version Range | Purpose                                                    |
|----------------------|---------------|------------------------------------------------------------|
| `flutter`            | `sdk: flutter` | Core Flutter SDK                                          |
| `cupertino_icons`    | `^1.0.8`      | iOS-style icon set                                         |
| `sqflite`            | `^2.3.3`      | SQLite database for local storage                          |
| `sqflite_common_ffi` | `^2.3.2`      | SQLite FFI support (for testing on desktop)                |
| `path`               | `^1.9.0`      | Cross-platform path manipulation for DB file location      |
| `intl`               | `^0.20.2`     | Date/time formatting (Indonesian locale)                   |
| `fl_chart`           | `^0.69.0`     | Bar chart for tasks-completed-per-day on Beranda           |
| `shared_preferences` | `^2.3.0`      | Persist login session state (isLoggedIn flag)              |
| `provider`           | `^6.1.2`      | State management (ChangeNotifier-based)                    |

### `pubspec.yaml` — `dev_dependencies`:
| Package           | Version Range | Purpose                          |
|-------------------|---------------|----------------------------------|
| `flutter_test`    | `sdk: flutter`| Flutter testing framework        |
| `flutter_lints`   | `^5.0.0`      | Recommended lint rules           |

### `pubspec.yaml` — `flutter.assets`:
```yaml
flutter:
  assets:
    - assets/images/
```

---

## 4. Page Navigation Flow

### Route Map (Named Routes)

| Route Name              | Screen Widget                    | Auth Required | Description                              |
|-------------------------|----------------------------------|---------------|------------------------------------------|
| `/login`                | `LoginScreen`                    | No            | Entry screen; redirects to `/beranda` on success |
| `/beranda`              | `BerandaScreen`                  | Yes           | Home dashboard with stats and navigation |
| `/add-important-task`   | `AddImportantTaskScreen`         | Yes           | Form to add a "penting" task             |
| `/add-regular-task`     | `AddRegularTaskScreen`           | Yes           | Form to add a "biasa" task               |
| `/task-list`            | `TaskListScreen`                 | Yes           | Full task list with filter/toggle        |
| `/settings`             | `SettingsScreen`                 | Yes           | Change password, developer info          |

### Navigation Details

1. **App starts** → `main.dart` checks `shared_preferences` for `isLoggedIn` flag
   - If `true` → navigate to `/beranda`
   - If `false` → navigate to `/login`

2. **LoginScreen** → on successful validation → sets `isLoggedIn = true` → `Navigator.pushReplacementNamed('/beranda')`

3. **BerandaScreen** → contains 4 navigation buttons:
   - "Tambah Tugas Penting" → `Navigator.pushNamed('/add-important-task')`
   - "Tambah Tugas Biasa" → `Navigator.pushNamed('/add-regular-task')`
   - "Daftar Tugas" → `Navigator.pushNamed('/task-list')`
   - "Pengaturan" → `Navigator.pushNamed('/settings')`

4. **AddImportantTaskScreen** → on save → calls `TaskProvider.addTask(type: 'penting')` → `Navigator.pop()` (returns to Beranda)

5. **AddRegularTaskScreen** → on save → calls `TaskProvider.addTask(type: 'biasa')` → `Navigator.pop()` (returns to Beranda)

6. **TaskListScreen** → standalone page; checkboxes update in-place via `TaskProvider.toggleTask()`

7. **SettingsScreen** → "Logout" button → clears `isLoggedIn` → `Navigator.pushReplacementNamed('/login')`

8. **Logout flow**: Available from SettingsScreen; clears session and redirects to login.

### Route Generation Strategy
- Use `onGenerateRoute` in `MaterialApp` with a switch statement matching route strings to screen constructors.
- Each screen receives dependencies via `Provider.of()` — no route arguments needed.

---

## 5. State Management Approach

### Approach: **Provider (ChangeNotifier)**

**Why Provider:**
- The app is small-to-medium in scope (6 screens, 2 data models). Provider is lightweight, well-documented, and sufficient without the boilerplate of BLoC/Riverpod.
- `ChangeNotifier` pattern is straightforward for CRUD operations on tasks and auth state.
- Easy for maintainers to understand and extend.
- No need for complex state trees, middleware, or streams.

### Providers:

#### `AuthProvider` (extends ChangeNotifier)
| Field/Method             | Description                                        |
|--------------------------|----------------------------------------------------|
| `isLoggedIn` (bool)      | Whether the user is currently logged in            |
| `isLoading` (bool)       | Loading state during login validation              |
| `login(username, password)` | Validates credentials via DatabaseHelper, sets `isLoggedIn` |
| `logout()`               | Clears session, resets `isLoggedIn` to false       |
| `changePassword(oldPwd, newPwd)` | Validates old password, updates DB, notifies listeners |

#### `TaskProvider` (extends ChangeNotifier)
| Field/Method                  | Description                                          |
|-------------------------------|------------------------------------------------------|
| `tasks` (List<Task>)          | All tasks loaded from DB                             |
| `isLoading` (bool)            | Loading state during DB fetch                        |
| `completedCount` (int)        | Count of completed tasks                             |
| `incompleteCount` (int)       | Count of incomplete tasks                            |
| `dailyCompletedData` (List)   | Data for bar chart (last 7 days)                     |
| `loadTasks()`                 | Fetches all tasks from DB, computes derived values    |
| `addTask(title, desc, date, type)` | Inserts task into DB, reloads, notifies listeners |
| `toggleTaskCompletion(id)`    | Flips completion status in DB, reloads, notifies     |
| `deleteTask(id)`              | Removes task from DB, reloads, notifies              |

### Provider Placement:
- Both providers are declared at the top of the widget tree in `main.dart` via `MultiProvider`.
- Screens access providers using `Provider.of<T>(context)` or `context.read<T>()` / `context.watch<T>()`.
- `Consumer<TaskProvider>` used in BerandaScreen and TaskListScreen for efficient rebuilds.

---

## 6. Build Checklist

Execute these steps **in order**. Each step must complete before moving to the next.

### Phase 1: Project Setup
1. [ ] Update `pubspec.yaml`: add all dependencies (sqflite, path, intl, fl_chart, shared_preferences, provider) under `dependencies`
2. [ ] Update `pubspec.yaml`: add `assets/images/` under `flutter.assets`
3. [ ] Run `flutter pub get` to fetch all packages
4. [ ] Create directory structure:
   - `lib/models/`
   - `lib/database/`
   - `lib/providers/`
   - `lib/screens/`
   - `lib/widgets/`
   - `lib/utils/`
   - `assets/images/`

### Phase 2: Utility & Model Layer
5. [ ] Create `lib/utils/colors.dart`: define all color constants (see Section 7)
6. [ ] Create `lib/utils/app_routes.dart`: define route name constants and `onGenerateRoute` function
7. [ ] Create `lib/models/task.dart`: define `Task` class with `fromJson`, `toJson`, and `copyWith` methods

### Phase 3: Database Layer
8. [ ] Create `lib/database/database_helper.dart`:
   - Implement singleton `DatabaseHelper` class
   - `initDatabase()` with `onCreate` creating `users` and `tasks` tables
   - Insert seed user `(user, user)` in `onCreate`
   - Implement all CRUD methods listed in Section 2
   - Implement `getDailyCompletedCounts(7)` for bar chart data

### Phase 4: State Management Layer
9. [ ] Create `lib/providers/auth_provider.dart`:
   - Implement `AuthProvider` class extending `ChangeNotifier`
   - `login()`, `logout()`, `changePassword()` methods
   - Use `SharedPreferences` for session persistence
10. [ ] Create `lib/providers/task_provider.dart`:
    - Implement `TaskProvider` class extending `ChangeNotifier`
    - `loadTasks()`, `addTask()`, `toggleTaskCompletion()`, `deleteTask()`
    - Computed getters: `completedCount`, `incompleteCount`, `dailyCompletedData`

### Phase 5: Reusable Widgets
11. [ ] Create `lib/widgets/task_tile.dart`:
    - Accepts `Task` object and `onToggle` callback
    - Checkbox for completion toggle
    - Arrow icon: red (`kPentingColor`) if type='penting', green (`kBiasaColor`) if type='biasa'
    - Strikethrough text when `task.isCompleted == true`
12. [ ] Create `lib/widgets/summary_card.dart`:
    - Displays a count label (e.g., "Tugas Selesai: 5") with an icon
    - Used on Beranda for completed/incomplete counts
13. [ ] Create `lib/widgets/nav_button.dart`:
    - Styled button with icon + label
    - Used for the 4 navigation buttons on Beranda

### Phase 6: Screens (Build in dependency order)
14. [ ] Create `lib/screens/login_screen.dart`:
    - TextFormFields for username and password
    - Login button that calls `AuthProvider.login()`
    - Shows error snackbar on invalid credentials
    - On success: saves `isLoggedIn = true` via SharedPreferences, navigates to `/beranda`
15. [ ] Create `lib/screens/beranda_screen.dart`:
    - AppBar with app title
    - Two `SummaryCard` widgets (completed count, incomplete count)
    - `fl_chart` `BarChart` widget showing last 7 days of completed tasks
    - 4 `NavButton` widgets: Tambah Penting, Tambah Biasa, Daftar Tugas, Pengaturan
    - Wrapped in `Consumer<TaskProvider>` for auto-refresh
    - Logout button in AppBar actions
16. [ ] Create `lib/screens/add_important_task_screen.dart`:
    - Form with: `DatePicker` (date), `TextFormField` (title), `TextFormField` (description)
    - Save button: calls `TaskProvider.addTask(type: 'penting')`
    - Validates all fields are non-empty before saving
    - On save: pops back to Beranda
17. [ ] Create `lib/screens/add_regular_task_screen.dart`:
    - Identical form to above but saves with `type: 'biasa'`
18. [ ] Create `lib/screens/task_list_screen.dart`:
    - `ListView.builder` rendering `TaskTile` for each task
    - Uses `TaskProvider.tasks` from provider
    - Supports scrolling
    - AppBar with title and task count
    - Empty state widget when no tasks exist
19. [ ] Create `lib/screens/settings_screen.dart`:
    - "Change Password" section: 3 TextFormFields (current password, new password, confirm new password)
    - Validate current password matches via `DatabaseHelper`
    - Validate new password matches confirmation
    - Save button calls `AuthProvider.changePassword()`
    - "Developer Info" section: displays name, NIM, and photo (from `assets/images/developer_photo.jpg`)
    - Logout button at bottom

### Phase 7: App Entry Point & Wiring
20. [ ] Rewrite `lib/main.dart`:
    - Wrap app in `MultiProvider` with `AuthProvider` and `TaskProvider`
    - Initialize `SharedPreferences` and `DatabaseHelper` before `runApp`
    - Set up `MaterialApp` with:
      - `title: 'Agenda Nusantara'`
      - `theme` using color scheme from `utils/colors.dart`
      - `initialRoute` determined by login state (`/beranda` or `/login`)
      - `routes` map or `onGenerateRoute` using `utils/app_routes.dart`
    - Call `TaskProvider.loadTasks()` after login and on app start

### Phase 8: Assets
21. [ ] Add a placeholder developer photo at `assets/images/developer_photo.jpg` (any valid image, to be replaced later)

### Phase 9: Testing & Validation
22. [ ] Run `flutter analyze` — fix all warnings/errors
23. [ ] Run `flutter run` on emulator/device — verify all screens load
24. [ ] Test login flow:
    - Default credentials (user/user) succeed
    - Wrong credentials show error
    - After logout, return to login
25. [ ] Test task creation:
    - Add important task → appears in list with red arrow
    - Add regular task → appears in list with green arrow
26. [ ] Test task list:
    - Checkbox toggles completion and strikethrough
    - Counts on Beranda update after toggle
27. [ ] Test Beranda chart:
    - Bar chart reflects completed tasks per day
28. [ ] Test settings:
    - Change password with wrong current password → error
    - Change password with mismatched confirm → error
    - Successful change persists across logout/login
29. [ ] Test persistence:
    - Kill and restart app → login state persists
    - Tasks persist across restarts

---

## 7. Color Scheme

### Primary / Theme Colors
| Constant Name       | Hex Code  | Usage                                         |
|---------------------|-----------|-----------------------------------------------|
| `kPrimaryColor`     | `#1565C0` | Main app theme color (blue) — AppBar, buttons  |
| `kPrimaryLight`     | `#5E92F3` | Light variant of primary for backgrounds       |
| `kPrimaryDark`      | `#003C8F` | Dark variant of primary for status bar         |
| `kAccentColor`      | `#FF9800` | Accent color for highlights and FAB            |
| `kBackgroundColor`  | `#F5F5F5` | App background color (light gray)              |
| `kSurfaceColor`     | `#FFFFFF` | Card/surface background (white)                |
| `kTextColor`        | `#212121` | Primary text color (near black)                |
| `kTextSecondary`    | `#757575` | Secondary/hint text color (gray)               |

### Task Type Colors
| Constant Name   | Hex Code  | Usage                                          |
|-----------------|-----------|------------------------------------------------|
| `kPentingColor` | `#E53935` | Important task (penting) arrow icon, badges, accents |
| `kBiasaColor`   | `#43A047` | Regular task (biasa) arrow icon, badges, accents     |

### Status / Utility Colors
| Constant Name     | Hex Code  | Usage                                          |
|-------------------|-----------|------------------------------------------------|
| `kSuccessColor`   | `#4CAF50` | Success messages, confirmed actions            |
| `kErrorColor`     | `#F44336` | Error messages, validation failures            |
| `kCompletedColor` | `#9E9E9E` | Strikethrough/completed task text color        |

### ThemeData Configuration
```dart
ThemeData(
  colorScheme: ColorScheme.fromSeed(
    seedColor: Color(0xFF1565C0), // kPrimaryColor
    brightness: Brightness.light,
  ),
  appBarTheme: AppBarTheme(
    backgroundColor: Color(0xFF1565C0),
    foregroundColor: Colors.white,
  ),
  useMaterial3: true,
)
```