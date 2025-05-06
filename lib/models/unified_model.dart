import 'package:depanini/models/provider_account_model.dart';
import 'package:depanini/models/client_account_model.dart';

enum UserType { client, prestataire }

class UnifiedUser {
  final String id;
  final UserType type;
  final ClientModel? clientData;
  final ProviderAccountModel? providerData;

  UnifiedUser({
    required this.id,
    required this.type,
    this.clientData,
    this.providerData,
  });
}

extension UnifiedUserGetters on UnifiedUser {
  String get username {
    return type == UserType.client
        ? clientData?.username ?? ''
        : providerData?.username ?? '';
  }

  String get email {
    return type == UserType.client
        ? clientData?.email ?? ''
        : providerData?.email ?? '';
  }

  String get phoneNumber {
    return type == UserType.client
        ? clientData?.phoneNumber ?? ''
        : providerData?.phoneNumber ?? '';
  }

  String get address {
    return type == UserType.client
        ? clientData?.localisation ?? ''
        : providerData?.localisation ?? '';
  }
}
