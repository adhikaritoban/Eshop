import 'package:flutter/material.dart';
import '../providers/products_provider.dart';
import '../widgets/product_item.dart';
import 'package:provider/provider.dart';

class ProductGrid extends StatelessWidget {

  /*get _showOnlyFavorites status from product_overview_screen*/
  final bool showFavs;
  ProductGrid(this.showFavs);

  @override
  Widget build(BuildContext context) {
    //give access to product object
    //if state of favorite is change then rebuild this widget
    final productsProviderData = Provider.of<ProductsProvider>(context);

    //if showFavs is true the get list of favoriteProductItems from products provider class else show all items

    final products = showFavs ? productsProviderData.favoriteProductItems :productsProviderData.items;

    return GridView.builder(
      padding: const EdgeInsets.all(10.0),
      itemCount: products.length,
      itemBuilder: (ctx, index) =>
          //provide new listener to show the change of product favorite state using only one product
          //provide single product using builder of ChangeNotifierProvider
          ChangeNotifierProvider.value(
        value: products[index],
        //this will return single item and do for all other
        child: ProductItem(
            /*  products[index].id,
          products[index].title,
          products[index].imageUrl,*/
            ),
      ),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 3 / 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
    );
  }
}
