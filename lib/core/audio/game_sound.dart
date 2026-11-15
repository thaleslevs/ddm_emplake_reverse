/// Efeitos sonoros do jogo, sintetizados em código (a entrega não pode ter
/// arquivos de áudio). Cada efeito é uma sequência de notas curtas com timbre
/// de 8 bits, no clima do visual pixel.
enum GameSound {
  /// Arpejo subindo (dó-mi-sol-dó).
  correct([
    Note(523.25, start: 0, duration: 0.12),
    Note(659.25, start: 0.08, duration: 0.12),
    Note(783.99, start: 0.16, duration: 0.12),
    Note(1046.5, start: 0.24, duration: 0.28),
  ]),

  /// Duas notas graves descendo.
  wrong([
    Note(311.13, start: 0, duration: 0.16, wave: Wave.sawtooth, gain: 0.06),
    Note(233.08, start: 0.15, duration: 0.3, wave: Wave.sawtooth, gain: 0.06),
  ]),

  /// "Blip" curto ao soltar uma peça na expressão.
  place([Note(880, start: 0, duration: 0.05, gain: 0.05)]),

  /// Nota que escorrega para baixo ao pular o número.
  skip([Note(660, start: 0, duration: 0.18, slideTo: 330, wave: Wave.triangle, gain: 0.1)]);

  const GameSound(this.notes);
  final List<Note> notes;
}

enum Wave { square, triangle, sawtooth, sine }

class Note {
  const Note(
    this.frequency, {
    required this.start,
    required this.duration,
    this.wave = Wave.square,
    this.gain = 0.07,
    this.slideTo,
  });

  /// Frequência em Hz.
  final double frequency;

  /// Início e duração, em segundos, a partir do começo do efeito.
  final double start;
  final double duration;
  final Wave wave;

  /// Volume (0 a 1). Baixo de propósito: onda quadrada é estridente.
  final double gain;

  /// Se definido, a frequência desliza até este valor durante a nota.
  final double? slideTo;
}
