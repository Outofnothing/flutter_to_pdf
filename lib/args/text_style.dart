import 'package:flutter/services.dart' show AssetBundle;
import 'package:flutter/widgets.dart'
    show
        TextDecoration,
        TextDecorationStyle,
        TextStyle,
        FontStyle,
        FontWeight,
        debugPrint;

import 'package:pdf/widgets.dart' as pw
    show
        TextStyle,
        TextDecoration,
        TextDecorationStyle,
        Font,
        BoxDecoration,
        FontStyle,
        FontWeight;

import '../options/font_data.dart';
import 'color.dart';

class FontBunldle {
  final pw.Font? font;
  final pw.Font? fontNormal;
  final pw.Font? fontBold;
  final pw.Font? fontItalic;
  final pw.Font? fontBoldItalic;

  FontBunldle(
      {this.font,
      this.fontNormal,
      this.fontBold,
      this.fontItalic,
      this.fontBoldItalic});
}

extension TextStyleConverter on TextStyle {
  Future<pw.TextStyle> toPdfTextStyle(FontData fontData) async {
    FontBunldle? fontBundle = fontFamily != null
        ? await resolveFontBundle(fontFamily!, fontData)
        : null;
    return pw.TextStyle(
      color: color?.toPdfColor(),
      fontSize: fontSize,
      fontStyle: fontStyle?.toPdfFontStyle(),
      fontWeight: fontWeight?.toPdfFontWeight(),
      height: height,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      decoration: decoration?.toPdfTextDecoration(),
      decorationColor: decorationColor?.toPdfColor(),
      decorationStyle: decorationStyle?.toPdfTextDecorationStyle(),
      decorationThickness: decorationThickness,
      inherit: !inherit && fontBundle == null ? true : inherit,
      font: fontBundle?.font,
      fontNormal: fontBundle?.fontNormal,
      fontBold: fontBundle?.fontBold,
      fontItalic: fontBundle?.fontItalic,
      fontBoldItalic: fontBundle?.fontBoldItalic,
      fontFallback: fontFamilyFallback != null
          ? (await Future.wait(fontFamilyFallback!
                  .map((String font) => resolveFont(font, fontData))))
              .whereType<pw.Font>()
              .toList()
          : [],
      background: backgroundColor != null
          ? pw.BoxDecoration(
              color: backgroundColor!.toPdfColor(),
            )
          : null,
    );
  }

  Future<FontBunldle?> resolveFontBundle(
      String fontFamily, FontData fontData) async {
    if (!fontData.ttfFonts.containsKey(fontFamily)) {
      return null;
    }
    final String fontPath = '${fontData.ttfFonts[fontFamily]!}Regular.ttf';
    final String fontPathNormal =
        '${fontData.ttfFonts[fontFamily]!}Regular.ttf';
    final String fontPathBold = '${fontData.ttfFonts[fontFamily]!}Bold.ttf';
    final String fontPathItalic = '${fontData.ttfFonts[fontFamily]!}Italic.ttf';
    final String fontPathBoldItalic =
        '${fontData.ttfFonts[fontFamily]!}BoldItalic.ttf';

    pw.Font? font = await resolveFont(fontPath, fontData);
    pw.Font? fontNormal = await resolveFont(fontPathNormal, fontData);
    pw.Font? fontBold = await resolveFont(fontPathBold, fontData);
    pw.Font? fontItalic = await resolveFont(fontPathItalic, fontData);
    pw.Font? fontBoldItalic = await resolveFont(fontPathBoldItalic, fontData);

    return FontBunldle(
        font: font,
        fontNormal: fontNormal,
        fontBold: fontBold,
        fontItalic: fontItalic,
        fontBoldItalic: fontBoldItalic);
  }

  Future<pw.Font?> resolveFont(String font, FontData fontData) async {
    switch (font) {
      case '.AppleSystemUIFont':
        null;
      case 'Courier':
        return pw.Font.courier();
      case 'Helvetica':
        return pw.Font.helvetica();
      case 'Times':
        return pw.Font.times();
      case 'ZapfDingbats':
        return pw.Font.zapfDingbats();
      case 'Symbol':
        return pw.Font.symbol();
      default:
        if (!fontData.ttfFonts.containsKey(font)) {
          throw Exception('Unsupported Font: $font');
        }
        return await resolveCustomFont(
            fontData.ttfFonts[font]!, fontData.assetBundle);
    }
  }

  Future<pw.Font> resolveCustomFont(
      String ttfFontPath, AssetBundle assetBundle) async {
    final bytes = await assetBundle.load(ttfFontPath);
    if (bytes.buffer.asInt8List().isEmpty) {
      throw Exception('Font file $ttfFontPath is empty');
    }
    return pw.Font.ttf(bytes);
  }
}

extension TextDecorationConverter on TextDecoration {
  pw.TextDecoration toPdfTextDecoration() {
    pw.TextDecoration textDecoration = pw.TextDecoration.none;
    if (contains(TextDecoration.underline)) {
      textDecoration.merge(pw.TextDecoration.underline);
    }
    if (contains(TextDecoration.overline)) {
      textDecoration.merge(pw.TextDecoration.overline);
    }
    if (contains(TextDecoration.lineThrough)) {
      textDecoration.merge(pw.TextDecoration.lineThrough);
    }

    return textDecoration;
  }
}

extension TextDecorationStyleConverter on TextDecorationStyle {
  pw.TextDecorationStyle toPdfTextDecorationStyle() {
    switch (this) {
      case TextDecorationStyle.solid:
        return pw.TextDecorationStyle.solid;
      case TextDecorationStyle.double:
        return pw.TextDecorationStyle.double;
      // not supported by pdf package:
      // - TextDecorationStyle.dotted
      // - TextDecorationStyle.dashed
      // - TextDecorationStyle.wavy
      default:
        debugPrint(
            'Unsupported TextDecorationStyle: $this; defaulting to TextDecorationStyle.solid');
        return pw.TextDecorationStyle.solid;
    }
  }
}

extension FontStyleConverter on FontStyle {
  pw.FontStyle toPdfFontStyle() {
    switch (this) {
      case FontStyle.normal:
        return pw.FontStyle.normal;
      case FontStyle.italic:
        return pw.FontStyle.italic;
    }
  }
}

extension FontWeightConverter on FontWeight {
  pw.FontWeight toPdfFontWeight() {
    switch (this) {
      case FontWeight.normal:
        return pw.FontWeight.normal;
      case FontWeight.bold:
        return pw.FontWeight.bold;
      default:
        debugPrint(
            'Unsupported FontWeight: $this; defaulting to FontWeight.normal');
        return pw.FontWeight.normal;
    }
  }
}
