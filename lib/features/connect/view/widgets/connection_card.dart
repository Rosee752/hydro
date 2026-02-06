// lib/features/connect/view/widgets/connection_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../connect_controller.dart';

/// 88 × 88 dp pill that visualises *idle / connecting / connected*.
///
/// Greyscale & 40 % opacity when idle, spinner overlay when connecting,
/// subtle scale-pulse once connected.
class ConnectionCard extends StatelessWidget {
  const ConnectionCard({
    super.key,
    required this.service,
    required this.asset,
    required this.accent,
    required this.status,
    required this.onTap,
    required this.onLongPress,
  });

  final Service          service;
  final String           asset;
  final Color            accent;
  final ConnectionStatus status;
  final VoidCallback     onTap;
  final VoidCallback     onLongPress;

  @override
  Widget build(BuildContext context) {
    final bool idle       = status == ConnectionStatus.idle;
    final bool connecting = status == ConnectionStatus.connecting;
    final bool connected  = status == ConnectionStatus.connected;

    // scale animation once we arrive at CONNECTED
    final double scale = connected ? 1.05 : 1.0;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        splashColor: accent.withOpacity(.15),
        onTap      : idle      ? onTap       : null,
        onLongPress: connected ? onLongPress : null,
        child: AnimatedScale(
          scale: scale,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutBack,
          child: Container(
            width: 88,
            height: 88,
            padding: const EdgeInsets.all(12),
            clipBehavior: Clip.hardEdge,               // 🔒 keep effects inside
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: accent, width: 2),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                ColorFiltered(
                  colorFilter: idle
                      ? const ColorFilter.mode(
                      Colors.grey, BlendMode.saturation)
                      : const ColorFilter.mode(
                      Colors.transparent, BlendMode.dst),
                  child: SvgPicture.asset(
                    asset,
                    fit: BoxFit.contain,
                  ),
                ),
                if (connecting)
                  Container(
                    color: Colors.white.withOpacity(.6),
                    alignment: Alignment.center,
                    child: const SizedBox(
                      width: 32,
                      height: 32,
                      child: CircularProgressIndicator(strokeWidth: 3),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
