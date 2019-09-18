import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../screens/cart_screen.dart';
import '../widgets/app_drawer.dart';
import '../providers/cart.dart';
import '../widgets/product_grid.dart';
import '../widgets/badge.dart';
import '../providers/products_provider.dart';

// to show value for popupmenuitem value
enum FilterOptions {
  Favorites,
  All,
}

class ProductOverviewScreen extends StatefulWidget {
  @override
  _ProductOverviewScreenState createState() => _ProductOverviewScreenState();
}

class _ProductOverviewScreenState extends State<ProductOverviewScreen> {
  //show filter only in this screen
  var _showOnlyFavorites = false;

  //if you are running first time
  var _isInit = true;

  //check is in progress to get data from server
  var _isLoading = false;

  //to show all current product in the screen
  @override
  initState() {
    //does not work provider here
    //Future.delayed(Duration.zero).then((_){}) // hack wont work
    super.initState();
  }

  @override
  void didChangeDependencies() {
    //if first time this page gets init
    if (_isInit) {
      //check here and for ui update add set state
      setState(() {
        _isLoading = true;
      });

      //fetch data from server with help of ProductsProvider
      Provider.of<ProductsProvider>(context).fetchAndSetProducts().then((_) {
        setState(() {
          _isLoading = false;
        });
      });
    }

    //this ensure that never runs again without change in product item
    _isInit = false;

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    //listen: false means only need access to data not to change state of data in a widget
    //final productContainer = Provider.of<ProductsProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text('check'),
        actions: <Widget>[
          PopupMenuButton(
            onSelected: (FilterOptions selectedValue) {
              print('$selectedValue');

              //provider is not used so called setState with stateful class implementation
              //check if which value is fav or not if fav then
              // this is stateful widget with this class var need to be changed,so the widget rebuild to show fav filter affect
              setState(() {
                if (selectedValue == FilterOptions.Favorites) {
                  _showOnlyFavorites = true;
                  //for application state wise calling method for showing filter actions
                  //call a method from products provider which will get all fav only data
                  //productContainer.showFavoritesOnly();
                } else {
                  _showOnlyFavorites = false;
                  //productContainer.showFavoritesAll();
                }
              });
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                child: Text(
                  'Only Favorites',
                ),
                value: FilterOptions.Favorites,
              ),
              PopupMenuItem(
                child: Text(
                  'Show All',
                ),
                value: FilterOptions.All,
              ),
            ],
            icon: Icon(Icons.more_vert),
          ),
          Consumer<Cart>(
            builder: (_, cart, ch) => Badge(
              child: ch,
              value: cart.itemCount.toString(),
            ),
            child: IconButton(
              icon: Icon(Icons.shopping_cart),
              onPressed: () {
                Navigator.of(context).pushNamed(CartScreen.routeName);
              },
            ),
          ),
        ],
      ),
      drawer: AppDrawer(),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : ProductGrid(_showOnlyFavorites),
    );
  }
}
