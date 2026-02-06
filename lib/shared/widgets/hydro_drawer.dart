import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class HydroDrawer extends StatelessWidget {
  const HydroDrawer({super.key});

  @override
  Widget build(BuildContext ctx) => Drawer(
    child: ListView(
      children: [
        DrawerHeader(
          decoration: const BoxDecoration(color: Color(0xFF00BCD4)),
          child: Row(
            children: [
              SvgPicture.asset('assets/logoo.svg', width: 42),
              const SizedBox(width: 12),
              Text(
                'Hydro',
                style: GoogleFonts.fredoka(
                    fontSize: 28, color: Colors.white),
              ),
            ],
          ),
        ),
        _item(ctx, Icons.timeline, 'History', '/dashboard/history'),
        _item(ctx, Icons.analytics, 'Your Data', '/dashboard/your-data'),
        _item(ctx, Icons.emoji_events, 'Trophies', '/dashboard/trophies'),
        _item(ctx, Icons.link, 'Connect', '/dashboard/connect'),
        _item(ctx, Icons.alarm, 'Reminders', '/dashboard/reminders'),
      ],
    ),
  );

  ListTile _item(BuildContext ctx, IconData ic, String lbl, String route) =>
      ListTile(
        leading: Icon(ic),
        title: Text(lbl,
            style: GoogleFonts.fredoka(fontSize: 16, fontWeight: FontWeight.w500)),
        onTap: () {
          Navigator.pop(ctx);
          ctx.go(route);
        },
      );
}
