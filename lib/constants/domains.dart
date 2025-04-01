// lib/constants/domains.dart
enum Domains {
  plomberie,
  electricite,
  mecanique,
  informatique,
  jardinage,
  climatisation,
  menuiserie,
  chauffage,
  peinture,
  enfants,
}

// Extension to get a string representation if needed
extension DomainExtension on Domains {
  String get name {
    switch (this) {
      case Domains.plomberie:
        return 'Plomberie';
      case Domains.electricite:
        return 'Electricité';
      case Domains.mecanique:
        return 'Mécanique';
      case Domains.informatique:
        return 'Informatique';
      case Domains.jardinage:
        return 'Jardinage';
      case Domains.climatisation:
        return 'Climatisation';
      case Domains.menuiserie:
        return 'Menuiserie';
      case Domains.chauffage:
        return 'Chauffage';
      case Domains.peinture:
        return 'Peinture';
      case Domains.enfants:
        return 'Garde d\'enfants';
    }
  }
}
