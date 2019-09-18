import 'package:flutter/foundation.dart';

/*i want to have cart item*/
class CartItem {
  final String id;
  final String title;
  final int quantity;
  final double price;

  CartItem(
      {@required this.id,
      @required this.title,
      @required this.quantity,
      @required this.price});
}

class Cart with ChangeNotifier {
  //manage cart item
  Map<String, CartItem> _items = {};

  Map<String, CartItem> get items {
    return {..._items};
  }

  /*grt item count
  * */
  int get itemCount {
    return _items.length;
  }

  /*for adding cart*/
  void addItem(String productId, double price, String title) {
    //check if that product item is in cart or not
    if (_items.containsKey(productId)) {
      //change quantity, update will itself take existing cart item as parameter, in quantity existing cart item quantity is add with 1 to increase cart item quantity
      _items.update(
        productId,
        (existingCartItem) => CartItem(
          id: existingCartItem.id,
          title: existingCartItem.title,
          price: existingCartItem.price,
          quantity: existingCartItem.quantity + 1,
        ),
      );
    } else {
      //add new entry in that Map , putIfAbsent will require function as a value
      _items.putIfAbsent(
        productId,
        () => CartItem(
          id: DateTime.now().toString(),
          title: title,
          price: price,
          quantity: 1,
        ),
      );
    }
    notifyListeners();
  }

  /*for getting total amount*/
  double get getTotalAmount {
    double total = 0.0;
    //for every item in a map with key and value for entry
    _items.forEach((key, cartItem) {
      total += cartItem.price * cartItem.quantity; //
    });
    return total;
  }

  /*for removing the item */
  void removeItem(String productId) {
    _items.remove(productId);
    notifyListeners();
  }

  /*remove single item*/
  void removeSingleItem(String productId) {
    //current product
    if (!_items.containsKey(productId)) {
      return;
    }

    //check if product quantity is more than one then reduce the quantity
    if (_items[productId].quantity > 1) {
      _items.update(
        productId,
        (existingCartItem) => CartItem(
            id: existingCartItem.id,
            title: existingCartItem.title,
            price: existingCartItem.price,
            quantity: existingCartItem.quantity - 1),
      );
    }else {
      _items.remove(productId);
    }
    notifyListeners();
  }

  /*for clearing the cart item*/
  void clearCart() {
    _items = {};
    notifyListeners();
  }
}
