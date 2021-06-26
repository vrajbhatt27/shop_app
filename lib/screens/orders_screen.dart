import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/appDrawer.dart';
import '../providers/orders.dart' show Orders;
import '../widgets/order_item.dart';

class OrdersScreen extends StatefulWidget {
  static const routeName = "/orders-screen";

  @override
  _OrdersScreenState createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
	Future _ordersFuture;

	Future _obtainOrdersFuture(){
		return Provider.of<Orders>(context, listen: false).fetchAndSetOrders();
	}

	@override
		void initState() {
			_ordersFuture = _obtainOrdersFuture();
			super.initState();
		}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Your Orders"),
      ),
      drawer: AppDrawer(),
      body: FutureBuilder(
        future: _ordersFuture,
        builder: (ctx, dataSnapShot) {
          if (dataSnapShot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else {
            if (dataSnapShot.error != null) {
              return Center(
                child: Text("An Error Occured!"),
              );
            } else {
              return Consumer<Orders>(
                builder: (ctx, orders, child) => (orders.orders.isEmpty)
                    ? Center(
                        child: Text(
                          "No Orders",
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    : ListView.builder(
                        itemCount: orders.orders.length,
                        itemBuilder: (ctx, i) => OrderItem(orders.orders[i]),
                      ),
              );
            }
          }
        },
      ),
    );
  }
}
