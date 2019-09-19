import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './helpers/custom_route.dart';
import './screens/cart_screen.dart';
import './screens/edit_product_screen.dart';
import './screens/orders_screen.dart';
import './screens/product_detail_screen.dart';
import './screens/user_products_screen.dart';
import './screens/splash_screen.dart';
import './screens/product_overview_screen.dart';
import './providers/products_provider.dart';
import './providers/cart.dart';
import './providers/orders.dart';
import './providers/auth.dart';
import './screens/auth_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(
          value:
              Auth(), // will provide instance of product provider class to all childs
        ),

        //to fetch product attach token
        //use builder to forces you to create new provider based on previous change notifier provider Auth() - above provider
        //if Auth change this will rerun this provider
        //list of pre product list and must check if previous product is null or not

        ChangeNotifierProxyProvider<Auth, ProductsProvider>(
          builder: (ctx, auth, previousProducts) => ProductsProvider(
            auth.token,
            auth.userId,
            previousProducts == null ? [] : previousProducts.items,
          ),
        ),

        ChangeNotifierProvider.value(
          value: Cart(),
        ),

        ChangeNotifierProxyProvider<Auth, Orders>(
          builder: (ctx, auth, previousOrders) =>
              //if previousOrder is not null get previous order else pass null
              Orders(auth.token, auth.userId,
                  previousOrders == null ? [] : previousOrders.orders),
        ),
      ],
      //consumer of auth runs when change done while login sign up
      child: Consumer<Auth>(
        builder: (ctx, auth, _) => MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'MyShop',
          theme: ThemeData(
            primarySwatch: Colors.purple,
            accentColor: Colors.deepOrange,
            fontFamily: 'Lato',

              //if want material page route effect
              pageTransitionsTheme: PageTransitionsTheme(builders: {
                //define what should it look like
                //use CustomPageTransitionBuilder
                TargetPlatform.android: CustomPageTransitionBuilder(),
                TargetPlatform.iOS: CustomPageTransitionBuilder(),
              }),
          ),
          //if user is authenticate has token then go to ProductOverviewScreen else try to auto login to ProductOverviewScreen
          home: auth.isAuth
              ? ProductOverviewScreen()
              : FutureBuilder(
                  //if user has already login and resume app try login
                  future: auth.tryAutoLogin(),
                  //now we can check
                  builder: (ctx, authResultSnapshot) =>
                      authResultSnapshot.connectionState ==
                              ConnectionState.waiting
                          ? SplashScreen()
                          : AuthScreen(),
                ),
          routes: {
            ProductDetailScreen.routeName: (ctx) => ProductDetailScreen(),
            CartScreen.routeName: (ctx) => CartScreen(),
            OrdersScreen.routeName: (ctx) => OrdersScreen(),
            UserProductsScreen.routeName: (ctx) => UserProductsScreen(),
            EditProductScreen.routeName: (ctx) => EditProductScreen(),
          },
        ),
      ),
    );
  }
}
