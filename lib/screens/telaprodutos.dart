import 'package:flutter/material.dart';
import 'package:cafe_da_vila/components/card_produto.dart';
import 'package:cafe_da_vila/models/produto.dart';
import 'package:cafe_da_vila/screens/telaformulario.dart';

class TelaProdutos extends StatefulWidget {
  final List<Produto> produtos;
  final Set<String> favoritos;
  final bool carregando;
  final String aviso;
  final Future<void> Function() onAtualizar;
  final Future<void> Function(Produto) onSalvar;
  final Future<void> Function(String) onExcluir;
  final Future<void> Function(String) onFavoritar;

  const TelaProdutos({
    super.key,
    required this.produtos,
    required this.favoritos,
    required this.carregando,
    required this.aviso,
    required this.onAtualizar,
    required this.onSalvar,
    required this.onExcluir,
    required this.onFavoritar,
  });

  @override
  State<TelaProdutos> createState() => _TelaProdutosState();
}

class _TelaProdutosState extends State<TelaProdutos> {
  final pesquisaDigitada = TextEditingController();
  bool processando = false;
  bool somenteFavoritos = false;

  List<Produto> get produtosFiltrados {
    final pesquisa = pesquisaDigitada.text.trim().toLowerCase();
    return widget.produtos.where((produto) {
      final corresponde = produto.nome.toLowerCase().contains(pesquisa) ||
          produto.categoria.toLowerCase().contains(pesquisa);
      final favorito = !somenteFavoritos || widget.favoritos.contains(produto.id);
      return corresponde && favorito;
    }).toList();
  }

  void mostrarMensagem(String texto) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(texto)));
  }

  Future<void> abrirFormulario([Produto? produto]) async {
    if (processando) return;
    final novoProduto = await Navigator.push<Produto>(
      context,
      MaterialPageRoute(builder: (_) => TelaFormulario(produto: produto)),
    );

    if (!mounted || novoProduto == null) return;
    setState(() => processando = true);
    try {
      await widget.onSalvar(novoProduto);
      if (!mounted) return;
      mostrarMensagem(produto == null ? 'Produto cadastrado!' : 'Produto atualizado!');
    } catch (erro) {
      if (!mounted) return;
      mostrarMensagem('Não foi possível salvar: $erro');
    } finally {
      if (mounted) setState(() => processando = false);
    }
  }

  Future<void> confirmarExclusao(Produto produto) async {
    if (processando) return;
    final confirmou = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir produto?'),
        content: Text('Deseja excluir ${produto.nome}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (!mounted || confirmou != true) return;
    setState(() => processando = true);
    try {
      await widget.onExcluir(produto.id);
      if (!mounted) return;
      mostrarMensagem('Produto excluído!');
    } catch (erro) {
      if (!mounted) return;
      mostrarMensagem('Não foi possível excluir: $erro');
    } finally {
      if (mounted) setState(() => processando = false);
    }
  }

  @override
  void dispose() {
    pesquisaDigitada.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lista = produtosFiltrados;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nosso cardápio'),
        actions: [
          IconButton(
            onPressed: widget.carregando || processando ? null : widget.onAtualizar,
            icon: const Icon(Icons.refresh),
            tooltip: 'Atualizar cardápio',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: processando ? null : () => abrirFormulario(),
        icon: const Icon(Icons.add),
        label: const Text('Novo produto'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 100),
            children: [
              TextField(
                controller: pesquisaDigitada,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(
                  labelText: 'Pesquisar por nome ou categoria',
                  prefixIcon: Icon(Icons.search),
                ),
              ),
              const SizedBox(height: 8),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Mostrar apenas favoritos'),
                value: somenteFavoritos,
                onChanged: (valor) => setState(() => somenteFavoritos = valor),
              ),
              if (widget.carregando || processando)
                const LinearProgressIndicator(),
              if (widget.aviso.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    widget.aviso,
                    style: const TextStyle(color: Colors.deepOrange),
                  ),
                ),
              const SizedBox(height: 10),
              Text(
                '${lista.length} produtos encontrados',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              if (lista.isEmpty && !widget.carregando)
                const Padding(
                  padding: EdgeInsets.all(20),
                  child: Text('Nenhum produto encontrado.'),
                ),
              for (final produto in lista)
                CardProduto(
                  key: ValueKey(produto.id),
                  produto: produto,
                  favorito: widget.favoritos.contains(produto.id),
                  onFavoritar: produto.id.isEmpty
                      ? null
                      : () async {
                          try {
                            await widget.onFavoritar(produto.id);
                          } catch (_) {
                            if (mounted) mostrarMensagem('Erro ao salvar favorito.');
                          }
                        },
                  onEditar: produto.id.isEmpty || processando
                      ? null
                      : () => abrirFormulario(produto),
                  onExcluir: produto.id.isEmpty || processando
                      ? null
                      : () => confirmarExclusao(produto),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
