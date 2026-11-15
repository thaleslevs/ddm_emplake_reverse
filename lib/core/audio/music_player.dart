// No navegador toca com a Web Audio API; fora dele (testes, outras
// plataformas) fica em silêncio.
export 'music_player_stub.dart' if (dart.library.js_interop) 'music_player_web.dart';
