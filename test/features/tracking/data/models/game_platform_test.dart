import 'package:flutter_test/flutter_test.dart';
import 'package:lorebase/features/tracking/data/models/game_platform.dart';
import 'package:lorebase/l10n/strings.g.dart';

void main() {
  group('GamePlatform', () {
    test('values map to backend strings', () {
      expect(GamePlatform.pc.apiValue, 'PC');
      expect(GamePlatform.nintendoSwitch.apiValue, 'Switch');
      expect(GamePlatform.switch2.apiValue, 'Switch 2');
      expect(GamePlatform.ps1.apiValue, 'PS1');
      expect(GamePlatform.ps2.apiValue, 'PS2');
      expect(GamePlatform.ps3.apiValue, 'PS3');
      expect(GamePlatform.ps4.apiValue, 'PS4');
      expect(GamePlatform.ps5.apiValue, 'PS5');
      expect(GamePlatform.xbox.apiValue, 'Xbox');
      expect(GamePlatform.xbox360.apiValue, 'Xbox 360');
      expect(GamePlatform.xboxOne.apiValue, 'Xbox One');
      expect(GamePlatform.snes.apiValue, 'SNES');
      expect(GamePlatform.nes.apiValue, 'NES');
      expect(GamePlatform.megaDrive.apiValue, 'Mega Drive');
      expect(GamePlatform.gba.apiValue, 'GBA');
      expect(GamePlatform.xboxSeriesXS.apiValue, 'Xbox Series X/S');
      expect(GamePlatform.mobile.apiValue, 'Mobile');
      expect(GamePlatform.vr.apiValue, 'VR');
      expect(GamePlatform.other.apiValue, 'Other');
    });

    test('fromApiValue returns matching platform', () {
      expect(GamePlatform.fromApiValue('PS5'), GamePlatform.ps5);
    });

    test('fromApiValue returns other for unknown', () {
      expect(GamePlatform.fromApiValue('Unknown'), GamePlatform.other);
    });

    test('label returns translated strings', () async {
      final ptBr = await AppLocale.ptBr.build();
      expect(GamePlatform.pc.label(ptBr), 'PC');
      expect(GamePlatform.nintendoSwitch.label(ptBr), 'Switch');
      expect(GamePlatform.switch2.label(ptBr), 'Switch 2');
      expect(GamePlatform.ps1.label(ptBr), 'PS1');
      expect(GamePlatform.ps2.label(ptBr), 'PS2');
      expect(GamePlatform.ps3.label(ptBr), 'PS3');
      expect(GamePlatform.ps4.label(ptBr), 'PS4');
      expect(GamePlatform.ps5.label(ptBr), 'PS5');
      expect(GamePlatform.xbox.label(ptBr), 'Xbox');
      expect(GamePlatform.xbox360.label(ptBr), 'Xbox 360');
      expect(GamePlatform.xboxOne.label(ptBr), 'Xbox One');
      expect(GamePlatform.snes.label(ptBr), 'SNES');
      expect(GamePlatform.nes.label(ptBr), 'NES');
      expect(GamePlatform.megaDrive.label(ptBr), 'Mega Drive');
      expect(GamePlatform.gba.label(ptBr), 'GBA');
      expect(GamePlatform.xboxSeriesXS.label(ptBr), 'Xbox Series X/S');
      expect(GamePlatform.mobile.label(ptBr), 'Mobile');
      expect(GamePlatform.vr.label(ptBr), 'VR');
      expect(GamePlatform.other.label(ptBr), 'Outro');
    });
  });
}
