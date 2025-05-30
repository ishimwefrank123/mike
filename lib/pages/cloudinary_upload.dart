import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class CloudinaryUploadScreen extends StatefulWidget {
  const CloudinaryUploadScreen({super.key});

  @override
  State<CloudinaryUploadScreen> createState() => _CloudinaryUploadScreenState();
}

class _CloudinaryUploadScreenState extends State<CloudinaryUploadScreen> {
  File? selectedImage;
  String? uploadedImageUrl;
  final ImagePicker _picker = ImagePicker();

  Future<void> pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> uploadImageToCloudinary(File imageFile) async {
    final cloudName = "frankishimwe";
    final uploadPreset = "flutter_preset"; // You must create this in your Cloudinary

    final url = Uri.parse("https://api.cloudinary.com/v1_1/$cloudName/image/upload");

    final request = http.MultipartRequest('POST', url)
      ..fields['upload_preset'] = uploadPreset
      ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

    final response = await request.send();

    if (response.statusCode == 200) {
      final responseData = jsonDecode(await response.stream.bytesToString());
      setState(() {
        uploadedImageUrl = responseData['secure_url'];
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("✅ Image uploaded successfully!"),
        backgroundColor: Colors.green,
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("❌ Upload failed. Try again."),
        backgroundColor: Colors.red,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Cloudinary Image Upload")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            selectedImage != null
                ? Image.file(selectedImage!, height: 200)
                : const Text("No image selected"),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: pickImage,
              icon: const Icon(Icons.photo_library),
              label: const Text("Pick Image"),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: selectedImage != null
                  ? () => uploadImageToCloudinary(selectedImage!)
                  : null,
              icon: const Icon(Icons.cloud_upload),
              label: const Text("Upload to Cloudinary"),
            ),
            const SizedBox(height: 20),
            if (uploadedImageUrl != null) ...[
              const Text("Uploaded Image:"),
              const SizedBox(height: 10),
              Image.network(uploadedImageUrl!, height: 200),
              const SizedBox(height: 10),
              SelectableText(uploadedImageUrl!),
            ],
          ],
        ),
      ),
    );
  }
}
