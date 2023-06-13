class Product {
  
  String name;
  String imageUri;
  String price;
  
  Product({required this.name, required this.imageUri, required this.price});
  
  static Product fromMap(Map<String, dynamic> productMap) {
    return Product(name: productMap['product_name'], imageUri: productMap['product_images'], price: productMap['product_discounted_price']);
  }

  toMap() {
    return {
      "id": 885,
      "product_name": "Samsung P7100 Galaxy Tab 10.1v",
      "product_barcode": "1000000000820",
      "product_barcode2": "1000000000820",
      "category_id": 81,
      "product_price": "756.00",
      "product_discounted_price": "756.00",
      "tax_amount": null,
      "product_images": "https://marshaldiag268.blob.core.windows.net/smemedia/placeholder.jpg",
      "tax_name": null,
      "tax_value": null
    };
  }
  
}