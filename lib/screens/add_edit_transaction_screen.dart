import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/transaction.dart';
import '../services/database_service.dart';
import '../utils/constants.dart';

class AddEditTransactionScreen extends StatefulWidget {
  final Transaction? transaction;
  final String? transactionType;
  final DateTime? selectedDate;

  const AddEditTransactionScreen({
    super.key,
    this.transaction,
    this.transactionType,
    this.selectedDate,
  });

  @override
  State<AddEditTransactionScreen> createState() =>
      _AddEditTransactionScreenState();
}

class _AddEditTransactionScreenState extends State<AddEditTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _amountController;
  late TextEditingController _descriptionController;
  late String _type;
  late DateTime _date;
  String? _category;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _type = widget.transaction?.type ??
        widget.transactionType ??
        AppConstants.typeIncome;
    _date = widget.transaction?.date ?? widget.selectedDate ?? DateTime.now();
    _category = widget.transaction?.category;
    _amountController = TextEditingController(
      text: widget.transaction?.amount.toStringAsFixed(2) ?? '',
    );
    _descriptionController = TextEditingController(
      text: widget.transaction?.description ?? '',
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  List<String> get _categories {
    return _type == AppConstants.typeIncome
        ? AppConstants.incomeCategories
        : AppConstants.expenseCategories;
  }

  Future<void> _saveTransaction() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final amount = double.parse(_amountController.text);
    final now = DateTime.now();

    final transaction = Transaction(
      id: widget.transaction?.id,
      type: _type,
      amount: amount,
      description: _descriptionController.text,
      category: _category,
      date: _date,
      createdAt: widget.transaction?.createdAt ?? now,
      updatedAt: now,
    );

    try {
      if (widget.transaction == null) {
        await DatabaseService.instance.createTransaction(transaction);
      } else {
        await DatabaseService.instance.updateTransaction(transaction);
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.transaction == null
                  ? 'Transaction added'
                  : 'Transaction updated',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() => _date = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.transaction != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Transaction' : 'Add Transaction'),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (!isEdit) ...[
                      const Text(
                        'Transaction Type',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SegmentedButton<String>(
                        segments: const [
                          ButtonSegment(
                            value: 'income',
                            label: Text('Income'),
                            icon: Icon(Icons.arrow_downward),
                          ),
                          ButtonSegment(
                            value: 'expense',
                            label: Text('Expense'),
                            icon: Icon(Icons.arrow_upward),
                          ),
                        ],
                        selected: {_type},
                        onSelectionChanged: (Set<String> selected) {
                          setState(() {
                            _type = selected.first;
                            _category = null;
                          });
                        },
                      ),
                      const SizedBox(height: 24),
                    ],
                    TextFormField(
                      controller: _amountController,
                      decoration: const InputDecoration(
                        labelText: 'Amount *',
                        prefixText: '\$ ',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^\d+\.?\d{0,2}'),
                        ),
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter an amount';
                        }
                        final amount = double.tryParse(value);
                        if (amount == null || amount <= 0) {
                          return 'Please enter a valid amount';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description *',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 2,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a description';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _category,
                      decoration: const InputDecoration(
                        labelText: 'Category (Optional)',
                        border: OutlineInputBorder(),
                      ),
                      items: _categories.map((category) {
                        return DropdownMenuItem(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() => _category = value);
                      },
                    ),
                    const SizedBox(height: 16),
                    InkWell(
                      onTap: _selectDate,
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Date',
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.calendar_today),
                        ),
                        child: Text(
                          '${_date.year}-${_date.month.toString().padLeft(2, '0')}-${_date.day.toString().padLeft(2, '0')}',
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _saveTransaction,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _type == AppConstants.typeIncome
                                  ? AppConstants.incomeColor
                                  : AppConstants.expenseColor,
                              foregroundColor: Colors.white,
                            ),
                            child: Text(isEdit ? 'Update' : 'Save'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
