class Item {
  final String id;
  final String title;
  final String location;
  final String type; // lost or found

  Item({
    required this.id,
    required this.title,
    required this.location,
    required this.type,
  });

  // Convert Firestore → Item
  factory Item.fromFirestore(Map<String, dynamic> data, String docId) {
    return Item(
      id: docId,
      title: data['title'] ?? '',
      location: data['location'] ?? '',
      type: data['type'] ?? '',
    );
  }

  // Convert Item → Firestore
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'location': location,
      'type': type,
    };
  }
}