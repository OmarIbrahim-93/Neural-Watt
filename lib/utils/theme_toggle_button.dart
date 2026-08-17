import 'package:flutter/material.dart';
import 'theme.dart';

/// Reusable interactive Animated Theme Toggle Button for AppBars.
class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: AppThemeNotifier.instance,
      builder: (context, mode, child) {
        final bool isDark = AppThemeNotifier.instance.isDark(context);

        return IconButton(
          tooltip: isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode',
          onPressed: () => AppThemeNotifier.instance.toggleTheme(context),
          icon: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return RotationTransition(
                turns: child.key == const ValueKey('dark_icon')
                    ? Tween<double>(begin: 0.75, end: 1.0).animate(animation)
                    : Tween<double>(begin: 0.25, end: 1.0).animate(animation),
                child: ScaleTransition(
                  scale: animation,
                  child: child,
                ),
              );
            },
            child: isDark
                ? const Icon(
                    Icons.wb_sunny_outlined,
                    key: ValueKey('dark_icon'),
                    color: Color(0xFFF59E0B), // Golden amber for sun in dark mode
                    size: 22,
                  )
                : const Icon(
                    Icons.dark_mode_outlined,
                    key: ValueKey('light_icon'),
                    color: Color(0xFF64748B), // Slate moon icon in light mode
                    size: 22,
                  ),
          ),
        );
      },
    );
  }
}
