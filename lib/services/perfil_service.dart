import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class PerfilService {
  final FlutterSecureStorage banco = const FlutterSecureStorage();

  Future<String> lerNome() async {
    return await banco.read(key: 'nome_cliente') ?? '';
  }

  Future<String> lerEmail() async {
    return await banco.read(key: 'email_cliente') ?? '';
  }

  Future<void> salvar(String nome, String email) async {
    await banco.write(key: 'nome_cliente', value: nome);
    await banco.write(key: 'email_cliente', value: email);
  }
}
