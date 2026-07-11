import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lystra/domain/models/household.dart';

class HouseholdModel {
  const HouseholdModel({
    required this.id,
    required this.name,
    required this.ownerId,
    required this.inviteCode,
    required this.memberIds,
  });

  final String id;
  final String name;
  final String ownerId;
  final String inviteCode;
  final List<String> memberIds;

  factory HouseholdModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return HouseholdModel(
      id: doc.id,
      name: data['name'] as String? ?? '',
      ownerId: data['ownerId'] as String? ?? '',
      inviteCode: data['inviteCode'] as String? ?? '',
      memberIds:
          (data['memberIds'] as List<dynamic>?)?.cast<String>() ?? [],
    );
  }

  Map<String, dynamic> toFirestore() => {
        'name': name,
        'ownerId': ownerId,
        'inviteCode': inviteCode,
        'memberIds': memberIds,
      };

  Household toDomain() => Household(
        id: id,
        name: name,
        ownerId: ownerId,
        inviteCode: inviteCode,
        memberIds: memberIds,
      );

  factory HouseholdModel.fromDomain(Household h) => HouseholdModel(
        id: h.id,
        name: h.name,
        ownerId: h.ownerId,
        inviteCode: h.inviteCode,
        memberIds: h.memberIds,
      );
}
