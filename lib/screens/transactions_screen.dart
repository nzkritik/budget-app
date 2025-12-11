import 'package:flutter/material.dart';
import '../models/transaction.dart';
import '../services/database_service.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';
import '../widgets/month_year_picker.dart';
import '../widgets/transaction_tile.dart';
import '../widgets/stats_card.dart';
import 'add_edit_transaction_screen.dart';

class TransactionsScreen extends StatefulWidget {
  final bool openAddTransaction;

  const TransactionsScreen({
    super.key,
    this.openAddTransaction = false,
  });

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  DateTime _selectedDate = DateTime.now();
  List<BudgetTransaction> _transactions = [];
  Map<String, double> _stats = {
    'income': 0.0,
    'expenses': 0.0,
    'balance': 0.0,
  };
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
    if (widget.openAddTransaction) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showAddTransactionMenu();
      });
    }
  }

  Future<void> _loadTransactions() async {
    setState(() => _isLoading = true);
    final transactions = await DatabaseService.instance.readTransactionsByMonth(
      _selectedDate.year,
      _selectedDate.month,
    );
    final stats = await DatabaseService.instance.getMonthlyStats(
      _selectedDate.year,
      _selectedDate.month,
    );
    setState(() {
      _transactions = transactions;
      _stats = stats;
      _isLoading = false;
    });
  }

  void _showAddTransactionMenu() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.arrow_downward, color: Colors.green),
              title: const Text('Add Income'),
              onTap: () {
                Navigator.pop(context);
                _navigateToAddTransaction(AppConstants.typeIncome);
              },
            ),
            ListTile(
              leading: const Icon(Icons.arrow_upward, color: Colors.red),
              title: const Text('Add Expense'),
              onTap: () {
                Navigator.pop(context);
                _navigateToAddTransaction(AppConstants.typeExpense);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _navigateToAddTransaction(String type) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditTransactionScreen(
          transactionType: type,
          selectedDate: _selectedDate,
        ),
      ),
    );
    _loadTransactions();
  }

  Future<void> _navigateToEditTransaction(BudgetTransaction transaction) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditTransactionScreen(
          transaction: transaction,
          selectedDate: _selectedDate,
        ),
      ),
    );
    _loadTransactions();
  }

  Future<void> _deleteTransaction(BudgetTransaction transaction) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Transaction'),
        content: const Text('Are you sure you want to delete this transaction?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && transaction.id != null) {
      await DatabaseService.instance.deleteTransaction(transaction.id!);
      _loadTransactions();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Transaction deleted')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          MonthYearPicker(
            selectedDate: _selectedDate,
            onDateChanged: (date) {
              setState(() => _selectedDate = date);
              _loadTransactions();
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: _buildMiniStatsCard(
                    'Income',
                    _stats['income']!,
                    AppConstants.incomeColor,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildMiniStatsCard(
                    'Expenses',
                    _stats['expenses']!,
                    AppConstants.expenseColor,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildMiniStatsCard(
                    'Balance',
                    _stats['balance']!,
                    _stats['balance']! >= 0
                        ? AppConstants.incomeColor
                        : AppConstants.expenseColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _transactions.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.inbox,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No transactions for this month',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: _transactions.length,
                        itemBuilder: (context, index) {
                          final transaction = _transactions[index];
                          return TransactionTile(
                            transaction: transaction,
                            onEdit: () => _navigateToEditTransaction(transaction),
                            onDelete: () => _deleteTransaction(transaction),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            onPressed: () => _navigateToAddTransaction(AppConstants.typeIncome),
            backgroundColor: Colors.green,
            icon: const Icon(Icons.add),
            label: const Text('Income'),
            heroTag: 'income',
          ),
          const SizedBox(width: 12),
          FloatingActionButton.extended(
            onPressed: () => _navigateToAddTransaction(AppConstants.typeExpense),
            backgroundColor: Colors.red,
            icon: const Icon(Icons.add),
            label: const Text('Expense'),
            heroTag: 'expense',
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStatsCard(String title, double amount, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              Helpers.formatCurrency(amount),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
