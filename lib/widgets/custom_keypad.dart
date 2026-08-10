import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomKeypad extends StatelessWidget {
  final Function(String key) onKeyPress;
  final bool showDoubleZero;
  final bool isDark;

  const CustomKeypad({
    super.key,
    required this.onKeyPress,
    this.showDoubleZero = false,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final List<String> keys = showDoubleZero
        ? ['1', '2', '3', '4', '5', '6', '7', '8', '9', '00', '0', 'back']
        : ['1', '2', '3', '4', '5', '6', '7', '8', '9', '.', '0', 'back'];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 2.1,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: keys.length,
      itemBuilder: (context, index) {
        final keyStr = keys[index];
        final isBack = keyStr == 'back';

        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => onKeyPress(keyStr),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xD90B1329) : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? const Color(0x24FFFFFF) : const Color(0x80CBD5E1),
                  width: 1.5,
                ),
              ),
              alignment: Alignment.center,
              child: isBack
                  ? Icon(
                      Icons.backspace_outlined,
                      size: 22,
                      color: isDark ? Colors.white : Colors.black87,
                    )
                  : Text(
                      keyStr,
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
            ),
          ),
        );
      },
    );
  }
}
