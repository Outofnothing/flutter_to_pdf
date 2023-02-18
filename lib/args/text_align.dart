import 'package:flutter/widgets.dart' show TextAlign;

import 'package:pdf/widgets.dart' as pw show TextAlign;


extension TextAlignConverter on TextAlign {
  pw.TextAlign? toPdfTextAlign() {
    switch (this) {
      case TextAlign.center:
        return pw.TextAlign.center;
      case TextAlign.justify:
        return pw.TextAlign.justify;
      case TextAlign.left:
        return pw.TextAlign.left;
      case TextAlign.right:
        return pw.TextAlign.right;
      // not supported in pdf package:
      // - TextAlign.end
      // - TextAlign.start
      case TextAlign.start:
        return null;
      default:
        throw Exception('Unsupported TextAlign: $this');
    }
  }
}