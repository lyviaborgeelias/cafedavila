# ☕ Café da Vila

Aplicativo de cafeteria desenvolvido em **Flutter e Dart**, com interface responsiva e integração ao **Firebase**.

O aplicativo permite visualizar produtos, gerenciar o cardápio, adicionar favoritos, cadastrar recados e salvar informações do perfil.

## 🛠️ Tecnologias utilizadas

- **Flutter e Dart** — desenvolvimento do aplicativo
- **Cloud Firestore** — armazenamento dos produtos
- **Firebase Authentication** — autenticação de usuários
- **Firebase Realtime Database** — integração HTTP (GET, POST, PUT e DELETE)
- **Armazenamento local** — favoritos e dados do perfil

## 🚀 Como executar o projeto

### 1. Pré-requisitos

- Flutter SDK instalado
- VS Code ou Android Studio
- Google Chrome para execução Web
- Emulador Android configurado
- Firebase configurado no projeto

### 2. Instalar as dependências

Abra o terminal na pasta do projeto e execute:

```bash
flutter pub get
```

### 🌐 Executar na Web

Para abrir o aplicativo no Google Chrome:

```bash
flutter run -d chrome --dart-define=FIREBASE_DB_URL=https://cafedavila-2fc46-default-rtdb.firebaseio.com
```

O aplicativo abrirá automaticamente no navegador.

### 📱 Executar no Android Studio

1. Abra o Android Studio.
2. Acesse **Device Manager**.
3. Inicie um emulador Android, como o Pixel 9.
4. No terminal do VS Code, verifique os dispositivos disponíveis:

```bash
flutter devices
```

Execute o aplicativo:

```bash
flutter run -d emulator-5554 --dart-define=FIREBASE_DB_URL=https://cafedavila-2fc46-default-rtdb.firebaseio.com
```

**Observação:** substitua `emulator-5554` pelo ID do seu dispositivo, caso seja diferente.

## 🧪 Verificação do projeto

Para verificar possíveis problemas no código:

```bash
flutter analyze
```

Para executar os testes:

```bash
flutter test
```

## 📦 Gerar APK

Execute:

```bash
flutter build apk --release --dart-define=FIREBASE_DB_URL=https://cafedavila-2fc46-default-rtdb.firebaseio.com
```

O arquivo será gerado em:

```text
build/app/outputs/flutter-apk/app-release.apk
```

## 📂 Funcionalidades

- **Início:** apresentação da cafeteria e produtos em destaque.
- **Cardápio:** consulta, cadastro, edição, exclusão e favoritos.
- **Recados:** gerenciamento de anotações pelo Firebase Realtime Database.
- **Perfil:** armazenamento local de nome e e-mail.

**Observação:** é necessária uma conexão com a internet e a configuração correta do Firebase para acessar os dados online.

---

**Projeto acadêmico — Café da Vila** ☕
