import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/person_model.dart';

class PeopleService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // Auto ensure anonymous login if user is null
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
  static Future<CollectionReference> _getPeopleCol() async {
    final uid = await _getUid();
    return _db.collection('users').doc(uid).collection('people');
  }

  // ========== ADD PERSON ==========
  static Future<String> addPerson(PersonModel person) async {
    final col = await _getPeopleCol();
    final doc = await col.add(person.toMap());
    return doc.id;
  }

  // ========== UPDATE PERSON ==========
  static Future<void> updatePerson(PersonModel person) async {
    final col = await _getPeopleCol();
    await col.doc(person.id).update(person.toMap());
  }

  // ========== DELETE PERSON ==========
  static Future<void> deletePerson(String id) async {
    final col = await _getPeopleCol();
    await col.doc(id).delete();
  }

  // ========== GET ALL (Stream) ==========
  static Stream<List<PersonModel>> getPeopleStream() async* {
    final uid = await _getUid();
    yield* _db
        .collection('users')
        .doc(uid)
        .collection('people')
        .orderBy('name')
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => PersonModel.fromMap(d.id, d.data())).toList());
  }

  // ========== GET ONE ==========
  static Future<PersonModel?> getPerson(String id) async {
    final col = await _getPeopleCol();
    final doc = await col.doc(id).get();
    if (!doc.exists) return null;
    return PersonModel.fromMap(doc.id, doc.data() as Map<String, dynamic>);
  }

  // ========== SEARCH ==========
  static List<PersonModel> filterPeople(
      List<PersonModel> people, String query) {
    if (query.trim().isEmpty) return people;
    final q = query.toLowerCase().trim();
    return people.where((p) {
      final name = p.name.toLowerCase();
      final phone = (p.phone ?? '').toLowerCase();
      return name.contains(q) || phone.contains(q);
    }).toList();
  }

  // ========== UPDATE BALANCE ==========
  static Future<void> updateBalance({
    required String personId,
    required double toReceive,
    required double toPay,
  }) async {
    final col = await _getPeopleCol();
    await col.doc(personId).update({
      'totalToReceive': toReceive,
      'totalToPay': toPay,
      'updatedAt': Timestamp.now(),
    });
  }
}
