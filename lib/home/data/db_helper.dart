import 'package:cloud_firestore/cloud_firestore.dart';

class DBHelper {
  static final FirebaseFirestore db = FirebaseFirestore.instance;

  static const collectionRoom = 'rooms';
  static const callerCollection = 'callerCollection';
}
