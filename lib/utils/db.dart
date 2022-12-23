import 'dart:io';
import 'package:flutterapp/utils/day.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';
import './day.dart';

class DatabaseHelper {
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;
  Future<Database> get database async => _database ??= await _initDatabase();

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'finenance.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute("PRAGMA foreign_keys = ON");
    await db.execute('''
      CREATE TABLE 'transaction'(
        id INTEGER PRIMARY KEY,
        date TEXT,
        total INTEGER
      )
    ''');
    await db.execute('''
      CREATE TABLE 'items'(
        title TEXT,
        description TEXT,
        amount INTEGER,
        dayid INTEGER,
        FOREIGN KEY(dayid) REFERENCES 'transaction'(id),
        PRIMARY KEY(title, dayid)
      )
    ''');
  }

  void deleteItem(item) async {
    Database db = await instance.database;
    int newTotal = item['total'] - item['data'].amount;

    await db.rawDelete(
        "DELETE FROM 'items' WHERE dayid = ${item['data'].dayid} AND title = '${item['data'].title}'");

    if (newTotal == 0) {
      await db.rawDelete(
          "DELETE FROM 'transaction' WHERE date = '${item['date']}'");
    } else {
      await db.rawUpdate(
          "UPDATE 'transaction' SET total = $newTotal WHERE date = '${item['date']}'");
    }
  }

  Future<int> getWallet() async {
    Database db = await instance.database;
    dynamic rows = await db.rawQuery('''
        SELECT SUM(total) as total
        FROM 'transaction'
    ''');

    return rows[0]['total'];
  }

  Future<int> getThisMonthExpenses(String month) async {
    Database db = await instance.database;
    dynamic rows = await db.rawQuery('''
        SELECT SUM(total) as total
        FROM 'transaction'
        WHERE date LIKE '%$month%'
    ''');

    return rows[0]['total'];
  }

  Future<TransactionModel> getWithDate(String date) async {
    Database db = await instance.database;
    dynamic rows = await db.rawQuery('''
        SELECT * 
        FROM 'transaction'
        JOIN 'items' ON 'transaction'.id = 'items'.dayid  
        WHERE date = '$date'
    ''');

    if (rows.isEmpty) {
      return TransactionModel(date: date, total: 0, items: []);
    }

    TransactionModel res = TransactionModel(
        date: rows[0]['date'], total: rows[0]['total'], items: []);

    rows.forEach((el) {
      res.items.add(ItemList.fromMap(el));
    });

    return res;
  }

  Future<List> getTransactions(String? month) async {
    Database db = await instance.database;
    dynamic res = await db.rawQuery(
        "SELECT * FROM 'transaction' JOIN 'items' ON 'transaction'.id = 'items'.dayid WHERE date LIKE '%$month%'");

    List<TransactionModel> transactionList = [];

    convert(list) {
      list.forEach((transaction) {
        Iterable temp = transactionList
            .where((e) => e.id.toString() == transaction['id'].toString());
        if (temp.isNotEmpty) {
          int idx = transactionList.indexOf(temp.elementAt(0));

          transactionList[idx].items.add(ItemList.fromMap(transaction));
        } else {
          transactionList.add(TransactionModel.fromMap(transaction));
        }
      });
    }

    convert(res);

    transactionList.sort(((a, b) => b.id!.compareTo(a.id!)));

    return transactionList;
  }

  Future addTransaction(TransactionModel transaction) async {
    Database db = await instance.database;
    dynamic temp = transaction.toMap();
    List<Map<dynamic, Object?>> date = await db.rawQuery(
        "SELECT total, id FROM 'transaction' WHERE date = '${temp['date']}'");

    if (date.isNotEmpty) {
      int value = int.parse("${date[0]['total']}");

      await db.insert('items', {...temp['items'][0], 'dayid': date[0]['id']});
      await db.rawUpdate(
          "UPDATE 'transaction' SET total = ($value + ${temp['total']}) WHERE id = ${date[0]['id']} ");
    } else {
      int id = await db.insert(
          'transaction', {'date': temp['date'], 'total': temp['total']});

      await db.insert('items', {...temp['items'][0], 'dayid': id});
    }
  }

  void updateTransaction(TransactionModel data) async {
    Database db = await instance.database;
    dynamic temp = data.toMap();
    var row = await db.rawQuery(
        "SELECT id, total, amount FROM 'transaction' JOIN 'items' WHERE date = '${temp['date']}' AND title = '${temp['items'][0]['title']}' AND dayid = id");

    int total = int.parse("${row[0]['total']}");
    int oldAmount = int.parse("${row[0]['amount']}");
    int newAmount = int.parse("${temp['items'][0]['amount']}");

    int newTotal = total - oldAmount + newAmount;

    await db.rawUpdate(
        "UPDATE 'transaction' SET total = $newTotal WHERE id = ${row[0]['id']}");

    await db.rawUpdate(
        "UPDATE 'items' SET amount = '${temp['items'][0]['amount']}', description = '${temp['items'][0]['description']}' WHERE dayid = ${row[0]['id']} AND title = '${temp['items'][0]['title']}'");
  }
}
