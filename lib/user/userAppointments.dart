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

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'part': part.toString().split('.').last, // Convert enum to string value
      'description': description,
      'sevearity':
          severity.toString().split('.').last, // Convert enum to string value
    };
  }
}
