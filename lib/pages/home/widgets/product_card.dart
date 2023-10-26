import 'package:eeasy_rfid/api_collection/eeasy_rfid_api.dart';
import 'package:eeasy_rfid/models/product.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shimmer/shimmer.dart';

import '../../../util/data.dart';

class ProductCard extends StatefulWidget {

  final String epc;

  const ProductCard({Key? key, required this.epc}) : super(key: key);

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {

  Product? product;

  /// TODO: Revert code after testing

  @override
  void initState() {
    if(AppData.epcProductMap.containsKey(widget.epc)) {
      product = AppData.epcProductMap[widget.epc]!;
    }
    else{
      RfidAPICollection.getProductFromEPC(widget.epc).then((value) {
        if(value.data != null) {
          AppData.epcProductMap.addAll({widget.epc : value.data!});
          if(mounted) {
            setState(() { product = value.data; });
          }
        }
        else {
          ///Fluttertoast.showToast(msg: '${widget.epc} : ${value.statusCode} : ${value.reasonPhrase}');
        }
      });
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return product != null ? LoadedProductCard(product: product!, key: ValueKey(widget.epc)) : const ShimmerProductCard();
  }
}



class LoadedProductCard extends StatelessWidget {

  final Product product;

  const LoadedProductCard({Key? key, required this.product}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xffD9D9D9), width: 1))),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(40),
            child: Image.network(product.imageUri, width: 40, height: 40, fit: BoxFit.cover),
          ),
          const SizedBox(width: 10),
          Text(product.name, style: const TextStyle(color: Color(0xff344054))),
          const Expanded(child: SizedBox()),
          Text('AED ${double.parse(product.discountedPrice).toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w600))
        ],
      ),
    );
  }
}




class ShimmerProductCard extends StatelessWidget {
  const ShimmerProductCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xffD9D9D9), width: 1))),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(40),
            child: Shimmer.fromColors(baseColor: Colors.grey.shade400, highlightColor: Colors.white, child: Image.asset('assets/avatar.png', width: 40, height: 40)),
          ),
          const SizedBox(width: 10),
          Shimmer.fromColors(baseColor: Colors.grey.shade400, highlightColor: Colors.white, child: Container(width: 80, height: 10, color: Colors.white)),
          const Expanded(child: SizedBox()),
          Shimmer.fromColors(baseColor: Colors.grey.shade400, highlightColor: Colors.white, child: Container(width: 30, height: 10, color: Colors.white))
        ],
      ),
    );
  }
}



class DemoProductCard extends StatelessWidget {

  final String epc;

  const DemoProductCard({Key? key, required this.epc}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xffD9D9D9), width: 1))),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(40),
            child: Image.asset('assets/avatar.png', width: 40, height: 40, fit: BoxFit.cover),
          ),
          const SizedBox(width: 10),
          Text(epc, style: const TextStyle(color: Color(0xff344054))),
          const Expanded(child: SizedBox()),
          const Text('AED 111.11', style: TextStyle(fontWeight: FontWeight.w600))
        ],
      ),
    );
  }
}

