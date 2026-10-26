import 'package:flutter/material.dart';
import 'package:cafe_da_vila/models/produto.dart';

class CardProduto extends StatelessWidget {
  final Produto produto;
  final bool favorito;
  final VoidCallback? onFavoritar;
  final VoidCallback? onEditar;
  final VoidCallback? onExcluir;

  const CardProduto({
    super.key,
    required this.produto,
    this.favorito = false,
    this.onFavoritar,
    this.onEditar,
    this.onExcluir,
  });

  @override
  Widget build(BuildContext context) {
    final promocao = produto is ProdutoPromocional;
    final simbolo = switch (produto.categoria) {
      'Doce' => Icons.cake_outlined,
      'Salgado' => Icons.bakery_dining_outlined,
      'Bebida' => Icons.local_drink_outlined,
      _ => Icons.coffee_outlined,
    };

    return Card(
      color: Colors.white,
      margin: const EdgeInsets.symmetric(vertical: 7),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: const Color(0xFFF3E4D5),
                  child: Icon(simbolo, color: const Color(0xFF70452E)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        produto.nome,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                        ),
                      ),
                      Text(produto.categoria),
                    ],
                  ),
                ),
                if (promocao)
                  const Chip(
                    label: Text('Oferta'),
                    visualDensity: VisualDensity.compact,
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Text(produto.descricao),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  'R\$ ${produto.precoFinal.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Color(0xFF70452E),
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (promocao)
                  Text(
                    'R\$ ${produto.preco.toStringAsFixed(2)}',
                    style: const TextStyle(
                      decoration: TextDecoration.lineThrough,
                      color: Colors.grey,
                    ),
                  ),
              ],
            ),
            if (onFavoritar != null || onEditar != null || onExcluir != null)
              Align(
                alignment: Alignment.centerRight,
                child: Wrap(
                  spacing: 4,
                  children: [
                    if (onFavoritar != null)
                      IconButton(
                        tooltip: 'Favoritar',
                        onPressed: onFavoritar,
                        icon: Icon(
                          favorito ? Icons.favorite : Icons.favorite_border,
                          color: favorito ? Colors.red : Colors.grey,
                        ),
                      ),
                    if (onEditar != null)
                      IconButton(
                        tooltip: 'Editar produto',
                        onPressed: onEditar,
                        icon: const Icon(Icons.edit_outlined),
                      ),
                    if (onExcluir != null)
                      IconButton(
                        tooltip: 'Excluir produto',
                        onPressed: onExcluir,
                        icon: const Icon(Icons.delete_outline),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
