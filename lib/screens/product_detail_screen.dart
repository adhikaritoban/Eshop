import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/products_provider.dart';

class ProductDetailScreen extends StatelessWidget {
  static const String routeName = '/product-detail';

  @override
  Widget build(BuildContext context) {
    final productId = ModalRoute.of(context).settings.arguments as String;
    final loadedProductData =
        Provider.of<ProductsProvider>(context, listen: false)
            .findById(productId);

    //for showing app bar with animation
    return Scaffold(
      /* appBar: AppBar(
        title: Text(loadedProductData.title),
      ),*/
      //take control of scroll
      body: CustomScrollView(
        //scrollable area on screen
        slivers: <Widget>[
          //sliver appbar
          SliverAppBar(
            //dynamic change widgets like image
            expandedHeight: 300,
            //appbar will always be visible , and if scrolled do go out of view instead change to appbar and stick at top
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(loadedProductData.title),
              //if expanded show image and app bar
              background: Hero(
                tag: loadedProductData.id,
                child: Image.network(
                  loadedProductData.imageUrl,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          //delegate tell how to render list
          SliverList(
            delegate: SliverChildListDelegate(
              [
                SizedBox(
                  height: 10.0,
                ),
                Text(
                  '\$ ${loadedProductData.price}',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 20,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: 10.0,
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  width: double.infinity,
                  child: Text(
                    loadedProductData.description,
                    textAlign: TextAlign.center,
                    softWrap: true,
                  ),
                ),
                SizedBox(height: 800,),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
