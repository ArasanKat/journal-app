import 'package:bobby_womack/models/journal_entry.model.dart';
import 'package:bobby_womack/services/journal_service.dart';
import 'package:flutter/material.dart';

class JournalEntriesWidget extends StatefulWidget {

  final List<JournalEntry> savedJournalEntries;
  final BaseJournalService journalService;
  JournalEntriesWidget(this.savedJournalEntries, this.journalService);
 

  @override
  _JournalEntriesState createState() => _JournalEntriesState();

}

class _JournalEntriesState extends State<JournalEntriesWidget> {

  void _viewSavedJournalEntry(JournalEntry journalEntry) {

    String journalEntryViewData = journalEntry.content + '\n' + 'Score: ' + widget.journalService.convertScore(journalEntry.score).toString() + '\n'; 
                                  
    Navigator.of(context).push(new MaterialPageRoute<void>(builder: (BuildContext context) {
      /* return new Scaffold(
        appBar: new AppBar(
          title: Text(widget.journalService.formatDate(journalEntry.dateCreated)),
        ),
        body: Padding(
              padding: const EdgeInsets.all(25.0),
              child: Text(journalEntryViewData),
        )
      ); */
      return new Scaffold(
        appBar: new AppBar(
          title: Text(widget.journalService.formatDate(journalEntry.dateCreated)),
        ),
        body: Center(
              child: new Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              //crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                new Text(
                  journalEntry.content,
                ),
                new Text(
                 widget.journalService.convertScore(journalEntry.score).toString(),
                ),
              ]
              ),
        )
      );
    }));

  }

  @override
  Widget build(BuildContext context) {
    
    final Iterable<ListTile> tiles = widget.savedJournalEntries.map(
      (JournalEntry journalEntry) {
        return new ListTile(
          title: new Center(child: new Text(
            widget.journalService.formatDate(journalEntry.dateCreated),
          )),
          onTap: () {
            _viewSavedJournalEntry(journalEntry);
          });
      },
    );

    final List<Widget> divided = ListTile.divideTiles(
      context: context,
      tiles: tiles,
    ).toList();

    return ListView(children: divided);
  }
}
