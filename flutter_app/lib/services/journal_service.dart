import 'dart:async';
import 'dart:convert';
import 'package:bobby_womack/models/journal_entry.model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:bobby_womack/services/authentication_service.dart';


abstract class BaseJournalService {

  Future<JournalEntry> createJournalEntry(String journalEntryContent);
  Future<List<JournalEntry>> getJournalEntriesByDate(String date);
  Future<List<JournalEntry>> getAllJournalEntries();
  String formatDate(DateTime date); 
  double convertScore(double oldRangeScore);

}

class JournalService implements BaseJournalService {

  final AuthenticationService _auth = new AuthenticationService();
  //Url for testing on IOS
  final String baseUrl = "localhost:4000";
  //Url for testing on Android
  //final String baseUrl = "10.0.2.2:4000";
  List<JournalEntry> journalEntriesList = new List<JournalEntry>();

  Future<JournalEntry> createJournalEntry(String journalEntryContent) async {

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String firebaseToken = prefs.get("firebase_token");
    var url = new Uri.http(baseUrl, "/newJournalEntry");
    Map journalEntryData = { 'content': journalEntryContent, 'date_created': DateTime.now().toString()};
    var body = jsonEncode(journalEntryData);
    var response = await http.post(url, headers:{"content-type" : "application/json", "ApiToken" : firebaseToken }, body: body);
    if(response.statusCode == 401){
      await _auth.getCurrentUser().then((user) async{
        await user.getIdToken(refresh: true).then((token) async{
          prefs.setString("firebase_token", token);
          firebaseToken = prefs.get("firebase_token");
          response = await http.post(url, headers:{"content-type" : "application/json", "ApiToken" : firebaseToken }, body: body);
        });
      }); 
    }
    var data = json.decode(utf8.decode(response.bodyBytes));
    JournalEntry journalEntry = new JournalEntry(
      data['content'], 
      DateTime.parse(data['date_created']), 
      data['score'].toDouble(), 
      data['magnitude'].toDouble(),
    );

    return journalEntry;
  } 

  Future<List<JournalEntry>> getJournalEntriesByDate(String date) async {

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String formattedDate = date;
    Map<String, String> dateData = { 'date': formattedDate };
    String firebaseToken = prefs.get("firebase_token");
    var url = new Uri.http(baseUrl, "/journalEntriesByDate", dateData);
    var response = await http.get(url, headers:{"content-type" : "application/json", "ApiToken" : firebaseToken });
    if(response.statusCode == 401){
      await _auth.getCurrentUser().then((user) async{
        await user.getIdToken(refresh: true).then((token) async{
          prefs.setString("firebase_token", token);
          firebaseToken = prefs.get("firebase_token");
          response = await http.get(url, headers:{"content-type" : "application/json", "ApiToken" : firebaseToken });
        });
      }); 
    }
    var data = json.decode(utf8.decode(response.bodyBytes)) as List;
    List<JournalEntry> journalEntries = new List<JournalEntry>();

    if(data == null){
      return journalEntries;
    }
    else{
       for(int i =0; i<data.length; i++){
        JournalEntry journalEntry = new JournalEntry(
          data[i]['content'], 
          DateTime.parse(data[i]['date_created']), 
          data[i]['score'].toDouble(), 
          data[i]['magnitude'].toDouble(),
        ); 
        journalEntries.insert(i,journalEntry);
      }
    }
    return journalEntries;
  } 

  Future<List<JournalEntry>> getAllJournalEntries() async {

    SharedPreferences prefs = await SharedPreferences.getInstance();    
    String firebaseToken = prefs.get("firebase_token");
    var url = new Uri.http(baseUrl, "/journalEntries");
    var response = await http.get(url, headers:{"content-type" : "application/json", "ApiToken" : firebaseToken });
    if(response.statusCode == 401){
      await _auth.getCurrentUser().then((user) async{
        await user.getIdToken(refresh: true).then((token) async{
          prefs.setString("firebase_token", token);
          firebaseToken = prefs.get("firebase_token");
          response = await http.get(url, headers:{"content-type" : "application/json", "ApiToken" : firebaseToken });
        });
      }); 
    }
    var data = json.decode(utf8.decode(response.bodyBytes)) as List;
    List<JournalEntry> journalEntries = new List<JournalEntry>();

    for(int i =0; i<data.length; i++){
      JournalEntry scoreChart = new JournalEntry( 
        data[i]['content'], 
        DateTime.parse(data[i]['date_created']), 
        data[i]['score'].toDouble(), 
        data[i]['magnitude'].toDouble(),
      ); 
      journalEntries.insert(i,scoreChart);
    }

    return journalEntries;
    
  }

  String formatDate(DateTime date){

    DateTime localDateTime = date.toLocal();
    int twentyFourHour = localDateTime.hour;
    String minutes = localDateTime.minute.toString();
    String seconds = localDateTime.second.toString();

    String hour;
    String meridiem;

    if(twentyFourHour > 12){

      hour = (twentyFourHour-12).toString();
      meridiem = "pm";

    }
    else{
      meridiem = "am";
      hour = twentyFourHour.toString();
    }

    var formattedDate =  hour + ":" + minutes + ":" + seconds + " " + meridiem; 

    return formattedDate;
  }

  //convert scores range from -1 to 1 into 0 to 1
  double convertScore(double oldRangeScore){
    double newRangeScore = ((oldRangeScore*0.5)+0.5)*100;
    return newRangeScore;
  }
}



