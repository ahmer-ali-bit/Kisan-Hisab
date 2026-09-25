import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../config/constants.dart';
import '../models/entry_model.dart';
import '../models/rate_model.dart';

class EntryService {
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

  // ========== ADD ENTRY (with Person Balance Update via Transaction) ==========
  static Future<String> addEntry(EntryModel entry) async {
    final uid = await _getUid();
    final entriesRef = _db.collection('users').doc(uid).collection('entries');
    final newEntryRef = entriesRef.doc();

    await _db.runTransaction((transaction) async {
      // Update person balance if personId exists
      if (entry.personId != null && entry.personId!.isNotEmpty) {
        final personRef = _db
            .collection('users')
            .doc(uid)
            .collection('people')
            .doc(entry.personId);

        final personSnap = await transaction.get(personRef);
        if (personSnap.exists) {
          final data = personSnap.data() as Map<String, dynamic>;
          double toReceive = (data['totalToReceive'] ?? 0).toDouble();
          double toPay = (data['totalToPay'] ?? 0).toDouble();

          // Apply balance change
          final delta = _calculateBalanceDelta(entry);
          toReceive += delta['toReceive'] ?? 0;
          toPay += delta['toPay'] ?? 0;

          transaction.update(personRef, {
            'totalToReceive': toReceive,
            'totalToPay': toPay,
            'updatedAt': Timestamp.now(),
          });
        }
      }

      // Save the entry
      transaction.set(newEntryRef, entry.toMap());
    });

    return newEntryRef.id;
  }

  // ========== UPDATE ENTRY (Reverse old balance, apply new) ==========
  static Future<void> updateEntry(
      EntryModel oldEntry, EntryModel newEntry) async {
    final uid = await _getUid();
    final entryRef =
        _db.collection('users').doc(uid).collection('entries').doc(newEntry.id);

    await _db.runTransaction((transaction) async {
      // 1. Reverse OLD entry effect on old person
      if (oldEntry.personId != null && oldEntry.personId!.isNotEmpty) {
        final oldPersonRef = _db
            .collection('users')
            .doc(uid)
            .collection('people')
            .doc(oldEntry.personId);

        final oldPersonSnap = await transaction.get(oldPersonRef);
        if (oldPersonSnap.exists) {
          final data = oldPersonSnap.data() as Map<String, dynamic>;
          double toReceive = (data['totalToReceive'] ?? 0).toDouble();
          double toPay = (data['totalToPay'] ?? 0).toDouble();

          final delta = _calculateBalanceDelta(oldEntry);
          toReceive -= delta['toReceive'] ?? 0;
          toPay -= delta['toPay'] ?? 0;

          transaction.update(oldPersonRef, {
            'totalToReceive': toReceive,
            'totalToPay': toPay,
            'updatedAt': Timestamp.now(),
          });
        }
      }

      // 2. Apply NEW entry effect on new person
      if (newEntry.personId != null && newEntry.personId!.isNotEmpty) {
        final newPersonRef = _db
            .collection('users')
            .doc(uid)
            .collection('people')
            .doc(newEntry.personId);

        // Fetch again (if same person, use updated values)
        final newPersonSnap = await transaction.get(newPersonRef);
        if (newPersonSnap.exists) {
          final data = newPersonSnap.data() as Map<String, dynamic>;
          double toReceive = (data['totalToReceive'] ?? 0).toDouble();
          double toPay = (data['totalToPay'] ?? 0).toDouble();

          final delta = _calculateBalanceDelta(newEntry);
          toReceive += delta['toReceive'] ?? 0;
          toPay += delta['toPay'] ?? 0;

          transaction.update(newPersonRef, {
            'totalToReceive': toReceive,
            'totalToPay': toPay,
            'updatedAt': Timestamp.now(),
          });
        }
      }

      // 3. Update entry
      transaction.update(entryRef, newEntry.toMap());
    });
  }

  // ========== SOFT DELETE (Move to Trash) ==========
  static Future<void> softDeleteEntry(EntryModel entry) async {
    final uid = await _getUid();
    final entryRef =
        _db.collection('users').doc(uid).collection('entries').doc(entry.id);

    await _db.runTransaction((transaction) async {
      // Reverse balance
      if (entry.personId != null && entry.personId!.isNotEmpty) {
        final personRef = _db
            .collection('users')
            .doc(uid)
            .collection('people')
            .doc(entry.personId);

        final personSnap = await transaction.get(personRef);
        if (personSnap.exists) {
          final data = personSnap.data() as Map<String, dynamic>;
          double toReceive = (data['totalToReceive'] ?? 0).toDouble();
          double toPay = (data['totalToPay'] ?? 0).toDouble();

          final delta = _calculateBalanceDelta(entry);
          toReceive -= delta['toReceive'] ?? 0;
          toPay -= delta['toPay'] ?? 0;

          transaction.update(personRef, {
            'totalToReceive': toReceive,
            'totalToPay': toPay,
            'updatedAt': Timestamp.now(),
          });
        }
      }

      // Soft delete
      transaction.update(entryRef, {
        'isDeleted': true,
        'deletedAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
      });
    });
  }

