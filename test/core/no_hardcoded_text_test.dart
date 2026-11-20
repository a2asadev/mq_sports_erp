import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Every word a person reads lives in lib/l10n/app_en.arb (so a new language is
/// one more .arb file). This test fails when screen or widget code puts English
/// text back into the code: Text('...'), labelText: '...', title: '...' and so on.
void main() {
  // Product and credit names are not translated.
  const Set<String> allowed = <String>{'A2 Stocks', 'A2 STOCKS', 'A2 Devs'};

  final RegExp textCall = RegExp(r'''\bText\(\s*(?:const\s+)?(['"])((?:(?!\1).)*[A-Za-z]{2}(?:(?!\1).)*)\1''');
  final RegExp namedText = RegExp(
    r'''\b(?:labelText|hintText|helperText|errorText|tooltip|semanticLabel|title|subtitle|label|content|message|description|emptyText)\s*:\s*(?:const\s+)?(?:Text\(\s*)?(['"])((?:(?!\1).)*[A-Za-z]{2}(?:(?!\1).)*)\1''',
  );

  test('screens and widgets contain no hard-coded user-facing text', () {
    final List<String> found = <String>[];
    for (final String dir in <String>['lib/screens', 'lib/widgets']) {
      for (final FileSystemEntity f in Directory(dir).listSync(recursive: true)) {
        if (f is! File || !f.path.endsWith('.dart')) {
          continue;
        }
        final String src = f.readAsStringSync();
        for (final RegExp re in <RegExp>[textCall, namedText]) {
          for (final RegExpMatch m in re.allMatches(src)) {
            final String text = m.group(2)!;
            // An interpolation that holds quotes of its own ('${a ? 'x' : 'y'}') ends the match early.
            if (allowed.contains(text) || text.startsWith(r'${') || !RegExp(r'[A-Za-z]{2}').hasMatch(text.replaceAll(RegExp(r'\$\w+'), ''))) {
              continue;
            }
            final int line = src.substring(0, m.start).split('\n').length;
            found.add('${f.path.replaceAll('\\', '/')}:$line: "$text"');
          }
        }
      }
    }
    expect(found, isEmpty, reason: 'Move these into lib/l10n/app_en.arb and use context.l10n:\n${found.join('\n')}');
  });
}
