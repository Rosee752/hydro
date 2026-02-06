import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NumberField extends StatelessWidget {
  const NumberField({
    super.key,
    required this.initial,
    required this.label,
    required this.min,
    required this.max,
    required this.onSaved,
  });

  final int initial, min, max;
  final String label;
  final ValueChanged<int> onSaved;

  @override
  Widget build(BuildContext context) {
    final ctrl = TextEditingController(text: '$initial');

    return TextFormField(
      controller: ctrl,
      keyboardType: TextInputType.number,
      style: GoogleFonts.fredoka(fontSize: 16, color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.fredoka(color: Colors.white70),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.white38),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.white),
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
      onFieldSubmitted: (val) {
        final v = int.tryParse(val);
        if (v != null && v >= min && v <= max) onSaved(v);
      },
    );
  }
}
