import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:frankmichaelflutterproject/service/database.dart';
import 'package:frankmichaelflutterproject/service/shared_pref.dart';
import 'package:frankmichaelflutterproject/widget/widget_support.dart';
import 'package:frankmichaelflutterproject/pages/order.dart' as myorder;

class Details extends StatefulWidget {
  final Map<String, dynamic> foodItem;

  const Details({super.key, required this.foodItem});

  @override
  State<Details> createState() => _DetailsState();
}

class _DetailsState extends State<Details> {
  int quantity = 1;
  String? userId;

  @override
  void initState() {
    super.initState();
    getUserId();
  }

  Future<void> getUserId() async {
    userId = await SharedPreferenceHelper().getUserId();
    setState(() {});
  }

  Future<void> addToCartAndNavigate() async {
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("⚠️ User ID not found. Please log in.")),
      );
      return;
    }

    int total = int.parse(widget.foodItem['price']) * quantity;

    Map<String, dynamic> cartItem = {
      "Name": widget.foodItem['name'],
      "Image": widget.foodItem['image'],
      "Price": widget.foodItem['price'],
      "Quantity": quantity.toString(),
      "Total": total.toString(),
      "Timestamp": FieldValue.serverTimestamp(),
    };

    try {
      await DatabaseMethods().addFoodToCart(cartItem, userId!);

      // ✅ Show notification
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("✅ Added to cart successfully"),
          backgroundColor: Colors.green.shade700,
        ),
      );

      // ✅ Navigate to Order screen
      Future.delayed(const Duration(milliseconds: 500), () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const myorder.Order()),
        );
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ Failed to add to cart")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final food = widget.foodItem;

    return Scaffold(
      body: Container(
        margin: const EdgeInsets.only(top: 50.0, left: 20.0, right: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: const Icon(Icons.arrow_back_ios_new_outlined),
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                food['image'],
                width: double.infinity,
                height: MediaQuery.of(context).size.height / 2.5,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 15.0),
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(food['name'], style: AppWidget.semiBoldTextFeildStyle()),
                    Text(food['category'], style: AppWidget.LightTextFeildStyle()),
                  ],
                ),
                const Spacer(),
                buildQuantityButton(Icons.remove, () {
                  if (quantity > 1) {
                    setState(() => quantity--);
                  }
                }),
                const SizedBox(width: 20),
                Text(quantity.toString(), style: AppWidget.semiBoldTextFeildStyle()),
                const SizedBox(width: 20),
                buildQuantityButton(Icons.add, () {
                  setState(() => quantity++);
                }),
              ],
            ),
            const SizedBox(height: 20.0),
            Text(
              food['detail'],
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: AppWidget.LightTextFeildStyle(),
            ),
            const SizedBox(height: 30.0),
            Row(
              children: [
                Text("Delivery Time", style: AppWidget.semiBoldTextFeildStyle()),
                const SizedBox(width: 25.0),
                const Icon(Icons.alarm, color: Colors.black54),
                const SizedBox(width: 5.0),
                Text("30 min", style: AppWidget.semiBoldTextFeildStyle())
              ],
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.only(bottom: 40.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Total Price", style: AppWidget.semiBoldTextFeildStyle()),
                      Text(
                        "\$${int.parse(food['price']) * quantity}",
                        style: AppWidget.HeadlineTextFeildStyle(),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: addToCartAndNavigate,
                    child: Container(
                      width: MediaQuery.of(context).size.width / 2,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: const [
                          Text("Add to cart",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16.0,
                                  fontFamily: 'Poppins')),
                          SizedBox(width: 30.0),
                          Icon(Icons.shopping_cart_outlined, color: Colors.white),
                          SizedBox(width: 10.0),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget buildQuantityButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.all(4),
        child: Icon(icon, color: Colors.white),
      ),
    );
  }
}
