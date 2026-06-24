import '../../../../l10n/strings.g.dart';

enum GamePlatform {
  pc('PC'),
  nintendoSwitch('Switch'),
  switch2('Switch 2'),
  ps1('PS1'),
  ps2('PS2'),
  ps3('PS3'),
  ps4('PS4'),
  ps5('PS5'),
  xbox('Xbox'),
  xbox360('Xbox 360'),
  xboxOne('Xbox One'),
  snes('SNES'),
  nes('NES'),
  megaDrive('Mega Drive'),
  gba('GBA'),
  xboxSeriesXS('Xbox Series X/S'),
  mobile('Mobile'),
  vr('VR'),
  other('Other');

  final String apiValue;

  const GamePlatform(this.apiValue);

  String label(Translations t) {
    return switch (this) {
      GamePlatform.pc => t.game_platform_pc,
      GamePlatform.nintendoSwitch => t.game_platform_switch,
      GamePlatform.switch2 => t.game_platform_switch2,
      GamePlatform.ps1 => t.game_platform_ps1,
      GamePlatform.ps2 => t.game_platform_ps2,
      GamePlatform.ps3 => t.game_platform_ps3,
      GamePlatform.ps4 => t.game_platform_ps4,
      GamePlatform.ps5 => t.game_platform_ps5,
      GamePlatform.xbox => t.game_platform_xbox,
      GamePlatform.xbox360 => t.game_platform_xbox_360,
      GamePlatform.xboxOne => t.game_platform_xbox_one,
      GamePlatform.snes => t.game_platform_snes,
      GamePlatform.nes => t.game_platform_nes,
      GamePlatform.megaDrive => t.game_platform_mega_drive,
      GamePlatform.gba => t.game_platform_gba,
      GamePlatform.xboxSeriesXS => t.game_platform_xbox_series_xs,
      GamePlatform.mobile => t.game_platform_mobile,
      GamePlatform.vr => t.game_platform_vr,
      GamePlatform.other => t.game_platform_other,
    };
  }

  static GamePlatform fromApiValue(String value) {
    return GamePlatform.values.firstWhere(
      (p) => p.apiValue == value,
      orElse: () => GamePlatform.other,
    );
  }
}
