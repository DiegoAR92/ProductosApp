import 'dart:convert';
import 'dart:io';

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
  File newPicture;

  ProductsService() {
    this.loadProducts();
  }

  Future<List<Product>> loadProducts() async {
    this.isLoading = true;
    notifyListeners();
    final url = Uri.https(_baseUrl, 'products.json');
    final resp = await http.get(url);
    final Map<String, dynamic> productsMap = json.decode(resp.body);
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
    isSaving = true;
    notifyListeners();
    if (product.id == null) {
      await createProduct(product);
    } else {
      await updateProduct(product);
    }
    isSaving = false;
    notifyListeners();
  }

  Future<String> updateProduct(Product product) async {
    final url = Uri.https(_baseUrl, 'products/${product.id}.json');
    await http.put(url, body: product.toJson());
    final index =
        this.product.indexWhere((element) => element.id == product.id);
    this.product[index] = product;
    return product.id;
  }

  Future<String> createProduct(Product product) async {
    final url = Uri.https(_baseUrl, 'products.json');
    final resp = await http.post(url, body: product.toJson());
    final decodeData = json.decode(resp.body);
    product.id = decodeData['name'];
    this.product.add(product);
    return product.id;
  }

  void updateSelectedProductImage(String path) {
    this.selectedProduct.picture = path;
    this.newPicture = File.fromUri(Uri(path: path));
    notifyListeners();
  }

  Future<String> uploadImage() async {
    if (this.newPicture == null) return null;
    this.isSaving = true;
    notifyListeners();
    final url = Uri.parse(
        'https://api.cloudinary.com/v1_1/diegoar92/image/upload?upload_preset=vkvfzqly');
    final imageUploadRequest = http.MultipartRequest('POST', url);
    final file =
        await http.MultipartFile.fromPath('file', this.newPicture.path);
    imageUploadRequest.files.add(file);
    final streamResponse = await imageUploadRequest.send();
    final resp = await http.Response.fromStream(streamResponse);
    if (resp.statusCode != 200 && resp.statusCode != 201) return null;
    final decodeData = json.decode(resp.body);
    this.newPicture = null;
    return decodeData['secure_url'];
  }
}
