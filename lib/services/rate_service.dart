import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/rate_model.dart';

class RateService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // Auto ensure anonymous login
  static Future<String> _getUid() async {
    var user = _auth.currentUser;
    if (user == null) {
      final cred = await _auth.signInAnonymously();
      user = cred.user;
    }
    if (user == null) throw Exception('User not logged in');
    return user.uid;
  }

  // Collection Reference
  static Future<CollectionReference> _getRatesCol() async {
    final uid = await _getUid();
    return _db.collection('users').doc(uid).collection('rates');
  }

  // ========== ADD RATE ==========
  static Future<String> addRate(RateModel rate) async {
    final col = await _getRatesCol();
    final doc = await col.add(rate.toMap());
    return doc.id;
  }

  // ========== DELETE RATE ==========
  static Future<void> deleteRate(String id) async {
    final col = await _getRatesCol();
    await col.doc(id).delete();
  }

  // ========== GET RATES STREAM BY TYPE ==========
  static Stream<List<RateModel>> getRatesStream(String type) async* {
    final uid = await _getUid();
    yield* _db
        .collection('users')
        .doc(uid)
        .collection('rates')
        .where('type', isEqualTo: type)
        .orderBy('effectiveFrom', descending: true) // Latest upar aayega
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => RateModel.fromMap(d.id, d.data())).toList());
  }
}
