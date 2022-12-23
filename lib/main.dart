import 'package:flutter/material.dart';
import 'package:flutterapp/screens/transaction.dart';
import 'screens/home.dart';
import 'screens/second_page.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.blue.shade700,
      ),
      home: Scaffold(body: _MainScreenState()),
    );
  }
}

class _MainScreenState extends StatefulWidget {
  @override
  State<_MainScreenState> createState() => _MainScreenStateState();
}

class _MainScreenStateState extends State<_MainScreenState> {
  final _navigatorKey = GlobalKey<NavigatorState>();

  int _index = 0;
  _onTapped(int selectedIndex) {
    switch (selectedIndex) {
      case 0:
        _navigatorKey.currentState?.pushNamed('/');
        break;
      case 1:
        _navigatorKey.currentState?.pushNamed('/second');
        break;
    }

    setState(() {
      _index = selectedIndex;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Navigator(
        key: _navigatorKey,
        initialRoute: '/',
        onGenerateRoute: (RouteSettings settings) {
          WidgetBuilder builder;
          switch (settings.name) {
            case '/':
              builder = (context) => const Home();
              break;
            case '/second':
              builder = (context) => const SecondPage();
              break;
            case '/transaction':
              builder = (context) => Transaction(data: settings.arguments);
              break;
            default:
              builder = (context) => const Home();
          }

          return MaterialPageRoute(builder: builder, settings: settings);
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Theme.of(context).primaryColor,
          unselectedItemColor: Colors.grey[400],
          currentIndex: _index,
          onTap: _onTapped,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.wallet), label: 'Wallet'),
          ]),
    );
  }
}
