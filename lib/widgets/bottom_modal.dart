import 'package:flutter/material.dart';
import 'package:flutterapp/utils/day.dart';
import 'package:flutterapp/utils/db.dart';
import 'package:flutterapp/widgets/second_bottom_modal.dart';
import 'package:flutterapp/widgets/transaction_tile.dart';
import 'package:intl/intl.dart';

class BottomModal extends StatefulWidget {
  const BottomModal({Key? key}) : super(key: key);

  @override
  State<BottomModal> createState() => _BottomModalState();
}

class _BottomModalState extends State<BottomModal> {
  final _date = DateFormat('E d, MMMM y').format(DateTime.now());
  int length = 0;
  List items = [];
  TransactionModel data =
      TransactionModel(date: '', total: 0, items: <ItemList>[]);

  getData() async {
    TransactionModel res = await DatabaseHelper.instance.getWithDate(_date);
    setState(() {
      data = res;
    });
  }

  void dateHandler() {}

  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      heightFactor: 0.9,
      child: Column(children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child:
                    const Text('Cancel', style: TextStyle(color: Colors.blue))),
            const Text('Add a transaction', style: TextStyle(fontSize: 16.0)),
            const SizedBox(
              width: 46.0,
            ),
          ],
        ),
        Expanded(
          child: Container(
            decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12.0),
                    topRight: Radius.circular(12.0))),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24.0, vertical: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Transactions',
                                  style: TextStyle(fontSize: 18.0)),
                              Text('${data.total}',
                                  style: const TextStyle(fontSize: 16.0)),
                            ],
                          ),
                          const SizedBox(
                            height: 8.0,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: const [
                              Text('Date', style: TextStyle(fontSize: 18.0)),
                              Text('Today', style: TextStyle(fontSize: 16.0)),
                            ],
                          ),
                          const SizedBox(
                            height: 16.0,
                          ),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: data.items.length,
                            itemBuilder: (BuildContext context, int index) {
                              return TransactionTile(
                                  data: data.items, index: index);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton(
                      onPressed: () {
                        showModalBottomSheet(
                            isScrollControlled: true,
                            enableDrag: false,
                            context: context,
                            backgroundColor: Colors.grey.shade100,
                            builder: (context) =>
                                AddTransaction(list: data.items));
                      },
                      style: ButtonStyle(
                        minimumSize: MaterialStateProperty.all(
                            const Size(double.infinity, 40.0)),
                        shape: MaterialStateProperty.all(RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4.0))),
                        elevation: MaterialStateProperty.all(0.0),
                        backgroundColor: MaterialStateProperty.all(
                            Theme.of(context).primaryColor),
                      ),
                      child: Wrap(
                          spacing: 8.0,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: const [
                            Icon(Icons.add_circle),
                            Text(
                              'Add transaction',
                              style: TextStyle(fontSize: 18.0),
                            ),
                          ])),
                ),
              ],
            ),
          ),
        )
      ]),
    );
  }
}
