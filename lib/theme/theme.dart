import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FTTheme {
  static ThemeData get light => FlexThemeData.light(
        scheme: FlexScheme.flutterDash,
        subThemesData: const FlexSubThemesData(
          interactionEffects: true,
          tintedDisabledControls: true,
          useM2StyleDividerInM3: true,
          inputDecoratorIsFilled: true,
          inputDecoratorBorderType: FlexInputBorderType.outline,
          alignedDropdown: true,
          navigationRailUseIndicator: true,
          navigationRailLabelType: NavigationRailLabelType.all,
        ),
        // keyColors: const FlexKeyColors(
        //   useSecondary: true,
        //   useTertiary: true,
        //   useError: true,
        //   contrastLevel: 1,
        // ),
        visualDensity: FlexColorScheme.comfortablePlatformDensity,
        cupertinoOverrideTheme: const CupertinoThemeData(applyThemeToAll: true),
      );
  static ThemeData get dark => FlexThemeData.dark(
        scheme: FlexScheme.flutterDash,
        subThemesData: const FlexSubThemesData(
          interactionEffects: true,
          tintedDisabledControls: true,
          blendOnColors: true,
          useM2StyleDividerInM3: true,
          inputDecoratorIsFilled: false,
          inputDecoratorBorderType: FlexInputBorderType.underline,
          alignedDropdown: true,
          navigationRailUseIndicator: true,
          navigationRailLabelType: NavigationRailLabelType.all,
        ),
        keyColors: const FlexKeyColors(
          useSecondary: true,
          useTertiary: true,
          useError: true,
          contrastLevel: 1,
        ),
        visualDensity: FlexColorScheme.comfortablePlatformDensity,
        cupertinoOverrideTheme: const CupertinoThemeData(applyThemeToAll: true),
      );
}
