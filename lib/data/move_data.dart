enum GestureCode { R, D, DR, RD, DRD, CIRCLE, L, U }

class Buff {
  final String label;
  final int turns;
  const Buff(this.label, this.turns);
}

class MoveData {
  final String id;
  final String name;
  final String nameEn;
  final int diff;
  final String stars;
  final List<GestureCode> command;
  final List<String> cmdDisplay;
  final int attack;
  final Buff? buff;
  final String desc;
  final List<String> frames; // asset paths
  final String? iconAsset;   // dedicated icon PNG (optional)

  const MoveData({
    required this.id,
    required this.name,
    required this.nameEn,
    required this.diff,
    required this.stars,
    required this.command,
    required this.cmdDisplay,
    required this.attack,
    this.buff,
    required this.desc,
    required this.frames,
    this.iconAsset,
  });

  /// Dedicated icon if available, otherwise first animation frame.
  String get icon => iconAsset ?? frames[0];
}

const List<MoveData> kMoves = [
  // ── 1★ ──────────────────────────────────────────
  MoveData(
    id: 'toprock',
    name: '베이직 탑락', nameEn: 'Basic Toprock',
    diff: 1, stars: '★☆☆☆☆',
    command: [GestureCode.D], cmdDisplay: ['ㅣ'],
    attack: 10, desc: '리듬에 맞춰 팔과 다리를 교차하는 기초 서기 스텝.',
    frames: [
      'assets/images/animations/toprock/bboy_toprock_f1_1772667465651.png',
      'assets/images/animations/toprock/bboy_toprock_f2_1772667478141.png',
      'assets/images/animations/toprock/bboy_toprock_f3_1772667494120.png',
      'assets/images/animations/toprock/bboy_toprock_f4_1772667507494.png',
      'assets/images/animations/toprock/bboy_toprock_f5_1772667523769.png',
      'assets/images/animations/toprock/bboy_toprock_f6_1772667542218.png',
    ],
  ),
  MoveData(
    id: 'mechanic_twostep',
    name: '메카닉 투스텝', nameEn: 'Mechanic Two-Step',
    diff: 1, stars: '★☆☆☆☆',
    command: [GestureCode.R], cmdDisplay: ['ㅡ'],
    attack: 10, desc: '유압 관절로 좌우를 가볍게 딛는 기초 스텝.',
    frames: [
      'assets/images/animations/mechanic_twostep/bboy_mechanic_twostep_f1.png',
      'assets/images/animations/mechanic_twostep/bboy_mechanic_twostep_f2.png',
      'assets/images/animations/mechanic_twostep/bboy_mechanic_twostep_f3.png',
      'assets/images/animations/mechanic_twostep/bboy_mechanic_twostep_f4.png',
      'assets/images/animations/mechanic_twostep/bboy_mechanic_twostep_f5.png',
      'assets/images/animations/mechanic_twostep/bboy_mechanic_twostep_f6.png',
    ],
  ),
  MoveData(
    id: 'dataswip_toplock',
    name: '데이터 스윕 탑락', nameEn: 'Data Sweep Toprock',
    diff: 1, stars: '★☆☆☆☆',
    command: [GestureCode.DR], cmdDisplay: ['ㄴ'],
    attack: 12, desc: '팔을 교차할 때 기계 팔에서 스캔 레이저가 바닥을 훑는다.',
    iconAsset: 'assets/images/animations/dataswip_toplock/dataswip_toplock.png',
    frames: [
      'assets/images/animations/dataswip_toplock/bboy_dataswip_toplock_f1.png',
      'assets/images/animations/dataswip_toplock/bboy_dataswip_toplock_f2.png',
      'assets/images/animations/dataswip_toplock/bboy_dataswip_toplock_f3.png',
      'assets/images/animations/dataswip_toplock/bboy_dataswip_toplock_f4.png',
      'assets/images/animations/dataswip_toplock/bboy_dataswip_toplock_f5.png',
      'assets/images/animations/dataswip_toplock/bboy_dataswip_toplock_f6.png',
    ],
  ),
  // ── 2★ ──────────────────────────────────────────
  MoveData(
    id: 'footwork',
    name: '베이직 풋워크', nameEn: 'Basic Footwork',
    diff: 2, stars: '★★☆☆☆',
    command: [GestureCode.DR, GestureCode.R], cmdDisplay: ['ㄴ', 'ㅡ'],
    attack: 22, desc: '바닥에 손을 짚고 다리를 빠르게 회전시키는 기초 스텝.',
    iconAsset: 'assets/images/animations/footwork/bboy_footwork_f3_1772667618284.png',
    frames: [
      'assets/images/animations/footwork/bboy_footwork_f1_1772667590331.png',
      'assets/images/animations/footwork/bboy_footwork_f2_1772667604426.png',
      'assets/images/animations/footwork/bboy_footwork_f3_1772667618284.png',
      'assets/images/animations/footwork/bboy_footwork_f4_1772667631937.png',
      'assets/images/animations/footwork/bboy_footwork_f5_1772667647180.png',
      'assets/images/animations/footwork/bboy_footwork_f6_1772667660198.png',
    ],
  ),
  MoveData(
    id: 'baby_freeze',
    name: '베이비 프리즈', nameEn: 'Baby Freeze',
    diff: 2, stars: '★★☆☆☆',
    command: [GestureCode.RD], cmdDisplay: ['ㄱ'],
    attack: 20, buff: Buff('DEF +5', 1),
    desc: '팔꿈치를 옆구리에 고정하고 공중에서 멈추는 기초 프리즈.',
    frames: [
      'assets/images/animations/baby_freeze/bboy_freeze_f1_1772667724774.png',
      'assets/images/animations/baby_freeze/bboy_freeze_f2_1772667740068.png',
      'assets/images/animations/baby_freeze/bboy_freeze_f3_1772667757810.png',
      'assets/images/animations/baby_freeze/bboy_freeze_f4_1772667771184.png',
      'assets/images/animations/baby_freeze/bboy_freeze_f5.png',
      'assets/images/animations/baby_freeze/bboy_freeze_f6.png',
    ],
  ),
  MoveData(
    id: 'glitch_wave',
    name: '글리치 웨이브', nameEn: 'Glitch Wave',
    diff: 2, stars: '★★☆☆☆',
    command: [GestureCode.DR, GestureCode.RD], cmdDisplay: ['ㄴ', 'ㄱ'],
    attack: 28, desc: '웨이브 도중 시스템 오류처럼 기계적으로 끊기는 효과.',
    iconAsset: 'assets/images/animations/glitch_wave/glitch_wave.png',
    frames: [
      'assets/images/animations/glitch_wave/bboy_glitch_wave_f1.png',
      'assets/images/animations/glitch_wave/bboy_glitch_wave_f2.png',
      'assets/images/animations/glitch_wave/bboy_glitch_wave_f3.png',
      'assets/images/animations/glitch_wave/bboy_glitch_wave_f4.png',
      'assets/images/animations/glitch_wave/bboy_glitch_wave_f5.png',
      'assets/images/animations/glitch_wave/bboy_glitch_wave_f6.png',
    ],
  ),
  // ── 3★ ──────────────────────────────────────────
  MoveData(
    id: 'hologram_sixstep',
    name: '홀로그램 식스스텝', nameEn: 'Hologram Six-Step',
    diff: 3, stars: '★★★☆☆',
    command: [GestureCode.DRD], cmdDisplay: ['ㄹ'],
    attack: 45, desc: '발이 닿는 지점에 육각형 홀로그램 패널이 나타났다 사라진다.',
    iconAsset: 'assets/images/animations/hologram_sixstep/hologram_sixstep.png',
    frames: [
      'assets/images/animations/hologram_sixstep/bboy_hologram_sixstep_f1.png',
      'assets/images/animations/hologram_sixstep/bboy_hologram_sixstep_f2.png',
      'assets/images/animations/hologram_sixstep/bboy_hologram_sixstep_f3.png',
      'assets/images/animations/hologram_sixstep/bboy_hologram_sixstep_f4.png',
      'assets/images/animations/hologram_sixstep/bboy_hologram_sixstep_f5.png',
      'assets/images/animations/hologram_sixstep/bboy_hologram_sixstep_f6.png',
    ],
  ),
  MoveData(
    id: 'booster_swipe',
    name: '부스터 스와이프', nameEn: 'Booster Swipe',
    diff: 3, stars: '★★★☆☆',
    command: [GestureCode.RD, GestureCode.DR], cmdDisplay: ['ㄱ', 'ㄴ'],
    attack: 50, buff: Buff('SPD +10', 1),
    desc: '종아리 부스터에서 화염이 분사되며 역동적인 체공을 연출한다.',
    iconAsset: 'assets/images/animations/booster_swipe/booster_swipe.png',
    frames: [
      'assets/images/animations/booster_swipe/bboy_booster_swipe_f1.png',
      'assets/images/animations/booster_swipe/bboy_booster_swipe_f2.png',
      'assets/images/animations/booster_swipe/bboy_booster_swipe_f3.png',
      'assets/images/animations/booster_swipe/bboy_booster_swipe_f4.png',
      'assets/images/animations/booster_swipe/bboy_booster_swipe_f5.png',
      'assets/images/animations/booster_swipe/bboy_booster_swipe_f6.png',
    ],
  ),
  MoveData(
    id: 'nano_flux',
    name: '나노 플럭스', nameEn: 'Nano-Flux',
    diff: 3, stars: '★★★☆☆',
    command: [GestureCode.RD, GestureCode.R], cmdDisplay: ['ㄱ', 'ㅡ'],
    attack: 48, desc: "미세 글리치와 함께 관절이 튀다 '베이비 프리즈' 자세로 정지.",
    iconAsset: 'assets/images/animations/nano_flux/nano_flux.png',
    frames: [
      'assets/images/animations/nano_flux/bboy_nano_flux_f1.png',
      'assets/images/animations/nano_flux/bboy_nano_flux_f2.png',
      'assets/images/animations/nano_flux/bboy_nano_flux_f3.png',
      'assets/images/animations/nano_flux/bboy_nano_flux_f4.png',
      'assets/images/animations/nano_flux/bboy_nano_flux_f5.png',
      'assets/images/animations/nano_flux/bboy_nano_flux_f6.png',
    ],
  ),
  MoveData(
    id: 'electric_flare',
    name: '일렉트릭 플레어', nameEn: 'Electric Flare',
    diff: 3, stars: '★★★☆☆',
    command: [GestureCode.DR, GestureCode.D, GestureCode.RD],
    cmdDisplay: ['ㄴ', 'ㅣ', 'ㄱ'],
    attack: 55, desc: '다리를 V자로 회전하며 전기 스파크 링이 형성된다.',
    iconAsset: 'assets/images/animations/electric_flare/electric_flare.png',
    frames: [
      'assets/images/animations/electric_flare/bboy_electric_flare_f1.png',
      'assets/images/animations/electric_flare/bboy_electric_flare_f2.png',
      'assets/images/animations/electric_flare/bboy_electric_flare_f3.png',
      'assets/images/animations/electric_flare/bboy_electric_flare_f4.png',
      'assets/images/animations/electric_flare/bboy_electric_flare_f5.png',
      'assets/images/animations/electric_flare/bboy_electric_flare_f6.png',
    ],
  ),
  // ── 4★ ──────────────────────────────────────────
  MoveData(
    id: 'flare',
    name: '베이직 플레어', nameEn: 'Basic Flare',
    diff: 4, stars: '★★★★☆',
    command: [GestureCode.DRD, GestureCode.R], cmdDisplay: ['ㄹ', 'ㅡ'],
    attack: 80, desc: '양손으로 바닥을 짚고 다리를 원형으로 크게 회전하는 기술.',
    frames: [
      'assets/images/animations/flare/bboy_flare_f1_1772700507824.png',
      'assets/images/animations/flare/bboy_flare_f2_1772700524737.png',
      'assets/images/animations/flare/bboy_flare_f3.png',
      'assets/images/animations/flare/bboy_flare_f4_1772700549019.png',
      'assets/images/animations/flare/bboy_flare_f5_1772700563209.png',
      'assets/images/animations/flare/bboy_flare_f6_1772700580384.png',
    ],
  ),
  MoveData(
    id: 'headspin',
    name: '헤드스핀', nameEn: 'Headspin',
    diff: 4, stars: '★★★★☆',
    command: [GestureCode.CIRCLE], cmdDisplay: ['○'],
    attack: 85, buff: Buff('ATK +15', 1),
    desc: '머리를 지축으로 전신을 수직 회전. 보조 관절로 속도 극대화.',
    frames: [
      'assets/images/animations/headspin/bboy_headspin_f1_1772688488978.png',
      'assets/images/animations/headspin/bboy_headspin_f2_1772688520719.png',
      'assets/images/animations/headspin/bboy_headspin_f3_1772688536161.png',
      'assets/images/animations/headspin/bboy_headspin_f4_1772688550943.png',
      'assets/images/animations/headspin/bboy_headspin_f5_1772688563852.png',
      'assets/images/animations/headspin/bboy_headspin_f6_1772688577578.png',
    ],
  ),
  MoveData(
    id: 'plazma_spin',
    name: '플라즈마 스핀', nameEn: 'Plasma Spin',
    diff: 4, stars: '★★★★☆',
    command: [GestureCode.CIRCLE, GestureCode.D], cmdDisplay: ['○', 'ㅣ'],
    attack: 90, desc: '한 팔로 지탱하며 수평 회전. 발끝에 에너지 잔상 궤적이 남는다.',
    iconAsset: 'assets/images/animations/plazma_spin/plazma_spin.png',
    frames: [
      'assets/images/animations/plazma_spin/bboy_plazma_spin_f1.png',
      'assets/images/animations/plazma_spin/bboy_plazma_spin_f2.png',
      'assets/images/animations/plazma_spin/bboy_plazma_spin_f3.png',
      'assets/images/animations/plazma_spin/bboy_plazma_spin_f4.png',
      'assets/images/animations/plazma_spin/bboy_plazma_spin_f5.png',
      'assets/images/animations/plazma_spin/bboy_plazma_spin_f6.png',
    ],
  ),
  MoveData(
    id: 'neurallink_windmill',
    name: '뉴럴 링크 윈드밀', nameEn: 'Neural-Link Windmill',
    diff: 4, stars: '★★★★☆',
    command: [GestureCode.CIRCLE, GestureCode.DR, GestureCode.RD],
    cmdDisplay: ['○', 'ㄴ', 'ㄱ'],
    attack: 100, desc: '초고속 윈드밀 회전과 함께 데이터 스트리밍 시각 효과.',
    iconAsset: 'assets/images/animations/neurallink_windmill/neurallink_windmill.png',
    frames: [
      'assets/images/animations/neurallink_windmill/bboy_neurallink_windmill_f1.png',
      'assets/images/animations/neurallink_windmill/bboy_neurallink_windmill_f2.png',
      'assets/images/animations/neurallink_windmill/bboy_neurallink_windmill_f3.png',
      'assets/images/animations/neurallink_windmill/bboy_neurallink_windmill_f4.png',
      'assets/images/animations/neurallink_windmill/bboy_neurallink_windmill_f5.png',
      'assets/images/animations/neurallink_windmill/bboy_neurallink_windmill_f6.png',
    ],
  ),
  // ── 5★ ──────────────────────────────────────────
  MoveData(
    id: 'digital_ghost',
    name: '디지털 고스트', nameEn: 'Digital Ghost',
    diff: 5, stars: '★★★★★',
    command: [GestureCode.DRD, GestureCode.RD, GestureCode.DR],
    cmdDisplay: ['ㄹ', 'ㄱ', 'ㄴ'],
    attack: 130, buff: Buff('ALL +20', 2),
    desc: '초고속 풋워크로 여러 명의 잔상이 남는 착시를 일으킨다.',
    iconAsset: 'assets/images/animations/digital_ghost/digital_ghost.png',
    frames: [
      'assets/images/animations/digital_ghost/bboy_digital_ghost_f1.png',
      'assets/images/animations/digital_ghost/bboy_digital_ghost_f2.png',
      'assets/images/animations/digital_ghost/bboy_digital_ghost_f3.png',
      'assets/images/animations/digital_ghost/bboy_digital_ghost_f4.png',
      'assets/images/animations/digital_ghost/bboy_digital_ghost_f5.png',
      'assets/images/animations/digital_ghost/bboy_digital_ghost_f6.png',
    ],
  ),
];
