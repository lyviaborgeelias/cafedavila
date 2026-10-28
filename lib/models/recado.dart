class Recado {
  final String id;
  final String titulo;
  final String mensagem;

  const Recado({
    this.id = '',
    required this.titulo,
    required this.mensagem,
  });

  factory Recado.fromJson(String id, Map<String, dynamic> dados) {
    return Recado(
      id: id,
      titulo: (dados['titulo'] ?? '').toString(),
      mensagem: (dados['mensagem'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'titulo': titulo,
      'mensagem': mensagem,
    };
  }
}
