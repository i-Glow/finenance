import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutterapp/utils/day.dart';
import 'package:flutterapp/utils/db.dart';
import 'package:intl/intl.dart';

class AddTransaction extends StatefulWidget {
  final List<ItemList>? list;
  const AddTransaction({Key? key, required this.list}) : super(key: key);

  @override
  State<AddTransaction> createState() => _AddTransactionState();
}

class _AddTransactionState extends State<AddTransaction> {
  //transaction type list
  List<String> items = [
    'Bills',
    'Clothes',
    'Deposit',
    'Electronics',
    'Entertainment',
    'Food',
    'Health',
    'Home goods',
    'Pets',
    'Self-Care',
    'Transport',
    'Other',
  ];
  dynamic selectedItem;

  @override
  void initState() {
    super.initState();
    setState(() {
      // items = items.where((element) => element == 'Food').toList();
      items = items
          .where((element) => !widget.list!.any((el) => element == el.title))
          .toList();
      selectedItem = items[0];
    });
  }

  final totalController = TextEditingController();
  final descriptionController = TextEditingController();

  @override
  void dispose() {
    // Clean up controllers when the widget is disposed.
    totalController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  confirmHandler() {
    int amount = 0;

    if (totalController.text.isNotEmpty) {
      amount = 0 - int.parse(totalController.text);

      if (selectedItem == 'Deposit') {
        amount = 0 - amount;
      }
    }

    ItemList item = ItemList(
        title: selectedItem,
        amount: amount,
        description: descriptionController.text);
    TransactionModel data = TransactionModel(
        date: DateFormat('E d, MMMM y').format(DateTime.now()),
        total: amount,
        items: [item]);

    DatabaseHelper.instance.addTransaction(data);
  }

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      heightFactor: 0.9,
      child: ListView(children: [
        Container(
          color: Colors.white,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child:
                      const Text('Back', style: TextStyle(color: Colors.blue))),
              const Text('Add a transaction'),
              TextButton(
                  onPressed: () {
                    confirmHandler();
                    Navigator.of(context).pop();
                    Navigator.of(context).pushNamed('/');
                  },
                  child: const Text('Confirm',
                      style: TextStyle(color: Colors.blue))),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.0),
            color: Colors.white,
          ),
          margin: const EdgeInsets.all(16.0),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: const [
                      SizedBox(width: 12.0),
                      Text(
                        'Transaction type',
                        style: TextStyle(fontSize: 14.0),
                      ),
                    ]),
                    const SizedBox(height: 8.0),
                    Container(
                      height: 48.0,
                      padding: const EdgeInsets.only(left: 12.0),
                      decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(4.0)),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton(
                            isExpanded: true,
                            elevation: 4,
                            dropdownColor: Colors.grey.shade200,
                            icon: const SizedBox.shrink(),
                            alignment: Alignment.centerLeft,
                            borderRadius: BorderRadius.circular(4.0),
                            value: selectedItem,
                            items: items.map((String item) {
                              return DropdownMenuItem(
                                value: item,
                                child: Text(
                                  item,
                                  style: const TextStyle(fontSize: 14.0),
                                ),
                              );
                            }).toList(),
                            onChanged: (item) {
                              setState(() {
                                selectedItem = item;
                              });
                            }),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 24.0,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        SizedBox(
                          width: 12.0,
                        ),
                        Text('Total Spent'),
                      ],
                    ),
                    const SizedBox(
                      height: 8.0,
                    ),
                    Container(
                      decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(4.0)),
                      height: 48.0,
                      child: TextField(
                        controller: totalController,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp(r'^\d+\.?\d{0,2}'))
                        ],
                        decoration: const InputDecoration(
                            border: InputBorder.none,
                            contentPadding:
                                EdgeInsets.symmetric(horizontal: 12.0)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 24.0,
                ),
                Column(
                  children: [
                    Row(
                      children: const [
                        SizedBox(
                          width: 12.0,
                        ),
                        Text('Description'),
                      ],
                    ),
                    const SizedBox(
                      height: 8.0,
                    ),
                    Container(
                      decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(4.0)),
                      child: TextField(
                        controller: descriptionController,
                        autocorrect: false,
                        minLines: 1,
                        maxLines: 20,
                        decoration: const InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.all(12.0)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ]),
    );
  }
}
