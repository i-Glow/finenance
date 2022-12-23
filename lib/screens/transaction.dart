import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutterapp/utils/day.dart';
import 'package:flutterapp/utils/db.dart';

class Transaction extends StatefulWidget {
  final dynamic data;

  const Transaction({Key? key, this.data}) : super(key: key);

  @override
  State<Transaction> createState() => _TransactionState();
}

class _TransactionState extends State<Transaction> {
  Container _chooseIcon([item = 'Food']) {
    const double size = 28.0;
    const double padding = 6.0;
    const double borderRadius = 12.0;

    tile(int color, IconData icon) {
      return Container(
        padding: const EdgeInsets.all(padding),
        decoration: BoxDecoration(
          color: Color(color),
          borderRadius: const BorderRadius.all(Radius.circular(borderRadius)),
        ),
        child: Icon(icon, size: size, color: Colors.white),
      );
    }

    switch (item) {
      case 'Food':
        return tile(0xffbd9433, Icons.restaurant);
      case 'Health':
        return tile(0xffdb5656, CupertinoIcons.heart_fill);
      case 'Other':
        return tile(0xffffba23, Icons.shopping_basket_rounded);
      case 'Deposit':
        return tile(0xff4ab07e, Icons.attach_money_sharp);
      case 'Electronics':
        return tile(0xff33adff, Icons.computer);
      case 'Self-Care':
        return tile(0xffb87089, Icons.abc);
      case 'Entertainment':
        return tile(0xff915bbd, Icons.sports_basketball);
      case 'Transport':
        return tile(0xffb3b4b5, Icons.tram);
      case 'Clothes':
        return tile(0xff326ccf, Icons.abc);
      case 'Pets':
        return tile(0xff8c5f34, Icons.pets);
      case 'Home goods':
        return tile(0xffedbfa6, Icons.home);
      case 'Bills':
        return tile(0xffb5192c, Icons.money_off);
      default:
        return tile(0xffffba23, Icons.shopping_basket_rounded);
    }
  }

  final amountController = TextEditingController();
  final descriptionController = TextEditingController();

  void updateControllers() {
    amountController.value = amountController.value.copyWith(
      text: "${widget.data['data'].amount}".replaceFirst("-", ""),
      selection: TextSelection.collapsed(
          offset: "${widget.data['data'].amount}".length),
    );

    descriptionController.value = descriptionController.value.copyWith(
      text: widget.data['data'].description,
      selection: TextSelection.collapsed(
          offset: widget.data['data'].description.length),
    );
  }

  saveHandler() {
    int amount = 0 - int.parse(amountController.text);

    ItemList item = ItemList(
        title: widget.data['data'].title,
        amount: amount,
        description: descriptionController.text);
    TransactionModel data = TransactionModel(
        date: widget.data['date'], total: widget.data['total'], items: [item]);

    DatabaseHelper.instance.updateTransaction(data);
    Navigator.of(context).pushNamed('/');
  }

  @override
  initState() {
    super.initState();
    updateControllers();
  }

  @override
  void dispose() {
    // Clean up controllers when the widget is disposed.
    amountController.dispose();
    super.dispose();
  }

  List<Widget> defaultUi() {
    return [
      Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
        OutlinedButton(
          onPressed: () {
            DatabaseHelper.instance.deleteItem(widget.data);
            Navigator.of(context).pushNamed('/');
          },
          style: ButtonStyle(
              side: MaterialStateProperty.all(
                  const BorderSide(color: Colors.red)),
              padding: MaterialStateProperty.all(const EdgeInsets.symmetric(
                  horizontal: 32.0, vertical: 12.0))),
          child: const Text(
            'Delete',
            style: TextStyle(fontSize: 18.0, color: Colors.red),
          ),
        ),
        ElevatedButton(
            onPressed: () {
              setState(() {
                _isEditing = true;
              });
            },
            style: ButtonStyle(
                padding: MaterialStateProperty.all(const EdgeInsets.symmetric(
                    horizontal: 42.0, vertical: 12.0))),
            child: const Text('Edit', style: TextStyle(fontSize: 18.0)))
      ])
    ];
  }

  List<Widget> editUi() {
    return [
      Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
        OutlinedButton(
          onPressed: () {
            amountController.text =
                "${widget.data['data'].amount}".replaceFirst("-", "");

            descriptionController.text = widget.data['data'].description;

            setState(() {
              _isEditing = false;
            });
          },
          style: ButtonStyle(
              padding: MaterialStateProperty.all(const EdgeInsets.symmetric(
                  horizontal: 32.0, vertical: 12.0))),
          child: const Text(
            'Cancel',
            style: TextStyle(fontSize: 18.0),
          ),
        ),
        ElevatedButton(
            onPressed: saveHandler,
            style: ButtonStyle(
                padding: MaterialStateProperty.all(const EdgeInsets.symmetric(
                    horizontal: 42.0, vertical: 12.0))),
            child: const Text('Save', style: TextStyle(fontSize: 18.0)))
      ])
    ];
  }

  bool _isEditing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back),
          color: Colors.black87,
        ),
        title: Text(
          widget.data['date'],
          style: const TextStyle(color: Colors.black87),
        ),
        centerTitle: true,
        elevation: 1.0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            ListTile(
              contentPadding: const EdgeInsets.all(0.0),
              leading: _chooseIcon(widget.data['data'].title),
              title: Text(
                widget.data['data'].title,
                style: const TextStyle(color: Color(0xff3b4475)),
              ),
              subtitle: Text(
                widget.data['data'].description,
                maxLines: 1,
              ),
              trailing: Text("${widget.data['data'].amount}"),
            ),
            const Text("Amount", style: TextStyle(fontSize: 18.0)),
            Container(
              decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(4.0)),
              height: 48.0,
              child: TextField(
                enabled: _isEditing,
                controller: amountController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))
                ],
                decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 12.0)),
              ),
            ),
            const SizedBox(height: 8.0),
            const Text("Description", style: TextStyle(fontSize: 18.0)),
            const SizedBox(height: 8.0),
            Container(
              decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(4.0)),
              child: TextField(
                controller: descriptionController,
                enabled: _isEditing,
                autocorrect: false,
                minLines: 1,
                maxLines: 20,
                decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0)),
              ),
            ),
            const SizedBox(
              height: 16.0,
            ),
            if (_isEditing == false) ...defaultUi() else ...editUi(),
          ]),
        ),
      ),
    );
  }
}
