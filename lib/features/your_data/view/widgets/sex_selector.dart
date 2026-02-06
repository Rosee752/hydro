import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Rounded pill selector (Male / Female / Other) that matches Hydro’s style.
class SexSelector extends StatelessWidget {
  const SexSelector({super.key, required this.value, required this.onChanged});

  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    const labels = {'male': 'Male', 'female': 'Female', 'other': 'Other'};

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        color: Colors.white.withOpacity(.15),
      ),
      child: CupertinoSegmentedControl<String>(
        groupValue: value,
        padding: const EdgeInsets.all(4),
        onValueChanged: onChanged,
        selectedColor: Colors.white.withOpacity(.25),
        unselectedColor: Colors.transparent,
        borderColor: Colors.transparent,
        children: {
          for (final entry in labels.entries)
            entry.key: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 14),
              child: Text(entry.value,
                  style: GoogleFonts.fredoka(
                    fontWeight:
                    value == entry.key ? FontWeight.w600 : FontWeight.w400,
                    color: Colors.white,
                  )),
            )
        },
      ),
    );
  }
}
