import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:trade_match/models/category.dart';
import 'package:trade_match/models/item.dart';
import 'package:trade_match/services/api_service.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:trade_match/theme.dart';

class AddItemPage extends StatefulWidget {
  final Item? item; // If provided, we are in Edit mode
  const AddItemPage({super.key, this.item});

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
  
  // Edit mode flags
  bool get _isEditing => widget.item != null;
  bool _isLoading = false;

  // Categories
  List<Category> _categories = [];
  bool _isLoadingCategories = true;

  @override
  void initState() {
    super.initState();
    _fetchCategories();
    
    if (_isEditing) {
      _initializeEditMode();
    } else {
      _getCurrentLocation();
    }
  }

  void _initializeEditMode() {
    final item = widget.item!;
    _title = item.title;
    _description = item.description;
    _estimatedValue = item.estimatedValue;
    _condition = item.condition;
    _categoryId = item.categoryId;
    _locationCity = item.locationCity;
    _locationLat = item.locationLat;
    _locationLon = item.locationLon;
    _wantsDescription = item.wantsDescription;
    
    // Existing images
    if (item.images != null) {
      _imageUrls.addAll(item.images!.map((e) => e.imageUrl));
    }
    
    // Existing wants (categories)
    if (item.wants != null) {
      _wantedCategoryIds.addAll(item.wants!.map((e) => e.wantedCategoryId));
    }
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load categories: $e')),
        );
      }
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
      setState(() => _isLoading = true);

      try {
        // Upload NEW images and get URLs
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
          'image_urls': _imageUrls, // Contains both old and new URLs
          'wanted_category_ids': _wantedCategoryIds,
        };

        if (_isEditing) {
          await _apiService.updateItem(widget.item!.id, itemData);
          if (mounted) {
             ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Item updated successfully')));
          }
        } else {
          await _apiService.createItem(itemData);
          if (mounted) {
             ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Item created successfully')));
          }
        }
        
        if (mounted) {
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to ${_isEditing ? 'update' : 'create'} item: $e')),
          );
        }
      } finally {
        if (mounted) {
           setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Item' : 'Add New Item'),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
          child: Center(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: ResponsiveUtils.getMaxContentWidth(context),
              ),
              padding: ResponsiveUtils.getResponsivePadding(context),
              child: Form(
            key: _formKey,
            child: ListView(
              children: [
                // Image uploader
                _buildImageUploader(),
                const SizedBox(height: AppSpacing.md),
                // Title
                TextFormField(
                  initialValue: _title,
                  decoration: const InputDecoration(labelText: 'Title'),
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter a title' : null,
                  onSaved: (value) => _title = value!,
                ),
                const SizedBox(height: AppSpacing.md),
                // Description
                TextFormField(
                  initialValue: _description,
                  decoration: const InputDecoration(labelText: 'Description'),
                  maxLines: 3,
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter a description' : null,
                  onSaved: (value) => _description = value!,
                ),
                const SizedBox(height: AppSpacing.md),
                // Estimated Value
                TextFormField(
                  initialValue: _estimatedValue?.toString(),
                  decoration: const InputDecoration(labelText: 'Estimated Value'),
                  keyboardType: TextInputType.number,
                  onSaved: (value) => _estimatedValue = double.tryParse(value!),
                ),
                const SizedBox(height: AppSpacing.md),
                // Condition
                _buildConditionSelector(),
                const SizedBox(height: AppSpacing.md),
                // Category
                _buildCategorySelector(),
                const SizedBox(height: AppSpacing.md),
                // Location
                _buildLocationPicker(),
                const SizedBox(height: AppSpacing.md),
                // Wants Description
                TextFormField(
                  initialValue: _wantsDescription,
                  decoration:
                      const InputDecoration(labelText: 'What I Want (Description)'),
                  maxLines: 3,
                  onSaved: (value) => _wantsDescription = value,
                ),
                const SizedBox(height: AppSpacing.md),
                // Wanted Categories
                _buildWantedCategoriesSelector(),
                const SizedBox(height: AppSpacing.xl),
                const SizedBox(height: AppSpacing.lg),
                // Submit button with gradient
                SizedBox(
                  width: double.infinity,
                  child: GradientButton(
                    text: _isEditing ? 'Update Item' : 'Add Item',
                    onPressed: _submitForm,
                    icon: _isEditing ? Icons.check : Icons.add,
                  )
                )
              ]
            )
          )
        )
      )
    )
  );
  }

  Widget _buildImageUploader() {
    final totalImages = _imageUrls.length + _imageFiles.length;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Images', style: AppTextStyles.labelBold),
        const SizedBox(height: AppSpacing.sm),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: totalImages + 1,
          itemBuilder: (context, index) {
            if (index == totalImages) {
              return GestureDetector(
                onTap: _pickImages,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: const Icon(Icons.add_a_photo),
                ),
              );
            }
            
            // Display existing remote images first, then new local images
            if (index < _imageUrls.length) {
               return Stack(
                 fit: StackFit.expand,
                 children: [
                   Image.network(_imageUrls[index], fit: BoxFit.cover),
                   Positioned(
                     right: 0,
                     top: 0,
                     child: GestureDetector(
                       onTap: () {
                         setState(() {
                           _imageUrls.removeAt(index);
                         });
                       },
                       child: const CircleAvatar(
                         radius: 12,
                         backgroundColor: Colors.red,
                         child: Icon(Icons.close, size: 16, color: Colors.white),
                       ),
                     ),
                   )
                 ],
               );
            } else {
               final localIndex = index - _imageUrls.length;
               return Stack(
                 fit: StackFit.expand,
                 children: [
                   Image.file(File(_imageFiles[localIndex].path), fit: BoxFit.cover),
                   Positioned(
                     right: 0,
                     top: 0,
                     child: GestureDetector(
                       onTap: () {
                         setState(() {
                           _imageFiles.removeAt(localIndex);
                         });
                       },
                       child: const CircleAvatar(
                         radius: 12,
                         backgroundColor: Colors.red,
                         child: Icon(Icons.close, size: 16, color: Colors.white),
                       ),
                     ),
                   )
                 ],
               );
            }
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
        const Text('Location', style: AppTextStyles.labelBold),
        const SizedBox(height: AppSpacing.sm),
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
            style: AppTextStyles.labelBold),
        const SizedBox(height: AppSpacing.sm),
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
