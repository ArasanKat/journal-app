import 'package:bobby_womack/services/authentication_service.dart';
import 'package:bobby_womack/services/journal_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart' show CalendarCarousel;
import 'package:flutter_calendar_carousel/classes/event.dart';
import 'package:bobby_womack/pages/journal_entries.widget.dart';

class JournalCalenderWidget extends StatefulWidget {

  final BaseAuthenticationService auth;
  final BaseJournalService journalService;

  JournalCalenderWidget(this.auth, this.journalService);

  @override
  _JournalCalenderState createState() => _JournalCalenderState();
}

class _JournalCalenderState extends State<JournalCalenderWidget> {

  void _seeJournalEntriesFromDate(String date)  {

    widget.journalService.getJournalEntriesByDate(date).then((journalEntries){
      if(journalEntries.length == 0){
        final snackBar = SnackBar(
          content: new Text('You Have No Journal Entries On This Date', textAlign: TextAlign.center),
          duration: Duration(seconds: 1),
        );
        // Find the Scaffold in the Widget tree and use it to show a SnackBar
        Scaffold.of(context).showSnackBar(snackBar);
      }
      else{
        Navigator.of(context).push(new MaterialPageRoute<void>(builder: (BuildContext context) {
        return new Scaffold(
          appBar: new AppBar(
            title: Text(date),
          ),
            body: Container(
              //padding: const EdgeInsets.all(25.0),
              child: JournalEntriesWidget(journalEntries, widget.journalService),
            )
          );
        })
        );
      }   
    });
  } 


  @override
  Widget build(BuildContext context) {

    DateTime _currentDate;

    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(
            child: CalendarCarousel<Event>(
              maxSelectedDate: DateTime.now(),
              onDayPressed: (DateTime date, List<Event> eventList) {
                this.setState(() => _currentDate = date);
                 _seeJournalEntriesFromDate(date.toString().substring(0,10));  
              },
              inactiveWeekendTextStyle: TextStyle(color:Colors.grey),
              thisMonthDayBorderColor: Colors.grey,
              height: 420.0,
              selectedDateTime: _currentDate,
              daysHaveCircularBorder: true, /// null for not rendering any border, true for circular border, false for rectangular border
              dayButtonColor: Colors.white,
              selectedDayButtonColor: Colors.blue,
              todayButtonColor: Colors.blue,
              todayBorderColor: Colors.blue,
              weekendTextStyle: TextStyle(
                color: Colors.black,
              ),
              weekdayTextStyle: TextStyle(
                color: Colors.blue
              ),              
            )
          ),
      
        ],
      ),
    );  
  }

}
