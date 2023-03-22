import 'package:flutter/material.dart' show TextField;

import 'package:pdf/pdf.dart' show PdfColors, PdfFieldFlags;
import 'package:pdf/widgets.dart' as pw show TextField, Text, Widget, Container, EdgeInsets, Stack, Positioned, Transform, Alignment, ConstrainedBox, BoxConstraints;

import '../export_instance.dart';
import '/args/text_style.dart';
import '/args/input_decoration.dart';
import '/args/text_align.dart';
import '/args/text_direction.dart';


extension TextFieldConverter on TextField {
  Future<pw.Widget> toPdfWidget(ExportInstance instance, TextField? contextWidget) async {
    final TextField textField = contextWidget ?? this;

    pw.Widget? label;

    if (textField.decoration?.label != null) {
      final pw.Widget labelWidget = await instance.exportFunc(textField.decoration!.label!);

      label = pw.Transform.scale(
        scale: 0.6,
        child: pw.Container(
          color: PdfColors.white,
          padding: const pw.EdgeInsets.symmetric(horizontal: 2.0),
          child: labelWidget,
        ),
      );
    }

    if (textField.decoration?.labelText != null) {
      label = pw.Transform.scale(
        scale: 0.6,
        child: pw.Container(
          color: PdfColors.white,
          padding: const pw.EdgeInsets.symmetric(horizontal: 2.0),
          child: pw.Text(
            textField.decoration!.labelText!,
          ),
        ),
      );
    }

    return pw.Stack(
      alignment: pw.Alignment.center,
      children: [
        pw.Container(
          padding: const pw.EdgeInsets.all(8.0),
          margin: const pw.EdgeInsets.all(8.0),
          decoration: !instance.delegate.options.textFieldOptions.ignoreDecoration
              ? textField.decoration?.border?.toPdfInputBorder()
              : null,
          child: instance.delegate.options.textFieldOptions.interactive ? pw.TextField(
            width: double.infinity,
            name: textField.hashCode.toString(),
            defaultValue: textField.controller?.value.text,
            textStyle: (instance.delegate.options.textFieldOptions.getTextStyle(textField.key)
                ?? textField.style)?.toPdfTextStyle(),
            maxLength: textField.maxLength,
            fieldFlags: {
              if (textField.maxLines != null && textField.maxLines! > 1) PdfFieldFlags.multiline,
              if (textField.obscureText) PdfFieldFlags.password,
            },
          ) : pw.ConstrainedBox(
            constraints: const pw.BoxConstraints(minHeight: 13, minWidth: double.infinity),
            child: pw.Text(
            textField.controller?.value.text ?? '',
            maxLines: textField.maxLines,
            textAlign: textField.textAlign.toPdfTextAlign(),
            textDirection: textField.textDirection?.toPdfTextDirection(),
            style: (instance.delegate.options.textFieldOptions.getTextStyle(textField.key)
                ?? textField.style)?.toPdfTextStyle(),
          )),
        ),
        if (label != null) pw.Positioned(
          left: 10.0,
          top: 0.0,
          child: label,
        ),
      ],
    );
  }
}
