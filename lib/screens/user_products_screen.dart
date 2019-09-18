import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/app_drawer.dart';
import '../widgets/user_product_item.dart';
import '../providers/products_provider.dart';
import '../screens/edit_product_screen.dart';

class UserProductsScreen extends StatelessWidget {
  static const String routeName = '/user-product';

  //also load product if this is first visit to this screen
  //named future fuction for refresh
  Future<void> _refreshProducts(BuildContext context) async {
    //here we want filter by user and show user product only, so pass true to fetchAndSetProducts
    await Provider.of<ProductsProvider>(context, listen: false)
        .fetchAndSetProducts(true);
  }

  @override
  Widget build(BuildContext context) {
    print("usr product manage rebuild");
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Products'),
        actions: <Widget>[
          IconButton(
              color: Colors.white,
              icon: Icon(Icons.add),
              onPressed: () {
                Navigator.of(context).pushNamed(EditProductScreen.routeName);
              }),
        ],
      ),
      drawer: AppDrawer(),

      //here _refreshProducts fuction return future, to show data in manage page while going to that screen for first time

      body: FutureBuilder(
        future: _refreshProducts(context),
        builder: (ctx, snapshot) =>
            snapshot.connectionState == ConnectionState.waiting
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : RefreshIndicator(
                    onRefresh: () => _refreshProducts(context),
                    child: Consumer<ProductsProvider>(
                      builder: (ctx, productData,_) => Padding(
                        padding: EdgeInsets.all(8.0),
                        child: ListView.builder(
                          itemCount: productData.items.length,
                          itemBuilder: (ctx, index) => Column(
                            children: <Widget>[
                              UserProductItem(
                                productData.items[index].id,
                                productData.items[index].title,
                                productData.items[index].imageUrl,
                              ),
                              Divider(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
      ),
    );
  }
}
