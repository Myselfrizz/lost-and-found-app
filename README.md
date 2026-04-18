# Lost & Found Community App

A Flutter-based mobile application that allows users to report and discover lost or found items within a community. The app uses Firebase for authentication, real-time data storage, and image handling, along with location-based input for better tracking.

---

## Features

- Create posts for lost or found items
- Upload item images
- Add location manually or via map
- Real-time feed using Firebase Firestore
- User authentication
- View and manage personal posts

---

## Tech Stack

- Flutter (Dart)
- Firebase Authentication
- Cloud Firestore
- Firebase Storage
- Google Maps / Geolocation

---

## How It Works

1. User logs in
2. Creates a post (lost or found)
3. Image is uploaded to Firebase Storage
4. Data is stored in Firestore
5. Feed updates in real time

---

## Setup

1. Clone the repository  
   `git clone https://github.com/myselfrizz/lost-and-found-app.git`

2. Install dependencies  
   `flutter pub get`

3. Add Firebase configuration  
   - Place `google-services.json` in `android/app/`

4. Run the app  
   `flutter run`

---

## Notes

- Firebase must be configured before running
- Security rules should be properly set for Firestore and Storage
- API keys should be restricted

---

## Limitations

- No search/filter functionality yet
- No messaging between users
- No notifications

---

## Author

Rizwan