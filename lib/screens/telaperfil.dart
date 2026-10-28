import 'package:flutter/material.dart';
import 'package:cafe_da_vila/services/perfil_service.dart';

// Cores usadas nas outras telas do Cafe da Vila.
class _CoresPerfil {
  static const marrom = Color(0xFF70452E);
  static const marromEscuro = Color(0xFF4E3427);
  static const creme = Color(0xFFFFF9F2);
  static const bege = Color(0xFFF5E6D9);
  static const pessego = Color(0xFFFFF0E7);
  static const texto = Color(0xFF342922);
  static const secundario = Color(0xFF85756B);
  static const borda = Color(0xFFECDDD1);
}

class TelaPerfil extends StatefulWidget {
  const TelaPerfil({super.key});

  @override
  State<TelaPerfil> createState() => _TelaPerfilState();
}

class _TelaPerfilState extends State<TelaPerfil> {
  final formulario = GlobalKey<FormState>();
  final nomeDigitado = TextEditingController();
  final emailDigitado = TextEditingController();
  final PerfilService banco = PerfilService();

  bool carregando = true;
  bool salvando = false;
  String nomeSalvo = '';

  @override
  void initState() {
    super.initState();
    carregarDados();
  }

  Future<void> carregarDados() async {
    try {
      final nome = await banco.lerNome();
      final email = await banco.lerEmail();

      if (!mounted) return;
      nomeDigitado.text = nome;
      emailDigitado.text = email;
      nomeSalvo = nome.trim();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível ler os dados locais.')),
      );
    } finally {
      if (mounted) setState(() => carregando = false);
    }
  }

  Future<void> salvarDados() async {
    if (salvando || !formulario.currentState!.validate()) return;

    setState(() => salvando = true);

    try {
      final nome = nomeDigitado.text.trim();
      final email = emailDigitado.text.trim();
      await banco.salvar(nome, email);

      if (!mounted) return;
      setState(() => nomeSalvo = nome);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Seus dados foram salvos neste dispositivo!'),
          backgroundColor: _CoresPerfil.marrom,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Erro ao salvar os dados.')));
    } finally {
      if (mounted) setState(() => salvando = false);
    }
  }

  String get primeiroNome {
    if (nomeSalvo.isEmpty) return '';
    return nomeSalvo.split(RegExp(r'\s+')).first;
  }

  String get iniciais {
    final partes = nomeSalvo
        .trim()
        .split(RegExp(r'\s+'))
        .where((parte) => parte.isNotEmpty)
        .toList();

    if (partes.isEmpty) return '';
    if (partes.length == 1) return partes.first[0].toUpperCase();

    return '${partes.first[0]}${partes.last[0]}'.toUpperCase();
  }

  InputDecoration decorarCampo({
    required String titulo,
    required String dica,
    required IconData icone,
  }) {
    return InputDecoration(
      labelText: titulo,
      hintText: dica,
      prefixIcon: Icon(icone, color: _CoresPerfil.marrom),
      labelStyle: const TextStyle(color: _CoresPerfil.marromEscuro),
      hintStyle: const TextStyle(color: _CoresPerfil.secundario),
      filled: true,
      fillColor: _CoresPerfil.creme,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: _CoresPerfil.borda),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: _CoresPerfil.marrom, width: 1.7),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.7),
      ),
    );
  }

  Widget construirCabecalho() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _CoresPerfil.bege,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _CoresPerfil.borda),
      ),
      child: Row(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: _CoresPerfil.marrom,
              borderRadius: BorderRadius.circular(22),
            ),
            alignment: Alignment.center,
            child: iniciais.isEmpty
                ? const Icon(
                    Icons.person_rounded,
                    color: Colors.white,
                    size: 38,
                  )
                : Text(
                    iniciais,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  primeiroNome.isEmpty
                      ? 'Seu espaço pessoal'
                      : 'Olá, $primeiroNome!',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                    color: _CoresPerfil.texto,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Seus dados, do seu jeito.',
                  style: TextStyle(
                    fontSize: 13,
                    color: _CoresPerfil.secundario,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget construirFormulario() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _CoresPerfil.borda),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0C70452E),
            blurRadius: 18,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _CoresPerfil.pessego,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.badge_outlined,
                  color: _CoresPerfil.marrom,
                  size: 23,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Informações pessoais',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                        color: _CoresPerfil.texto,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Atualize seus dados abaixo',
                      style: TextStyle(
                        fontSize: 12,
                        color: _CoresPerfil.secundario,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 26),
          TextFormField(
            controller: nomeDigitado,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.name],
            decoration: decorarCampo(
              titulo: 'Nome completo',
              dica: 'Como podemos chamar você?',
              icone: Icons.person_outline_rounded,
            ),
            validator: (valor) => valor == null || valor.trim().isEmpty
                ? 'Digite seu nome'
                : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: emailDigitado,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            autofillHints: const [AutofillHints.email],
            decoration: decorarCampo(
              titulo: 'E-mail',
              dica: 'seuemail@exemplo.com',
              icone: Icons.mail_outline_rounded,
            ),
            validator: (valor) {
              final email = valor?.trim() ?? '';
              if (!email.contains('@') || !email.contains('.')) {
                return 'Digite um e-mail válido';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: FilledButton.icon(
              onPressed: salvando ? null : salvarDados,
              style: FilledButton.styleFrom(
                backgroundColor: _CoresPerfil.marrom,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              icon: salvando
                  ? const SizedBox(
                      width: 19,
                      height: 19,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.check_circle_outline_rounded, size: 21),
              label: Text(
                salvando ? 'Salvando dados...' : 'Salvar alterações',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget construirAvisoPrivacidade() {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: _CoresPerfil.pessego,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _CoresPerfil.borda),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.lock_outline_rounded, color: _CoresPerfil.marrom),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Privacidade em primeiro lugar',
                  style: TextStyle(
                    color: _CoresPerfil.marromEscuro,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Seu nome e e-mail ficam armazenados neste dispositivo. '
                  'Eles não são enviados à API de produtos.',
                  style: TextStyle(
                    color: _CoresPerfil.secundario,
                    height: 1.5,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    nomeDigitado.dispose();
    emailDigitado.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _CoresPerfil.creme,
      appBar: AppBar(title: const Text('Meu perfil')),
      body: SafeArea(
        child: carregando
            ? const Center(
                child: CircularProgressIndicator(color: _CoresPerfil.marrom),
              )
            : Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 620),
                  child: Form(
                    key: formulario,
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
                      children: [
                        construirCabecalho(),
                        const SizedBox(height: 20),
                        construirFormulario(),
                        const SizedBox(height: 18),
                        construirAvisoPrivacidade(),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
