import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/calculators.dart';
import '../pricing/pricing.dart';
import '../theme.dart';
import 'shape_preview.dart';

/// A working calculator, running the same pricing rule as the app.
///
/// [compact] shows only the measurements and the price — used in the home
/// page hero. The full version adds the merchant's side: units, rate, wastage,
/// rounding, tiered rates and quantity discounts.
class CalculatorDemo extends StatefulWidget {
  const CalculatorDemo({super.key, required this.info, this.compact = false});

  final CalculatorInfo info;
  final bool compact;

  @override
  State<CalculatorDemo> createState() => _CalculatorDemoState();
}

class _CalculatorDemoState extends State<CalculatorDemo> {
  late List<TextEditingController> _fields;
  late TextEditingController _rate;
  late TextEditingController _productPrice;
  late TextEditingController _wastage;
  late TextEditingController _qty;
  late String _inputUnit;
  late String _pricingUnit;
  String _rounding = 'nearest';
  bool _tiers = false;
  bool _discounts = false;

  CalculatorInfo get info => widget.info;
  TypeSpec get spec => info.spec;

  @override
  void initState() {
    super.initState();
    _reset();
  }

  @override
  void didUpdateWidget(covariant CalculatorDemo oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.info.type != widget.info.type) {
      _replaceControllers();
    }
  }

  /// Swap in fresh controllers. The old ones are still attached to text fields
  /// until this frame rebuilds, so they are disposed after it, not now.
  void _replaceControllers() {
    final old = [..._fields, _rate, _productPrice, _wastage, _qty];
    _reset();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      for (final c in old) {
        c.dispose();
      }
    });
  }

  void _reset() {
    _fields = [
      for (final v in info.demoValues)
        TextEditingController(text: formatMeasure(v)),
    ];
    _rate = TextEditingController(text: _centsToText(info.demo.ratePerUnit));
    _productPrice =
        TextEditingController(text: _centsToText(info.productPrice));
    _wastage = TextEditingController(text: '0');
    _qty = TextEditingController(text: '1');
    _inputUnit = info.demo.inputUnit;
    _pricingUnit = info.demo.pricingUnit;
    _rounding = 'nearest';
    _tiers = false;
    _discounts = false;
  }

  void _disposeControllers() {
    for (final c in _fields) {
      c.dispose();
    }
    _rate.dispose();
    _productPrice.dispose();
    _wastage.dispose();
    _qty.dispose();
  }

  @override
  void dispose() {
    _disposeControllers();
    super.dispose();
  }

  // ------------------------------------------------------------------------
  // Parsing
  // ------------------------------------------------------------------------

  static String _centsToText(int cents) {
    final whole = cents ~/ 100;
    final frac = cents % 100;
    return frac == 0 ? '$whole' : '$whole.${frac.toString().padLeft(2, '0')}';
  }

  /// "12.5" -> 1250. String maths, like toMinor in the app. Null if invalid.
  static int? _toCents(String raw) {
    final s = raw.trim().replaceAll(',', '');
    if (!RegExp(r'^\d+(\.\d{0,2})?$').hasMatch(s)) {
      return null;
    }
    final parts = s.split('.');
    final cents = parts.length > 1 ? '${parts[1]}00'.substring(0, 2) : '00';
    return int.parse(parts[0]) * 100 + int.parse(cents);
  }

  static double _toDouble(String raw) =>
      double.tryParse(raw.trim()) ?? double.nan;

  int get _quantity {
    final q = int.tryParse(_qty.text.trim()) ?? 1;
    return q < 1 ? 1 : q;
  }

  PriceResult _compute() {
    final rate = _toCents(_rate.text);
    final product = _toCents(_productPrice.text);
    if (rate == null || product == null) {
      return const PriceResult.fail(
          'Enter prices as numbers, for example 85 or 85.50.');
    }
    final wastage = _wastage.text.trim();
    final config = info.demo.copyWith(
      inputUnit: _inputUnit,
      pricingUnit: _pricingUnit,
      ratePerUnit: rate,
      roundingMode: _rounding,
      overagePct: wastage.isEmpty || wastage == '0' ? null : wastage,
      clearOverage: wastage.isEmpty || wastage == '0',
      tiers: _tiers ? info.demoTiers : const [],
      quantityDiscounts: _discounts ? demoDiscounts : const [],
    );
    final values = [for (final c in _fields) _toDouble(c.text)];
    final r = computePrice(config, values, product, _quantity);
    if (!r.ok && r.reason.startsWith('Measurements')) {
      return const PriceResult.fail(
          'Enter every measurement as a number above zero.');
    }
    return r;
  }

  // ------------------------------------------------------------------------
  // Labels
  // ------------------------------------------------------------------------

  String get _pricingLabel => unitNames[_pricingUnit] ?? _pricingUnit;

  /// What the customer types in, for field suffixes.
  String get _fieldUnit =>
      spec.direct ? _pricingLabel : (unitNames[_inputUnit] ?? _inputUnit);

  // ------------------------------------------------------------------------
  // Build
  // ------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final result = _compute();
    final mobile = Layout.isMobile(context);

    final customer = _CustomerSide(
      info: info,
      fields: _fields,
      fieldUnit: spec.dim == Dimension.count ? '' : _fieldUnit,
      // The quantity calculator already asks "how many", so a second
      // quantity box would only confuse.
      qty: widget.compact || spec.dim == Dimension.count ? null : _qty,
      result: result,
      quantity: _quantity,
      pricingLabel: _pricingLabel,
      onChanged: () => setState(() {}),
      compact: widget.compact,
    );

    if (widget.compact) {
      return customer;
    }

    final merchant = _MerchantSide(
      spec: spec,
      info: info,
      inputUnit: _inputUnit,
      pricingUnit: _pricingUnit,
      rounding: _rounding,
      tiers: _tiers,
      discounts: _discounts,
      rate: _rate,
      productPrice: _productPrice,
      wastage: _wastage,
      pricingLabel: _pricingLabel,
      onInputUnit: (v) => setState(() => _inputUnit = v),
      onPricingUnit: (v) => setState(() => _pricingUnit = v),
      onRounding: (v) => setState(() => _rounding = v),
      onTiers: (v) => setState(() => _tiers = v),
      onDiscounts: (v) => setState(() => _discounts = v),
      onChanged: () => setState(() {}),
      onReset: () => setState(_replaceControllers),
    );

    if (mobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [customer, const SizedBox(height: 20), merchant],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 6, child: customer),
        const SizedBox(width: 24),
        Expanded(flex: 5, child: merchant),
      ],
    );
  }
}

