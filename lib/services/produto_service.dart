
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cafe_da_vila/models/produto.dart';

class ProdutoService {
  final CollectionReference<Map<String, dynamic>> _produtos =
      FirebaseFirestore.instance.collection('produtos');

  Future<List<Produto>> buscarProdutos() async {
    final resultado = await _produtos.get();

    final lista = resultado.docs.map((documento) {
      return Produto.fromJson({
        ...documento.data(),
        'id': documento.id,
      });
    }).toList();

    lista.sort(
      (a, b) => a.nome.toLowerCase().compareTo(
        b.nome.toLowerCase(),
      ),
    );

    return lista;
  }

  Future<void> cadastrarProduto(Produto produto) async {
    await _produtos.add(produto.toJson());
  }

  Future<void> atualizarProduto(Produto produto) async {
    if (produto.id.isEmpty) {
      throw Exception('Produto sem identificador.');
    }

    await _produtos.doc(produto.id).update(
      produto.toJson(),
    );
  }

  Future<void> excluirProduto(String id) async {
    if (id.isEmpty) {
      throw Exception('Produto sem identificador.');
    }

    await _produtos.doc(id).delete();
  }
}
