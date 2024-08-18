import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:rxdart/rxdart.dart';

class NotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final _messageStreamController = BehaviorSubject<RemoteMessage>();

  // REQUEST PERMISSION Call this in main on startup
  Future<void> requestPermission() async {
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
      print('User granted provisional permission');
    } else {
      print('User declined or has not accepted permission.');
    }
  }

  // SETUP INTERACTIONS
  void setupInteractions() {
    FirebaseMessaging.onMessage.listen((event) {
      print('Got a message whilst in the foreground!');
      print('Message data: ${event.data}');

      _messageStreamController.sink.add(event);
    });

    // User opened message
    FirebaseMessaging.onMessageOpenedApp.listen((event) {
      print('Message clicked!');
    });
  }

  void dispose() {
    _messageStreamController.close();
  }

  /*
  SETUP TOKEN LISTENERS
  Each device has a token, need to get this token in order to send notifications to correct device.
  */
  void setupTokenListeners() {
    FirebaseMessaging.instance.getToken().then((token) {
      saveTokenToDatabase(token);
    });
    FirebaseMessaging.instance.onTokenRefresh.listen(saveTokenToDatabase);
  }

  // SAVE DEVICE TOKEN
  void saveTokenToDatabase(String? token) {
    // Get current user ID
    String? userID = FirebaseAuth.instance.currentUser?.uid;

    // If the current user is logged in & has a token, save it to the DB
    if (userID != null && token != null) {
      FirebaseFirestore.instance
      .collection('Users')
      .doc(userID).set({
        'fcmToken': token,
      }, SetOptions(merge: true));
    }  
  }
  /*
  CLEAR DEVICE TOKEN
  It's important to clear the token when the user logs out.
  */

  Future<void> clearTokenOnLogout(String userID) async {
    try {
      await FirebaseFirestore.instance
      .collection('Users')
      .doc(userID)
      .update({
        'fcmToken': FieldValue.delete(),
      });
      print('Token cleared.');
    } catch (e) {
      print('Failed to clear token: $e');
    }
  }
}