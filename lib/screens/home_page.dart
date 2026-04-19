import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:lost_found_app/screens/add_item_.dart';
import 'package:lost_found_app/screens/map_view.dart';
import 'package:lost_found_app/screens/myPost.dart';
import 'package:lost_found_app/screens/show_item.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required String title});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
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

  Widget buildItemCard(Map<String, dynamic> data) {
    final currentUser = FirebaseAuth.instance.currentUser;
    final isMine = data['userId'] == currentUser?.uid;
    final imageUrl = data['imageUrl'] as String?;
    final timestamp = data['createdAt'] as Timestamp?;
    final type = data['type'] ?? '';

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ItemDetailPage(
                title: data['title'] ?? '',
                description: data['description'] ?? '',
                location: data['location'] ?? '',
                imageUrl: imageUrl,

                contact: data['contact'] ?? '',
                lat: data['lat'] != null ? data['lat'].toDouble() : 0.0,
                lng: data['lng'] != null ? data['lng'].toDouble() : 0.0,
                timestamp: timestamp,
                type: type,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: CachedNetworkImage(
                  imageUrl: imageUrl ?? '',
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    width: 100,
                    height: 100,
                    color: Colors.grey.shade300,
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  errorWidget: (context, url, error) {
                    print("IMAGE LOAD ERROR: $error");
                    return Container(
                      width: 100,
                      height: 100,
                      color: Colors.grey.shade300,
                      child: Icon(Icons.broken_image),
                    );
                  },
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title + Badge
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            data['title'] ?? '',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: type == 'lost'
                                ? Colors.red.shade100
                                : Colors.green.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            type.toUpperCase(),
                            style: TextStyle(
                              fontSize: 12,
                              color: type == 'lost' ? Colors.red : Colors.green,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),

                    if (isMine)
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade100,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          "Your Post",
                          style: TextStyle(color: Colors.blue, fontSize: 10),
                        ),
                      ),
                    const SizedBox(height: 6),

                    // Location
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 14),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            data['location'] ?? '',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.access_time, size: 12, color: Colors.grey),
                        SizedBox(width: 4),
                        Text(
                          formatTime(timestamp),
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text("LostLink"),
          centerTitle: true,
          bottom: TabBar(
            labelStyle: TextStyle(fontSize: 20),
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            unselectedLabelStyle: TextStyle(fontSize: 15),

            tabs: [
              Tab(text: "Lost"),
              Tab(text: "Found"),
            ],
          ),
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.person),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MyPostsPage()),
                );
              },
            ),
            // IconButton(
            //   icon: Icon(Icons.map),
            //   onPressed: () {
            //     Navigator.push(
            //       context,
            //       MaterialPageRoute(builder: (_) => MapViewPage()),
            //     );
            //   },
            // ),
          ],
        ),
        body: TabBarView(
          children: [
            //  LOST TAB
            StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('items')
                  .where('type', isEqualTo: 'lost')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData) {
                  return Center(child: Text("No data"));
                }

                final items = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    var data = items[index].data() as Map<String, dynamic>;
                    final imageUrl = data['imageUrl'] as String?;
                    return buildItemCard(data);
                  },
                );
              },
            ),

            // FOUND TAB
            StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('items')
                  .where('type', isEqualTo: 'found')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text("Something went wrong"));
                }

                if (snapshot.hasError) {
                  return Center(child: Text("Something went wrong"));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData) {
                  return const Center(child: Text("No data"));
                }

                final items = snapshot.data!.docs;

                if (items.isEmpty) {
                  return const Center(child: Text("No items yet"));
                }

                return ListView.builder(
                  padding: const EdgeInsets.only(top: 10, bottom: 80),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    var data = items[index].data() as Map<String, dynamic>;
                    return buildItemCard(data);
                  },
                );
              },
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AddItemPage()),
            );
          },
          child: const Icon(Icons.add_box),
        ),
      ),
    );
  }
}
