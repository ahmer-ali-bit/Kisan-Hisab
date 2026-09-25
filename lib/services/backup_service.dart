import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/backup_model.dart';

class BackupService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static const int maxBackupBytes = 900 * 1024;

  static Future<String> _getUid() async {
    var user = _auth.currentUser;
    if (user == null) {
      final cred = await _auth.signInAnonymously();
      user = cred.user;
    }
    if (user == null) throw Exception('User not logged in');
    return user.uid;
  }

  static Future<CollectionReference> _backupsCol() async {
    final uid = await _getUid();
    return _db.collection('users').doc(uid).collection('backups');
  }

  // ========== COLLECT ALL DATA ==========
  static Future<Map<String, dynamic>> _collectAllData() async {
    final uid = await _getUid();
    final userRef = _db.collection('users').doc(uid);

    final peopleSnap = await userRef.collection('people').get();
    final entriesSnap = await userRef.collection('entries').get();
    final ratesSnap = await userRef.collection('rates').get();

    final people = peopleSnap.docs.map((d) {
      final m = Map<String, dynamic>.from(d.data());
      m['_id'] = d.id;
      return m;
    }).toList();

    final entries = entriesSnap.docs.map((d) {
      final m = Map<String, dynamic>.from(d.data());
      m['_id'] = d.id;
      return m;
    }).toList();

    final rates = ratesSnap.docs.map((d) {
      final m = Map<String, dynamic>.from(d.data());
      m['_id'] = d.id;
      return m;
    }).toList();

    return {
      'version': 1,
      'app': 'KISAN_HISAB',
      'exportedAt': DateTime.now().toIso8601String(),
      'people': people,
      'entries': entries,
      'rates': rates,
    };
  }

  // Safe Sanitizer for JSON encoding
  static dynamic _sanitize(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) {
      return {'_ts': value.millisecondsSinceEpoch};
    }
    if (value is DateTime) {
      return {'_ts': value.millisecondsSinceEpoch};
    }
    if (value is Map) {
      return value.map((k, v) => MapEntry(k.toString(), _sanitize(v)));
    }
    if (value is List) {
      return value.map(_sanitize).toList();
    }
    if (value is num || value is String || value is bool) {
      return value;
    }
    return value.toString();
  }

  static Map<String, dynamic> _restoreTimestamps(Map<String, dynamic> map) {
    final result = <String, dynamic>{};
    map.forEach((key, value) {
      if (value is Map && value.containsKey('_ts') && value.length == 1) {
        result[key] = Timestamp.fromMillisecondsSinceEpoch(value['_ts'] as int);
      } else if (value is Map) {
        result[key] = _restoreTimestamps(Map<String, dynamic>.from(value));
      } else if (value is List) {
        result[key] = value.map((item) {
          if (item is Map && item.containsKey('_ts') && item.length == 1) {
            return Timestamp.fromMillisecondsSinceEpoch(item['_ts'] as int);
          }
          if (item is Map) {
            return _restoreTimestamps(Map<String, dynamic>.from(item));
          }
          return item;
        }).toList();
      } else {
        result[key] = value;
      }
    });
    return result;
  }

  // ========== CREATE BACKUP ==========
  static Future<BackupModel> createBackup({String? label}) async {
    final raw = await _collectAllData();
    final sanitized = _sanitize(raw) as Map<String, dynamic>;
    final jsonStr = jsonEncode(sanitized);
    final base64Data = base64Encode(utf8.encode(jsonStr));

    if (base64Data.length > maxBackupBytes) {
      throw Exception(
        'Backup too large (${(base64Data.length / 1024).toStringAsFixed(0)} KB).',
      );
    }

    final peopleCount = (raw['people'] as List).length;
    final entriesCount = (raw['entries'] as List).length;
    final ratesCount = (raw['rates'] as List).length;

    final col = await _backupsCol();
    final now = DateTime.now();
    final docLabel = label ??
        'Backup ${now.day}/${now.month}/${now.year} ${now.hour}:${now.minute.toString().padLeft(2, '0')}';

    final doc = await col.add({
      'label': docLabel,
      'createdAt': Timestamp.fromDate(now),
      'peopleCount': peopleCount,
      'entriesCount': entriesCount,
      'ratesCount': ratesCount,
      'sizeBytes': base64Data.length,
      'data': base64Data,
    });

    return BackupModel(
      id: doc.id,
      label: docLabel,
      createdAt: now,
      peopleCount: peopleCount,
      entriesCount: entriesCount,
      ratesCount: ratesCount,
      sizeBytes: base64Data.length,
    );
  }

  // ========== LIST BACKUPS ==========
  static Stream<List<BackupModel>> getBackupsStream() async* {
    final uid = await _getUid();
    yield* _db
        .collection('users')
        .doc(uid)
        .collection('backups')
        .snapshots()
        .map((snap) {
      final list =
          snap.docs.map((d) => BackupModel.fromMap(d.id, d.data())).toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  // ========== RESTORE BACKUP FROM FIRESTORE ==========
  static Future<void> restoreBackup(String backupId,
      {bool replaceAll = true}) async {
    final uid = await _getUid();
    final backupRef =
        _db.collection('users').doc(uid).collection('backups').doc(backupId);
    final backupSnap = await backupRef.get();

    if (!backupSnap.exists) throw Exception('Backup doc not found');

    final base64Data = backupSnap.data()?['data'] as String?;
    if (base64Data == null || base64Data.isEmpty) {
      throw Exception('Backup data is empty');
    }

    await importFromBase64String(base64Data, replaceAll: replaceAll);
  }

  // ========== DELETE BACKUP ==========
  static Future<void> deleteBackup(String backupId) async {
    final col = await _backupsCol();
    await col.doc(backupId).delete();
  }

  // ========== EXPORT STRING ==========
  static Future<String> exportAsBase64String() async {
    final raw = await _collectAllData();
    final sanitized = _sanitize(raw) as Map<String, dynamic>;
    final jsonStr = jsonEncode(sanitized);
    return base64Encode(utf8.encode(jsonStr));
  }

  // ========== BULLETPROOF MULTI-STAGE DECODER ==========
  static Map<String, dynamic> _parseBackupString(String input) {
    final clean = input.trim();
    if (clean.isEmpty) {
      throw Exception('Backup input string is empty');
    }

    // Attempt 1: Direct JSON parsing
    if (clean.startsWith('{') && clean.endsWith('}')) {
      try {
        return jsonDecode(clean) as Map<String, dynamic>;
      } catch (e) {
        debugPrint('Direct JSON parse failed: $e');
      }
    }

    // Attempt 2: Standard Base64 Cleaned
    String b64 = clean.replaceAll(RegExp(r'\s+'), '');
    b64 = b64.replaceAll('-', '+').replaceAll('_', '/');
    while (b64.length % 4 != 0) {
      b64 += '=';
    }

    try {
      final List<int> bytes = base64Decode(b64);
      final String jsonStr = utf8.decode(bytes, allowMalformed: true);
      return jsonDecode(jsonStr) as Map<String, dynamic>;
    } catch (e) {
      debugPrint('Attempt 2 Base64 decode failed: $e');
    }

    // Attempt 3: Replacing spaces with + (if copy-paste converted + into space)
    try {
      String altB64 =
          clean.replaceAll('\r', '').replaceAll('\n', '').replaceAll(' ', '+');
      while (altB64.length % 4 != 0) {
        altB64 += '=';
      }
      final List<int> bytes = base64Decode(altB64);
      final String jsonStr = utf8.decode(bytes, allowMalformed: true);
      return jsonDecode(jsonStr) as Map<String, dynamic>;
    } catch (e) {
      debugPrint('Attempt 3 Base64 decode failed: $e');
    }

    throw Exception(
        'Backup decode nahi ho saka. Code ghalat ya incomplete hai.');
  }

  // ========== IMPORT FROM BASE64 OR JSON STRING ==========
  static Future<void> importFromBase64String(String input,
      {bool replaceAll = true}) async {
    final Map<String, dynamic> decoded = _parseBackupString(input);
    final data = _restoreTimestamps(decoded);

    if (data['app'] != null && data['app'] != 'KISAN_HISAB') {
      throw Exception('Yeh backup KISAN HISAB ka nahi hai.');
    }

    final people = List<Map<String, dynamic>>.from(
      (data['people'] as List? ?? []).map((e) => Map<String, dynamic>.from(e)),
    );
    final entries = List<Map<String, dynamic>>.from(
      (data['entries'] as List? ?? []).map((e) => Map<String, dynamic>.from(e)),
    );
    final rates = List<Map<String, dynamic>>.from(
      (data['rates'] as List? ?? []).map((e) => Map<String, dynamic>.from(e)),
    );

    final uid = await _getUid();
    final userRef = _db.collection('users').doc(uid);

    if (replaceAll) {
      await _deleteCollection(userRef.collection('people'));
      await _deleteCollection(userRef.collection('entries'));
      await _deleteCollection(userRef.collection('rates'));
    }

    await _writeInBatches(userRef.collection('people'), people);
    await _writeInBatches(userRef.collection('entries'), entries);
    await _writeInBatches(userRef.collection('rates'), rates);
  }

  static Future<void> _deleteCollection(CollectionReference col) async {
    const pageSize = 400;
    while (true) {
      final snap = await col.limit(pageSize).get();
      if (snap.docs.isEmpty) break;
      final batch = _db.batch();
      for (final d in snap.docs) {
        batch.delete(d.reference);
      }
      await batch.commit();
      if (snap.docs.length < pageSize) break;
    }
  }

  static Future<void> _writeInBatches(
    CollectionReference col,
    List<Map<String, dynamic>> items,
  ) async {
    const batchSize = 400;
    for (var i = 0; i < items.length; i += batchSize) {
      final chunk = items.skip(i).take(batchSize);
      final batch = _db.batch();
      for (final item in chunk) {
        final id = item.remove('_id') as String?;
        item.remove('_id');
        final ref = (id != null && id.isNotEmpty) ? col.doc(id) : col.doc();
        batch.set(ref, item);
      }
      await batch.commit();
    }
  }
}
