// Licensed under the Apache License, Version 2.0
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:otel_lightspeed/otel_lightspeed.dart';
import 'package:test/test.dart';

void main() {
  group('otel_lightspeed', () {
    test('suppression toggles in zone', () async {
      expect(lightspeedInstrumentationSuppressed(), isFalse);
      await runWithoutLightspeedInstrumentationAsync(() async {
        expect(lightspeedInstrumentationSuppressed(), isTrue);
      });
      expect(lightspeedInstrumentationSuppressed(), isFalse);
    });

    test('LightspeedResult fields default null', () {
      const r = LightspeedResult();
      expect(r.statusCode, isNull);
    });
  });
}
