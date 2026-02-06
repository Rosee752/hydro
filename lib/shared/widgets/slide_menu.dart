import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SlideMenu extends StatelessWidget {
  const SlideMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          const DrawerHeader(child: Text('Hydro')),
          _item(context, Icons.show_chart,  'History',            '/dashboard/history'),
          _item(context, Icons.person,      'Your Data',          '/dashboard/your-data'),
          _item(context, Icons.military_tech,'Trophies',          '/dashboard/trophies'),
          _item(context, Icons.watch,       'Connect',            '/dashboard/connect'),
          _item(context, Icons.alarm,       'Reminder Settings',  '/dashboard/reminders'),
        ],
      ),
    );
  }

  ListTile _item(BuildContext ctx, IconData ic, String lbl, String route) =>
      ListTile(
        leading: Icon(ic),
        title: Text(lbl),
        onTap: () {
          Navigator.pop(ctx);
          ctx.go(route);
        },
      );
}
