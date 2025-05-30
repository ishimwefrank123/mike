import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:random_string/random_string.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddFood extends StatefulWidget {
  const AddFood({super.key});

  @override
  State<AddFood> createState() => _AddFoodState();
}

class _AddFoodState extends State<AddFood> {
  final List<String> foodItems = ['Ice-cream', 'Burger', 'Salad', 'Pizza'];
  String? selectedCategory;

  TextEditingController nameController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController detailController = TextEditingController();

  final ImagePicker _picker = ImagePicker();
  File? selectedImage;
  String? uploadedImageUrl;

  Future<void> pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<String?> uploadImageToCloudinary(File imageFile) async {
    final uploadPreset = "food_upload"; // make sure this exists and is unsigned
    final url = Uri.parse("https://api.cloudinary.com/v1_1/frankishimwe/image/upload");

    try {
      final request = http.MultipartRequest('POST', url)
        ..fields['upload_preset'] = uploadPreset
        ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final responseData = jsonDecode(responseBody);
        return responseData['secure_url'];
      } else {
        debugPrint("Upload failed: $responseBody");
        return null;
      }
    } catch (e) {
      debugPrint("Upload exception: $e");
      return null;
    }
  }

  Future<void> uploadItem() async {
    if (selectedImage == null ||
        nameController.text.isEmpty ||
        priceController.text.isEmpty ||
        detailController.text.isEmpty ||
        selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("⚠️ Please fill all fields and select an image.")),
      );
      return;
    }

    String? imageUrl = await uploadImageToCloudinary(selectedImage!);

    if (imageUrl != null) {
      String foodId = randomAlphaNumeric(10);

      Map<String, dynamic> foodItem = {
        "id": foodId,
        "image": imageUrl,
        "name": nameController.text,
        "price": priceController.text,
        "detail": detailController.text,
        "category": selectedCategory,
        "timestamp": FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance.collection('foodItems').add(foodItem);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Food Item Added Successfully!")),
      );

      setState(() {
        selectedImage = null;
        uploadedImageUrl = imageUrl;
        nameController.clear();
        priceController.clear();
        detailController.clear();
        selectedCategory = null;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ Failed to upload image.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Food Item"),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Upload Food Image"),
            const SizedBox(height: 10),
            Center(
              child: GestureDetector(
                onTap: pickImage,
                child: selectedImage == null
                    ? Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          border: Border.all(),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.add_a_photo, size: 40),
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(selectedImage!, width: 150, height: 150, fit: BoxFit.cover),
                      ),
              ),
            ),
            const SizedBox(height: 20),
            const Text("Food Name"),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(hintText: "Enter food name"),
            ),
            const SizedBox(height: 20),
            const Text("Price"),
            TextField(
              controller: priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(hintText: "Enter price"),
            ),
            const SizedBox(height: 20),
            const Text("Details"),
            TextField(
              controller: detailController,
              maxLines: 5,
              decoration: const InputDecoration(hintText: "Enter food details"),
            ),
            const SizedBox(height: 20),
            const Text("Select Category"),
            DropdownButton<String>(
              value: selectedCategory,
              isExpanded: true,
              hint: const Text("Choose category"),
              items: foodItems.map((item) {
                return DropdownMenuItem(
                  value: item,
                  child: Text(item),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedCategory = value;
                });
              },
            ),
            const SizedBox(height: 30),
            Center(
              child: ElevatedButton.icon(
                onPressed: uploadItem,
                icon: const Icon(Icons.upload),
                label: const Text("Submit"),
              ),
            ),
            
          ],
        ),
      ),
    );
  }
}
