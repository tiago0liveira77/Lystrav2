import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:lystra/domain/models/app_user.dart';

part 'app_user_model.g.dart';

@JsonSerializable(explicitToJson: true)
class AppUserModel {
  const AppUserModel({
    required this.uid,
    required this.email,
    this.displayName,
    this.photoUrl,
    this.isPremium = false,
    this.householdId,
  });

  final String uid;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final bool isPremium;
  final String? householdId;

  factory AppUserModel.fromJson(Map<String, dynamic> json) =>
      _$AppUserModelFromJson(json);

  factory AppUserModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    // Provide defaults for fields that may be absent in partial documents
    // (e.g. created via mergeDoc with only {'isPremium': true})
    return AppUserModel.fromJson({
      'email': '',
      'isPremium': false,
      ...data,
      'uid': doc.id,
    });
  }

  Map<String, dynamic> toJson() => _$AppUserModelToJson(this);

  Map<String, dynamic> toFirestore() {
    final j = toJson()..remove('uid');
    return j;
  }

  AppUser toDomain() => AppUser(
        uid: uid,
        email: email,
        displayName: displayName,
        photoUrl: photoUrl,
        isPremium: isPremium,
        householdId: householdId,
      );

  factory AppUserModel.fromDomain(AppUser user) => AppUserModel(
        uid: user.uid,
        email: user.email,
        displayName: user.displayName,
        photoUrl: user.photoUrl,
        isPremium: user.isPremium,
        householdId: user.householdId,
      );
}
