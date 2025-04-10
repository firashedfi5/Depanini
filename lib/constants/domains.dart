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

  String get image {
    switch (this) {
      case Domains.plomberie:
        return 'assets/images/plomberie.png';
      case Domains.electricite:
        return 'assets/images/electricite.png';
      case Domains.mecanique:
        return 'assets/images/mécanique.png';
      case Domains.informatique:
        return 'assets/images/informatique.png';
      case Domains.jardinage:
        return 'assets/images/jardinage.png';
      case Domains.climatisation:
        return 'assets/images/climatisation.png';
      case Domains.menuiserie:
        return 'assets/images/menuiserie.png';
      case Domains.chauffage:
        return 'assets/images/chauffage.png';
      case Domains.peinture:
        return 'assets/images/peinture.png';
      case Domains.enfants:
        return 'assets/images/garde_d\'enfants.png';
    }
  }
}
