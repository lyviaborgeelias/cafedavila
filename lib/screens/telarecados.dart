import 'package:flutter/material.dart';
import 'package:cafe_da_vila/models/recado.dart';
import 'package:cafe_da_vila/services/recado_service.dart';

// Mesma identidade visual da Home do Café da Vila.
class _Cores {
  static const marrom = Color(0xFF70452E);
  static const marromClaro = Color(0xFF95674B);
  static const creme = Color(0xFFFFF9F2);
  static const pessego = Color(0xFFFFD9C8);
  static const bege = Color(0xFFF6E8DA);
  static const texto = Color(0xFF372B25);
  static const secundario = Color(0xFF89786D);
  static const borda = Color(0xFFEEDFD3);
}

class TelaRecados extends StatefulWidget {
  const TelaRecados({super.key});

  @override
  State<TelaRecados> createState() => _TelaRecadosState();
}

class _TelaRecadosState extends State<TelaRecados> {
  final RecadoService servico = RecadoService();
  List<Recado> recados = [];
  bool carregando = true;
  bool processando = false;
  String aviso = '';

  @override
  void initState() {
    super.initState();
    carregarRecados();
  }

  Future<void> carregarRecados() async {
    if (mounted) setState(() => carregando = true);

    try {
      final lista = await servico.buscarRecados();
      if (!mounted) return;
      setState(() {
        recados = lista;
        aviso = '';
      });
    } catch (erro) {
      if (!mounted) return;
      setState(() => aviso = 'Não foi possível carregar os recados: $erro');
    } finally {
      if (mounted) setState(() => carregando = false);
    }
  }

