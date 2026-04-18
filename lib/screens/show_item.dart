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
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // IMAGE
            if (imageUrl != null && imageUrl!.isNotEmpty)
              Image.network(
                imageUrl!,
                width: double.infinity,
                height: 220,
                fit: BoxFit.cover,
              ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // TYPE
                  Text(
                    type.toUpperCase(),
                    style: TextStyle(
                      color: type == 'lost' ? Colors.red : Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  // DESCRIPTION
                  Text(description),

                  const SizedBox(height: 10),

                  // LOCATION
                  Text("Location: $location"),

                  const SizedBox(height: 10),

                  const SizedBox(height: 6),

                  Row(
                    children: [
                      Icon(Icons.access_time, size: 14, color: Colors.grey),
                      SizedBox(width: 4),
                      Text(
                        "Posted: ${formatTime(timestamp)}",
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),
                  // CONTACT
                  Text(
                    contact.isEmpty
                        ? "No contact available"
                        : "Contact : $contact",
                  ),

                  const SizedBox(height: 20),

                  // BUTTONS
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: contact.isEmpty
                            ? null
                            : () => _call(contact),
                        child: const Text("Call"),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: contact.isEmpty
                            ? null
                            : () => _whatsapp(contact),
                        child: const Text("WhatsApp"),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () => _navigate(lat, lng),
                        child: const Text("Navigate"),
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
