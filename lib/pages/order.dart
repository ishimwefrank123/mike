import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:frankmichaelflutterproject/service/database.dart';
import 'package:frankmichaelflutterproject/service/shared_pref.dart';
import 'package:frankmichaelflutterproject/widget/widget_support.dart';

class Order extends StatefulWidget {
  const Order({super.key});

  @override
  State<Order> createState() => _OrderState();
}

class _OrderState extends State<Order> {
  String? userId, wallet;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    userId = await SharedPreferenceHelper().getUserId();
    wallet = await SharedPreferenceHelper().getUserWallet();
    setState(() {}); // Trigger widget rebuild
  }

  Future<void> _deleteCartItem(String docId) async {
    if (userId != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('cart')
          .doc(docId)
          .delete();
    }
  }

  Future<void> _checkout(List<DocumentSnapshot> docs, int total) async {
    if (userId == null || wallet == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ User not logged in.")),
      );
      return;
    }

    int balance = int.tryParse(wallet!) ?? 0;
    if (balance < total) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ Insufficient balance.")),
      );
      return;
    }

    // Deduct balance
    int newBalance = balance - total;
    await SharedPreferenceHelper().saveUserWallet(newBalance.toString());

    // Clear cart
    for (var doc in docs) {
      await doc.reference.delete();
    }

    setState(() {
      wallet = newBalance.toString();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("✅ Checkout successful.")),
    );
  }

  Widget _buildCartItems(Stream<QuerySnapshot> cartStream) {
    return StreamBuilder<QuerySnapshot>(
      stream: cartStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        var docs = snapshot.data!.docs;
        int total = 0;

        for (var doc in docs) {
          total += int.tryParse(doc['Total'] ?? '0') ?? 0;
        }

        if (docs.isEmpty) {
          return const Expanded(
            child: Center(child: Text("🛒 Your cart is empty.")),
          );
        }

        return Expanded(
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    var item = docs[index];

                    return Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 20.0, vertical: 8),
                      child: Material(
                        elevation: 3.0,
                        borderRadius: BorderRadius.circular(10),
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Row(
                            children: [
                              // Quantity Box
                              Container(
                                width: 35,
                                height: 50,
                                decoration: BoxDecoration(
                                  border: Border.all(),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Center(
                                  child: Text(item['Quantity'] ?? '1'),
                                ),
                              ),
                              const SizedBox(width: 10),

                              // Image
                              ClipRRect(
                                borderRadius: BorderRadius.circular(30),
                                child: Image.network(
                                  item['Image'] ?? '',
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) =>
                                      const Icon(Icons.broken_image),
                                ),
                              ),
                              const SizedBox(width: 10),

                              // Info
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(item['Name'] ?? '',
                                        style: AppWidget.semiBoldTextFeildStyle()),
                                    Text("\$${item['Total']}",
                                        style: AppWidget.semiBoldTextFeildStyle()),
                                  ],
                                ),
                              ),

                              // Delete Icon
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _deleteCartItem(item.id),
                              )
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              const Divider(),

              // Total
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Total Price", style: AppWidget.boldTextFeildStyle()),
                    Text("\$$total", style: AppWidget.semiBoldTextFeildStyle()),
                  ],
                ),
              ),

              // Checkout Button
              GestureDetector(
                onTap: () => _checkout(docs, total),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  width: MediaQuery.of(context).size.width,
                  margin: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(
                    child: Text(
                      "Checkout",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (userId == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // AppBar Section
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios),
                  onPressed: () => Navigator.pop(context),
                ),
                Text("🧾 Order Summary",
                    style: AppWidget.HeadlineTextFeildStyle()),
              ],
            ),

            const SizedBox(height: 10),

            // Cart Items + Total
            _buildCartItems(
              FirebaseFirestore.instance
                  .collection('users')
                  .doc(userId)
                  .collection('cart')
                  .snapshots(),
            ),
          ],
        ),
      ),
    );
  }
}
