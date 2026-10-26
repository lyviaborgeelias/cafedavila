import 'package:flutter_test/flutter_test.dart';
import 'package:cafe_da_vila/models/produto.dart';

void main() {
  test('produto simples mantém o preço', () {
    const produto = Produto(
      nome: 'Café expresso',
      descricao: 'Café pequeno',
      categoria: 'Café',
      preco: 8,
    );

    expect(produto.precoFinal, 8);
    expect(produto.toJson()['desconto'], 0);
  });

  test('produto promocional aplica o desconto', () {
    const produto = ProdutoPromocional(
      nome: 'Cappuccino',
      descricao: 'Com leite',
      categoria: 'Café',
      preco: 20,
      desconto: 25,
    );

    expect(produto.precoFinal, 15);
    expect(produto.toJson()['desconto'], 25);
  });

  test('JSON da API vira a subclasse correta', () {
    final produto = Produto.fromJson({
      'id': '3',
      'nome': 'Bolo',
      'descricao': 'Fatia',
      'categoria': 'Doce',
      'preco': '12.5',
      'desconto': '10',
    });

    expect(produto, isA<ProdutoPromocional>());
    expect(produto.precoFinal, 11.25);
  });
}
