/*

 All lines marked as
  //v WEB
  (line)
  //^ WEB

 Must be UNCOMMENTED for WEB
 and COMMENTED for MOBILE

 */

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_journal_demo/HomePage.dart';

//v WEB
//import 'package:firebase/firebase.dart';
//^ WEB

class FirebaseWrapper {
  Future<String> _webSignIn(String email, String password) async {
    //v WEB
//    try {
//      var authResult = await auth().signInWithEmailAndPassword(email, password);
//      var userDocResult =
//          await firestore().collection('users').doc(authResult.user.uid).get();
//      return userDocResult.id;
//    } catch (error) {
//      print('Firebase: failed webSignIn: $error');
//      return null;
//    }
    //^ WEB

    return null;
  }

  Future<void> _webSignOut() async {
    //v WEB
//    return await auth().signOut();
    //^ WEB

    return;
  }

  Future<bool> _webCreateAccount(String email, String password) async {
    //v WEB
//    try {
//      var authResult =
//          await auth().createUserWithEmailAndPassword(email, password);
//      await firestore()
//          .collection('users')
//          .doc(authResult.user.uid)
//          .set({'uid': authResult.user.uid, 'email': email});
//    } catch (error)  {
//      print('Firebase: failed webSignIn: $error');
//      return false;
//    }
    //^ WEB

    return false;
  }

  Future<Map<String, dynamic>> _webGetPosts(String uid) async {
    //v WEB
//    try {
//      var entriesDocResult = await firestore().collection('entries')
//          .doc(uid)
//          .get();
//      return entriesDocResult.data();
//    } catch (error) {
//      print('Failed to retrieve entries');
//    }
    //^ WEB
    return null;
  }

  Future<bool> _webCreatePost(String uid, UserPost post) async {
    //v WEB
//    var timestampID = DateTime.now().millisecondsSinceEpoch.toString();
//    try {
//      await firestore().collection('entries').doc(uid).update(data: {timestampID : post.map()});
//      return true;
//    } catch (error) {
//      print('Failed to create post');
//      try {
//        await firestore().collection('entries').doc(uid).set({});
//        await firestore().collection('entries').doc(uid).update(data: {timestampID : post.map()});
//        return true;
//      } catch (innerError) {
//        print('Failed again to create post');
//      }
//    }
    //^ WEB
    return false;
  }

  Future<bool> _webUpdatePost(String uid, UserPost post) async {
    //v WEB
//    try {
//      await firestore().collection('entries').doc(uid).update(data: {post.id : post.map()});
//      return true;
//    } catch (error) {
//      print('Failed to updated post');
//    }
    //^ WEB
    return false;
  }

  Future<bool> _webDeletePost(String uid, UserPost post) async {
    //v WEB
//    try {
//      var userDoc = await firestore().collection('entries').doc(uid).get();
//      var userData = userDoc.data();
//      userData.remove(post.id);
//      await firestore().collection('entries').doc(uid).set(userData);
//      return true;
//    } catch (error) {
//      print('Failed to delete post');
//    }
    //^ WEB
    return false;
  }

  //Returns uid on success, null on failure
  Future<String> signIn(String email, String password) async {
    if (kIsWeb) {
      return _webSignIn(email, password);
    }
    return _mobileSignIn(email, password);
  }

  Future<void> signOut() async {
    if (kIsWeb) {
      _webSignOut();
    }
    return _mobileSignOut();
  }

  Future<bool> createAccount(String email, String password) async {
    if (kIsWeb) {
      return _webCreateAccount(email, password);
    }
    return _mobileCreateAccount(email, password);
  }

  Future<String> checkActiveUser() async {
    if (kIsWeb) {
      return null;
    }
    try {
      var authResult = await FirebaseAuth.instance.currentUser();
      if (authResult != null) {
        var userDoc = await Firestore.instance
            .collection('users')
            .document(authResult.uid)
            .get();
        return userDoc.documentID;
      }
    } catch (error) {
      print('No active user');
    }
    return null;
  }

  Future<Map<String, dynamic>> getPosts(String uid) async {
    if (kIsWeb) {
      return _webGetPosts(uid);
    }
    return _mobileGetPosts(uid);
  }

  Future<bool> createPost(String uid, UserPost post) async {
    if (kIsWeb) {
      return _webCreatePost(uid, post);
    }
    return _mobileCreatePost(uid, post);
  }

  Future<bool> updatePost(String uid, UserPost post) async {
    if (kIsWeb) {
      return _webUpdatePost(uid, post);
    }
    return _mobileUpdatePost(uid, post);
  }

  Future<bool> deletePost(String uid, UserPost post) async {
    if (kIsWeb) {
      return _webDeletePost(uid, post);
    }
    return _mobileDeletePost(uid, post);
  }

  Future<String> _mobileSignIn(String email, String password) async {
    try {
      var authResult = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      var userDocResult = await Firestore.instance
          .collection('users')
          .document(authResult.user.uid)
          .get();
      return userDocResult.documentID;
    } catch (error) {
      print('Firebase: failed webSignIn: $error');
      return null;
    }
  }

  Future<void> _mobileSignOut() async {
    return await FirebaseAuth.instance.signOut();
  }

  Future<bool> _mobileCreateAccount(String email, String password) async {
    try {
      var authResult = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      await Firestore.instance
          .collection('users')
          .document(authResult.user.uid)
          .setData({'uid': authResult.user.uid, 'email': email});
      return true;
    } catch (error) {
      print('Firebase: failed mobileCreateAccount: $error');
      return false;
    }
  }

  Future<Map<String, dynamic>> _mobileGetPosts(String uid) async {
    try {
      var entriesDocResult =
          await Firestore.instance.collection('entries').document(uid).get();
      return entriesDocResult.data;
    } catch (error) {
      print('Failed to retrieve entries');
    }
    return null;
  }

  Future<bool> _mobileCreatePost(String uid, UserPost post) async {
    var timestampID = DateTime.now().millisecondsSinceEpoch.toString();
    try {
      await Firestore.instance
          .collection('entries')
          .document(uid)
          .updateData({timestampID: post.map()});
      return true;
    } catch (error) {
      print('Failed to create post');
      try {
        await Firestore.instance
            .collection('entries')
            .document(uid).setData({});
        await Firestore.instance
            .collection('entries')
            .document(uid)
            .updateData({timestampID: post.map()});
        return true;
      } catch (innerError) {
        print('Failed to create post again');
      }
    }
    return false;
  }

  Future<bool> _mobileUpdatePost(String uid, UserPost post) async {
    try {
      await Firestore.instance
          .collection('entries')
          .document(uid)
          .updateData({post.id: post.map()});
      return true;
    } catch (error) {
      print('Failed to update post');
    }
    return false;
  }

  Future<bool> _mobileDeletePost(String uid, UserPost post) async {
    try {
      var userDoc = await Firestore.instance.collection('entries').document(uid).get();
      var userData = userDoc.data;
      userData.remove(post.id);
      await Firestore.instance.collection('entries').document(uid).setData(userData);
      return true;
    } catch (error) {
      print('Failed to delete post');
    }
    return false;
  }
}
