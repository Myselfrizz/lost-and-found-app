import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ItemDetailPage extends StatelessWidget {
  final String title;
  final String location;
  final String description;
  final String contact;
  final String? imageUrl;
  final String type;
  final double lat;
  final double lng;
  final Timestamp? timestamp;

  const ItemDetailPage({
    super.key,
    required this.title,
    required this.description,
    required this.location,
    required this.contact,
    required this.type,
    required this.lat,
    required this.lng,
    this.imageUrl,
    this.timestamp,
  });
  void _navigate(double lat, double lng) async {
    final Uri uri = Uri.parse(
      "https://www.google.com/maps/dir/?api=1&destination=$lat,$lng",
    );

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  void _call(String contact) async {
    final Uri uri = Uri.parse("tel:$contact");
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  void _whatsapp(String contact) async {
    final cleaned = contact.replaceAll(RegExp(r'[^0-9]'), '');
    final Uri uri = Uri.parse("https://wa.me/$cleaned");

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  String formatTime(Timestamp? timestamp) {
    if (timestamp == null) return '';

    final date = timestamp.toDate();
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 60) {
      return "${diff.inMinutes} min ago";
    } else if (diff.inHours < 24) {
      return "${diff.inHours} hr ago";
    } else if (diff.inDays < 7) {
      return "${diff.inDays} days ago";
    } else {
      return "${date.day}/${date.month}/${date.year}";
    }
  }

  @override
  Widget build(BuildContext context) {
    final sectionTitle = TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w600,
      color: Colors.grey[600],
    );

    final mainText = TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w500,
      color: Colors.black87,
    );

    final lightText = TextStyle(fontSize: 13, color: Colors.grey[600]);
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // IMAGE
            if (imageUrl != null && imageUrl!.isNotEmpty)
              AspectRatio(
                aspectRatio: 3 / 4,
                child: Image.network(imageUrl!, fit: BoxFit.cover),
              ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // TYPE
                  Text(
                    title,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),

                  SizedBox(height: 12),

                  // TYPE BADGE (you already have container → keep or replace)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: type == 'lost'
                          ? Colors.red.withOpacity(0.1)
                          : Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      type.toUpperCase(),
                      style: TextStyle(
                        color: type == 'lost' ? Colors.red : Colors.green,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  SizedBox(height: 20),

                  // DESCRIPTION
                  Text("Description", style: sectionTitle),
                  SizedBox(height: 6),
                  Text(description, style: mainText),

                  SizedBox(height: 20),

                  // LOCATION
                  Text("Location", style: sectionTitle),
                  SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 16, color: Colors.grey),
                      SizedBox(width: 4),
                      Expanded(child: Text(location, style: mainText)),
                    ],
                  ),

                  SizedBox(height: 20),

                  // TIME
                  Row(
                    children: [
                      Icon(Icons.access_time, size: 14, color: Colors.grey),
                      SizedBox(width: 4),
                      Text(formatTime(timestamp), style: lightText),
                    ],
                  ),

                  SizedBox(height: 20),

                  // CONTACT
                  Text("Contact", style: sectionTitle),
                  SizedBox(height: 6),
                  Text(
                    contact.isEmpty ? "No contact available" : contact,
                    style: mainText,
                  ),

                  SizedBox(height: 20),
                  const SizedBox(height: 20),

                  // BUTTONS
                  Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: contact.isEmpty
                              ? null
                              : () => _call(contact),
                          icon: Icon(Icons.call),
                          label: Text("Call"),
                        ),
                      ),
                      SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: contact.isEmpty
                              ? null
                              : () => _whatsapp(contact),
                          icon: Icon(Icons.message),
                          label: Text("WhatsApp"),
                        ),
                      ),
                      SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () => _navigate(lat, lng),
                          icon: Icon(Icons.navigation),
                          label: Text("Navigate"),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
