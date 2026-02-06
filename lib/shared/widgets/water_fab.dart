import 'package:flutter/material.dart';

class WaterFAB extends StatelessWidget {
  final void Function(BuildContext) onAdd;
  const WaterFAB({super.key, required this.onAdd});

  @override
  Widget build(BuildContext context) => FloatingActionButton(
    onPressed: () => onAdd(context),
    backgroundColor: Colors.white.withOpacity(0.25),
    shape: const StadiumBorder(),
    child: const Icon(Icons.add, color: Colors.white),
  );
}
