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

  String get imageURL {
    switch (this) {
      case Domains.plomberie:
        return 'https://res.cloudinary.com/dgdvqiztn/image/upload/v1743787343/Pipeline_maintenance-amico_bslucl.png';
      case Domains.electricite:
        return 'https://res.cloudinary.com/dgdvqiztn/image/upload/v1743783417/n1bgqqca6vlybh5qsgds.png';
      case Domains.mecanique:
        return 'https://res.cloudinary.com/dgdvqiztn/image/upload/v1743787238/Car_accesories-bro_mly8j5.png';
      case Domains.informatique:
        return 'https://res.cloudinary.com/dgdvqiztn/image/upload/v1743786626/Computer_troubleshooting-amico_uim4o7.png';
      case Domains.jardinage:
        return 'https://res.cloudinary.com/dgdvqiztn/image/upload/v1743786795/Seeding-amico_dk65q9.png';
      case Domains.climatisation:
        return 'https://res.cloudinary.com/dgdvqiztn/image/upload/v1743787550/Refreshing_from_Summer_heat-pana_givmwl.png';
      case Domains.menuiserie:
        return 'https://res.cloudinary.com/dgdvqiztn/image/upload/v1743786896/Woodworker-bro_krk9nl.png';
      case Domains.chauffage:
        return 'https://res.cloudinary.com/dgdvqiztn/image/upload/v1743787512/Weather-bro_zgfbdy.png';
      case Domains.peinture:
        return 'https://res.cloudinary.com/dgdvqiztn/image/upload/v1743787012/Mural_artist-bro_m07tpd.png';
      case Domains.enfants:
        return 'https://res.cloudinary.com/dgdvqiztn/image/upload/v1743787097/Children-bro_rr7qse.png';
    }
  }
}