  // ========== RESTORE FROM TRASH ==========
  static Future<void> restoreEntry(EntryModel entry) async {
    final uid = await _getUid();
    final entryRef =
        _db.collection('users').doc(uid).collection('entries').doc(entry.id);

    await _db.runTransaction((transaction) async {
      // Reapply balance
      if (entry.personId != null && entry.personId!.isNotEmpty) {
        final personRef = _db
            .collection('users')
            .doc(uid)
            .collection('people')
            .doc(entry.personId);

        final personSnap = await transaction.get(personRef);
        if (personSnap.exists) {
          final data = personSnap.data() as Map<String, dynamic>;
          double toReceive = (data['totalToReceive'] ?? 0).toDouble();
          double toPay = (data['totalToPay'] ?? 0).toDouble();

          final delta = _calculateBalanceDelta(entry);
          toReceive += delta['toReceive'] ?? 0;
          toPay += delta['toPay'] ?? 0;

          transaction.update(personRef, {
            'totalToReceive': toReceive,
            'totalToPay': toPay,
            'updatedAt': Timestamp.now(),
          });
        }
      }

      transaction.update(entryRef, {
        'isDeleted': false,
        'deletedAt': null,
        'updatedAt': Timestamp.now(),
      });
    });
  }

  // ========== PERMANENT DELETE (from Trash) ==========
  static Future<void> permanentDelete(String id) async {
    final uid = await _getUid();
    await _db
        .collection('users')
        .doc(uid)
        .collection('entries')
        .doc(id)
        .delete();
  }

  // ========== GET ALL ACTIVE ENTRIES ==========
  static Stream<List<EntryModel>> getEntriesStream() async* {
    final uid = await _getUid();
    yield* _db
        .collection('users')
        .doc(uid)
        .collection('entries')
        .where('isDeleted', isEqualTo: false)
        .snapshots()
        .map((snap) {
      final list =
          snap.docs.map((d) => EntryModel.fromMap(d.id, d.data())).toList();
      // Client-side sort by date (latest first)
      list.sort((a, b) => b.date.compareTo(a.date));
      return list;
    });
  }

  // ========== GET DELETED ENTRIES (Trash) ==========
  static Stream<List<EntryModel>> getTrashStream() async* {
    final uid = await _getUid();
    yield* _db
        .collection('users')
        .doc(uid)
        .collection('entries')
        .where('isDeleted', isEqualTo: true)
        .snapshots()
        .map((snap) {
      final list =
          snap.docs.map((d) => EntryModel.fromMap(d.id, d.data())).toList();
      // Client-side sort by deletedAt (latest first)
      list.sort((a, b) {
        final aDate = a.deletedAt ?? a.updatedAt;
        final bDate = b.deletedAt ?? b.updatedAt;
        return bDate.compareTo(aDate);
      });
      return list;
    });
  }

  // ========== GET ENTRIES BY PERSON ==========
  static Stream<List<EntryModel>> getPersonEntriesStream(
      String personId) async* {
    final uid = await _getUid();
    yield* _db
        .collection('users')
        .doc(uid)
        .collection('entries')
        .where('personId', isEqualTo: personId)
        .where('isDeleted', isEqualTo: false)
        .snapshots()
        .map((snap) {
      final list =
          snap.docs.map((d) => EntryModel.fromMap(d.id, d.data())).toList();
      list.sort((a, b) => b.date.compareTo(a.date));
      return list;
    });
  }

  // ========== GET LATEST RATE (for auto-fill) ==========
  static Future<RateModel?> getLatestRate(String type, DateTime forDate) async {
    final uid = await _getUid();
    final snap = await _db
        .collection('users')
        .doc(uid)
        .collection('rates')
        .where('type', isEqualTo: type)
        .where('effectiveFrom',
            isLessThanOrEqualTo: Timestamp.fromDate(forDate))
        .orderBy('effectiveFrom', descending: true)
        .limit(1)
        .get();

    if (snap.docs.isEmpty) return null;
    return RateModel.fromMap(snap.docs.first.id, snap.docs.first.data());
  }

  // ========== INTERNAL: Balance Delta Calculator ==========
  static Map<String, double> _calculateBalanceDelta(EntryModel entry) {
    // Logic:
    // Kapas: Farmer bought cotton FROM person → farmer owes person → toPay INCREASE
    // Paani: Farmer gave water TO person → person owes farmer → toReceive INCREASE
    // Mazdoori: Farmer hired person → farmer owes person → toPay INCREASE
    // Expense: General expense, no person balance change (but if person, treat as toPay)
    // Payment Receive: Person paid farmer → toReceive DECREASE (or toPay DECREASE if we owed them)
    // Payment Pay: Farmer paid person → toPay DECREASE

    switch (entry.type) {
      case EntryTypes.kapas:
        // Farmer got cotton, will pay person later → toPay increases
        return {'toReceive': 0, 'toPay': entry.amount};

      case EntryTypes.paani:
        // Farmer gave water service → person will pay farmer → toReceive increases
        return {'toReceive': entry.amount, 'toPay': 0};

      case EntryTypes.mazdoori:
        // Farmer hired labor → farmer owes labor → toPay increases
        return {'toReceive': 0, 'toPay': entry.amount};

      case EntryTypes.expense:
        // General expense on person (rare) → toPay increases
        return {'toReceive': 0, 'toPay': entry.amount};

      case EntryTypes.paymentReceive:
        // Farmer received money → reduces person's due → toReceive DECREASE
        return {'toReceive': -entry.amount, 'toPay': 0};

      case EntryTypes.paymentPay:
        // Farmer paid person → reduces what farmer owes → toPay DECREASE
        return {'toReceive': 0, 'toPay': -entry.amount};

      default:
        return {'toReceive': 0, 'toPay': 0};
    }
  }
}
