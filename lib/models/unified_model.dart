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
