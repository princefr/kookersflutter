import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kookers/UI/Colors.dart';
import 'package:kookers/UI/Haptics.dart';

/// Inline tip selector shown on the checkout screen.
///
/// Renders a row of preset amounts (None / 2 / 5 / 10 / Custom) plus a
/// label. Calls back via [onChanged] with the chosen amount in the
/// user's currency. The grand total is computed by the parent.
class TipSelector extends StatefulWidget {
  /// Subtotal before tip (i.e. `order.totalWithFees`).
  final num subtotal;

  /// Currency symbol used to render the custom-amount dialog and the
  /// preset labels (when `showAmounts` is true).
  final String currencySymbol;

  /// Called every time the user picks a new tip amount.
  final ValueChanged<num> onChanged;

  const TipSelector({
    super.key,
    required this.subtotal,
    required this.currencySymbol,
    required this.onChanged,
  });

  @override
  State<TipSelector> createState() => _TipSelectorState();
}

class _TipSelectorState extends State<TipSelector> {
  /// Index into `_presets`. The last index is "Custom".
  int _selected = 0;
  num _customAmount = 0;

  /// Preset tip amounts. The first entry is "no tip" (0), which is the
  /// default — we don't push tipping on the user, just make it easy.
  static const List<num?> _presets = [0, 2, 5, 10, null];

  num get _currentAmount =>
      _selected == _presets.length - 1 ? _customAmount : (_presets[_selected] ?? 0);

  void _select(int index, num amount) {
    setState(() => _selected = index);
    Haptics.selection();
    widget.onChanged(amount);
  }

  Future<void> _pickCustom() async {
    final controller = TextEditingController(text: _customAmount.toString());
    final result = await showDialog<num>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('payment.tipCustom'.tr()),
        content: TextField(
          controller: controller,
          keyboardType:
              const TextInputType.numberWithOptions(decimal: true),
          autofocus: true,
          decoration: InputDecoration(
            suffixText: widget.currencySymbol,
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('common.cancel'.tr()),
          ),
          ElevatedButton(
            onPressed: () {
              final parsed = num.tryParse(controller.text) ?? 0;
              Navigator.pop(ctx, parsed < 0 ? 0 : parsed);
            },
            child: Text('common.validate'.tr()),
          ),
        ],
      ),
    );
    if (result != null) {
      _customAmount = result;
      _select(_presets.length - 1, result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(CupertinoIcons.heart, size: 18, color: KookersColors.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'payment.tipTitle'.tr(),
                      style: GoogleFonts.montserrat(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: KookersColors.textPrimary,
                      ),
                    ),
                    Text(
                      'payment.tipDesc'.tr(),
                      style: GoogleFonts.montserrat(
                        fontSize: 11,
                        color: KookersColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _presets.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final preset = _presets[index];
                final selected = _selected == index;
                String label;
                if (preset == null) {
                  label = 'payment.tipCustom'.tr();
                } else if (preset == 0) {
                  label = 'payment.tipNone'.tr();
                } else {
                  label = '$preset ${widget.currencySymbol}';
                }
                return _TipChip(
                  label: label,
                  selected: selected,
                  onTap: () {
                    if (preset == null) {
                      _pickCustom();
                    } else {
                      _select(index, preset);
                    }
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _TipChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _TipChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? KookersColors.primary : KookersColors.surfaceAlt,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Text(
            label,
            style: GoogleFonts.montserrat(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: selected ? Colors.white : KookersColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}
