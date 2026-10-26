class Produto {
  final String id;
  final String nome;
  final String descricao;
  final String categoria;
  final double preco;

  const Produto({
    this.id = '',
    required this.nome,
    required this.descricao,
    required this.categoria,
    required this.preco,
  });

  double get precoFinal => preco;

  factory Produto.fromJson(Map<String, dynamic> json) {
    final id = (json['id'] ?? '').toString();
    final nome = (json['nome'] ?? '').toString();
    final descricao = (json['descricao'] ?? '').toString();
    final categoria = (json['categoria'] ?? 'Café').toString();
    final preco = _lerNumero(json['preco']);
    final desconto = _lerNumero(json['desconto']);

    if (desconto > 0 && desconto <= 100) {
      return ProdutoPromocional(
        id: id,
        nome: nome,
        descricao: descricao,
        categoria: categoria,
        preco: preco,
        desconto: desconto,
      );
    }

    return Produto(
      id: id,
      nome: nome,
      descricao: descricao,
      categoria: categoria,
      preco: preco,
    );
  }

  static double _lerNumero(dynamic valor) {
    return double.tryParse((valor ?? 0).toString()) ?? 0;
  }

  Map<String, dynamic> toJson() {
    return {
      'nome': nome,
      'descricao': descricao,
      'categoria': categoria,
      'preco': preco,
      'desconto': 0,
    };
  }

  Map<String, dynamic> toJsonComId() {
    return {...toJson(), 'id': id};
  }
}

class ProdutoPromocional extends Produto {
  final double desconto;

  const ProdutoPromocional({
    super.id,
    required super.nome,
    required super.descricao,
    required super.categoria,
    required super.preco,
    required this.desconto,
  });

  @override
  double get precoFinal => preco * (1 - desconto / 100);

  @override
  Map<String, dynamic> toJson() {
    return {...super.toJson(), 'desconto': desconto};
  }
}
