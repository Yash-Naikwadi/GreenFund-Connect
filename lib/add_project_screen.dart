import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:universal_html/html.dart' as html;
import 'package:flutter/foundation.dart'; // For kIsWeb

class AddProjectScreen extends StatefulWidget {
  const AddProjectScreen({Key? key}) : super(key: key);

  @override
  _AddProjectScreenState createState() => _AddProjectScreenState();
}

class _AddProjectScreenState extends State<AddProjectScreen> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController goalAmountController = TextEditingController();
  File? _image; // Mobile image file
  html.File? _webImage; // Web image file
  bool isLoading = false;
  String? imageUrl;

  // Cloudinary API details
  final String cloudName = "duspjxybv";
  final String apiKey = "462927448234225";
  final String uploadPreset = "GREENFUND-CONNECT";

  // Function to pick an image (for Mobile & Web)
  Future<void> pickImage() async {
    if (kIsWeb) {
      final html.FileUploadInputElement uploadInput = html.FileUploadInputElement()..accept = 'image/*';
      uploadInput.click();

      uploadInput.onChange.listen((event) {
        final files = uploadInput.files;
        if (files!.isNotEmpty) {
          _webImage = files.first;
          setState(() {});
        }
      });
    } else {
      final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        File compressedImage = await compressImage(File(pickedFile.path));
        setState(() => _image = compressedImage);
      }
    }
  }

  // Function to compress image for mobile
  Future<File> compressImage(File imageFile) async {
    final result = await FlutterImageCompress.compressAndGetFile(
      imageFile.absolute.path,
      '${imageFile.path}_compressed.jpg',
      quality: 80,
    );
    return File(result!.path);
  }

  // Function to upload image to Cloudinary
  Future<String?> uploadImageToCloudinary() async {
    try {
      FormData formData = FormData.fromMap({
        "upload_preset": uploadPreset,
        "api_key": apiKey,
      });

      if (kIsWeb) {
        final reader = html.FileReader();
        reader.readAsDataUrl(_webImage!);
        await reader.onLoad.first;
        final encoded = reader.result as String;

        formData.files.add(MapEntry(
          "file",
          MultipartFile.fromString(encoded, filename: _webImage!.name),
        ));
      } else {
        formData.files.add(MapEntry(
          "file",
          await MultipartFile.fromFile(_image!.path),
        ));
      }

      Response response = await Dio().post(
        "https://api.cloudinary.com/v1_1/$cloudName/image/upload",
        data: formData,
      );

      if (response.statusCode == 200) {
        return response.data["secure_url"];
      }
      return null;
    } catch (e) {
      print("Cloudinary Upload Error: $e");
      return null;
    }
  }

  // Function to add project to Firestore
  void addProject() async {
    if (titleController.text.isEmpty ||
        descriptionController.text.isEmpty ||
        goalAmountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("All fields are required!")),
      );
      return;
    }

    double? goalAmount = double.tryParse(goalAmountController.text);
    if (goalAmount == null || goalAmount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Enter a valid goal amount!")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      String userId = FirebaseAuth.instance.currentUser?.uid ?? "unknown";
      String userEmail = FirebaseAuth.instance.currentUser?.email ?? "unknown@example.com";
      String userName = FirebaseAuth.instance.currentUser?.displayName ?? "Anonymous";

      // Upload image and get URL
      imageUrl = await uploadImageToCloudinary();

      // Save project details in Firestore
      await FirebaseFirestore.instance.collection('projects').add({
        'title': titleController.text,
        'description': descriptionController.text,
        'goalAmount': goalAmount,
        'currentAmountRaised': 0.0,
        'imageUrl': imageUrl,
        'ownerId': userId,
        'ownerEmail': userEmail,
        'ownerName': userName,
        'timestamp': FieldValue.serverTimestamp(),
      });

      setState(() => isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Project added successfully!")),
      );

      Navigator.pop(context);
    } catch (e) {
      setState(() => isLoading = false);
      print("Error adding project: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to add project. Check logs.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Add New Project")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(labelText: "Project Title", border: OutlineInputBorder()),
              ),
              SizedBox(height: 10),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(labelText: "Project Description", border: OutlineInputBorder()),
                maxLines: 3,
              ),
              SizedBox(height: 10),
              TextField(
                controller: goalAmountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: "Goal Amount (₹)", border: OutlineInputBorder()),
              ),
              SizedBox(height: 20),

              // Image preview
              _image != null
                  ? Image.file(_image!, height: 150)
                  : _webImage != null
                      ? Text("Web image selected")
                      : Text("No image selected"),
              TextButton.icon(
                onPressed: pickImage,
                icon: Icon(Icons.image),
                label: Text("Pick an Image"),
              ),

              SizedBox(height: 20),
              isLoading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: addProject,
                      child: Text("Submit Project"),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
