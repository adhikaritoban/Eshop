import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

//add mixin called ChangeNotifier
class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;

  //be changeable, if change we now notify to all widgets in app that single product is changing state of favorite
  bool isFavorite;

  Product({
    @required this.id,
    @required this.title,
    @required this.description,
    @required this.price,
    @required this.imageUrl,
    this.isFavorite = false,
  });

  //rollback update of favorite
  void _setFavValue(bool newValue) {
    isFavorite = newValue;
    notifyListeners();
  }

  /*for changing the favorite state of the product*/
  Future<void> toogleFavoriteStatus(String token, userId) async {
    final oldStatus = isFavorite;

    //change state of favorite
    isFavorite = !isFavorite;
    //notify all listeners
    notifyListeners();

    try {
      //send patch request
      final url =
          'https://maxshopstate.firebaseio.com/userFavorites/$userId/$id.json?auth=$token';

      //replace favorite status and remove path and map like json
      final response = await http.put(
        url,
        body: json.encode(
          //after switch isFavorite is change to false
          isFavorite,
        ),
      );

      //if error
      if (response.statusCode >= 400) {
        //rollback
        _setFavValue(oldStatus);
      }
    } catch (error) {
      //rollback
      _setFavValue(oldStatus);
    }
  }
}
