import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/constants/colors.dart';

class SellItemPage extends StatefulWidget {
  const SellItemPage({super.key});
  @override
  State<SellItemPage> createState() => _SellItemPageState();
}

class _SellItemPageState extends State<SellItemPage> {
  final List<XFile> _images = [];
  final picker = ImagePicker();

  Future pickImage() async {
    final picked = await picker.pickMultiImage();
    if (picked.isNotEmpty) {
      setState(() => _images.addAll(picked));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () {
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              } else {
                Navigator.of(context).popUntil((route) => route.isFirst);
              }
            }),
        title: const Text('Sell an Item', style: TextStyle(color: Colors.black)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Photos (up to 5)', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: pickImage,
              child: DottedBorder(
                borderType: BorderType.RRect,
                radius: const Radius.circular(12),
                dashPattern: const [6, 6],
                color: Colors.grey.shade300,
                child: Container(
                  height: 120,
                  width: double.infinity,
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.add_a_photo_outlined, size: 36, color: AppColors.textLight),
                      SizedBox(height: 8),
                      Text('Add Photo', style: TextStyle(color: AppColors.textLight, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            const Text('Add clear photos to attract more buyers', style: TextStyle(color: AppColors.textLight, fontSize: 12)),
            const SizedBox(height: 14),
            _buildTextField('Item Title*', 'What are you selling?'),
            _buildDropdown('Category*', ['Electronics', 'Furniture', 'Books', 'Clothing']),
            _buildTextField('Description*', 'Describe your item in detail...', maxLines: 4),
            _buildDropdown('Condition*', ['New', 'Like New', 'Good', 'Fair']),
            _buildTextField('Price*', '\$ 0.00', keyboardType: TextInputType.number),
            const SizedBox(height: 18),
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Listing created! (Mock)')),
                );
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('List Item for Sale', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ),
            const SizedBox(height: 10),
            const Center(child: Text('Your listing will be reviewed within 24 hours', style: TextStyle(color: AppColors.textLight, fontSize: 12))),
          ],
        ),
      ),
      
    );
  }

  Widget _buildTextField(String label, String hint, {int maxLines = 1, TextInputType? keyboardType}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade200)),
            child: TextField(
              maxLines: maxLines,
              keyboardType: keyboardType,
              decoration: InputDecoration(contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14), hintText: hint, border: InputBorder.none),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown(String label, List<String> items) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade200)),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: DropdownButtonFormField<String>(
              items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (_) {},
              decoration: const InputDecoration(border: InputBorder.none),
            ),
          ),
        ],
      ),
    );
  }

  
}
