
# Lost & Found Community App

Flutter-based lost and found app with Firebase backend, real-time feed, image uploads, and location support.

## Screenshots

### Feed
<p align="center">
  <img src="assets/screenshots/lost_tab.jpeg" width="100"/>
  <img src="assets/screenshots/found_tab.jpeg" width="100"/>
</p>
<p align="center"><sub>Lost Items | Found Items</sub></p>

### Actions
<p align="center">
  <img src="assets/screenshots/report_item.jpeg" width="100"/>
  <img src="assets/screenshots/my_posts.jpeg" width="100"/>
</p>
<p align="center"><sub>Report Item | My Posts</sub></p>

### Authentication
<p align="center">
  <img src="assets/screenshots/login_and_signUp.jpeg" width="100"/>
</p>
<p align="center"><sub>Login / Signup</sub></p>
---
## Run Locally

**Prerequisites**
Before you begin, ensure you have the following ready:
* [Flutter SDK](https://docs.flutter.dev/get-started/install) installed.
* An active Android Emulator, iOS Simulator, or physical device connected.

**1. Clone the repository:**
```bash
git clone [https://github.com/Myselfrizz/lost-and-found-app.git](https://github.com/Myselfrizz/lost-and-found-app.git)
cd lost-and-found-app

**2. Install dependencies:**

```bash
 flutter pub get
```
**3. Configure Firebase:**
This project relies on Firebase. The recommended way to link your Firebase project is by using the FlutterFire CLI so that all platforms are configured automatically.
- Create a project in the Firebase Console.
- Run the following command in the root directory of this project and select your Firebase project:

```bash
  flutterfire configure
```
(Note: If you prefer the manual route, you must download your configuration files from Firebase and add google-services.json to android/app/ for Android, and GoogleService-Info.plist to ios/Runner/ for iOS).

Run the App:

```bash
  flutter run
```
### Project Structure

The application's source code is organized within the `lib/` directory:

```text
lib/
├── models/                     # Data structures
│   └── item.dart               # Blueprint for lost/found items
├── screens/                    # UI Views and Pages
│   ├── add_item_.dart          # Screen to report a new item
│   ├── home_page.dart          # Main feed displaying items
│   ├── login_screen.dart       # Authentication UI
│   ├── map_picker.dart         # Location selection interface
│   ├── map_view.dart           # Displaying items on a map
│   ├── myPost.dart             # User's personal post history
│   └── show_item.dart          # Detailed view of a specific item
├── services/                   # Backend communication logic
│   ├── auth_Functions.dart     # Firebase Auth methods
│   └── firestore_services.dart # Database CRUD operations
├── firebase_options.dart       # Auto-generated Firebase config
├── main.dart                   # App entry point
└── theme.dart                  # App-wide styling and colors

## Documentation

### Overview

This application enables users to report and browse lost or found items using a real-time backend powered by Firebase.
---

### Core Components

- **Authentication**
  - Firebase Authentication is used to identify users
  - Each post is associated with a `userId`

- **Firestore (Database)**
  - Collection: `items`
  - Stores item details (title, description, location, image URL, etc.)
  - Real-time updates via Firestore streams

- **Firebase Storage**
  - Stores uploaded images
  - Path structure:
    ```
    user_uploads/{userId}/{timestamp}.jpg
    ```

- **Feed System**
  - Built using `StreamBuilder`
  - Listens to Firestore updates in real time
  - Filters items by type (`lost` / `found`)

---

### Data Flow

1. User authenticates
2. User selects an image and enters item details
3. Image is uploaded to Firebase Storage
4. Download URL is generated
5. Data is stored in Firestore
6. Feed updates automatically via stream

---

### Error Handling

- Image loading errors handled with fallback UI
- Null or invalid data safely handled in UI components

---

### Security

- Authentication required for database and storage access
- Storage scoped per user (`user_uploads/{userId}`)
- API keys restricted via Google Cloud Console
---
## Deployment

Build a release APK:

```bash
flutter build apk --release
```
The generated file will be available at:
```
build/app/outputs/flutter-apk/app-release.apk
```

Download APK:

https://drive.google.com/file/d/1E-YPfwGTG1FKawLk3EOevZZ7pIY32jae/view

Note:
- Enable installation from unknown sources on the device before installing
- This method is intended for testing and manual distribution
---
## Limitations & Future Scope

While the core functionality of the app is stable, there are a few limitations and areas planned for future development:

* **Image Compression:** Currently, images are uploaded to Firebase Storage in their original size. In the future, client-side image compression (e.g., using `flutter_image_compress`) will be implemented to reduce bandwidth and storage costs.
* **Full-Text Search:** Firestore has limited native capabilities for complex string matching. Searching for items is currently limited to basic category/type filtering. Integrating a third-party service like Algolia or Typesense is planned for robust keyword searching.
* **Push Notifications:** Users must manually check the feed to see if their lost item has been found. Integrating Firebase Cloud Messaging (FCM) to notify users when a potential match is posted nearby is a future goal.
* **Offline Caching:** The app currently requires an active internet connection to load the feed. Implementing local caching mechanisms (like SQLite or Hive) would allow users to view previously loaded items while offline.
* **Map API Quotas:** The map and location picker features rely on mapping APIs, which may have usage limits on the free tier.
---

## Support
If you find any issues or have suggestions, feel free to open an issue or submit a pull request.
