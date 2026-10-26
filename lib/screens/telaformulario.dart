import 'package:flutter/material.dart';
import 'package:cafe_da_vila/models/produto.dart';

class TelaFormulario extends StatefulWidget {
  final Produto? produto;

  const TelaFormulario({super.key, this.produto});

  @override
  State<TelaFormulario> createState() => _TelaFormularioState();
}

class _TelaFormularioState extends State<TelaFormulario> {
  final formulario = GlobalKey<FormState>();
  final nomeDigitado = TextEditingController();
  final descricaoDigitada = TextEditingController();
  final precoDigitado = TextEditingController();
  final descontoDigitado = TextEditingController();
  String categoria = 'Café';

  final categorias = ['Café', 'Bebida', 'Doce', 'Salgado'];

  @override
  void initState() {
    super.initState();
    final produto = widget.produto;
    if (produto != null) {
      nomeDigitado.text = produto.nome;
      descricaoDigitada.text = produto.descricao;
      precoDigitado.text = produto.preco.toStringAsFixed(2);
      categoria = produto.categoria;
      descontoDigitado.text = produto is ProdutoPromocional
          ? produto.desconto.toStringAsFixed(0)
          : '0';
    } else {
      descontoDigitado.text = '0';
    }
  }

  double? converterNumero(String texto) {
    return double.tryParse(texto.trim().replaceAll(',', '.'));
  }

  void salvarDados() {
    if (!formulario.currentState!.validate()) return;

    final preco = converterNumero(precoDigitado.text)!;
    final desconto = converterNumero(descontoDigitado.text)!;
    final id = widget.produto?.id ?? '';

    final Produto produto = desconto > 0
        ? ProdutoPromocional(
            id: id,
            nome: nomeDigitado.text.trim(),
            descricao: descricaoDigitada.text.trim(),
            categoria: categoria,
            preco: preco,
            desconto: desconto,
          )
        : Produto(
            id: id,
            nome: nomeDigitado.text.trim(),
            descricao: descricaoDigitada.text.trim(),
            categoria: categoria,
            preco: preco,
          );

    Navigator.pop(context, produto);
  }

  @override
  void dispose() {
    nomeDigitado.dispose();
    descricaoDigitada.dispose();
    precoDigitado.dispose();
    descontoDigitado.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final editando = widget.produto != null;

    return Scaffold(
      appBar: AppBar(title: Text(editando ? 'Editar produto' : 'Novo produto')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 650),
          child: Form(
            key: formulario,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                TextFormField(
                  controller: nomeDigitado,
                  decoration: const InputDecoration(labelText: 'Nome do produto'),
                  validator: (valor) => valor == null || valor.trim().isEmpty
                      ? 'Digite o nome'
                      : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: descricaoDigitada,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: 'Descrição'),
                  validator: (valor) => valor == null || valor.trim().isEmpty
                      ? 'Digite a descrição'
                      : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: categoria,
                  decoration: const InputDecoration(labelText: 'Categoria'),
                  items: categorias
                      .map((item) => DropdownMenuItem(value: item, child: Text(item)))
                      .toList(),
                  onChanged: (valor) {
                    if (valor != null) setState(() => categoria = valor);
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: precoDigitado,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Preço em reais'),
                  validator: (valor) {
                    final preco = converterNumero(valor ?? '');
                    if (preco == null || preco <= 0 || !preco.isFinite) {
                      return 'Digite um preço válido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: descontoDigitado,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Desconto em % (0 para nenhum)',
                  ),
                  validator: (valor) {
                    final desconto = converterNumero(valor ?? '');
                    if (desconto == null || desconto < 0 || desconto > 90 || !desconto.isFinite) {
                      return 'Informe um desconto entre 0 e 90';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: salvarDados,
                  icon: const Icon(Icons.save),
                  label: Text(editando ? 'Salvar alterações' : 'Cadastrar produto'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
