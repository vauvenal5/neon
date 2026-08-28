import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neon_framework/src/theme/server.dart';
import 'package:neon_framework/src/theme/theme.dart';
import 'package:nextcloud/core.dart' as core;

core.ThemingPublicCapabilities_Theming _buildServerTheme(String color) => core.ThemingPublicCapabilities_Theming(
      (b) => b
        ..name = 'Account'
        ..url = 'https://cloud.example.com'
        ..slogan = ''
        ..color = color
        ..colorText = '#ffffff'
        ..colorElement = color
        ..colorElementBright = color
        ..colorElementDark = color
        ..logo = ''
        ..background = 'ignored-background.png'
        ..backgroundText = '#ffffff'
        ..backgroundPlain = false
        ..backgroundDefault = false
        ..logoheader = ''
        ..favicon = '',
    );

void main() {
  const deviceScheme = ColorScheme.light(primary: Colors.green);
  final accountServerTheme = ServerTheme(nextcloudTheme: _buildServerTheme('#c2185b'));

  test('themeFor overrides only the account server theme', () {
    const appTheme = AppTheme.test(
      useNextcloudTheme: true,
      deviceThemeLight: deviceScheme,
      platform: TargetPlatform.linux,
    );

    // Account settings should retain global theme configuration while replacing server-derived colors.
    final theme = appTheme.themeFor(Brightness.light, serverTheme: accountServerTheme);

    expect(theme.colorScheme.primary.toARGB32(), const Color(0xffc2185b).toARGB32());
    expect(theme.platform, TargetPlatform.linux);
    expect(theme.extension<ServerTheme>(), accountServerTheme);
  });

  test('themeFor ignores account server colors when Nextcloud theming is disabled', () {
    const appTheme = AppTheme.test(deviceThemeLight: deviceScheme);

    final theme = appTheme.themeFor(Brightness.light, serverTheme: accountServerTheme);

    expect(theme.colorScheme, deviceScheme);
    expect(theme.extension<ServerTheme>(), accountServerTheme);
  });

  test('themeFor uses the device scheme when the account has no server theme', () {
    final activeServerTheme = ServerTheme(nextcloudTheme: _buildServerTheme('#0000ff'));
    final appTheme = AppTheme.test(
      serverTheme: activeServerTheme,
      useNextcloudTheme: true,
      deviceThemeLight: deviceScheme,
    );

    final theme = appTheme.themeFor(
      Brightness.light,
      serverTheme: const ServerTheme(nextcloudTheme: null),
    );

    expect(theme.colorScheme, deviceScheme);
    expect(theme.extension<ServerTheme>()?.nextcloudTheme, isNull);
  });
}
