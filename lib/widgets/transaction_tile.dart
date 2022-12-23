import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterapp/utils/day.dart';

class TransactionTile extends StatelessWidget {
  final List<ItemList> data;
  final int index;
  final Function? onTap;

  const TransactionTile(
      {Key? key, required this.data, required this.index, this.onTap})
      : super(key: key);

  handleOnTap() {
    onTap!();
  }

  Container _chooseIcon([item = 'Food And Drinks']) {
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

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: handleOnTap,
      contentPadding: const EdgeInsets.all(0.0),
      leading: _chooseIcon(data[index].title),
      title: Text(
        data[index].title,
        style: const TextStyle(color: Color(0xff3b4475)),
      ),
      subtitle: Text(
        data[index].description,
        maxLines: 1,
      ),
      trailing: Text("${data[index].amount}"),
    );
  }
}
