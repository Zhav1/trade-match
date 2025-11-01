import 'package:flutter/material.dart';

class LocationMessageBubble extends StatelessWidget {
  final String locationName;
  final String address;
  final bool isMe;
  final bool isAgreed;
  final bool isOtherUserAgreed;
  final VoidCallback? onAgree;

  const LocationMessageBubble({
    Key? key,
    required this.locationName,
    required this.address,
    required this.isMe,
    required this.isAgreed,
    required this.isOtherUserAgreed,
    this.onAgree,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7,
        ),
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
              ],
            ),
            SizedBox(height: 8),
            Text(
              locationName,
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 4),
            Text(
              address,
              style: TextStyle(fontSize: 12),
            ),
            SizedBox(height: 8),
            if (!isMe && !isAgreed && onAgree != null)
              ElevatedButton(
                onPressed: onAgree,
                child: Text('Agree to Location'),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 36),
                ),
              ),
            if (isAgreed || isOtherUserAgreed)
              Wrap(
                spacing: 8,
                children: [
                  Chip(
                    label: Text('You agreed'),
                    backgroundColor: Colors.green[100],
                  ),
                  if (isOtherUserAgreed)
                    Chip(
                      label: Text('They agreed'),
                      backgroundColor: Colors.green[100],
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}