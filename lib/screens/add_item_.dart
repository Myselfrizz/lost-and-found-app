import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:lost_found_app/screens/map_picker.dart';
import 'package:toggle_switch/toggle_switch.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geocoding/geocoding.dart';

class AddItemPage extends StatefulWidget {
  final Map<String, dynamic>? existingData;
  final String? docId;

  const AddItemPage({super.key, this.existingData, this.docId});

  @override
  State<AddItemPage> createState() => _AddItemPageState();
}

InputDecoration inputStyle(String label, IconData icon) {
  return InputDecoration(
    labelText: label,
    prefixIcon: Icon(icon),
    filled: true,
    fillColor: Colors.grey.shade100,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
  );
}

class _AddItemPageState extends State<AddItemPage> {
  @override
  void initState() {
    super.initState();

    if (widget.existingData != null) {
      final data = widget.existingData!;

      titleController.text = data['title'] ?? '';
      locationController.text = data['location'] ?? '';
      descController.text = data['description'] ?? '';
      contactController.text = data['contact'] ?? '';
      isLost = data['type'] == 'lost';
    }
  }

  final _formKey = GlobalKey<FormState>();

  final titleController = TextEditingController();
  final locationController = TextEditingController();
  final descController = TextEditingController();
  final contactController = TextEditingController();
  bool isLost = true;
  bool isLoading = false;

  File? _image;
  double? selectedLat;
  double? selectedLng;
  Future<void> getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      Placemark place = placemarks[0];

      String address =
          "${place.street}, ${place.locality}, ${place.administrativeArea}";

      setState(() {
        selectedLat = position.latitude;
        selectedLng = position.longitude;

        locationController.text = address;
      });
    } catch (e) {
      print("ERROR: $e");
    }
  }

  //  Pick Image
  Future<void> pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      setState(() {
        _image = File(picked.path);
      });
    }
  }

  //  Upload Image
  Future<String?> uploadImage() async {
    if (_image == null) return null;

    try {
      final fileName = DateTime.now().millisecondsSinceEpoch.toString();

      final ref = FirebaseStorage.instance
          .ref()
          .child('items_images')
          .child(fileName);

      await ref.putFile(_image!);

      final url = await ref.getDownloadURL();
      print("IMAGE UPLOADED: $url");

      return url;
    } catch (e) {
      print("UPLOAD ERROR: $e");
      return null;
    }
  }

  //  Submit Item
  Future<void> submitItem() async {
  if (!_formKey.currentState!.validate()) return;

 if (locationController.text.trim().isEmpty) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text("Please enter or select location")),
  );
  return;
}

  if (_image == null && widget.docId == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Please select an image")),
    );
    return;
  }

  setState(() => isLoading = true);

  try {
    String? imageUrl;

    if (_image != null) {
      imageUrl = await uploadImage();
    } else if (widget.existingData != null) {
      imageUrl = widget.existingData!['imageUrl'];
    }

    final data = {
      'title': titleController.text,
      'location': locationController.text,
      'lat': selectedLat,
      'lng': selectedLng,
      'description': descController.text,
      'type': isLost ? 'lost' : 'found',
      'contact': contactController.text.trim(),
      'imageUrl': imageUrl,
    };

    if (widget.docId != null) {
      // EDIT MODE
      final docRef = FirebaseFirestore.instance
          .collection('items')
          .doc(widget.docId);

      final docSnap = await docRef.get();

      if (!docSnap.exists) {
        // fallback if deleted
        await FirebaseFirestore.instance.collection('items').add({
          ...data,
          'createdAt': DateTime.now(),
          'userId': FirebaseAuth.instance.currentUser!.uid,
        });
      } else {
        await docRef.update({
          ...data,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    } else {
      //  NEW POST
      await FirebaseFirestore.instance.collection('items').add({
        ...data,
        'createdAt': DateTime.now(),
        'userId': FirebaseAuth.instance.currentUser!.uid,
      });
    }

    Navigator.pop(context);
  } catch (e) {
    print("ERROR: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Error: $e")),
    );
  } finally {
    setState(() => isLoading = false);
  }
}

  @override
  void dispose() {
    titleController.dispose();
    locationController.dispose();
    descController.dispose();
    contactController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Report Item")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                //  Title
                const SizedBox(height: 16),
                TextFormField(
                  controller: titleController,
                  validator: (value) =>
                      value == null || value.isEmpty ? "Enter title" : null,
                  decoration: inputStyle("Item title", Icons.label),
                ),

                const SizedBox(height: 16),

                //  Location
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: locationController,
                      decoration: inputStyle("Location", Icons.location_on),
                    ),

                    const SizedBox(height: 16),

                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: () async {
                          final LatLng? pickedLocation = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MapPickerPage(),
                            ),
                          );

                          if (pickedLocation != null) {
                            final placemarks = await placemarkFromCoordinates(
                              pickedLocation.latitude,
                              pickedLocation.longitude,
                            );

                            final place = placemarks.first;

                            final address =
                                "${place.street}, ${place.locality}, ${place.administrativeArea}";

                            setState(() {
                              selectedLat = pickedLocation.latitude;
                              selectedLng = pickedLocation.longitude;
                              locationController.text = address;
                            });
                          }
                        },
                        icon: Icon(Icons.map, size: 18),
                        label: Text("Pick on Map"),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Description
                TextFormField(
                  controller: descController,
                  maxLines: 3,
                  decoration: inputStyle("Description", Icons.description),
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller: contactController,
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Enter contact number";
                    }
                    return null;
                  },
                  decoration: inputStyle("Contact", Icons.phone),
                ),
                const SizedBox(height: 16),

                //  Image Picker
                GestureDetector(
                  onTap: pickImage,
                  child: Container(
                    height: 160,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: _image != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(_image!, fit: BoxFit.cover),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.camera_alt,
                                size: 40,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 8),
                              Text("Tap to upload image"),
                            ],
                          ),
                  ),
                ),

                const SizedBox(height: 16),

                //  Toggle
                Container(
                  padding: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ToggleSwitch(
                    initialLabelIndex: isLost ? 0 : 1,
                    totalSwitches: 2,
                    labels: ['Lost', 'Found'],
                    radiusStyle: true,
                    activeBgColors: [
                      [Colors.red.shade400],
                      [Colors.green.shade400],
                    ],
                    onToggle: (index) {
                      setState(() {
                        isLost = index == 0;
                      });
                    },
                  ),
                ),

                const SizedBox(height: 16),

                //  Submit Button
                isLoading
                    ? const CircularProgressIndicator()
                    : SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: submitItem,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green.shade700,
                            padding: EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            "Submit",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
