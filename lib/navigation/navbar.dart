import 'package:flutter/material.dart';
import 'package:cafe_da_vila/models/produto.dart';
import 'package:cafe_da_vila/screens/telahome.dart';
import 'package:cafe_da_vila/screens/telaprodutos.dart';
import 'package:cafe_da_vila/screens/telaperfil.dart';
import 'package:cafe_da_vila/screens/telarecados.dart';
import 'package:cafe_da_vila/services/cache_service.dart';
import 'package:cafe_da_vila/services/produto_service.dart';

class NavBar extends StatefulWidget {
  const NavBar({super.key});

  @override
  State<NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  final ProdutoService api = ProdutoService();
  final CacheService cache = CacheService();

  int indexAtual = 0;
  List<Produto> produtos = [];
  Set<String> favoritos = {};
  bool carregando = true;
  String aviso = '';

  @override
  void initState() {
    super.initState();
    carregarProdutos();
  }

  Future<void> carregarProdutos() async {
    setState(() => carregando = true);

    try {
      final produtosSalvos = await cache.lerProdutos();
      final favoritosSalvos = await cache.lerFavoritos();
      if (!mounted) return;
      setState(() {
        produtos = produtosSalvos;
        favoritos = favoritosSalvos;
      });
    } catch (_) {
      // Um cache inválido não deve impedir a consulta online.
    }

    try {
      final lista = await api.buscarProdutos();
      await cache.salvarProdutos(lista);
      if (!mounted) return;
      setState(() {
        produtos = lista;
        aviso = '';
      });
    } catch (erro) {
      if (!mounted) return;
      setState(() {
        aviso = 'Não foi possível atualizar o cardápio. $erro';
      });
    } finally {
      if (mounted) setState(() => carregando = false);
    }
  }

  Future<void> salvarProduto(Produto produto) async {
    if (produto.id.isEmpty) {
      await api.cadastrarProduto(produto);
    } else {
      await api.atualizarProduto(produto);
    }
    await carregarProdutos();
  }

  Future<void> excluirProduto(String id) async {
    await api.excluirProduto(id);
    favoritos.remove(id);
    await cache.salvarFavoritos(favoritos);
    await carregarProdutos();
  }

  Future<void> mudarFavorito(String id) async {
    setState(() {
      if (favoritos.contains(id)) {
        favoritos.remove(id);
      } else {
        favoritos.add(id);
      }
    });
    await cache.salvarFavoritos(favoritos);
  }

  @override
  Widget build(BuildContext context) {
    final paginas = [
      TelaHome(
        produtos: produtos,
        carregando: carregando,
        onVerCardapio: () => setState(() => indexAtual = 1),
      ),
      TelaProdutos(
        produtos: produtos,
        favoritos: favoritos,
        carregando: carregando,
        aviso: aviso,
        onAtualizar: carregarProdutos,
        onSalvar: salvarProduto,
        onExcluir: excluirProduto,
        onFavoritar: mudarFavorito,
      ),
      const TelaRecados(),
      const TelaPerfil(),
    ];

    return Scaffold(
      body: IndexedStack(index: indexAtual, children: paginas),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: indexAtual,
        onTap: (novoIndex) => setState(() => indexAtual = novoIndex),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF70452E),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Início'),
          BottomNavigationBarItem(icon: Icon(Icons.coffee), label: 'Cardápio'),
          BottomNavigationBarItem(icon: Icon(Icons.note_alt_outlined), label: 'Recados'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }
}
