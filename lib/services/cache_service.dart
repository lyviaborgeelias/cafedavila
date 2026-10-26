import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:cafe_da_vila/models/produto.dart';

class CacheService {
  final SharedPreferencesAsync banco = SharedPreferencesAsync();

  Future<void> salvarProdutos(List<Produto> produtos) async {
    final lista = produtos.map((produto) => produto.toJsonComId()).toList();
    await banco.setString('produtos_cache', jsonEncode(lista));
  }

  Future<List<Produto>> lerProdutos() async {
    final texto = await banco.getString('produtos_cache');
    if (texto == null) return [];

    final lista = jsonDecode(texto) as List<dynamic>;
    return lista
        .map((item) => Produto.fromJson(Map<String, dynamic>.from(item as Map)))
        .toList();
  }

  Future<void> salvarFavoritos(Set<String> ids) async {
    await banco.setStringList('favoritos', ids.toList());
  }

  Future<Set<String>> lerFavoritos() async {
    final lista = await banco.getStringList('favoritos') ?? [];
    return lista.toSet();
  }
}
