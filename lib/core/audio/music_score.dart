import 'dart:math' as math;

/// Trilha original do Emplake: lenta, em lá menor, com acordes que "ondulam"
/// (o tocador aplica um vibrato lento, como fita velha), baixo marcado e uma
/// melodia simples. Composta aqui, nota por nota, e sintetizada em tempo real
/// (a entrega não pode ter arquivos de áudio).
///
/// Cada compasso tem 8 passos de colcheia. O loop tem 8 compassos; a cada três
/// voltas, uma fica só com acordes, baixo e percussão, para respirar.
abstract final class MusicScore {
  static const bpm = 84;

  static const stepsPerBar = 8;

  /// Duração de um passo (colcheia), em segundos.
  static double get stepSeconds => 60 / bpm / 2;

  static const bars = <MusicBar>[
    // Am9
    MusicBar(
      chord: [57, 60, 64, 67, 71],
      bassRoot: 45,
      melody: [(0, 76, 2), (2, 74, 1), (3, 72, 1), (4, 69, 4)],
    ),
    // Fmaj7
    MusicBar(
      chord: [53, 57, 60, 64],
      bassRoot: 41,
      melody: [(0, 72, 2), (2, 69, 1), (3, 67, 1), (4, 69, 4)],
    ),
    // Cmaj7 com G no baixo
    MusicBar(
      chord: [55, 60, 64, 71],
      bassRoot: 43,
      melody: [(0, 76, 2), (2, 79, 2), (4, 76, 2), (6, 74, 2)],
    ),
    // E7
    MusicBar(
      chord: [52, 56, 59, 62],
      bassRoot: 40,
      melody: [(0, 71, 3), (3, 68, 1), (4, 71, 2), (6, 74, 2)],
    ),
    // Dm9
    MusicBar(
      chord: [53, 57, 60, 64],
      bassRoot: 38,
      melody: [(0, 77, 2), (2, 76, 1), (3, 74, 1), (4, 72, 2), (6, 69, 2)],
    ),
    // Am com C no baixo
    MusicBar(
      chord: [52, 57, 60, 64],
      bassRoot: 48,
      melody: [(0, 72, 1), (1, 74, 1), (2, 76, 2), (4, 81, 4)],
    ),
    // Bm7(b5)
    MusicBar(
      chord: [57, 62, 65, 71],
      bassRoot: 47,
      melody: [(0, 77, 2), (2, 74, 2), (4, 71, 2), (6, 69, 2)],
    ),
    // E7, voltando para Am
    MusicBar(
      chord: [52, 56, 59, 62],
      bassRoot: 40,
      melody: [(0, 68, 2), (2, 71, 2), (4, 76, 4)],
    ),
  ];

  /// Linha de baixo de cada compasso: (passo, semitons acima da fundamental,
  /// duração em passos). Fundamental, quinta, oitava e sétima menor.
  static const bassPattern = [(0, 0, 3), (3, 7, 1), (4, 12, 2), (6, 10, 2)];

  /// Frequência em Hz de uma nota MIDI (69 = lá 440).
  static double frequency(int midi) => 440 * math.pow(2, (midi - 69) / 12).toDouble();
}

class MusicBar {
  const MusicBar({required this.chord, required this.bassRoot, required this.melody});

  /// Notas MIDI do acorde do teclado.
  final List<int> chord;

  /// Fundamental do baixo (MIDI).
  final int bassRoot;

  /// Melodia: (passo, nota MIDI, duração em passos).
  final List<(int, int, int)> melody;
}
