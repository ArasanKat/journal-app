import 'package:bobby_womack/pages/journal.widget.dart';
import 'package:bobby_womack/pages/journal_calender.widget.dart';
import 'package:bobby_womack/pages/score_chart.widget.dart';
import 'package:bobby_womack/services/authentication_service.dart';
import 'package:bobby_womack/services/journal_service.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {

  HomePage({Key key, this.auth, this.userId, this.onSignedOut}) : super(key: key);

  final BaseAuthenticationService auth;
  final VoidCallback onSignedOut;
  final String userId;

  @override
  _HomePageState createState() => _HomePageState();

}

 enum FormMode { LOGIN, SIGNUP }

class _HomePageState extends State<HomePage> {

  int _selectedIndex = 0;
  final journalEntryController = TextEditingController();
  final List<Widget> _widgetTabs = [
    JournalWidget(AuthenticationService(), JournalService()),
    JournalCalenderWidget(AuthenticationService(), JournalService()),
    ScoreChartWidget(AuthenticationService(), JournalService())
  ];

  void _onItemTapped(int index) {

    setState(() {
      _selectedIndex = index;
    });

  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text("Journal App"),
        actions: <Widget>[
            // action button
            IconButton(
              icon: Icon(Icons.exit_to_app),
              onPressed: () {
                widget.auth.signOut();
                Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
              },
            ),
        ]
      ),
      body: _widgetTabs.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        fixedColor: Colors.indigo,
        onTap: _onItemTapped,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
              icon: Icon(Icons.book), title: Text('Journal')),
          BottomNavigationBarItem(
              icon: Icon(Icons.format_list_bulleted), title: Text('Entries')),
          BottomNavigationBarItem(
              icon: Icon(Icons.assessment), title: Text('VADER')),
        ],
      ),
    );
  }  
}
