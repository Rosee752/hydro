import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../dashboard/widgets/mood_background.dart';   // ⬅ NEW
import '../../dashboard/widgets/bubble_field.dart';      // ⬅ NEW
import '../connect_controller.dart';
import 'widgets/connection_card.dart';
import 'widgets/arrow_connector.dart';

/// Screen that lets the user “connect” Hydro, Google Fit and Samsung Health.
///
/// Uses a fake 2-second delay – no real SDK calls.
class ConnectScreen extends StatelessWidget {
  const ConnectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = ConnectController(); // singleton

    return ChangeNotifierProvider.value(
      value: controller,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: Stack(
          children: [
            const CalmDashboardBackground(),         // backdrop
            Positioned.fill(
              top: kToolbarHeight + MediaQuery.of(context).padding.top,
              child: SingleChildScrollView(
                padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Connect',
                        style: Theme.of(context).textTheme.headlineMedium),
                    const SizedBox(height: 24),

                    // Hydro card
                    _RowWithArrow(
                      service: Service.hydro,
                      title: 'Hydro!',
                      asset: 'assets/hydro_drop.svg',
                      accent: const Color(0xFF0094FF),
                      controller: controller,
                    ),
                    const SizedBox(height: 24),

                    // Google Fit
                    _RowWithArrow(
                      service: Service.googleFit,
                      title: 'Google Fit',
                      asset: 'assets/google_fit.svg',
                      accent: const Color(0xFF4285F4),
                      controller: controller,
                    ),
                    const SizedBox(height: 24),

                    // Samsung Health
                    _RowWithArrow(
                      service: Service.samsungHealth,
                      title: 'Samsung Health',
                      asset: 'assets/samsung_health.svg',
                      accent: const Color(0xFF00B2D6),
                      controller: controller,
                    ),

                    const SizedBox(height: 40),

                    // explanatory footer
                    Center(
                      child: Text(
                        'Connecting lets Hydro adjust your daily goal\n'
                            'and sync health stats automatically.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(
                          color: Colors.white70,
                          shadows: const [
                            Shadow(color: Colors.black26, blurRadius: 2)
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Helper widget that shows a card and, if not the last, an arrow below it.
class _RowWithArrow extends StatelessWidget {
  const _RowWithArrow({
    required this.service,
    required this.title,
    required this.asset,
    required this.accent,
    required this.controller,
  });

  final Service           service;
  final String            title;
  final String            asset;
  final Color             accent;
  final ConnectController controller;

  @override
  Widget build(BuildContext context) => Consumer<ConnectController>(
    builder: (_, ctl, _) {
      final status = ctl.stateOf(service);

      return Column(
        children: [
          // card with label
          Row(
            children: [
              ConnectionCard(
                service : service,
                asset   : asset,
                accent  : accent,
                status  : status,
                onTap   : () async {
                  await ctl.connect(service);
                  if (ctl.stateOf(service) ==
                      ConnectionStatus.connected) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('$title connected!')),
                    );
                  }
                },
                onLongPress: () => _showDisconnect(context, ctl),
              ),
              const SizedBox(width: 16),
              Text(title,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(color: Colors.white)),
            ],
          ),

          // arrow (skip after last item)
          if (service != Service.samsungHealth)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: ArrowConnector(
                belowStatus: status,
                accent: accent,
              ),
            ),
        ],
      );
    },
  );

  void _showDisconnect(BuildContext ctx, ConnectController ctl) {
    showModalBottomSheet(
      context: ctx,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: ListTile(
            leading: const Icon(Icons.link_off),
            title: const Text('Disconnect (demo)'),
            onTap: () async {
              Navigator.pop(ctx);
              await Future.delayed(const Duration(milliseconds: 300));
              ctl.disconnect(service);
            },
          ),
        ),
      ),
    );
  }
}

/// Backdrop reused from the dashboard (gradient + bubbles).
class CalmDashboardBackground extends StatelessWidget {
  const CalmDashboardBackground({super.key});

  @override
  Widget build(BuildContext context) => const Stack(
    children: [
      MoodBackground(progress: .25),
      BubbleField(),
    ],
  );
}
