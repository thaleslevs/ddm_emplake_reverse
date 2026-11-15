// No navegador usa a Web Audio API; fora dele (testes, outras plataformas)
// não toca nada.
export 'sound_player_stub.dart' if (dart.library.js_interop) 'sound_player_web.dart';
