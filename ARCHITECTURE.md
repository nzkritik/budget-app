# Budget App Architecture

## Overview
This document describes the architecture and implementation details of the Budget App, a cross-platform Flutter application for personal budget management.

## Architecture Pattern
The app follows a simple layered architecture:
- **UI Layer**: Screens and Widgets
- **Business Logic**: Database operations and state management
- **Data Layer**: Models and local storage

## Directory Structure

### Models (`lib/models/`)
Contains data models that represent the core entities of the application.
- `transaction.dart`: Defines the Transaction model with serialization methods

### Services (`lib/services/`)
Contains business logic and data access layers.
- `database_service.dart`: Singleton service for SQLite database operations
  - CRUD operations for transactions
  - Monthly statistics calculations
  - Uses sqflite package for database access

### Screens (`lib/screens/`)
Main application screens that represent complete pages.
- `dashboard_screen.dart`: Shows monthly summary with income, expenses, and balance
- `transactions_screen.dart`: Lists all transactions for a selected month with filtering
- `add_edit_transaction_screen.dart`: Form for adding new or editing existing transactions

### Widgets (`lib/widgets/`)
Reusable UI components used across multiple screens.
- `transaction_tile.dart`: Displays a single transaction in a list
- `stats_card.dart`: Card widget for displaying financial statistics
- `month_year_picker.dart`: Custom date picker for selecting month and year

### Utils (`lib/utils/`)
Utility classes and helper functions.
- `constants.dart`: App-wide constants (colors, categories, transaction types)
- `helpers.dart`: Helper functions for formatting dates and currency

## Data Flow

### Adding a Transaction
1. User taps "Add Income" or "Add Expense" button
2. `AddEditTransactionScreen` opens with pre-selected type
3. User fills form and taps "Save"
4. Transaction is saved to SQLite via `DatabaseService`
5. User returns to previous screen
6. Screen refreshes to show updated data

### Viewing Transactions
1. User navigates to `TransactionsScreen`
2. Screen loads transactions for current month via `DatabaseService`
3. User can change month using `MonthYearPicker`
4. Transactions are re-fetched for selected month
5. Summary statistics are displayed at the top

### Editing/Deleting
1. User taps edit icon on a transaction
2. `AddEditTransactionScreen` opens with pre-filled data
3. Changes are saved via `DatabaseService.updateTransaction`
4. For delete: Confirmation dialog appears
5. If confirmed, transaction is deleted via `DatabaseService.deleteTransaction`

## Database Schema

### transactions Table
```sql
CREATE TABLE transactions (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  type TEXT NOT NULL,           -- 'income' or 'expense'
  amount REAL NOT NULL,
  description TEXT NOT NULL,
  category TEXT,
  date TEXT NOT NULL,           -- ISO 8601 format
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL
);
```

## State Management
The app uses StatefulWidget for local state management. Each screen manages its own state:
- Loading states
- Data lists
- Selected dates
- Form inputs

No global state management library is needed for this simple app, though the provider package is included for future extensions.

## Key Design Decisions

### 1. Local-First Architecture
- All data stored locally in SQLite
- No network calls or authentication
- Perfect for single-user, privacy-focused budgeting

### 2. Material Design 3
- Uses Flutter's Material 3 components
- Consistent color scheme throughout
- Responsive layouts for different screen sizes

### 3. Date-Based Organization
- Transactions organized by month and year
- Easy navigation between time periods
- Monthly summary calculations

### 4. Category System
- Pre-defined categories for income and expense
- Categories are optional
- Easy to extend with more categories

## Platform Support

### Android
- Minimum SDK: 21 (Android 5.0)
- Target SDK: Latest Flutter-supported version
- Uses Kotlin for native code

### iOS
- Minimum iOS version: 12.0
- Swift for native code
- Full iPhone and iPad support

### Web
- Progressive Web App (PWA) ready
- Service worker for offline support
- Responsive design

### Desktop (Windows, macOS, Linux)
- Native desktop applications
- Platform-specific window management
- Full keyboard and mouse support

## Testing Strategy

### Unit Tests
- Model serialization/deserialization
- Helper functions
- Data validation

### Widget Tests
- Individual widget behavior
- Form validation
- User interactions

### Integration Tests (Future)
- Complete user flows
- Database operations
- Navigation

## Future Enhancements
- Budget goals and limits
- Recurring transactions
- Data export (CSV, PDF)
- Charts and graphs
- Multi-currency support
- Cloud backup/sync
- Receipt attachments
