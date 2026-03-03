import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart'; // ✅ NEW: Required to understand Firestore Timestamps

class MissingAlert {
  final String id;
  final String petId;
  final String petName;

  /// 'active' or 'resolved'
  final String status;

  final DateTime createdAt;

  final String? lastSeenLocation;
  final DateTime? lastSeenAt;

  final String? contactName;
  final String? contactPhone;

  final String? notes;

  // ✅ NEW optional fields (Sprint 4)
  final String? microchipId;
  final String? distinguishingMarks;

  MissingAlert({
    required this.id,
    required this.petId,
    required this.petName,
    required this.status,
    required this.createdAt,
    this.lastSeenLocation,
    this.lastSeenAt,
    this.contactName,
    this.contactPhone,
    this.notes,
    this.microchipId,
    this.distinguishingMarks,
  });

  MissingAlert copyWith({
    String? id,
    String? petId,
    String? petName,
    String? status,
    DateTime? createdAt,
    String? lastSeenLocation,
    DateTime? lastSeenAt,
    String? contactName,
    String? contactPhone,
    String? notes,
    String? microchipId,
    String? distinguishingMarks,
  }) {
    return MissingAlert(
      id: id ?? this.id,
      petId: petId ?? this.petId,
      petName: petName ?? this.petName,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      lastSeenLocation: lastSeenLocation ?? this.lastSeenLocation,
      lastSeenAt: lastSeenAt ?? this.lastSeenAt,
      contactName: contactName ?? this.contactName,
      contactPhone: contactPhone ?? this.contactPhone,
      notes: notes ?? this.notes,
      microchipId: microchipId ?? this.microchipId,
      distinguishingMarks: distinguishingMarks ?? this.distinguishingMarks,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'petId': petId,
        'petName': petName,
        'status': status,
        'createdAt': createdAt.toIso8601String(),
        'lastSeenLocation': lastSeenLocation,
        'lastSeenAt': lastSeenAt?.toIso8601String(),
        'contactName': contactName,
        'contactPhone': contactPhone,
        'notes': notes,
        'microchipId': microchipId,
        'distinguishingMarks': distinguishingMarks,
      };

  factory MissingAlert.fromMap(Map<String, dynamic> map) {
    // ✅ NEW: Helper function to safely read dates from either Firestore or Local Storage
    DateTime parseDate(dynamic dateData) {
      if (dateData is Timestamp) {
        return dateData.toDate(); // It's from Firestore
      } else if (dateData is String) {
        return DateTime.parse(dateData); // It's from local storage
      }
      return DateTime.now(); // Safe fallback
    }

    return MissingAlert(
      id: map['id'] as String,
      petId: map['petId'] as String,
      petName: map['petName'] as String,
      status: map['status'] as String,
      createdAt: parseDate(map['createdAt']), // ✅ UPDATED
      lastSeenLocation: map['lastSeenLocation'] as String?,
      lastSeenAt: map['lastSeenAt'] != null ? parseDate(map['lastSeenAt']) : null, // ✅ UPDATED
      contactName: map['contactName'] as String?,
      contactPhone: map['contactPhone'] as String?,
      notes: map['notes'] as String?,
      microchipId: map['microchipId'] as String?,
      distinguishingMarks: map['distinguishingMarks'] as String?,
    );
  }

  // ✅ These two fix your storage errors
  String toJson() => jsonEncode(toMap());
  factory MissingAlert.fromJson(String source) =>
      MissingAlert.fromMap(jsonDecode(source) as Map<String, dynamic>);
}