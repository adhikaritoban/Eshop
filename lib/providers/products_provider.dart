import 'package:flutter/material.dart';

import 'dart:convert';
import './product.dart';
import 'package:http/http.dart' as http;
import '../models/http_exception.dart';

//mixin can be use by with keyword and it is like extending class and merge some property of ChangeNotifier in this class
//ChangeNotifier is like inheritance widget, allow to communicate and pass data using context
class ProductsProvider with ChangeNotifier {
  // _ defines private so make getter to get list and cannot be access by other class
  List<Product> _items = [
  ];

  /*for application wise purpose this filter is correct but for local filter use method of filter logic in that same class or screen */
  /* //to show favorites only
  var _showFavoritesOnly = false;*/

  /*get token here*/
  //we must initalize inorder to get previous products
  final String authToken;
  final String userId;
  ProductsProvider(this.authToken, this.userId, this._items);

  //return list of products from Product class, to let other widgets to get all products that need to change
  List<Product> get items {
    /*  //if favorite only selected
    if (_showFavoritesOnly) {
      return _items.where((productItem) => productItem.isFavorite).toList();
    }*/

    //use only this items or products
    return [..._items];
  }

/*
  */ /*for showing favorites only*/ /*
  void showFavoritesOnly() {
    _showFavoritesOnly = true;
    //notify is not done show call
    notifyListeners();
  }

  */ /*for showing all favorites*
   */ /*
  void showFavoritesAll() {
    _showFavoritesOnly = false;
    notifyListeners();
  }*/

  /*return list of favorite products using getter method that return favorite list */
  List<Product> get favoriteProductItems {
    return _items.where((productItem) => productItem.isFavorite).toList();
  }

  /*for showing product details*/
  Product findById(String productId) {
    return _items.firstWhere((product) => product.id == productId);
  }

  /*for adding and manage user own product*/
  /*if future is pass it will return something*/
  //using async will always return future
  Future<void> addProduct(Product product) async {
    /*send http request*/
    final url = 'https://maxshopstate.firebaseio.com/products.json?auth=$authToken';

    try {
      //wait for this to finish and go to other line
      final response = await http.post(
        url,
        body: json.encode(
          {
            'title': product.title,
            'description': product.description,
            'imageUrl': product.imageUrl,
            'price': product.price,
            //to remove isFvorite status from product to userFavorite table in backend
            //'isFavorite': product.isFavorite,

            //here now add user id
            'creatorId': userId,
          },
        ),
      );

      final newProduct = Product(
        title: product.title,
        description: product.description,
        price: product.price,
        imageUrl: product.imageUrl,
        id: json.decode(response.body)['name'],
      );

      _items.add(newProduct);
      //_items.insert(0,items); //at the start of the list
      notifyListeners(); //using this other widgets can rebuild and change ui

    } catch (error) {
      print(error);
      throw error;
    }
  }

  /*for getting all, current productitem */
  //filter data and all data can be 2 different api in server in real life
  //get both types of data filter, to only manage user product and to show all products to all user in home page
  //bool filterByUser = false is in square braces in order to indicate as optional parameter
  Future<void> fetchAndSetProducts([bool filterByUser = false]) async {
    /*send http request*/

    //check if  filter data is of user or not, if and only if this method gets filterByUser is true then only filter products ans display in user product screen
    final filterString = filterByUser ? 'orderBy="creatorId"&equalTo="$userId' : '';

    //get only user id data or products filter out using products.json?auth=$authToken&orderBy="creatorId"&equalTo="$userId"
    var url = 'https://maxshopstate.firebaseio.com/products.json?auth=$authToken&$filterString"';

    try {
      final response = await http.get(url);

      final extractedData = json.decode(response.body) as Map<String, dynamic>;

      if(extractedData == null) {
        return;
      }

      //request for another url for favorite status
      //get all favorite status of loggedin user
       url = 'https://maxshopstate.firebaseio.com/userFavorites/$userId.json?auth=$authToken';

      final favoriteResponse = await http.get(url);

      //get map of data of favorite with
      final favoriteData = json.decode(favoriteResponse.body);
      //for storing favorite status
      //temporary list
      final List<Product> loadedProducts = [];
      //get each item from map,
      extractedData.forEach((prodId, prodData) {
        //build each product here
        //create brand new product
        loadedProducts.add(
          Product(
            id: prodId,
            title: prodData['title'],
            description: prodData['description'],
            price: prodData['price'],

            //we have change prodData['isFavorite'] to favoriteData[prodId] then isFavorite will get productId key value from firebase userfavorites table
            //which will give either true or false as before done by prodData['isFavorite']
            //check if favorite is null or not, if null then he has never favorite anny product, if prodId is null the  ?? check for null if null then isFavorite is set to false
            isFavorite: favoriteData == null ? false : favoriteData[prodId] ?? false,
            imageUrl: prodData['imageUrl'],
          ),
        );
      });

      //now set _items with loadedProducts
      _items = loadedProducts;
      notifyListeners();
    } catch (error) {
      throw (error);
    }
  }

  /*for updating the product*/
  //changing to future and add async to update data in server
  Future<void> updateProduct(String id, Product newProduct) async {
    //check if existing product id is equal to newProduct id
    final prodIndex = _items.indexWhere((prod) => prod.id == id);

    if (prodIndex >= 0) {
      //send patch request
      final url = 'https://maxshopstate.firebaseio.com/products/$id.json?auth=$authToken';

      //for upadte to server
      await http.patch(
        url,
        body: json.encode(
          {
            'title': newProduct.title,
            'description': newProduct.description,
            'price': newProduct.price,
            'imageUrl': newProduct.imageUrl,
            // here favorite is not updated if update then every time we update product we update favorite state
          },
        ),
      );

      //_items place where prodIndex founds then update that productIndex with new product
      _items[prodIndex] = newProduct;
      notifyListeners();
    } else {
      print('...');
    }
  }

  /*for deleting the product*/
  Future<void> deleteProduct(String id) async {
    //send path request
    final url = 'https://maxshopstate.firebaseio.com/products/$id.json?auth=$authToken';

    final existingProductIndex = _items.indexWhere((prod) => prod.id == id);

    //set pointer to that product that need to be deleted
    //reference to the old product
    var existingProduct = _items[existingProductIndex];

    //it removes from the list but not from memory
    _items.removeAt(existingProductIndex);
    notifyListeners();

    //optimistic update this ensure that if failed to delete insert same old item in that index
    final response = await http.delete(url);

    if (response.statusCode >= 400) {
      //rollback to removal
      _items.insert(existingProductIndex, existingProduct);
      notifyListeners();

      throw HttpException('Could not delete product');
    }
    //if success to delete in memory
    existingProduct = null;
    // _items.removeWhere((prod) => prod.id == id);
  }
}
