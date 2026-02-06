import 'package:flutter/material.dart';

import '../../connect_controller.dart';

/// Down-arrow whose colour/greyscale follows the status of the card below.
class ArrowConnector extends StatelessWidget {
  const ArrowConnector({
    super.key,
    required this.belowStatus,
    required this.accent,
  });

  final ConnectionStatus belowStatus;
  final Color            accent;

  @override
  Widget build(BuildContext context) {
    final idle       = belowStatus == ConnectionStatus.idle;
    final connecting = belowStatus == ConnectionStatus.connecting;

    Color col;
    double opacity;
    if (idle) {
      col     = Colors.grey;
      opacity = .4;
    } else if (connecting) {
      col     = Colors.grey;
      opacity = .6;
    } else {
      col     = accent;
      opacity = 1.0;
    }

    return Icon(Icons.arrow_downward, color: col.withOpacity(opacity));
  }
}
