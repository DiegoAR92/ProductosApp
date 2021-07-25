import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:productos_app/models/models.dart';
import 'package:http/http.dart' as http;

class ProductsService extends ChangeNotifier {
  final String _baseUrl =
      'flutter-varios-292de-default-rtdb.europe-west1.firebasedatabase.app';
  final List<Product> product = [];
  Product selectedProduct;

  bool isLoading = true;
  bool isSaving = false;
  ProductsService() {
    this.loadProducts();
  }

  Future<List<Product>> loadProducts() async {
    this.isLoading = true;
    notifyListeners();
    final url = Uri.https(_baseUrl, 'products.json');
    final resp = await http.get(url);

    final Map<String, dynamic> productsMap = json.decode(resp.body);
    print(productsMap);

    productsMap.forEach((key, value) {
      final tempProduct = Product.fromMap(value);
      tempProduct.id = key;
      this.product.add(tempProduct);
    });
    this.isLoading = false;
    notifyListeners();
    return this.product;
  }

  Future saveOrCreateProduct(Product product) async {
    print(product);
    isSaving = true;
    notifyListeners();
    if (product.id == null) {
    } else {
      updateProduct(product);
    }

    isSaving = false;
    notifyListeners();
  }

  Future<String> updateProduct(Product product) async {
    final url = Uri.https(_baseUrl, 'products/${product.id}.json');
    final resp = await http.put(url, body: product.toJson());
    final decodeData = resp.body.toString();
    print(decodeData);

    final index =
        this.product.indexWhere((element) => element.id == product.id);
    this.product[index] = product;

    return product.id;
  }
}
