import 'dart:convert';

import 'package:http/http.dart' as http;

class ClimaService {
  // Localidade ilustrativa da cafeteria: Campinas (SP).
  static const endereco =
      'https://api.open-meteo.com/v1/forecast?latitude=-22.91&longitude=-47.06&current=temperature_2m';

  Future<double> buscarTemperatura() async {
    final resposta = await http.get(
      Uri.parse(endereco),
    ).timeout(const Duration(seconds: 12));

    if (resposta.statusCode != 200) {
      throw Exception('Clima indisponível.');
    }

    final dados = jsonDecode(utf8.decode(resposta.bodyBytes)) as Map<String, dynamic>;
    final atual = dados['current'] as Map<String, dynamic>;
    return (atual['temperature_2m'] as num).toDouble();
  }
}
