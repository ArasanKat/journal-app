import 'package:bobby_womack/models/journal_entry.model.dart';
import 'package:bobby_womack/services/authentication_service.dart';
import 'package:bobby_womack/services/journal_service.dart';
import 'package:flutter/material.dart';

class JournalWidget extends StatefulWidget {

  final BaseAuthenticationService auth;
  final BaseJournalService journalService;

  JournalWidget(this.auth, this.journalService);

  @override
  _JournalState createState() => _JournalState();
  
}

class _JournalState extends State<JournalWidget> {

  final journalEntryController = TextEditingController();

  void _viewSavedJournalEntry(JournalEntry journalEntry) {

    String journalEntryViewData = journalEntry.content + '\n' 
                                  + 'Score: ' + widget.journalService.convertScore(journalEntry.score).toString() + '\n'; 
                                  //+ 'Magnitude: ' +  journalEntry.magnitude.toString() + '\n';
    
                                 
    Navigator.of(context).push(new MaterialPageRoute<void>(builder: (BuildContext context) {
      /* return new Scaffold(
        appBar: new AppBar(
          title: Text(widget.journalService.formatDate(journalEntry.dateCreated)),
        ),
        body: Padding(
              padding: const EdgeInsets.all(25.0),
              child: 
                Text(journalEntryViewData),    
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
                 widget.journalService.convertScore(journalEntry.score).toString() + "%",
                ),
              ]
              ),
        )
      );
    }));
  }

  void _submitJournalEntry() {

    widget.journalService.createJournalEntry(journalEntryController.text).then((journalEntry){
      _viewSavedJournalEntry(journalEntry);
      journalEntryController.text = '';
    });

  } 

  @override
  Widget build(BuildContext context) {

    return Padding(
      padding: const EdgeInsets.all(50.0),
      child: new Column(
      //mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        new Expanded(
          child: TextField(
            controller: journalEntryController,
            keyboardType: TextInputType.multiline,
            maxLines: 12,
            decoration: InputDecoration(
                border: null, hintText: 'Dear Journal'),
          ),
        ),
        new Expanded(
          //child: 
          //mainAxisAlignment: MainAxisAlignment.end,
          child: Align(
            alignment: Alignment.bottomRight,
            child:new FloatingActionButton(
              onPressed: _submitJournalEntry,
              tooltip: 'Submit',
              child: Icon(Icons.add),
            ))
          ),
          
      ])
    );
  }

}
