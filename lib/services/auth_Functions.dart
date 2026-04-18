import 'package:firebase_auth/firebase_auth.dart';

Future<bool> signup(String email, String password) async {
  try {
    await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );
    return true;
  } on FirebaseAuthException catch (e) {
    print(e.message);
    return false;
  }
}

Future<bool> signin(String email, String password) async {
  try {
    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );
    return true; // success
  } on FirebaseAuthException catch (e) {
    print(e.message);
    return false; // failed
  }
}
