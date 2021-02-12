import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class BaseAuthenticationService {
  Future<String> signIn(String email, String password);

  Future<String> signUp(String email, String password);

  Future<FirebaseUser> getCurrentUser();

  Future<void> sendEmailVerification();

  Future<void> signOut();

  Future<bool> isEmailVerified();
  
  void addTokenToSharedPrefs();

  void checkTokenAndRefresh(Future<Null> httpRequest);

}

class AuthenticationService implements BaseAuthenticationService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<String> signIn(String email, String password) async {
    FirebaseUser user = await _firebaseAuth.signInWithEmailAndPassword(
        email: email, password: password);
    addTokenToSharedPrefs();
    return user.uid;
  }

  Future<String> signUp(String email, String password) async {
    FirebaseUser user = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email, password: password);
    return user.uid;
  }

  Future<FirebaseUser> getCurrentUser() async {
    FirebaseUser user = await _firebaseAuth.currentUser();
    return user;
  }

  Future<void> signOut() async {
    return _firebaseAuth.signOut();
  }

  Future<void> sendEmailVerification() async {
    FirebaseUser user = await _firebaseAuth.currentUser();
    user.sendEmailVerification();
  }

  Future<bool> isEmailVerified() async {
    FirebaseUser user = await _firebaseAuth.currentUser();
    return user.isEmailVerified;
  }

  //Add this method at the beggining of every request method in each service
  //Dart does not natively support interceptor to attach firebase token to each request
  //TODO: look into a 3rd party library that can accomplish this
  void addTokenToSharedPrefs() async{

    final SharedPreferences prefs = await SharedPreferences.getInstance();

    getCurrentUser().then((user){
      //remove refresh:true after figuring out how to only refresh when token expires
      user.getIdToken(refresh: true).then((token){
        prefs.setString("firebase_token", token);
      });

    });

  }

  void checkTokenAndRefresh(Future<Null> httpRequest) async{

    final SharedPreferences prefs = await SharedPreferences.getInstance();

    DateTime currentTimeStamp = DateTime.now();
    DateTime currentTokenTimeStamp = DateTime.parse(prefs.getString("firebase_token_timestamp"));

    getCurrentUser().then((user){

      var timeDiff = currentTimeStamp.difference(currentTokenTimeStamp);

      if(timeDiff.inMinutes > 59)
        user.getIdToken(refresh:true).then((token){
        prefs.setString("firebase_token", token);
        prefs.setString("firebase_token_timestamp", DateTime.now().toString());
      });

      httpRequest.then((onValue){
        print(onValue);
      });
    });
  }
}
