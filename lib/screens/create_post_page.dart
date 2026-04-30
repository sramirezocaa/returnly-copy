import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/post_service.dart';

class CreatePostPage extends StatefulWidget {
  final bool fromNavigationTab;

  const CreatePostPage({
    super.key,
    this.fromNavigationTab = false,
  });

  @override
  State<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  final PostService _postService = PostService();
  final ImagePicker _imagePicker = ImagePicker();

  String selectedCategory = 'Phone';
  String selectedStatus = 'Lost';

  final List<String> categories = [
    'Phone',
    'Wallet',
    'Keys',
    'Bag',
    'Jewelry',
    'Other',
  ];

  final List<String> statuses = [
    'Lost',
    'Found',
  ];

  final TextEditingController descriptionController = TextEditingController();

  Uint8List? selectedImageBytes;
  String selectedImageName = 'image.jpg';

  bool isLoading = false;

  @override
  void dispose() {
    descriptionController.dispose();
    super.dispose();
  }

  Future<void> pickImage() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
      );

      if (pickedFile == null) return;

      final Uint8List bytes = await pickedFile.readAsBytes();

      setState(() {
        selectedImageBytes = bytes;
        selectedImageName = pickedFile.name;
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to pick image: $e'),
        ),
      );
    }
  }

  Future<void> submitPost() async {
    setState(() {
      isLoading = true;
    });

    try {
      String imageUrl = '';

      if (selectedImageBytes != null) {
        imageUrl = await _postService.uploadPostImage(
          imageBytes: selectedImageBytes!,
          fileName: selectedImageName,
        );
      }

      await _postService.createPost(
        title: selectedCategory,
        description: descriptionController.text.trim().isEmpty
            ? 'No description available'
            : descriptionController.text.trim(),
        category: selectedCategory,
        status: selectedStatus,
        imageUrl: imageUrl,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Post submitted successfully'),
        ),
      );

      descriptionController.clear();

      setState(() {
        selectedCategory = 'Phone';
        selectedStatus = 'Lost';
        selectedImageBytes = null;
        selectedImageName = 'image.jpg';
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to create post: $e'),
        ),
      );
    }

    if (!mounted) return;

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Report an Item',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Fill out the information below to create a lost or found post.',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 25),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  children: [
                    if (selectedImageBytes != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.memory(
                          selectedImageBytes!,
                          height: 180,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      )
                    else
                      Column(
                        children: [
                          Icon(
                            Icons.image_outlined,
                            size: 50,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'Upload Item Photo',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: isLoading ? null : pickImage,
                      child: Text(
                        selectedImageBytes == null
                            ? 'Choose Image'
                            : 'Change Image',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: selectedCategory,
                items: categories.map((item) {
                  return DropdownMenuItem<String>(
                    value: item,
                    child: Text(item),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedCategory = value!;
                  });
                },
                decoration: const InputDecoration(
                  labelText: 'Select Item Type',
                  prefixIcon: Icon(Icons.category_outlined),
                ),
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: selectedStatus,
                items: statuses.map((item) {
                  return DropdownMenuItem<String>(
                    value: item,
                    child: Text(item),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedStatus = value!;
                  });
                },
                decoration: const InputDecoration(
                  labelText: 'Status',
                  prefixIcon: Icon(Icons.flag_outlined),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: descriptionController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'Enter item details here...',
                  prefixIcon: Icon(Icons.description_outlined),
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: isLoading ? null : submitPost,
                  icon: isLoading
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.check_circle_outline),
                  label: const Text(
                    'Submit Post',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}