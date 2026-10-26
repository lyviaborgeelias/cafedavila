import 'package:flutter/material.dart';
import 'package:cafe_da_vila/components/card_produto.dart';
import 'package:cafe_da_vila/models/produto.dart';
import 'package:cafe_da_vila/services/clima_service.dart';

class TelaHome extends StatefulWidget {
  final List<Produto> produtos;
  final bool carregando;
  final VoidCallback onVerCardapio;

  const TelaHome({
    super.key,
    required this.produtos,
    required this.carregando,
    required this.onVerCardapio,
  });

  @override
  State<TelaHome> createState() => _TelaHomeState();
}

class _TelaHomeState extends State<TelaHome> {
  late final Future<double> climaFuturo;

  @override
  void initState() {
    super.initState();
    climaFuturo = ClimaService().buscarTemperatura();
  }

  @override
  Widget build(BuildContext context) {
    final ofertas = widget.produtos.whereType<ProdutoPromocional>().toList();
    final destaques = ofertas.isNotEmpty
        ? ofertas.take(3).toList()
        : widget.produtos.take(3).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Café da Vila')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Container(
                    padding: const EdgeInsets.all(25),
                    decoration: BoxDecoration(
                      color: const Color(0xFF70452E),
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.coffee, color: Colors.white, size: 45),
                        const SizedBox(height: 16),
                        const Text(
                          'Seu café favorito, bem pertinho!',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 27,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Conheça nosso cardápio de cafés, doces e salgados.',
                          style: TextStyle(color: Colors.white70, fontSize: 16),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: widget.onVerCardapio,
                          icon: const Icon(Icons.menu_book),
                          label: const Text('Ver cardápio'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 15),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: FutureBuilder<double>(
                        future: climaFuturo,
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return const Text('Previsão do tempo indisponível.');
                          }
                          if (!snapshot.hasData) {
                            return const Text('Consultando o clima em Campinas...');
                          }
                          final temperatura = snapshot.data!;
                          final sugestao = temperatura >= 27
                              ? 'Que tal experimentar uma bebida gelada?'
                              : 'Um café quentinho combina com o dia!';
                          return Text(
                            'Campinas: ${temperatura.toStringAsFixed(0)}°C • $sugestao',
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    'Dados meteorológicos: Open-Meteo (CC BY 4.0)',
                    style: TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                  const SizedBox(height: 28),
                  const Text(
                    'Destaques do dia',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  if (widget.carregando && widget.produtos.isEmpty)
                    const Center(child: CircularProgressIndicator())
                  else if (widget.produtos.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(20),
                      child: Text('Ainda não há produtos cadastrados.'),
                    )
                  else
                    for (final produto in destaques) CardProduto(produto: produto),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: widget.onVerCardapio,
                    icon: const Icon(Icons.arrow_forward),
                    label: const Text('Consultar todos os produtos'),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    constraints.maxWidth < 420
                        ? 'Desenvolvido com Flutter e Dart'
                        : 'Cafeteria fictícia • Projeto acadêmico Flutter e Dart',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
