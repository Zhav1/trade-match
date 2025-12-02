import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:trade_match/models/category.dart';
import 'package:trade_match/services/api_service.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class AddItemPage extends StatefulWidget {
  const AddItemPage({super.key});

  @override
  _AddItemPageState createState() => _AddItemPageState();
}

class _AddItemPageState extends State<AddItemPage> {
  final _formKey = GlobalKey<FormState>();
  final _apiService = ApiService();

  // Form values
  String _title = '';
  String _description = '';
  double? _estimatedValue;
  String _condition = 'new';
  int? _categoryId;
  String _locationCity = '';
  double _locationLat = 0.0;
  double _locationLon = 0.0;
  String? _wantsDescription;
  final List<String> _imageUrls = [];
  final List<int> _wantedCategoryIds = [];

  // Image picking
  final ImagePicker _picker = ImagePicker();
  List<XFile> _imageFiles = [];

  // Categories
  List<Category> _categories = [];
  bool _isLoadingCategories = true;

  @override
  void initState() {
    super.initState();
    _fetchCategories();
    _getCurrentLocation();
  }

  Future<void> _fetchCategories() async {
    try {
      final categories = await _apiService.getCategories();
      setState(() {
        _categories = List<Category>.from(categories);
        _isLoadingCategories = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingCategories = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load categories: $e')),
      );
    }
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    Position position = await Geolocator.getCurrentPosition();
    List<Placemark> placemarks =
        await placemarkFromCoordinates(position.latitude, position.longitude);
    setState(() {
      _locationLat = position.latitude;
      _locationLon = position.longitude;
      _locationCity = placemarks.first.locality ?? '';
    });
  }

  Future<void> _pickImages() async {
    final List<XFile> selectedImages = await _picker.pickMultiImage();
    if (selectedImages.isNotEmpty) {
      setState(() {
        _imageFiles.addAll(selectedImages);
      });
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      try {
        // Upload images and get URLs
        for (var imageFile in _imageFiles) {
          final imageUrl = await _apiService.uploadImage(File(imageFile.path));
          _imageUrls.add(imageUrl);
        }

        final itemData = {
          'title': _title,
          'description': _description,
          'category_id': _categoryId,
          'condition': _condition,
          'estimated_value': _estimatedValue,
          'currency': 'USD',
          'location_city': _locationCity,
          'location_lat': _locationLat,
          'location_lon': _locationLon,
          'wants_description': _wantsDescription,
          'image_urls': _imageUrls,
          'wanted_category_ids': _wantedCategoryIds,
        };

        await _apiService.createItem(itemData);
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create item: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Item'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Image uploader
              _buildImageUploader(),
              const SizedBox(height: 16),
              // Title
              TextFormField(
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter a title' : null,
                onSaved: (value) => _title = value!,
              ),
              const SizedBox(height: 16),
              // Description
              TextFormField(
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
                validator: (value) =>
                    value!.isEmpty ? 'Please enter a description' : null,
                onSaved: (value) => _description = value!,
              ),
              const SizedBox(height: 16),
              // Estimated Value
              TextFormField(
                decoration: const InputDecoration(labelText: 'Estimated Value'),
                keyboardType: TextInputType.number,
                onSaved: (value) => _estimatedValue = double.tryParse(value!),
              ),
              const SizedBox(height: 16),
              // Condition
              _buildConditionSelector(),
              const SizedBox(height: 16),
              // Category
              _buildCategorySelector(),
              const SizedBox(height: 16),
              // Location
              _buildLocationPicker(),
              const SizedBox(height: 16),
              // Wants Description
              TextFormField(
                decoration:
                    const InputDecoration(labelText: 'What I Want (Description)'),
                maxLines: 3,
                onSaved: (value) => _wantsDescription = value,
              ),
              const SizedBox(height: 16),
              // Wanted Categories
              _buildWantedCategoriesSelector(),
              const SizedBox(height: 32),
              // Submit Button
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text('Add Item'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageUploader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Images', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: _imageFiles.length + 1,
          itemBuilder: (context, index) {
            if (index == _imageFiles.length) {
              return GestureDetector(
                onTap: _pickImages,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.add_a_photo),
                ),
              );
            }
            return Image.file(File(_imageFiles[index].path), fit: BoxFit.cover);
          },
        ),
      ],
    );
  }

  Widget _buildConditionSelector() {
    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(labelText: 'Condition'),
      value: _condition,
      items: ['new', 'like_new', 'good', 'fair']
          .map((condition) => DropdownMenuItem(
                value: condition,
                child: Text(condition.replaceAll('_', ' ').toUpperCase()),
              ))
          .toList(),
      onChanged: (value) => setState(() => _condition = value!),
    );
  }

  Widget _buildCategorySelector() {
    return DropdownButtonFormField<int>(
      decoration: const InputDecoration(labelText: 'Category'),
      value: _categoryId,
      items: _categories
          .map((category) => DropdownMenuItem(
                value: category.id,
                child: Text(category.name),
              ))
          .toList(),
      onChanged: (value) => setState(() => _categoryId = value),
      validator: (value) => value == null ? 'Please select a category' : null,
    );
  }

  Widget _buildLocationPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Location', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text('$_locationCity ($_locationLat, $_locationLon)'),
        TextButton.icon(
          onPressed: _getCurrentLocation,
          icon: const Icon(Icons.location_on),
          label: const Text('Update Location'),
        ),
      ],
    );
  }

  Widget _buildWantedCategoriesSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('What I Want (Categories)',
            style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: _categories
              .map((category) => FilterChip(
                    label: Text(category.name),
                    selected: _wantedCategoryIds.contains(category.id),
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _wantedCategoryIds.add(category.id);
                        }
                        else {
                          _wantedCategoryIds.remove(category.id);
                        }
                      });
                    },
                  ))
              .toList(),
        ),
      ],
    );
  }
}
