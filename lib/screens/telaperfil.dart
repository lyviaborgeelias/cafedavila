import 'package:flutter/material.dart';
import 'package:cafe_da_vila/services/perfil_service.dart';

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

  @override
  void initState() {
    super.initState();
    carregarDados();
  }

  Future<void> carregarDados() async {
    try {
      nomeDigitado.text = await banco.lerNome();
      emailDigitado.text = await banco.lerEmail();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Não foi possível ler os dados locais.')),
        );
      }
    } finally {
      if (mounted) setState(() => carregando = false);
    }
  }

  Future<void> salvarDados() async {
    if (!formulario.currentState!.validate()) return;
    setState(() => salvando = true);
    try {
      await banco.salvar(nomeDigitado.text.trim(), emailDigitado.text.trim());
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Dados salvos no dispositivo!')),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao salvar os dados.')),
      );
    } finally {
      if (mounted) setState(() => salvando = false);
    }
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
      appBar: AppBar(title: const Text('Meu perfil')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 650),
          child: carregando
              ? const CircularProgressIndicator()
              : Form(
                  key: formulario,
                  child: ListView(
                    padding: const EdgeInsets.all(22),
                    children: [
                      const CircleAvatar(
                        radius: 43,
                        backgroundColor: Color(0xFFF3E4D5),
                        child: Icon(
                          Icons.person,
                          size: 45,
                          color: Color(0xFF70452E),
                        ),
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'Seus dados pessoais',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Nome e e-mail são armazenados apenas neste dispositivo.',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 25),
                      TextFormField(
                        controller: nomeDigitado,
                        decoration: const InputDecoration(labelText: 'Nome'),
                        validator: (valor) => valor == null || valor.trim().isEmpty
                            ? 'Digite seu nome'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: emailDigitado,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(labelText: 'E-mail'),
                        validator: (valor) {
                          final email = valor?.trim() ?? '';
                          if (!email.contains('@') || !email.contains('.')) {
                            return 'Digite um e-mail válido';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      FilledButton.icon(
                        onPressed: salvando ? null : salvarDados,
                        icon: const Icon(Icons.save),
                        label: Text(salvando ? 'Salvando...' : 'Salvar dados'),
                      ),
                      const SizedBox(height: 15),
                      const Text(
                        'Informações pessoais não são enviadas à API de produtos.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
