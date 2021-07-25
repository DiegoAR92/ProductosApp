import 'package:flutter/material.dart';
import 'package:productos_app/screens/screens.dart';
import 'package:productos_app/services/services.dart';
import 'package:productos_app/widgets/widgets.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final productServices = Provider.of<ProductsService>(context);

    if (productServices.isLoading) {
      return LoadingScreen();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Productos'),
      ),
      body: ListView.builder(
          itemCount: productServices.product.length,
          itemBuilder: (BuildContext context, int index) => GestureDetector(
                child: ProductCard(
                  product: productServices.product[index],
                ),
                onTap: () {
                  productServices.selectedProduct =
                      productServices.product[index].copy();
                  Navigator.pushNamed(context, 'product');
                },
              )),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {},
      ),
    );
  }
}
