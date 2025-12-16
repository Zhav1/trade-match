import 'package:flutter/material.dart';
import 'package:trade_match/models/barter_item.dart';
import 'package:trade_match/services/api_service.dart';

class SubmitReviewPage extends StatefulWidget {
  final BarterMatch swap;

  const SubmitReviewPage({super.key, required this.swap});

  @override
  State<SubmitReviewPage> createState() => _SubmitReviewPageState();
}

class _SubmitReviewPageState extends State<SubmitReviewPage> {
  final ApiService _apiService = ApiService();
  final TextEditingController _commentController = TextEditingController();
  int _selectedRating = 0;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  int get _reviewedUserId {
    // Determine which user is being reviewed (the OTHER participant)
    final currentUserId = widget.swap.itemA.user.id; // This would need to come from auth state
    // For now, we'll just check both items and pick the other one
    // In real implementation, get current user ID from auth service
    return widget.swap.itemB.user.id;
  }

  Future<void> _submitReview() async {
    // Validation
    if (_selectedRating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a rating'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final reviewData = {
        'swap_id': widget.swap.id,
        'reviewed_user_id': _reviewedUserId,
        'rating': _selectedRating,
        if (_commentController.text.trim().isNotEmpty)
          'comment': _commentController.text.trim(),
      };

      await _apiService.createReview(reviewData);

      if (!mounted) return;

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Review submitted successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      // Pop back to previous screen
      Navigator.pop(context, true); // Return true to indicate success
    } catch (e) {
      if (!mounted) return;

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to submit review: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Determine which item belongs to the reviewed user
    final reviewedUserItem = widget.swap.itemB; // Assuming current user owns itemA
    final currentUserItem = widget.swap.itemA;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Write Review'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Trade Summary
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Trade Summary',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        // Current user's item
                        Expanded(
                          child: Column(
                            children: [
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: Colors.grey[200],
                                  image: currentUserItem.images.isNotEmpty
                                      ? DecorationImage(
                                          image: NetworkImage(currentUserItem.images.first.imageUrl),
                                          fit: BoxFit.cover,
                                        )
                                      : null,
                                ),
                                child: currentUserItem.images.isEmpty
                                    ? const Icon(Icons.image_not_supported)
                                    : null,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                currentUserItem.title,
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Icon(
                            Icons.swap_horiz,
                            color: Theme.of(context).colorScheme.primary,
                            size: 32,
                          ),
                        ),
                        // Reviewed user's item
                        Expanded(
                          child: Column(
                            children: [
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: Colors.grey[200],
                                  image: reviewedUserItem.images.isNotEmpty
                                      ? DecorationImage(
                                          image: NetworkImage(reviewedUserItem.images.first.imageUrl),
                                          fit: BoxFit.cover,
                                        )
                                      : null,
                                ),
                                child: reviewedUserItem.images.isEmpty
                                    ? const Icon(Icons.image_not_supported)
                                    : null,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                reviewedUserItem.title,
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Divider(),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: Colors.grey[200],
                          backgroundImage: reviewedUserItem.user.profilePictureUrl != null
                              ? NetworkImage(reviewedUserItem.user.profilePictureUrl!)
                              : null,
                          child: reviewedUserItem.user.profilePictureUrl == null
                              ? const Icon(Icons.person, size: 16)
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Trade with ${reviewedUserItem.user.name}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Rating Section
            const Text(
              'How was your experience?',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Rate your trading experience with this user',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),

            // Star Rating
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(5, (index) {
                  final starValue = index + 1;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedRating = starValue;
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Icon(
                        _selectedRating >= starValue ? Icons.star : Icons.star_border,
                        size: 48,
                        color: _selectedRating >= starValue
                            ? Theme.of(context).colorScheme.primary
                            : Colors.grey[400],
                      ),
                    ),
                  );
                }),
              ),
            ),
            if (_selectedRating > 0) ...[
              const SizedBox(height: 8),
              Center(
                child: Text(
                  _getRatingLabel(_selectedRating),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 32),

            // Comment Section
            const Text(
              'Share your experience (Optional)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _commentController,
              maxLines: 5,
              maxLength: 500,
              decoration: InputDecoration(
                hintText: 'Tell others about your trading experience...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                    width: 2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitReview,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Submit Review',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getRatingLabel(int rating) {
    switch (rating) {
      case 5:
        return 'Excellent!';
      case 4:
        return 'Good';
      case 3:
        return 'Average';
      case 2:
        return 'Poor';
      case 1:
        return 'Very Poor';
      default:
        return '';
    }
  }
}
