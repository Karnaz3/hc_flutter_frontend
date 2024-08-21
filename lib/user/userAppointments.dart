// userAppointment.dart

enum PartsEnum {
  HEAD,
  NECK,
  CHEST,
  ABDOMEN,
  PELVIS,
  ARM,
  LEG,
  FOOT,
  HAND,
  FINGER,
  TOE,
  EYE,
  EAR,
  NOSE,
  MOUTH,
  TEETH,
  TONGUE,
  LIPS,
  GUM,
  THROAT,
  SKIN,
  HAIR,
  NAIL,
  BONE,
  MUSCLE,
  TENDON,
  LIGAMENT,
  JOINT,
  NERVE,
  BLOOD,
  LYMPH,
  VESSEL,
  HEART,
  LUNG,
  LIVER,
  GALLBLADDER,
  PANCREAS,
  SPLEEN,
  KIDNEY,
  BLADDER,
  INTESTINE,
  STOMACH,
  ESOPHAGUS,
  THYROID,
  PARATHYROID,
  PITUITARY,
  VAGINA,
  ADRENAL,
  OVARY,
  UTERUS,
}

enum ReportSeverityEnum {
  LOW,
  MEDIUM,
  HIGH,
  CRITICAL,
}

class UserAppointment {
  final String email;
  final PartsEnum part;
  final String description;
  final ReportSeverityEnum severity;

  UserAppointment({
    required this.email,
    required this.part,
    required this.description,
    required this.severity,
  });

  // Convert the UserAppointment instance to a JSON-compatible map
  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'part': part.toString().split('.').last, // Enum to string value
      'description': description,
      'sevearity': severity.toString().split('.').last, // Enum to string value
    };
  }

  // Create a UserAppointment instance from a JSON-compatible map
  factory UserAppointment.fromJson(Map<String, dynamic> json) {
    return UserAppointment(
      email: json['email'],
      part: PartsEnum.values
          .firstWhere((e) => e.toString().split('.').last == json['part']),
      description: json['description'],
      severity: ReportSeverityEnum.values
          .firstWhere((e) => e.toString().split('.').last == json['sevearity']),
    );
  }
}
