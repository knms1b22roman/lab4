import 'package:flutter/material.dart';
import 'package:lab4/models/expense.dart';
import 'package:lab4/widgets/expenses_list/expenses_list.dart';
import 'package:lab4/widgets/new_expense.dart';
import 'package:lab4/widgets/chart/chart.dart';

class Expenses extends StatefulWidget {
  const Expenses({Key? key}) : super(key: key);

  @override
  State<Expenses> createState() {
    return _ExpensesState();
  }
}

class _ExpensesState extends State<Expenses> {
  Map<String, List<Expense>> familyExpenses = {
    'Dad': [],
    'Mother': [],
    'Brother': [],
    'Sister': [],
  };

  List<String> familyMembers = [
    'Dad',
    'Mother',
    'Brother',
    'Sister',
  ];

  List<Expense> allExpenses = [];

  String _selectedFamilyMember = 'Mother';
  bool _showTotal = false;
  bool _showDropdown = true;

  void _openAddExpenseOverlay() {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (ctx) => NewExpense(
        onAddExpense: _addExpense,
      ),
    );
  }

  void _addExpense(Expense expense) {
    final familyMember = expense.familyMember;
    if (familyExpenses.containsKey(familyMember)) {
      setState(() {
        familyExpenses[familyMember]!.add(expense);
        allExpenses.add(expense);
      });
    }
  }

  void _removeExpense(Expense expense) {
    final familyMember = expense.familyMember;
    if (familyExpenses.containsKey(familyMember)) {
      final index = familyExpenses[familyMember]!.indexOf(expense);
      setState(() {
        familyExpenses[familyMember]!.removeAt(index);
        allExpenses.remove(expense);
      });
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 3),
          content: const Text('Expense deleted.'),
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () {
              setState(() {
                familyExpenses[familyMember]!.insert(index, expense);
                allExpenses.add(expense);
              });
            },
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedFamilyMemberExpenses = familyExpenses[_selectedFamilyMember]!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Family Expense Tracker'),
        actions: [
          IconButton(
            onPressed: _openAddExpenseOverlay,
            icon: const Icon(Icons.add_box_rounded),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _showTotal =
                    !_showTotal; // Перемикач для відображення загальних витрат по темах
                if (_showTotal) {
                  _showDropdown =
                      false; // Приховувати DropdownButton у режимі сумарних витрат
                } else {
                  _showDropdown =
                      true; // Відображати DropdownButton у режимі окремих витрат
                }
              }); // Приховати DropdownButton у режимі сумарних витрат
            },
            child: Text(_showTotal ? 'Show Individual' : 'Show Total'),
          ),
          if (_showDropdown)
            DropdownButton(
              value: _selectedFamilyMember,
              items: familyMembers
                  .map(
                    (member) => DropdownMenuItem(
                      value: member,
                      child: Text(member),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedFamilyMember = value;
                  });
                }
              },
            ),
        ],
      ),
      body: Column(
        children: [
          Chart(
            memberExpenses:
                _showTotal ? allExpenses : selectedFamilyMemberExpenses,
          ),
          Expanded(
            child: ExpensesList(
              expenses: _showTotal ? allExpenses : selectedFamilyMemberExpenses,
              onRemoveExpense: _removeExpense,
            ),
          ),
        ],
      ),
    );
  }
}
