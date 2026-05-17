# otel_lightspeed

Dartastic OpenTelemetry bridge for Lightspeed (retail + restaurant POS).

Wraps each call in a CLIENT-kind span with vendor-specific attributes following OpenTelemetry semantic conventions where applicable.

```dart
import 'package:otel_lightspeed/otel_lightspeed.dart';

await tracedLightspeed<void>(
  operation: 'someOp',
  invoke: () async {
    final r = await client.someOp();
    return LightspeedCallResult(value: r, result: LightspeedResult(statusCode: 200));
  },
);
```

Suppress instrumentation within a block:

```dart
await runWithoutLightspeedInstrumentationAsync(() async {
  await client.someInternalSync();
});
```
