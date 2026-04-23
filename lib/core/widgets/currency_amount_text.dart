import 'package:flutter/material.dart';

import 'package:jood/core/utils/payment_amount_utils.dart';

const String _omaniRialSymbolAsset = 'assets/images/omr_symbol.png';

class CurrencyAmountText extends StatelessWidget {
  const CurrencyAmountText({
    super.key,
    required this.currency,
    required this.amount,
    this.style,
    this.textAlign = TextAlign.start,
    this.maxLines = 1,
    this.overflow = TextOverflow.clip,
  });

  final String currency;
  final num amount;
  final TextStyle? style;
  final TextAlign textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  @override
  Widget build(BuildContext context) {
    return CurrencyAmountInlineText(
      text: formatCurrency(currency, amount),
      style: style,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}

class CurrencyAmountInlineText extends StatelessWidget {
  const CurrencyAmountInlineText({
    super.key,
    required this.text,
    this.style,
    this.textAlign = TextAlign.start,
    this.maxLines = 1,
    this.overflow = TextOverflow.clip,
  });

  final String text;
  final TextStyle? style;
  final TextAlign textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  @override
  Widget build(BuildContext context) {
    final defaultStyle = DefaultTextStyle.of(context).style;
    final effectiveStyle = defaultStyle.merge(style);
    final matches = _InlineCurrencyMatch.parseAll(text);

    if (matches.isEmpty) {
      return Text(
        text,
        style: effectiveStyle,
        textAlign: textAlign,
        maxLines: maxLines,
        overflow: overflow,
      );
    }

    return _CurrencyInlineRichText(
      text: text,
      style: effectiveStyle,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      matches: matches,
    );
  }
}

class OmaniRialSymbol extends StatelessWidget {
  const OmaniRialSymbol({
    super.key,
    required this.width,
    required this.height,
  });

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      _omaniRialSymbolAsset,
      width: width,
      height: height,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
      excludeFromSemantics: true,
    );
  }
}

class _CurrencyInlineRichText extends StatelessWidget {
  const _CurrencyInlineRichText({
    required this.text,
    required this.style,
    required this.textAlign,
    required this.maxLines,
    required this.overflow,
    required this.matches,
  });

  final String text;
  final TextStyle style;
  final TextAlign textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final List<_InlineCurrencyMatch> matches;

  @override
  Widget build(BuildContext context) {
    if (matches.isEmpty) {
      return Text(
        text,
        style: style,
        textAlign: textAlign,
        maxLines: maxLines,
        overflow: overflow,
      );
    }

    final fontSize = style.fontSize ?? 14.0;
    final symbolHeight = fontSize * 0.9;
    final symbolWidth = symbolHeight * _InlineCurrencyMatch.symbolAspectRatio;
    final children = <InlineSpan>[];
    var currentIndex = 0;

    for (final match in matches) {
      if (currentIndex < match.start) {
        children.add(TextSpan(text: text.substring(currentIndex, match.start)));
      }

      if (match.symbolBeforeAmount) {
        children.add(
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: Padding(
              padding: EdgeInsetsDirectional.only(end: fontSize * 0.12),
              child: OmaniRialSymbol(
                width: symbolWidth,
                height: symbolHeight,
              ),
            ),
          ),
        );
        children.add(TextSpan(text: match.amountText));
      } else {
        children.add(TextSpan(text: match.amountText));
        children.add(
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: Padding(
              padding: EdgeInsetsDirectional.only(start: fontSize * 0.12),
              child: OmaniRialSymbol(
                width: symbolWidth,
                height: symbolHeight,
              ),
            ),
          ),
        );
      }

      currentIndex = match.end;
    }

    if (currentIndex < text.length) {
      children.add(TextSpan(text: text.substring(currentIndex)));
    }

    return Semantics(
      label: text,
      child: ExcludeSemantics(
        child: RichText(
          textAlign: textAlign,
          maxLines: maxLines,
          overflow: overflow ?? TextOverflow.clip,
          text: TextSpan(style: style, children: children),
        ),
      ),
    );
  }
}

class _InlineCurrencyMatch {
  const _InlineCurrencyMatch({
    required this.amountText,
    required this.start,
    required this.end,
    required this.symbolBeforeAmount,
  });

  static const double symbolAspectRatio = 790 / 450;
  static final RegExp _pattern = RegExp(
    '(OMR|OMN|\u0631\\.\\u0639|\uFDFC)\\s*(-?\\d+(?:\\.\\d+)?)|'
    '(-?\\d+(?:\\.\\d+)?)\\s*(OMR|OMN|\u0631\\.\\u0639|\uFDFC)',
    caseSensitive: false,
  );

  final String amountText;
  final int start;
  final int end;
  final bool symbolBeforeAmount;

  static List<_InlineCurrencyMatch> parseAll(String text) {
    final matches = <_InlineCurrencyMatch>[];

    for (final match in _pattern.allMatches(text)) {
      final leadingCurrency = match.group(1);
      final leadingAmount = match.group(2);
      final trailingAmount = match.group(3);
      final trailingCurrency = match.group(4);

      if (leadingCurrency != null &&
          leadingAmount != null &&
          isOmaniRialCurrency(leadingCurrency)) {
        matches.add(
          _InlineCurrencyMatch(
            amountText: leadingAmount,
            start: match.start,
            end: match.end,
            symbolBeforeAmount: true,
          ),
        );
        continue;
      }

      if (trailingCurrency != null &&
          trailingAmount != null &&
          isOmaniRialCurrency(trailingCurrency)) {
        matches.add(
          _InlineCurrencyMatch(
            amountText: trailingAmount,
            start: match.start,
            end: match.end,
            symbolBeforeAmount: false,
          ),
        );
      }
    }

    return matches;
  }
}
