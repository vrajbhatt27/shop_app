import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../providers/cart.dart';
import './cart.dart';

class OrderItem {
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime dateTime;

  OrderItem({
    @required this.id,
    @required this.amount,
    @required this.products,
    @required this.dateTime,
  });
}

class Orders with ChangeNotifier {
  List<OrderItem> _orders = [];
  String _authToken;
  String _userId;

  List<OrderItem> get orders {
    return [..._orders];
  }

  set authToken(String val) {
    _authToken = val;
  }

  set userId(String val) {
    _userId = val;
  }

  Future<void> addOrder(List<CartItem> cartProducts, double amount) async {
    var url = Uri.parse(
        "https://shopapp-b6141-default-rtdb.firebaseio.com/orders/$_userId.json?auth=$_authToken");
    final timeStamp = DateTime.now();

    final response = await http.post(
      url,
      body: json.encode({
        'amount': amount,
        'dateTime': timeStamp.toIso8601String(),
        'products': cartProducts
            .map((cp) => {
                  'id': cp.id,
                  'title': cp.title,
                  'quantity': cp.quantity,
                  'price': cp.price,
                })
            .toList(),
      }),
    );
    _orders.insert(
      0,
      OrderItem(
        id: json.decode(response.body)['name'],
        amount: amount,
        products: cartProducts,
        dateTime: timeStamp,
      ),
    );
    notifyListeners();
  }

  Future<void> fetchAndSetOrders() async {
    var url = Uri.parse(
        "https://shopapp-b6141-default-rtdb.firebaseio.com/orders/$_userId.json?auth=$_authToken");

    final response = await http.get(url);
    // print(json.decode(response.body));
    final List<OrderItem> loadedOrders = [];
    final extractedData = json.decode(response.body) as Map<String, dynamic>;
    if (extractedData == null) {
      return;
    }
    extractedData.forEach((orderId, orderData) {
      loadedOrders.add(
        OrderItem(
          id: orderId,
          amount: orderData["amount"],
          products: (orderData['products'] as List<dynamic>)
              .map(
                (item) => CartItem(
                  id: item["id"],
                  title: item["title"],
                  price: item["price"],
                  quantity: item["quantity"],
                ),
              )
              .toList(),
          dateTime: DateTime.parse(orderData["dateTime"]),
        ),
      );
    });

    _orders = loadedOrders.reversed.toList();
    notifyListeners();
  }
}
