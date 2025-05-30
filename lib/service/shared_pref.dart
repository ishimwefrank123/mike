import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class SharedPreferenceHelper {
  static const String userIdKey = "USERKEY";
  static const String userNameKey = "USERNAMEKEY";
  static const String userEmailKey = "USEREMAILKEY";
  static const String userWalletKey = "USERWALLETKEY";
  static const String userProfileImageKey = "USERPROFILEIMAGEKEY";

  // Save user ID
  Future<bool> saveUserId(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.setString(userIdKey, userId);
  }

  // Save user name
  Future<bool> saveUserName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.setString(userNameKey, name);
  }

  // Save user email
  Future<bool> saveUserEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.setString(userEmailKey, email);
  }

  // Save wallet amount
  Future<bool> saveUserWallet(String walletAmount) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.setString(userWalletKey, walletAmount);
  }

  // Save profile image URL or path
  Future<bool> saveUserProfileImage(String imageUrl) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.setString(userProfileImageKey, imageUrl);
  }

  // Get user ID
  Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final uid = prefs.getString(userIdKey);
    debugPrint("🧩 Retrieved User ID: $uid");
    return uid;
  }

  // Get user name
  Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(userNameKey);
  }

  // Get user email
  Future<String?> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(userEmailKey);
  }

  // Get wallet balance
  Future<String?> getUserWallet() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(userWalletKey);
  }

  // Get profile image
  Future<String?> getUserProfileImage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(userProfileImageKey);
  }

  // Optional: Clear profile image
  Future<bool> clearUserProfileImage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.remove(userProfileImageKey);
  }

  // Clear all saved data (logout)
  Future<void> clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    debugPrint("🧼 Cleared all SharedPreferences data.");
  }

  // ✅ Compatibility aliases for older method names:
  Future<String?> getUserProfile() => getUserProfileImage();
  Future<bool> saveUserProfile(String imageUrl) => saveUserProfileImage(imageUrl);
}
