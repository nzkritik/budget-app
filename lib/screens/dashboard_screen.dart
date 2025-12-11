import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';
import '../widgets/stats_card.dart';
import 'transactions_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Map<String, double> _stats = {
    'income': 0.0,
    'expenses': 0.0,
    'balance': 0.0,
  };
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() => _isLoading = true);
    final now = DateTime.now();
    final stats = await DatabaseService.instance.getMonthlyStats(
      now.year,
      now.month,
    );
    setState(() {
      _stats = stats;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Budget App'),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadStats,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Current Month: ${Helpers.formatMonthYear(DateTime.now())}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      StatsCard(
                        title: 'Total Income',
                        amount: _stats['income']!,
                        color: AppConstants.incomeColor,
                        icon: Icons.arrow_downward,
                      ),
                      const SizedBox(height: 12),
                      StatsCard(
                        title: 'Total Expenses',
                        amount: _stats['expenses']!,
                        color: AppConstants.expenseColor,
                        icon: Icons.arrow_upward,
                      ),
                      const SizedBox(height: 12),
                      StatsCard(
                        title: 'Current Balance',
                        amount: _stats['balance']!,
                        color: _stats['balance']! >= 0
                            ? AppConstants.incomeColor
                            : AppConstants.expenseColor,
                        icon: Icons.account_balance_wallet,
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const TransactionsScreen(),
                              ),
                            );
                            _loadStats();
                          },
                          icon: const Icon(Icons.list),
                          label: const Text('View Transactions'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.all(16),
                            backgroundColor: AppConstants.primaryColor,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const TransactionsScreen(
                                  openAddTransaction: true,
                                ),
                              ),
                            );
                            _loadStats();
                          },
                          icon: const Icon(Icons.add),
                          label: const Text('Add Transaction'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.all(16),
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
