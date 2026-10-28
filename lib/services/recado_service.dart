import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:cafe_da_vila/models/recado.dart';

class RecadoService {
  static const String enderecoBanco = String.fromEnvironment(
    'FIREBASE_DB_URL',
  );

  // O banco Realtime Database e separado do Firestore usado no cardapio.
  // O login anonimo ja e realizado no main.dart.
  Future<Uri> endereco({String? id}) async {
    final usuario = FirebaseAuth.instance.currentUser;
    if (usuario == null) {
      throw Exception('Usuario nao autenticado no Firebase.');
    }

    if (!enderecoBanco.startsWith('https://')) {
      throw Exception('Configure FIREBASE_DB_URL ao executar o Flutter.');
    }

    final token = await usuario.getIdToken();
    if (token == null || token.isEmpty) {
      throw Exception('Nao foi possivel obter o token do Firebase.');
    }

    final base = enderecoBanco.replaceAll(RegExp(r'/$'), '');
    final caminho = id == null
        ? '/recados/${usuario.uid}.json'
        : '/recados/${usuario.uid}/$id.json';

    return Uri.parse('$base$caminho').replace(
      queryParameters: {'auth': token},
    );
  }

  void verificarResposta(http.Response resposta, String acao) {
    if (resposta.statusCode != 200) {
      // Nao exibimos a URL completa, pois ela contem um token temporario.
      throw Exception('$acao falhou (HTTP ${resposta.statusCode}).');
    }
  }

  // GET: consulta os recados do usuario autenticado.
  Future<List<Recado>> buscarRecados() async {
    final resposta = await http.get(await endereco());
    verificarResposta(resposta, 'Consulta');

    final dados = jsonDecode(resposta.body);
    if (dados == null) return [];
    if (dados is! Map) throw Exception('Resposta inesperada do banco.');

    final lista = <Recado>[];
    for (final item in dados.entries) {
      if (item.value is Map) {
        lista.add(Recado.fromJson(
          item.key.toString(),
          Map<String, dynamic>.from(item.value as Map),
        ));
      }
    }
    lista.sort((a, b) => a.titulo.toLowerCase().compareTo(b.titulo.toLowerCase()));
    return lista;
  }

  // POST: cria um novo recado; o Firebase gera um ID.
  Future<void> cadastrarRecado(Recado recado) async {
    final resposta = await http.post(
      await endereco(),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(recado.toJson()),
    );
    verificarResposta(resposta, 'Cadastro');
  }

  // PUT: substitui os dados do recado selecionado.
  Future<void> atualizarRecado(Recado recado) async {
    if (recado.id.isEmpty) throw Exception('Recado sem identificador.');
    final resposta = await http.put(
      await endereco(id: recado.id),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(recado.toJson()),
    );
    verificarResposta(resposta, 'Atualizacao');
  }

  // DELETE: remove um recado existente.
  Future<void> excluirRecado(String id) async {
    if (id.isEmpty) throw Exception('Recado sem identificador.');
    final resposta = await http.delete(await endereco(id: id));
    verificarResposta(resposta, 'Exclusao');
  }
}
