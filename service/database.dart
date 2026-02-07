import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseMethods {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ================= USERS =================

  Future<void> addUserDetail(Map<String, dynamic> userInfoMap, String id) async {
    await _db.collection('users').doc(id).set(userInfoMap);
  }

  Future<void> deleteUser(String id) async {
    await _db.collection('users').doc(id).delete();
  }

  // ================= FOOD =================

  Future<void> addFoodItem(Map<String, dynamic> foodMap, String collectionName) async {
    await _db.collection(collectionName).add(foodMap);
  }

  Stream<QuerySnapshot> getFoodItem(String collectionName) {
    return _db.collection(collectionName).snapshots();
  }

  // ================= CART =================

  Future<void> addFoodToCart(Map<String, dynamic> cartMap, String userId) async {
    await _db.collection('users').doc(userId).collection("Cart").add(cartMap);
  }

  Stream<QuerySnapshot> getFoodCart(String userId) {
    return _db.collection("users").doc(userId).collection("Cart").snapshots();
  }

  Future<void> deleteCartItem(String userId, String docId) async {
    await _db
        .collection("users")
        .doc(userId)
        .collection("Cart")
        .doc(docId)
        .delete();
  }

  Future<void> updateCartItemQuantity(
      String userId, String docId, int newQuantity, int pricePerItem) async {
    await _db
        .collection("users")
        .doc(userId)
        .collection("Cart")
        .doc(docId)
        .update({
      "Quantity": newQuantity.toString(),
      "Total": (newQuantity * pricePerItem).toString(),
    });
  }

  Future<void> clearCart(String userId) async {
    final cartDocs =
    await _db.collection('users').doc(userId).collection('Cart').get();
    for (var doc in cartDocs.docs) {
      await doc.reference.delete();
    }
  }

  // ================= ORDERS =================

  Future<void> placeOrder(Map<String, dynamic> orderInfo) async {
    await _db.collection('Orders').add(orderInfo);
  }

  Stream<QuerySnapshot> getUserOrders(String userId) {
    return _db.collection('Orders').where('UserId', isEqualTo: userId).snapshots();
  }

  Future<void> deleteOrder(String orderId) async {
    await _db.collection('Orders').doc(orderId).delete();
  }

  // ================= RATINGS =================

  Future<void> addReviewToDatabase(Map<String, dynamic> ratingInfo) async {
    await _db.collection("Ratings").add(ratingInfo);
  }

  /// ⭐ FINAL METHOD
  /// 1️⃣ Save rating
  /// 2️⃣ Mark order as rated
  /// 3️⃣ Delete order AFTER delay
  Future<void> finalizeAndRemoveOrder({
    required String orderId,
    required int rating,
    required String review,
    required Map<String, dynamic> orderData,
  }) async {
    try {
      final firstItem = orderData["Items"][0];

      final ratingData = {
        "OrderNumber": orderData["OrderNumber"],
        "Name": firstItem["Name"],
        "Quantity": firstItem["Quantity"],
        "Rating": rating,
        "Review": review,
        "UserName": orderData["UserName"],
        "UserEmail": orderData["UserEmail"],
        "UserId": orderData["UserId"],
        "CreatedAt": FieldValue.serverTimestamp(),
      };

      // 1️⃣ Save rating
      await addReviewToDatabase(ratingData);

      // 2️⃣ Mark order as rated
      await _db.collection("Orders").doc(orderId).update({
        "hasRated": true,
        "Status": "Rated",
      });

      // 3️⃣ Delete order after delay
      Future.delayed(const Duration(seconds: 3), () async {
        await _db.collection("Orders").doc(orderId).delete();
      });
    } catch (e) {
      print("❌ finalizeAndRemoveOrder error: $e");
    }
  }
}
