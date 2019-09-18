import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth.dart';
import '../providers/cart.dart';
import '../providers/product.dart';
import '../screens/product_detail_screen.dart';

//need to change favorite state here using product
class ProductItem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // if consumer is used then provider should not be used , consumer will accept data as value arguments with ctx and child widget
    //use only single product to change favorite state
    final product = Provider.of<Product>(context, listen: false);
    print('product_item rebuild');

    final cart = Provider.of<Cart>(context, listen: false);

    //to get token in here and listen false means get token one time
    final authData = Provider.of<Auth>(context, listen: false);

    //consumer will update using builder
    // we will consume product provided data
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: GridTile(
        child: GestureDetector(
          onTap: () {
            Navigator.of(context).pushNamed(
              ProductDetailScreen.routeName,
              arguments: product.id,
            );
          },
          child: Image.network(
            product.imageUrl,
            fit: BoxFit.cover,
          ),
        ),
        footer: GridTileBar(
          backgroundColor: Colors.black87,

          // for only listening for favorite to change it state calling toogleFavoriteStatus using consumer provided data
          leading: Consumer<Product>(
            builder: (context, product, _) => IconButton(
              onPressed: () {
                product.toogleFavoriteStatus(authData.token, authData.userId);
                print('Fav rebuilds() here');
              },
              icon: Icon(
                product.isFavorite ? Icons.favorite : Icons.favorite_border,
                color: Theme.of(context).accentColor,
              ),
            ),

            //child: Text('Never Changes'),
          ),
          trailing: IconButton(
            icon: Icon(
              Icons.shopping_cart,
              color: Theme.of(context).accentColor,
            ),
            onPressed: () {
              cart.addItem(product.id, product.price, product.title);
              Scaffold.of(context).hideCurrentSnackBar();
              Scaffold.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Added item to card',
                  ),
                  duration: Duration(seconds: 2),
                  action: SnackBarAction(label: 'UNDO', onPressed: () {
                    cart.removeSingleItem(product.id);
                  }),
                ),
              );
            },
          ),
          title: Text(
            product.title,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
