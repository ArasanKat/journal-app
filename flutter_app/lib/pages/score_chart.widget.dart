import 'package:bobby_womack/models/journal_entry.model.dart';
import 'package:bobby_womack/services/authentication_service.dart';
import 'package:bobby_womack/services/journal_service.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';

class ScoreChartWidget extends StatefulWidget {

   final BaseAuthenticationService auth;
  final BaseJournalService journalService;
  final bool animate;

  ScoreChartWidget(this.auth, this.journalService, {this.animate});

  @override
  _ScoreChartState createState() => _ScoreChartState();

}

class _ScoreChartState extends State<ScoreChartWidget> {

  List<JournalEntry> _journalEntries = new List<JournalEntry>();

  @override
  void initState() {
    widget.journalService.getAllJournalEntries().then((journalEntries){
        setState(() {
            _journalEntries = journalEntries;
        });
    }); 
  }

  /// Create one series with sample hard coded data.
  List<charts.Series<JournalEntry, DateTime>> _getScoreChartData(data)  {
 
    return [
      new charts.Series<JournalEntry, DateTime>(
        id: 'Scores',
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (JournalEntry journalEntry, _) => journalEntry.dateCreated,
        measureFn: (JournalEntry journalEntry, _) => widget.journalService.convertScore(journalEntry.score),
        data: data,
      )
    ];  
  } 

  @override
  Widget build(BuildContext context) {

   return new charts.TimeSeriesChart(
      _getScoreChartData(_journalEntries),
      animate: widget.animate,
      // Optionally pass in a [DateTimeFactory] used by the chart. The factory
      // should create the same type of [DateTime] as the data provided. If none
      // specified, the default creates local date time.
      dateTimeFactory: const charts.LocalDateTimeFactory(),
    );
  }
  
}