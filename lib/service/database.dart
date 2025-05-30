import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseMethods {
  Future addUserDetail(Map<String, dynamic> userInfoMap, String id) async {
    return await FirebaseFirestore.instance
        .collection('users')
        .doc(id)
        .set(userInfoMap);
  }

  Future addFoodItem(Map<String, dynamic> foodMap, String collectionName) async {
    return await FirebaseFirestore.instance
        .collection(collectionName)
        .add(foodMap);
  }

  Future<Stream<QuerySnapshot>> getFoodItem(String collectionName) async {
    return FirebaseFirestore.instance
        .collection(collectionName)
        .snapshots();
  }

  /// ✅ Consistent lowercase 'cart' for both adding and reading
  Future addFoodToCart(Map<String, dynamic> cartItemMap, String userId) async {
    return await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection("cart") // ✅ lowercase
        .add(cartItemMap);
  }

  Future<Stream<QuerySnapshot>> getFoodCart(String userId) async {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection("cart") // ✅ lowercase (fixed)
        .snapshots();
  }

  /// 🗑️ Optional: Delete item from cart by doc ID
  Future deleteCartItem(String userId, String docId) async {
    return await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection("cart")
        .doc(docId)
        .delete();
  }
}