// ==========================================================================
// What the shopper sees
// ==========================================================================

class _CustomerSide extends StatelessWidget {
  const _CustomerSide({
    required this.info,
    required this.fields,
    required this.fieldUnit,
    required this.qty,
    required this.result,
    required this.quantity,
    required this.pricingLabel,
    required this.onChanged,
    required this.compact,
  });

  final CalculatorInfo info;
  final List<TextEditingController> fields;
  final String fieldUnit;
  final TextEditingController? qty;
  final PriceResult result;
  final int quantity;
  final String pricingLabel;
  final VoidCallback onChanged;
  final bool compact;

  static double _parse(String s) => double.tryParse(s.trim()) ?? double.nan;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final labels = info.spec.fields;
    final values = [for (final c in fields) _parse(c.text)];

    final inputs = <Widget>[
      for (var i = 0; i < fields.length; i++)
        _NumberField(
          controller: fields[i],
          label: labels[i],
          suffix: fieldUnit,
          onChanged: onChanged,
          integer: info.spec.dim == Dimension.count,
          // Said at the field, not in a banner below it, so the customer
          // knows which box to fix.
          errorText: values[i].isFinite && values[i] > 0
              ? null
              : 'Enter a size above 0',
        ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: Brand.white,
        borderRadius: BorderRadius.circular(Radii.panel),
        border: Border.all(color: Brand.line),
        boxShadow: Shadows.lg,
      ),
      padding: EdgeInsets.all(compact ? 22 : 26),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Brand.tint,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Text(
                    'Product page preview',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: Brand.indigo,
                        fontSize: 12,
                        fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const _LiveDot(),
            ],
          ),
          const SizedBox(height: 14),
          Text(info.example, style: t.titleLarge),
          const SizedBox(height: 16),
          if (ShapePreview.supports(info.type)) ...[
            ShapePreview(
              type: info.type,
              values: values,
              unit: fieldUnit,
              height: compact ? 128 : 160,
            ),
            const SizedBox(height: 18),
          ],
          Text('Enter your size',
              style: t.bodySmall
                  ?.copyWith(fontWeight: FontWeight.w600, color: Brand.ink)),
          const SizedBox(height: 10),
          _row(inputs),
          if (qty != null) ...[
            const SizedBox(height: 16),
            Text('Quantity',
                style: t.bodySmall
                    ?.copyWith(fontWeight: FontWeight.w600, color: Brand.ink)),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: _QtyStepper(controller: qty!, onChanged: onChanged),
            ),
          ],
          const SizedBox(height: 22),
          const Divider(),
          const SizedBox(height: 18),
          _PriceBlock(result: result, quantity: compact ? 1 : quantity),
          if (!compact && result.ok) ...[
            const SizedBox(height: 18),
            _Breakdown(
                result: result, pricingLabel: pricingLabel, quantity: quantity),
          ],
          const SizedBox(height: 18),
          SizedBox(
            height: 50,
            child: FilledButton.icon(
              // Deliberately inert: this is a preview, not a shop.
              onPressed: null,
              icon: const Icon(Icons.shopping_bag_outlined, size: 18),
              label: const Text('Add to cart'),
              style: FilledButton.styleFrom(
                disabledBackgroundColor: Brand.ink,
                disabledForegroundColor: Brand.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(Radii.control)),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "In your store this is your theme's own button.",
            textAlign: TextAlign.center,
            style: t.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _row(List<Widget> children) {
    return LayoutBuilder(
      builder: (context, c) {
        final perRow = c.maxWidth < 360 ? 1 : children.length;
        if (perRow == 1) {
          return Column(
            children: [
              for (var i = 0; i < children.length; i++) ...[
                if (i > 0) const SizedBox(height: 12),
                children[i],
              ],
            ],
          );
        }
        return Row(
          children: [
            for (var i = 0; i < children.length; i++) ...[
              if (i > 0) const SizedBox(width: 12),
              Expanded(child: children[i]),
            ],
          ],
        );
      },
    );
  }
}

class _PriceBlock extends StatelessWidget {
  const _PriceBlock({required this.result, required this.quantity});

  final PriceResult result;
  final int quantity;

  @override
  Widget build(BuildContext context) {
    if (!result.ok) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFBEB),
          borderRadius: BorderRadius.circular(Radii.control),
          border: Border.all(color: const Color(0xFFFDE68A)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.info_outline_rounded,
                color: Brand.amber, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(result.reason,
                  style: const TextStyle(
                      color: Brand.amber, fontSize: 14.5, height: 1.45)),
            ),
          ],
        ),
      );
    }

    final total = result.minor * quantity;
    return Semantics(
      // Announced by screen readers whenever it changes.
      container: true,
      liveRegion: true,
      label: quantity > 1
          ? 'Total ${formatMinor(total)}, ${formatMinor(result.minor)} each'
          : 'Price ${formatMinor(total)}',
      excludeSemantics: true,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  quantity > 1 ? 'Total for $quantity' : 'Your price',
                  style: const TextStyle(
                      color: Brand.muted,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: AnimatedMoney(
                    total,
                    style: const TextStyle(
                      color: Brand.ink,
                      fontSize: 42,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -1.4,
                      height: 1.05,
                      fontFeatures: [FontFeature.tabularFigures()],
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (quantity > 1)
            Flexible(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 6, left: 8),
                child: Text(
                  '${formatMinor(result.minor)} each',
                  textAlign: TextAlign.end,
                  style: const TextStyle(
                      color: Brand.body,
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Money that rolls to its new value instead of jumping, so the customer's eye
/// is drawn to the price as it changes. Tabular figures keep the digits from
/// shuffling sideways while it moves. No motion when the OS asks for none.
class AnimatedMoney extends StatelessWidget {
  const AnimatedMoney(this.minor, {super.key, required this.style});

  final int minor;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(end: minor.toDouble()),
      duration: Motion.of(context, const Duration(milliseconds: 320)),
      curve: Motion.curve,
      builder: (context, value, _) =>
          Text(formatMinor(value.round()), style: style),
    );
  }
}

/// A small pulsing-free "live" marker: the demo is running, not a screenshot.
class _LiveDot extends StatelessWidget {
  const _LiveDot();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: const Color(0xFF10B981),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                  color: const Color(0xFF10B981).withValues(alpha: 0.35),
                  blurRadius: 6)
            ],
          ),
        ),
        const SizedBox(width: 6),
        const Text('Live',
            style: TextStyle(
                color: Brand.muted,
                fontSize: 12.5,
                fontWeight: FontWeight.w600)),
      ],
    );
  }
}

