import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:thewasher/core/design/components/k_text_field.dart';
import 'package:thewasher/core/design/kleano_theme.dart';

Widget host(Widget child) => MaterialApp(
      theme: kleanoTheme(brightness: Brightness.light),
      home: Scaffold(body: Padding(padding: const EdgeInsets.all(16), child: child)),
    );

void main() {
  testWidgets('shows its label above the field', (WidgetTester t) async {
    await t.pumpWidget(host(const KTextField(label: 'Username')));
    expect(find.text('Username'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
  });

  testWidgets('obscure field toggles visibility with the eye button', (WidgetTester t) async {
    await t.pumpWidget(host(const KTextField(label: 'Password', obscure: true)));
    expect(t.widget<EditableText>(find.byType(EditableText)).obscureText, isTrue);
    await t.tap(find.byKey(const ValueKey<String>('k-text-field-visibility')));
    await t.pump();
    expect(t.widget<EditableText>(find.byType(EditableText)).obscureText, isFalse);
  });

  testWidgets('validator error appears below the field', (WidgetTester t) async {
    final GlobalKey<FormState> form = GlobalKey<FormState>();
    await t.pumpWidget(host(Form(
      key: form,
      child: KTextField(
        label: 'Username',
        validator: (String? v) => (v ?? '').isEmpty ? 'Required' : null,
      ),
    )));
    form.currentState!.validate();
    await t.pump();
    expect(find.text('Required'), findsOneWidget);
  });

  testWidgets('passes autofill hints and keyboard type to the text field', (WidgetTester t) async {
    await t.pumpWidget(host(const KTextField(
      label: 'Phone',
      keyboardType: TextInputType.phone,
      autofillHints: <String>[AutofillHints.telephoneNumber],
    )));
    final TextField f = t.widget(find.byType(TextField));
    expect(f.keyboardType, TextInputType.phone);
    expect(f.autofillHints, contains(AutofillHints.telephoneNumber));
  });

  testWidgets('input formatters restrict what can be typed', (WidgetTester t) async {
    final TextEditingController c = TextEditingController();
    await t.pumpWidget(host(KTextField(
      label: 'Phone',
      controller: c,
      inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
    )));
    await t.enterText(find.byType(TextField), '05a1b2');
    expect(c.text, '0512');
  });
}
