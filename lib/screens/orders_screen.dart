import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/app_drawer.dart';
import '../providers/orders.dart' show Orders;
import '../widgets/order_item.dart';

class OrdersScreen extends StatelessWidget {
  static const String routeName = '/orders';

  @override
  Widget build(BuildContext context) {

    //if we do this then will go in infinite loop bcoz future will return something in FutureBuilder and this element will get notified data and whole build will run again
    //and again we will return same future again and again
    //final ordersData = Provider.of<Orders>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('You orders'),
      ),
      drawer: AppDrawer(),

      //find if data has been get from server or not,
      body: FutureBuilder(
        //get data from Orders provider future methods and listens for data
          future:
              Provider.of<Orders>(context, listen: false).fetchAndSetOrders(),

          //get state of future and can do multiple things based on future return
          builder: (ctx, snapshot) {

            //using connection we had shown circularprogress so we need not to use stateful widget for progress bar and must use FutureBuilder
            if (snapshot.connectionState == ConnectionState.waiting) {
              //if future has not return something then loading
              return Center(
                child: CircularProgressIndicator(),
              );
            } else {

              //if we have error
              if (snapshot.error != null) {
                //do errorhandle
                return Center(
                  child: Text('An error occured'),
                );
              } else {
                //else we will return ListView and get data using consumer
                //we are interested in here for order data
                return Consumer<Orders>(
                  builder: (ctx, ordersData, child) => ListView.builder(
                    itemBuilder: (ctx, index) =>
                        OrderItem(ordersData.orders[index]),
                    itemCount: ordersData.orders.length,
                  ),
                );
              }
            }
          }),
    );
  }
}
