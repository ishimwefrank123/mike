import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:frankmichaelflutterproject/pages/details.dart';
import 'package:frankmichaelflutterproject/widget/widget_support.dart';
import 'package:frankmichaelflutterproject/admin/home_admin.dart'; // Import HomeAdmin

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool icecream = false, pizza = false, salad = false, burger = false;
  String? selectedCategory;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.only(top: 50.0, left: 20.0, right: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 👤 Top Greeting
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const HomeAdmin()),
                      );
                    },
                    child: Text("QUICK DELIVERY", style: AppWidget.boldTextFeildStyle()),
                  ),
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.shopping_cart_outlined, color: Colors.white),
                  )
                ],
              ),
              const SizedBox(height: 20.0),
              Text("Delicious Food", style: AppWidget.HeadlineTextFeildStyle()),
              Text("Discover and Get Great Food", style: AppWidget.LightTextFeildStyle()),
              const SizedBox(height: 20.0),
              showItem(),
              const SizedBox(height: 30.0),

              // 🔁 Firestore Dynamic Product Feed
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('foodItems')
                    .orderBy('timestamp', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Text("No food items uploaded yet.");
                  }

                  final filteredDocs = snapshot.data!.docs.where((doc) {
                    if (selectedCategory == null) return true;
                    final food = doc.data() as Map<String, dynamic>;
                    return food['category'] == selectedCategory;
                  }).toList();

                  return ListView.builder(
                    itemCount: filteredDocs.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      var food = filteredDocs[index].data() as Map<String, dynamic>;

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Details(foodItem: food),
                            ),
                          );
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 20),
                          child: Material(
                            elevation: 4,
                            borderRadius: BorderRadius.circular(16),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: Image.network(
                                    food['image'],
                                    height: 100,
                                    width: 100,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(food['name'],
                                          style: AppWidget.semiBoldTextFeildStyle()),
                                      const SizedBox(height: 4),
                                      Text(food['detail'],
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: AppWidget.LightTextFeildStyle()),
                                      const SizedBox(height: 4),
                                      Text("\$${food['price']}",
                                          style: AppWidget.semiBoldTextFeildStyle()),
                                      Text("(${food['category']})",
                                          style: AppWidget.LightTextFeildStyle()),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget showItem() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        buildCategoryIcon("Ice-cream", "images/ice-cream.png", icecream, () {
          setState(() {
            selectedCategory = "Ice-cream";
            icecream = true;
            pizza = salad = burger = false;
          });
        }),
        buildCategoryIcon("Pizza", "images/pizza.png", pizza, () {
          setState(() {
            selectedCategory = "Pizza";
            pizza = true;
            icecream = salad = burger = false;
          });
        }),
        buildCategoryIcon("Salad", "images/salad.png", salad, () {
          setState(() {
            selectedCategory = "Salad";
            salad = true;
            pizza = icecream = burger = false;
          });
        }),
        buildCategoryIcon("Burger", "images/burger.png", burger, () {
          setState(() {
            selectedCategory = "Burger";
            burger = true;
            pizza = icecream = salad = false;
          });
        }),
      ],
    );
  }

  Widget buildCategoryIcon(String category, String imagePath, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Material(
        elevation: 5.0,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? Colors.black : Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.all(8),
          child: Image.asset(
            imagePath,
            height: 40,
            width: 40,
            fit: BoxFit.cover,
            color: isSelected ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }
}
