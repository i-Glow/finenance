class TransactionModel {
  final int? id;
  final String date;
  final int total;
  final List<ItemList> items;

  TransactionModel(
      {this.id, required this.date, required this.total, required this.items});

  factory TransactionModel.fromMap(json) {
    return TransactionModel(
      id: json['id'],
      date: json['date'],
      total: json['total'],
      items: [ItemList.fromMap(json)],
    );
  }

  Map<dynamic, dynamic> toMap() {
    return {
      "id": id,
      "date": date,
      "total": total,
      "items": [items[0].toMap()]
    };
  }
}

class ItemList {
  final int? dayid;
  final String title;
  final int amount;
  final String description;

  ItemList(
      {this.dayid,
      required this.title,
      required this.amount,
      required this.description});

  factory ItemList.fromMap(json) {
    return ItemList(
        dayid: json['id'],
        title: json['title'],
        amount: json['amount'],
        description: json['description']);
  }

  Map<dynamic, dynamic> toMap() {
    return {
      "dayid": dayid,
      "title": title,
      "amount": amount,
      "description": description
    };
  }
}
