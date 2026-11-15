/// "ID do cliente da Web" do provedor Google no Firebase Authentication
/// (Authentication > Método de login > Google > Configuração do SDK da Web).
///
/// Não é segredo: o navegador o envia ao Google em todo login. No web o
/// firebase_ui faz o login pelo popup do Firebase, então ele só é usado de
/// fato em outras plataformas. Pode ser trocado na compilação com
/// `--dart-define=GOOGLE_CLIENT_ID=...`.
const googleWebClientId = String.fromEnvironment(
  'GOOGLE_CLIENT_ID',
  defaultValue: '947708519214-j1krpdaqhe4mhiqrmn5i9v3e71akkbm5.apps.googleusercontent.com',
);
