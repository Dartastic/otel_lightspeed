// Licensed under the Apache License, Version 2.0
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:otel_lightspeed/otel_lightspeed.dart';

/// Traces Lightspeed calls with OpenTelemetry.
///
/// `otel_lightspeed` depends on the OpenTelemetry API only, so the application
/// initializes an SDK once at startup. Wrap each Lightspeed call in
/// [tracedLightspeed]; the `invoke` callback makes the real call and reports what
/// came back, which is recorded on the span.
Future<void> main() async {
  await OTel.initialize(serviceName: 'lightspeed-example');

  // Traces a Lightspeed call.
  final lightspeedId = await tracedLightspeed<String>(
    operation: 'create',
    invoke: () async {
      // Make the Lightspeed call here, then report what it returned.
      const id = 'lightspeed_8f3a2c';
      return const LightspeedCallResult(
          value: id,
          result: LightspeedResult(
              accountId: 'account_8f3a2c',
              shopId: 'shop_8f3a2c',
              locationId: 'location_8f3a2c',
              saleId: 'sale_8f3a2c',
              employeeId: 'employee_8f3a2c',
              customerId: 'customer_8f3a2c',
              productId: 'product_8f3a2c',
              amount: 0.5,
              currency: 'usd',
              statusCode: 201,
              errorCode: 'example',
              errorMessage: 'example'));
    },
  );
  OTelLog.info('tracedLightspeed create returned $lightspeedId');

  // Calls that should not be traced, such as health checks, run inside
  // runWithoutLightspeedInstrumentationAsync.
  await runWithoutLightspeedInstrumentationAsync(
    () => tracedLightspeed<String>(
      operation: 'create',
      invoke: () async {
        const id = 'lightspeed_8f3a2c';
        return const LightspeedCallResult(
            value: id,
            result: LightspeedResult(
                accountId: 'account_8f3a2c',
                shopId: 'shop_8f3a2c',
                locationId: 'location_8f3a2c',
                saleId: 'sale_8f3a2c',
                employeeId: 'employee_8f3a2c',
                customerId: 'customer_8f3a2c',
                productId: 'product_8f3a2c',
                amount: 0.5,
                currency: 'usd',
                statusCode: 201,
                errorCode: 'example',
                errorMessage: 'example'));
      },
    ),
  );

  await OTel.shutdown();
}