  void mostrarMensagem(String mensagem, {bool erro = false}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(mensagem),
          backgroundColor: erro ? const Color(0xFFAD4942) : _Cores.marrom,
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  InputDecoration decorarCampo({
    required String titulo,
    required String dica,
    required IconData icone,
  }) {
    return InputDecoration(
      labelText: titulo,
      hintText: dica,
      prefixIcon: Icon(icone, color: _Cores.marromClaro),
      filled: true,
      fillColor: Colors.white,
      labelStyle: const TextStyle(color: _Cores.marrom),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: _Cores.borda),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: _Cores.marrom, width: 1.6),
      ),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
    );
  }

  Future<Recado?> abrirFormulario([Recado? recado]) async {
    String titulo = recado?.titulo ?? '';
    String mensagem = recado?.mensagem ?? '';
    final chaveFormulario = GlobalKey<FormState>();
    final editando = recado != null;

    return showDialog<Recado>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        scrollable: true,
        backgroundColor: _Cores.creme,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        titlePadding: const EdgeInsets.fromLTRB(22, 22, 22, 0),
        contentPadding: const EdgeInsets.fromLTRB(22, 20, 22, 10),
        actionsPadding: const EdgeInsets.fromLTRB(16, 6, 16, 16),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(11),
              decoration: BoxDecoration(
                color: _Cores.bege,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                editando ? Icons.edit_note_rounded : Icons.note_add_outlined,
                color: _Cores.marrom,
                size: 26,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    editando ? 'Editar recado' : 'Novo recado',
                    style: const TextStyle(
                      color: _Cores.texto,
                      fontWeight: FontWeight.bold,
                      fontSize: 21,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    editando ? 'Atualize sua anotação' : 'Registre uma nova ideia',
                    style: const TextStyle(
                      color: _Cores.secundario,
                      fontSize: 13,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: 390,
          child: Form(
            key: chaveFormulario,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  initialValue: titulo,
                  maxLength: 60,
                  textCapitalization: TextCapitalization.sentences,
                  onSaved: (valor) => titulo = valor!.trim(),
                  decoration: decorarCampo(
                    titulo: 'Título',
                    dica: 'Ex.: Promoção da semana',
                    icone: Icons.title_rounded,
                  ),
                  validator: (valor) => valor == null || valor.trim().isEmpty
                      ? 'Digite um título.'
                      : null,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  initialValue: mensagem,
                  minLines: 3,
                  maxLines: 5,
                  maxLength: 240,
                  textCapitalization: TextCapitalization.sentences,
                  onSaved: (valor) => mensagem = valor!.trim(),
                  decoration: decorarCampo(
                    titulo: 'Mensagem',
                    dica: 'Escreva seu recado aqui...',
                    icone: Icons.subject_rounded,
                  ),
                  validator: (valor) => valor == null || valor.trim().isEmpty
                      ? 'Digite uma mensagem.'
                      : null,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            style: TextButton.styleFrom(foregroundColor: _Cores.secundario),
            child: const Text('Cancelar'),
          ),
          FilledButton.icon(
            onPressed: () {
              if (!chaveFormulario.currentState!.validate()) return;
              chaveFormulario.currentState!.save();
              Navigator.pop(
                dialogContext,
                Recado(
                  id: recado?.id ?? '',
                  titulo: titulo,
                  mensagem: mensagem,
                ),
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: _Cores.marrom,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.check_rounded, size: 18),
            label: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  Future<void> salvarRecado([Recado? anterior]) async {
    if (processando) return;
    final recado = await abrirFormulario(anterior);
    if (!mounted || recado == null) return;

    setState(() => processando = true);
    try {
      if (recado.id.isEmpty) {
        await servico.cadastrarRecado(recado);
      } else {
        await servico.atualizarRecado(recado);
      }
      await carregarRecados();
      if (!mounted) return;
      mostrarMensagem('Recado salvo com sucesso!');
    } catch (erro) {
      if (mounted) mostrarMensagem('Erro ao salvar: $erro', erro: true);
    } finally {
      if (mounted) setState(() => processando = false);
    }
  }

  Future<void> excluirRecado(Recado recado) async {
    if (processando) return;

    final confirmou = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: _Cores.creme,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: const Row(
          children: [
            Icon(Icons.delete_outline_rounded, color: Color(0xFFAD4942)),
            SizedBox(width: 10),
            Expanded(child: Text('Excluir recado?')),
          ],
        ),
        content: Text('Deseja excluir "${recado.titulo}"? Essa ação não pode ser desfeita.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFAD4942),
              foregroundColor: Colors.white,
            ),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (!mounted || confirmou != true) return;

    setState(() => processando = true);
    try {
      await servico.excluirRecado(recado.id);
      await carregarRecados();
      if (mounted) mostrarMensagem('Recado excluído.');
    } catch (erro) {
      if (mounted) mostrarMensagem('Erro ao excluir: $erro', erro: true);
    } finally {
      if (mounted) setState(() => processando = false);
    }
  }

  Widget construirTituloLista() {
    final quantidade = recados.length;
    return Row(
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Meu mural',
                style: TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                  color: _Cores.texto,
                ),
              ),
              SizedBox(height: 5),
              Text(
                'Suas anotações, sempre à mão.',
                style: TextStyle(fontSize: 13, color: _Cores.secundario),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          decoration: BoxDecoration(
            color: _Cores.bege,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Text(
            '$quantidade ${quantidade == 1 ? 'recado' : 'recados'}',
            style: const TextStyle(
              color: _Cores.marrom,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget construirEstadoVazio() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 34, 24, 34),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _Cores.borda),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: _Cores.bege,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.edit_note_rounded,
              size: 44,
              color: _Cores.marrom,
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'Seu mural está em branco',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: _Cores.texto,
            ),
          ),
          const SizedBox(height: 9),
          const Text(
            'Que tal começar com uma ideia?\nSeu primeiro recado fica guardado aqui.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              color: _Cores.secundario,
            ),
          ),
          const SizedBox(height: 22),
          FilledButton.icon(
            onPressed: processando ? null : () => salvarRecado(),
            icon: const Icon(Icons.add, size: 20),
            label: const Text('Escrever primeiro recado'),
            style: FilledButton.styleFrom(
              backgroundColor: _Cores.marrom,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 19, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget construirCardRecado(Recado recado, int indice) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _Cores.borda),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A70452E),
            blurRadius: 16,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(11),
                decoration: BoxDecoration(
                  color: _Cores.bege,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Icon(
                  Icons.sticky_note_2_outlined,
                  color: _Cores.marrom,
                  size: 25,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ANOTAÇÃO ${indice + 1}',
                      style: const TextStyle(
                        fontSize: 10,
                        letterSpacing: 1.4,
                        fontWeight: FontWeight.bold,
                        color: _Cores.marromClaro,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      recado.titulo,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: _Cores.texto,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            recado.mensagem,
            style: const TextStyle(
              color: _Cores.secundario,
              fontSize: 14,
              height: 1.55,
            ),
          ),
          const SizedBox(height: 18),
          const Divider(color: _Cores.borda, height: 1),
          const SizedBox(height: 7),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'NO SEU MURAL',
                  style: TextStyle(
                    color: _Cores.secundario,
                    letterSpacing: 1,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: processando ? null : () => salvarRecado(recado),
                icon: const Icon(Icons.edit_outlined, size: 18),
                label: const Text('Editar'),
                style: TextButton.styleFrom(
                  foregroundColor: _Cores.marrom,
                  padding: const EdgeInsets.symmetric(horizontal: 7),
                ),
              ),
              IconButton(
                tooltip: 'Excluir recado',
                onPressed: processando ? null : () => excluirRecado(recado),
                icon: const Icon(Icons.delete_outline_rounded),
                color: const Color(0xFFAD4942),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget construirErro() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEAE5),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, color: Color(0xFFAD4942)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(aviso, style: const TextStyle(color: _Cores.texto)),
          ),
          IconButton(
            tooltip: 'Tentar novamente',
            onPressed: processando ? null : carregarRecados,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _Cores.creme,
      appBar: AppBar(
        title: const Text('Recados da cafeteria'),
        actions: [
          IconButton(
            tooltip: 'Atualizar recados',
            onPressed: carregando || processando ? null : carregarRecados,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: processando ? null : () => salvarRecado(),
        backgroundColor: _Cores.pessego,
        foregroundColor: _Cores.marrom,
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Novo recado',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: RefreshIndicator(
        color: _Cores.marrom,
        onRefresh: carregarRecados,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 110),
              children: [
                construirTituloLista(),
                const SizedBox(height: 16),
                if (carregando || processando)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 16),
                    child: LinearProgressIndicator(
                      color: _Cores.marrom,
                      backgroundColor: _Cores.bege,
                      minHeight: 3,
                    ),
                  ),
                if (aviso.isNotEmpty) ...[
                  construirErro(),
                  const SizedBox(height: 14),
                ],
                if (carregando && recados.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(35),
                    child: Center(
                      child: CircularProgressIndicator(color: _Cores.marrom),
                    ),
                  )
                else if (recados.isEmpty && aviso.isEmpty)
                  construirEstadoVazio()
                else
                  for (var i = 0; i < recados.length; i++)
                    construirCardRecado(recados[i], i),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
