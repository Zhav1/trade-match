import 'package:flutter/material.dart';

import 'package:url_launcher/url_launcher.dart';

class LocationMessageBubble extends StatelessWidget {
  final String locationName;
  final String address;
  final double? latitude;
  final double? longitude;
  final bool isMe;
  final bool isAgreed;
  final bool isOtherUserAgreed;
  final VoidCallback? onAgree;

  const LocationMessageBubble({
    super.key,
    required this.locationName,
    required this.address,
    this.latitude,
    this.longitude,
    required this.isMe,
    required this.isAgreed,
    required this.isOtherUserAgreed,
    this.onAgree,
  });

  Future<void> _launchMaps() async {
    if (latitude == null || longitude == null) return;

    // Google Maps URL
    final Uri googleMapsUrl = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude',
    );

    try {
      if (!await launchUrl(
        googleMapsUrl,
        mode: LaunchMode.externalApplication,
      )) {
        debugPrint('Could not launch valid map url');
      }
    } catch (e) {
      debugPrint('Error launching map: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7,
        ),
        // Use InkWell for tap effect if coordinates exist
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: (latitude != null && longitude != null) ? _launchMaps : null,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isMe ? Colors.blue[100] : Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.location_on, size: 16),
                      SizedBox(width: 4),
                      Text(
                        'Meeting Location',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      if (latitude != null && longitude != null) ...[
                        Spacer(),
                        Icon(
                          Icons.open_in_new,
                          size: 14,
                          color: Colors.grey[600],
                        ),
                      ],
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    locationName,
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  SizedBox(height: 4),
                  Text(address, style: TextStyle(fontSize: 12)),
                  SizedBox(height: 8),
                  if (!isMe && !isAgreed && onAgree != null)
                    ElevatedButton(
                      onPressed:
                          onAgree, // Needs to be separated from InkWell tap
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(double.infinity, 36),
                      ),
                      child: Text('Agree to Location'),
                    ),
                  // Show agreement status based on user role
                  if (isMe && isOtherUserAgreed)
                    Chip(
                      avatar: Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 18,
                      ),
                      label: Text('They Agreed'),
                      backgroundColor: Colors.green[100],
                    ),
                  if (!isMe && isAgreed)
                    Chip(
                      avatar: Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 18,
                      ),
                      label: Text('Agreed'),
                      backgroundColor: Colors.green[100],
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
