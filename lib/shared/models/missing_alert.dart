import 'dart:convert';

/// Represents a missing pet alert in the app.
///
/// For Sprint 3 we keep it simple and local:
/// - 'active'  -> pet is still missing
/// - 'resolved' -> pet was found / case closed
class MissingAlert {
  final String id;                // unique ID for this alert
  final String petId;             // which pet this alert is for
  final String petName;           // cached pet name for easy display
  final String status;            // 'active' or 'resolved'
  final String? lastSeenLocation; // e.g., "Near UNT Campus, Denton"
  final DateTime? lastSeenAt;     // when the pet was last seen
  final String? contactName;      // person to contact
  final String? contactPhone;     // phone / WhatsApp number
  final String? notes;            // any extra details
  final DateTime createdAt;       // when this alert was created

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
  });

  /// Helper to create a modified copy (useful later when editing an alert)
  MissingAlert copyWith({
    String? id,
    String? petId,
    String? petName,
    String? status,
    String? lastSeenLocation,
    DateTime? lastSeenAt,
    String? contactName,
    String? contactPhone,
    String? notes,
    DateTime? createdAt,
  }) {
    return MissingAlert(
      id: id ?? this.id,
      petId: petId ?? this.petId,
      petName: petName ?? this.petName,
      status: status ?? this.status,
      lastSeenLocation: lastSeenLocation ?? this.lastSeenLocation,
      lastSeenAt: lastSeenAt ?? this.lastSeenAt,
      contactName: contactName ?? this.contactName,
      contactPhone: contactPhone ?? this.contactPhone,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Convert to a Map (for JSON encoding).
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'petId': petId,
      'petName': petName,
      'status': status,
      'lastSeenLocation': lastSeenLocation,
      'lastSeenAt': lastSeenAt?.toIso8601String(),
      'contactName': contactName,
      'contactPhone': contactPhone,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Build from a Map (when decoding JSON).
  factory MissingAlert.fromMap(Map<String, dynamic> map) {
    return MissingAlert(
      id: map['id'] as String,
      petId: map['petId'] as String,
      petName: map['petName'] as String,
      status: map['status'] as String,
      lastSeenLocation: map['lastSeenLocation'] as String?,
      lastSeenAt: map['lastSeenAt'] != null
          ? DateTime.parse(map['lastSeenAt'] as String)
          : null,
      contactName: map['contactName'] as String?,
      contactPhone: map['contactPhone'] as String?,
      notes: map['notes'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  /// Single-object JSON helpers (like in Pet model).
  String toJson() => jsonEncode(toMap());

  factory MissingAlert.fromJson(String source) =>
      MissingAlert.fromMap(jsonDecode(source) as Map<String, dynamic>);
}