/// Minus, number, plus — the pattern shoppers already know from every cart.
class _QtyStepper extends StatelessWidget {
  const _QtyStepper({required this.controller, required this.onChanged});

  final TextEditingController controller;
  final VoidCallback onChanged;

  int get _value => int.tryParse(controller.text.trim()) ?? 1;

  void _set(int v) {
    controller.text = '${v.clamp(1, 99999)}';
    onChanged();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Radii.control),
        border: Border.all(color: const Color(0xFFCBD5E1)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            tooltip: 'Fewer',
            icon: const Icon(Icons.remove_rounded, size: 20),
            onPressed: _value > 1 ? () => _set(_value - 1) : null,
          ),
          SizedBox(
            width: 64,
            // Named for screen readers; the visible label sits above.
            child: Semantics(
              label: 'Quantity',
              child: TextField(
                controller: controller,
                onChanged: (_) => onChanged(),
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(5),
                ],
                style: const TextStyle(
                    color: Brand.ink,
                    fontSize: 16,
                    fontWeight: FontWeight.w700),
                decoration: const InputDecoration(
                  filled: false,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),
          IconButton(
            tooltip: 'More',
            icon: const Icon(Icons.add_rounded, size: 20),
            onPressed: () => _set(_value + 1),
          ),
        ],
      ),
    );
  }
}

