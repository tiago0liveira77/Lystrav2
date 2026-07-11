import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lystra/data/models/household_model.dart';
import 'package:lystra/data/services/firestore_service.dart';
import 'package:lystra/domain/models/household.dart';

class HouseholdRepository {
  HouseholdRepository({required FirestoreService firestoreService})
      : _firestore = firestoreService;

  final FirestoreService _firestore;
  static const _collection = 'households';

  static String _generateCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rng = Random.secure();
    return String.fromCharCodes(
      Iterable.generate(6, (_) => chars.codeUnitAt(rng.nextInt(chars.length))),
    );
  }

  Future<Household> createHousehold(String uid, String name) async {
    final code = _generateCode();
    final ref = await _firestore.addDoc(_collection, {
      'name': name.trim(),
      'ownerId': uid,
      'inviteCode': code,
      'memberIds': [uid],
    });
    return Household(
      id: ref.id,
      name: name.trim(),
      ownerId: uid,
      inviteCode: code,
      memberIds: [uid],
    );
  }

  Future<Household?> getHousehold(String householdId) async {
    try {
      final doc = await _firestore.getDoc('$_collection/$householdId');
      if (!doc.exists) return null;
      return HouseholdModel.fromFirestore(doc).toDomain();
    } catch (_) {
      return null;
    }
  }

  Future<Household?> findByInviteCode(String code) async {
    final snap = await FirebaseFirestore.instance
        .collection(_collection)
        .where('inviteCode', isEqualTo: code.trim().toUpperCase())
        .limit(1)
        .get();
    if (snap.docs.isEmpty) return null;
    return HouseholdModel.fromFirestore(snap.docs.first).toDomain();
  }

  Future<Household> joinHousehold(String uid, Household household) async {
    if (household.memberIds.contains(uid)) return household;
    final updated = household.copyWith(
      memberIds: [...household.memberIds, uid],
    );
    await _firestore.updateDoc(
      '$_collection/${household.id}',
      {'memberIds': updated.memberIds},
    );
    return updated;
  }

  Future<void> leaveHousehold(String uid, Household household) async {
    final updated =
        household.memberIds.where((id) => id != uid).toList();
    await _firestore.updateDoc(
      '$_collection/${household.id}',
      {'memberIds': updated},
    );
  }

  Stream<Household> watchHousehold(String householdId) {
    return _firestore.streamDoc('$_collection/$householdId').map((doc) {
      return HouseholdModel.fromFirestore(doc).toDomain();
    });
  }
}
