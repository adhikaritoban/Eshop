import 'dart:convert';
import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/http_exception.dart';

class Auth with ChangeNotifier {
  String _token;
  DateTime _expiryDate;
  String _userId;

  //timer for logout of authenticate user
  Timer _authTimer;

  //getter for user id
  String get userId {
    return _userId;
  }

  //is user authenticated
  bool get isAuth {
    //if user has token and has not been expire
    //if token is not equal to null then we r authenticated
    return token != null;
  }

  //for return token
  String get token {
    //not null and expiry Date is after current date and time
    if (_expiryDate != null &&
        _expiryDate.isAfter(DateTime.now()) &&
        _token != null) {
      return _token;
    }
    //or token is null
    return null;
  }

  Future<void> _authenticate(
      String email, String password, String urlSegment) async {
    final url =
        'https://www.googleapis.com/identitytoolkit/v3/relyingparty/$urlSegment?key=AIzaSyDSS-gGlb3ekJGcQkbLUUQaY5pDtV77gXA';
    try {
      final response = await http.post(
        url,
        body: json.encode(
          {
            'email': email,
            'password': password,
            'returnSecureToken': true,
          },
        ),
      );
      final responseData = json.decode(response.body);
      //if error exists
      if (responseData['error'] != null) {
        throw HttpException(responseData['error']['message']);
      }
      //if success store token, user id, expires
      _token = responseData['idToken'];
      _userId = responseData['localId'];
      _expiryDate = DateTime.now().add(
        Duration(
          seconds: int.parse(
            responseData['expiresIn'],
          ),
        ),
      );

      //check here if user token has expires or not, if expires auto logout
      _autoLogout();
      notifyListeners();
      /*store token in the memory, getInstance return future which eventually return shared preferences
      * await does not help here to store but will get real access to shared preferences*/
      final prefs = await SharedPreferences.getInstance();
      //here i have user data, add iso8601 to get standard date and time format
      final userData = json.encode(
        {
          'token': _token,
          'userId': _userId,
          'expiryDate': _expiryDate.toIso8601String(),
        },
      );
      //real storage of data
      prefs.setString('userData', userData);
    } catch (error) {
      throw error;
    }
  }

  Future<void> signup(String email, String password) async {
    //wait and return _authenticate future
    return _authenticate(email, password, 'signupNewUser');
  }

  Future<void> login(String email, String password) async {
    return _authenticate(email, password, 'verifyPassword');
  }

  /*to get shared preference user data set while login*/
  //future will return true or false
  Future<bool> tryAutoLogin() async {
    //get access to shared preferences
    final prefs = await SharedPreferences.getInstance();
    //checking if prefs contains a key or not, if not there is not data
    if (!prefs.containsKey('userData')) {
      //we cannot find data
      return false;
    }

    //get data
    //convert string data to map
    final extractedUserData =
        json.decode(prefs.getString('userData')) as Map<String, Object>;
    //get expiry date for valid or invalid token
    final expiryDate = DateTime.parse(extractedUserData['expiryDate']);
    //check
    if (expiryDate.isBefore(DateTime.now())) {
      //token is invalid
      return false;
    }

    //else have valid token
    //here we want to login
    _token = extractedUserData['token'];
    _userId = extractedUserData['userId'];
    //again set expiry date
    _expiryDate = expiryDate;
    notifyListeners();
    //to set timer again
    _autoLogout();
    return true;
  }

  /*for logout and use future for clearing shared prefreferences */
  Future<void> logout() async{
    _token = null;
    _userId = null;
    _expiryDate = null;

    //if user press logout on going timer should be stop
    if (_authTimer != null) {
      //if timer exists cancel that previous timer
      _authTimer.cancel();
      //and set auth timer to null
      _authTimer = null;
    }
    notifyListeners();

    //also clear shared preferences data
    final prefs = await SharedPreferences.getInstance();
    //prefs.remove('userData');
    prefs.clear();
  }

  //for using timer import dart async
  //automatic logout when the token expires
  void _autoLogout() {
    //first check if there exist the previous timer in the app, if present
    if (_authTimer != null) {
      //if timer exists cancel that previous timer
      _authTimer.cancel();
    }
    //here we get expiry date, and get difference of now and expiry date
    final timeToExpiry = _expiryDate.difference(DateTime.now()).inSeconds;
    //set a timer that expires with the token
    //logout should be tirggered if timer expires
    _authTimer = Timer(Duration(seconds: timeToExpiry), logout);
  }
}