class _Breakdown extends StatelessWidget {
  const _Breakdown(
      {required this.result,
      required this.pricingLabel,
      required this.quantity});

  final PriceResult result;
  final String pricingLabel;
  final int quantity;

  @override
  Widget build(BuildContext context) {
    final unit = pricingLabel == 'item'
        ? (result.orderedMeasure == 1 ? ' item' : ' items')
        : ' $pricingLabel';
    final perUnit = pricingLabel == 'item' ? 'item' : pricingLabel;

    final rows = <(String, String)>[
      ('Ordered', '${formatMeasure(result.orderedMeasure)}$unit'),
      if (result.measure != result.orderedMeasure)
        ('Charged for, with wastage', '${formatMeasure(result.measure)}$unit'),
      ('Rate', '${formatMinor(result.rateMinor)} per $perUnit'),
      if (result.discountPct > 0)
        ('Quantity discount', '${formatMeasure(result.discountPct)}% off'),
    ];

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
      decoration: BoxDecoration(
        color: Brand.soft,
        borderRadius: BorderRadius.circular(Radii.control),
        border: Border.all(color: Brand.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 6),
            child: Text(
              'HOW THIS PRICE WAS WORKED OUT',
              style: TextStyle(
                  color: Brand.muted,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1),
            ),
          ),
          for (final r in rows)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Expanded(
                      child: Text(r.$1,
                          style: const TextStyle(
                              color: Brand.body, fontSize: 14))),
                  const SizedBox(width: 12),
                  Flexible(
                    child: Text(
                      r.$2,
                      textAlign: TextAlign.end,
                      style: const TextStyle(
                          color: Brand.ink,
                          fontSize: 14,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          if (result.floorApplied)
            const _Note(
              icon: Icons.shield_outlined,
              text: "Lifted to the product's own price — the floor. "
                  'A cut smaller than one unit is charged as one.',
            ),
          if (result.capped)
            const _Note(
                icon: Icons.vertical_align_top_rounded,
                text: 'Held at the maximum price.'),
        ],
      ),
    );
  }
}

