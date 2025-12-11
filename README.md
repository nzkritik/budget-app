# Budget App

A simple, single-user cross-platform budget application built with Flutter and SQLite for local data persistence.

## Features

- **Dashboard Screen**: View current month's income, expenses, and balance at a glance
- **Transaction Management**: Add, edit, and delete income and expense transactions
- **Historical View**: Browse transactions by year and month
- **Local Storage**: All data persists locally using SQLite database
- **Cross-Platform**: Runs on iOS, Android, Web, and Desktop

## Getting Started

### Prerequisites

- Flutter SDK (3.0.0 or higher)
- Dart SDK (3.0.0 or higher)

### Installation

1. Clone the repository:
```bash
git clone https://github.com/nzkritik/budget-app.git
cd budget-app
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
flutter run
```

### Building for Different Platforms

- **Android**: `flutter build apk`
- **iOS**: `flutter build ios`
- **Web**: `flutter build web`
- **Windows**: `flutter build windows`
- **macOS**: `flutter build macos`
- **Linux**: `flutter build linux`

## Project Structure

```
lib/
├── main.dart                           # Entry point
├── models/
│   └── transaction.dart                # Transaction data model
├── services/
│   └── database_service.dart           # SQLite database operations
├── screens/
│   ├── dashboard_screen.dart           # Main dashboard
│   ├── transactions_screen.dart        # Transaction list view
│   └── add_edit_transaction_screen.dart # Add/Edit transaction form
├── widgets/
│   ├── transaction_tile.dart           # Transaction list item
│   ├── stats_card.dart                 # Statistics card widget
│   └── month_year_picker.dart          # Month/Year selector
└── utils/
    ├── constants.dart                  # App constants
    └── helpers.dart                    # Helper functions
```

## Database Schema

The app uses SQLite with the following schema:

```sql
CREATE TABLE transactions (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  type TEXT NOT NULL,              -- 'income' or 'expense'
  amount REAL NOT NULL,
  description TEXT NOT NULL,
  category TEXT,
  date TEXT NOT NULL,              -- ISO 8601 format
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL
);
```

## Dependencies

- **sqflite**: SQLite database for Flutter
- **intl**: Date formatting and currency display
- **provider**: State management (included for future extensions)

## License

This project is open source and available under the MIT License.
