import 'package:lystra/data/models/app_user_model.dart';
import 'package:lystra/data/services/firestore_service.dart';
import 'package:lystra/domain/models/app_user.dart';

class UserRepository {
  UserRepository({required FirestoreService firestoreService})
      : _firestore = firestoreService;

  final FirestoreService _firestore;

  String _path(String uid) => 'users/$uid';

  Future<AppUser?> getUser(String uid) async {
    try {
      final doc = await _firestore.getDoc(_path(uid));
      if (!doc.exists) return null;
      return AppUserModel.fromFirestore(doc).toDomain();
    } catch (_) {
      return null;
    }
  }

  Future<void> createOrUpdate(AppUser user) async {
    await _firestore.setDoc(
      _path(user.uid),
      AppUserModel.fromDomain(user).toFirestore(),
    );
  }

  Future<void> setPremium(String uid, bool value) async {
    await _firestore.mergeDoc(_path(uid), {'isPremium': value});
  }

  Future<void> setHouseholdId(String uid, String? householdId) async {
    await _firestore.mergeDoc(_path(uid), {'householdId': householdId});
  }

  Future<void> saveFcmToken(String uid, String token) async {
    await _firestore.mergeDoc(_path(uid), {'fcmToken': token});
  }
}