class _Note extends StatelessWidget {
  const _Note({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Brand.teal),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text,
                style: const TextStyle(
                    color: Brand.teal, fontSize: 13.5, height: 1.45)),
          ),
        ],
      ),
    );
  }
}

// ==========================================================================
// What the merchant configures
// ==========================================================================

class _MerchantSide extends StatelessWidget {
  const _MerchantSide({
    required this.spec,
    required this.info,
    required this.inputUnit,
    required this.pricingUnit,
    required this.rounding,
    required this.tiers,
    required this.discounts,
    required this.rate,
    required this.productPrice,
    required this.wastage,
    required this.pricingLabel,
    required this.onInputUnit,
    required this.onPricingUnit,
    required this.onRounding,
    required this.onTiers,
    required this.onDiscounts,
    required this.onChanged,
    required this.onReset,
  });

  final TypeSpec spec;
  final CalculatorInfo info;
  final String inputUnit;
  final String pricingUnit;
  final String rounding;
  final bool tiers;
  final bool discounts;
  final TextEditingController rate;
  final TextEditingController productPrice;
  final TextEditingController wastage;
  final String pricingLabel;
  final ValueChanged<String> onInputUnit;
  final ValueChanged<String> onPricingUnit;
  final ValueChanged<String> onRounding;
  final ValueChanged<bool> onTiers;
  final ValueChanged<bool> onDiscounts;
  final VoidCallback onChanged;
  final VoidCallback onReset;

  static String? _moneyError(String raw) =>
      RegExp(r'^\d+(\.\d{0,2})?$').hasMatch(raw.trim())
          ? null
          : 'e.g. 85 or 85.50';

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final pricingUnits = pricingUnitsFor(spec.dim);
    final inputUnits = inputUnitsFor(spec.dim);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Brand.soft,
        borderRadius: BorderRadius.circular(Radii.panel),
        border: Border.all(color: Brand.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(child: Text('Your settings', style: t.titleLarge)),
              TextButton(onPressed: onReset, child: const Text('Reset')),
            ],
          ),
          const SizedBox(height: 4),
          Text('What a merchant sets in the Measurely admin.',
              style: t.bodySmall),
          const SizedBox(height: 20),
          if (!spec.direct && inputUnits.isNotEmpty) ...[
            const _Label('Customers type in'),
            _UnitDropdown(
                value: inputUnit, options: inputUnits, onChanged: onInputUnit),
            const SizedBox(height: 16),
          ],
          if (pricingUnits.length > 1) ...[
            const _Label('You charge per'),
            _Segments(
              value: pricingUnit,
              options: {for (final u in pricingUnits) u: unitNames[u] ?? u},
              onChanged: onPricingUnit,
            ),
            const SizedBox(height: 16),
          ],
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _NumberField(
                  controller: rate,
                  label:
                      'Rate per ${pricingLabel == 'item' ? 'item' : pricingLabel}',
                  prefix: r'$',
                  onChanged: onChanged,
                  money: true,
                  errorText: _moneyError(rate.text),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _NumberField(
                  controller: productPrice,
                  label: 'Product price (floor)',
                  prefix: r'$',
                  onChanged: onChanged,
                  money: true,
                  errorText: _moneyError(productPrice.text),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const _PlanDivider('Starter and above'),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerLeft,
            child: SizedBox(
              width: 140,
              child: _NumberField(
                controller: wastage,
                label: 'Wastage',
                suffix: '%',
                onChanged: onChanged,
              ),
            ),
          ),
          const SizedBox(height: 16),
          const _Label('Rounding'),
          Align(
            alignment: Alignment.centerLeft,
            child: _Segments(
              value: rounding,
              options: const {'nearest': 'Nearest', 'up': 'Up', 'down': 'Down'},
              onChanged: onRounding,
            ),
          ),
          const SizedBox(height: 24),
          const _PlanDivider('Professional and above'),
          const SizedBox(height: 8),
          if (info.demoTiers.isNotEmpty)
            _Toggle(
              title: 'Tiered rates',
              subtitle: info.demoTiers
                  .map((b) => b.maxValue == null
                      ? '${b.minValue}+ $pricingLabel: ${formatMinor(b.unitPrice)}'
                      : '${b.minValue}–${b.maxValue} $pricingLabel: ${formatMinor(b.unitPrice)}')
                  .join('   ·   '),
              value: tiers,
              onChanged: onTiers,
            ),
          _Toggle(
            title: 'Quantity discounts',
            subtitle: '10–49: 5% off   ·   50+: 10% off',
            value: discounts,
            onChanged: onDiscounts,
          ),
        ],
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
            color: Brand.body, fontSize: 13.5, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _PlanDivider extends StatelessWidget {
  const _PlanDivider(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          text.toUpperCase(),
          style: const TextStyle(
            color: Brand.indigo,
            fontSize: 11.5,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(child: Divider()),
      ],
    );
  }
}

