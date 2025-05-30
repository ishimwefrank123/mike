import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:frankmichaelflutterproject/services/notification_service.dart';

class DeleteFood extends StatefulWidget {
  const DeleteFood({Key? key}) : super(key: key);

  @override
  State<DeleteFood> createState() => _DeleteFoodState();
}

class _DeleteFoodState extends State<DeleteFood> {
  final CollectionReference foodCollection =
      FirebaseFirestore.instance.collection('foodItems');

  Future<void> deleteFood(DocumentSnapshot foodDoc) async {
    try {
      final String name = foodDoc['name'] ?? 'Unknown';
      final String category = foodDoc['category'] ?? 'N/A';
      final double price = double.tryParse(foodDoc['price'].toString()) ?? 0.0;

      await foodCollection.doc(foodDoc.id).delete();

      // Show local notification after successful deletion
      NotificationService.showLocalNotification(
        title: 'Product Deleted',
        body: 'Deleted: $name, $category, \$${price.toStringAsFixed(2)}',
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Deleted $name successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete item: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Delete Food Items"),
        backgroundColor: Colors.redAccent,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: foodCollection.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading food items'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final items = snapshot.data!.docs;

          if (items.isEmpty) {
            return const Center(child: Text('No food items found.'));
          }

          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              var data = items[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: data['image'] != null
                      ? Image.network(
                          data['image'],
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                        )
                      : const Icon(Icons.fastfood),
                  title: Text(data['name'] ?? 'Unnamed'),
                  subtitle:
                      Text("\$${data['price']} (${data['category'] ?? 'N/A'})"),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text("Confirm Delete"),
                          content: const Text(
                              "Are you sure you want to delete this item?"),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text("Cancel"),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red),
                              onPressed: () {
                                Navigator.pop(context);
                                deleteFood(data);
                              },
                              child: const Text("Delete"),
                            ),
                            
                          ],
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
