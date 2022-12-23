import 'package:flutter/material.dart';
import 'package:flutterapp/utils/day.dart';
import 'package:flutterapp/widgets/bottom_modal.dart';
import 'package:flutterapp/widgets/transaction_tile.dart';
import 'package:intl/intl.dart';
import '../utils/db.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final _date = DateFormat('MMMM d').format(DateTime.now());

  int _selectedMonth = 0;
  int _total = 0;

  final List<String> _months = [
    DateFormat('MMMM').format(DateTime.now()),
    DateFormat('MMMM')
        .format(DateTime(DateTime.now().year, DateTime.now().month - 1)),
    DateFormat('MMMM')
        .format(DateTime(DateTime.now().year, DateTime.now().month - 2)),
    DateFormat('MMMM')
        .format(DateTime(DateTime.now().year, DateTime.now().month - 3)),
    DateFormat('MMMM')
        .format(DateTime(DateTime.now().year, DateTime.now().month - 4)),
    DateFormat('MMMM')
        .format(DateTime(DateTime.now().year, DateTime.now().month - 5)),
  ];

  @override
  initState() {
    super.initState();
    setState(() {
      _selectedMonth = 0;
    });

    DatabaseHelper.instance.getWallet().then((value) {
      setState(() {
        _total = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {},
          icon: const Icon(Icons.calendar_today),
          color: Colors.black87,
        ),
        title: Text(
          _date,
          style: const TextStyle(color: Colors.black87, fontSize: 14.0),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0.0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        physics: const BouncingScrollPhysics(),
        scrollDirection: Axis.vertical,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(16.0)),
              margin: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Main Wallet',
                      style: TextStyle(color: Colors.white)),
                  const SizedBox(height: 10.0),
                  Text(
                    '$_total',
                    style: const TextStyle(fontSize: 28.0, color: Colors.white),
                  ),
                  const SizedBox(height: 42.0),
                  Row(
                      // children: [
                      //   Column(
                      //     crossAxisAlignment: CrossAxisAlignment.start,
                      //     children: const [
                      //       Text('Expenses',
                      //           style: TextStyle(color: Colors.white)),
                      //       SizedBox(height: 6.0),
                      //       Text('1 670', style: TextStyle(color: Colors.white)),
                      //     ],
                      //   ),
                      //   const SizedBox(width: 6.0),
                      //   Column(
                      //     crossAxisAlignment: CrossAxisAlignment.start,
                      //     children: const [
                      //       Text('Income', style: TextStyle(color: Colors.white)),
                      //       SizedBox(height: 6.0),
                      //       Text('2 930', style: TextStyle(color: Colors.white)),
                      //     ],
                      //   ),
                      //   const SizedBox(width: 6.0),
                      //   Column(
                      //     crossAxisAlignment: CrossAxisAlignment.start,
                      //     children: [
                      //       const Text('This Month',
                      //           style: TextStyle(color: Colors.white)),
                      //       const SizedBox(height: 6.0),
                      //       Text('$_thisMonthTotal',
                      //           style: const TextStyle(color: Colors.white)),
                      //     ],
                      //   )
                      // ],
                      )
                ],
              ),
            ),
            Container(
              height: 60.0,
              alignment: Alignment.bottomCenter,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const AlwaysScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: _months.length,
                itemBuilder: (BuildContext context, int index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6.0),
                    child: FilterChip(
                      selected: index == _selectedMonth,
                      onSelected: (bool value) {
                        setState(() {
                          _selectedMonth = index;
                        });
                      },
                      label: Text(
                        _months[index],
                      ),
                    ),
                  );
                },
              ),
            ),
            Daily(month: _months[_selectedMonth])
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).primaryColor,
        onPressed: () {
          showModalBottomSheet(
              isScrollControlled: true,
              enableDrag: false,
              context: context,
              builder: (context) => const BottomModal());
        },
        child: const Icon(
          Icons.add,
          size: 24.0,
        ),
      ),
    );
  }
}

class Daily extends StatefulWidget {
  final String month;
  const Daily({Key? key, required this.month}) : super(key: key);

  @override
  State<Daily> createState() => _DailyState();
}

class _DailyState extends State<Daily> {
  List items = [];
  bool isLoaded = false;

  getData(String month) async {
    DatabaseHelper.instance.getTransactions(month).then((value) {
      setState(() {
        items = value;
      });
      setState(() {
        isLoaded = true;
      });
    });
  }

  @override
  void didUpdateWidget(_DailyState) {
    getData(widget.month);
    super.didUpdateWidget(_DailyState);
  }

  @override
  void initState() {
    super.initState();
    getData(widget.month);
  }

  @override
  Widget build(BuildContext context) {
    return Visibility(
      replacement: const Center(child: CircularProgressIndicator()),
      visible: isLoaded,
      child: ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: items.length,
        scrollDirection: Axis.vertical,
        padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 16.0),
        itemBuilder: (BuildContext context, int index) {
          return DayPurchases(items: items[index], index: index);
        },
      ),
    );
  }
}

class DayPurchases extends StatefulWidget {
  final dynamic items;
  final int index;

  const DayPurchases({Key? key, required this.items, required this.index})
      : super(key: key);

  @override
  State<DayPurchases> createState() => _DayPurchasesState();
}

class _DayPurchasesState extends State<DayPurchases> {
  String append = 'more';
  int itemsLength = 3;

  handleAppend(int index) {
    if (append == 'more') {
      setState(() {
        append = 'less';
        itemsLength = widget.items.items.length;
      });
    } else {
      setState(() {
        append = 'more';
        itemsLength = 3;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('${widget.items.date.split(",")[0]}'),
            Text("${widget.items.total}")
          ],
        ),
        PurchaseTile(
            data: widget.items.items,
            length: itemsLength,
            date: widget.items.date,
            total: widget.items.total),
        Visibility(
          visible: widget.items.items.length > 3,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                  onPressed: () {
                    handleAppend(widget.index);
                  },
                  child: Text(append))
            ],
          ),
        ),
        const SizedBox(height: 32.0),
      ],
    );
  }
}

class PurchaseTile extends StatelessWidget {
  final List<ItemList> data;
  final int length;
  final String date;
  final int total;

  const PurchaseTile(
      {Key? key,
      required this.data,
      required this.length,
      required this.date,
      required this.total})
      : super(key: key);

  handleTap(context, int index) {
    Navigator.pushNamed(context, '/transaction',
        arguments: {"data": data[index], "date": date, "total": total});
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      scrollDirection: Axis.vertical,
      itemCount: data.length > 2 ? length : data.length,
      itemBuilder: (BuildContext context, int index) {
        return TransactionTile(
          data: data,
          index: index,
          onTap: () => handleTap(context, index),
        );
      },
    );
  }
}