class _Toggle extends StatelessWidget {
  const _Toggle({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () => onChanged(!value),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          color: Brand.ink,
                          fontSize: 15,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: const TextStyle(color: Brand.muted, fontSize: 13)),
                ],
              ),
            ),
            Switch(value: value, onChanged: onChanged),
          ],
        ),
      ),
    );
  }
}

class _Segments extends StatelessWidget {
  const _Segments(
      {required this.value, required this.options, required this.onChanged});

  final String value;
  final Map<String, String> options;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<String>(
      segments: [
        for (final e in options.entries)
          ButtonSegment(value: e.key, label: Text(e.value)),
      ],
      selected: {value},
      showSelectedIcon: false,
      onSelectionChanged: (s) => onChanged(s.first),
      style: const ButtonStyle(visualDensity: VisualDensity.compact),
    );
  }
}

class _UnitDropdown extends StatelessWidget {
  const _UnitDropdown(
      {required this.value, required this.options, required this.onChanged});

  final String value;
  final List<String> options;
  final ValueChanged<String> onChanged;

  static const _long = {
    'mm': 'Millimetres',
    'cm': 'Centimetres',
    'm': 'Metres',
    'in': 'Inches',
    'ft': 'Feet',
    'yd': 'Yards',
    'g': 'Grams',
    'kg': 'Kilograms',
    'lb': 'Pounds',
  };

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: const InputDecoration(
          contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 4)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: options.contains(value) ? value : options.first,
          isExpanded: true,
          borderRadius: BorderRadius.circular(10),
          items: [
            for (final u in options)
              DropdownMenuItem(value: u, child: Text(_long[u] ?? u)),
          ],
          onChanged: (v) {
            if (v != null) {
              onChanged(v);
            }
          },
        ),
      ),
    );
  }
}

class _NumberField extends StatelessWidget {
  const _NumberField({
    required this.controller,
    required this.label,
    required this.onChanged,
    this.suffix = '',
    this.prefix,
    this.integer = false,
    this.money = false,
    this.errorText,
  });

  final TextEditingController controller;
  final String label;
  final VoidCallback onChanged;
  final String suffix;
  final String? prefix;
  final bool integer;
  final bool money;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final pattern = integer ? RegExp(r'[0-9]') : RegExp(r'[0-9.]');
    return TextField(
      controller: controller,
      onChanged: (_) => onChanged(),
      keyboardType: TextInputType.numberWithOptions(decimal: !integer),
      inputFormatters: [
        FilteringTextInputFormatter.allow(pattern),
        LengthLimitingTextInputFormatter(money ? 9 : 10),
      ],
      style: const TextStyle(
          color: Brand.ink, fontSize: 16, fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        labelText: label,
        suffixText: suffix.isEmpty ? null : suffix,
        suffixStyle:
            const TextStyle(color: Brand.muted, fontWeight: FontWeight.w600),
        prefixText: prefix,
        errorText: errorText,
      ),
    );
  }
}
