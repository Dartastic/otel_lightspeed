// Licensed under the Dartastic Pro Software License Agreement.
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';

import 'otel_lightspeed_suppression.dart';

class LightspeedResult {
  const LightspeedResult({
    this.accountId,
    this.shopId,
    this.locationId,
    this.saleId,
    this.employeeId,
    this.customerId,
    this.productId,
    this.amount,
    this.currency,
    this.statusCode,
    this.errorCode,
    this.errorMessage,
  });

  final String? accountId;
  final String? shopId;
  final String? locationId;
  final String? saleId;
  final String? employeeId;
  final String? customerId;
  final String? productId;
  final double? amount;
  final String? currency;
  final int? statusCode;
  final String? errorCode;
  final String? errorMessage;
}

class LightspeedCallResult<T> {
  const LightspeedCallResult({required this.value, this.result});
  final T value;
  final LightspeedResult? result;
}

Future<T> tracedLightspeed<T>({
  required String operation,
  required Future<LightspeedCallResult<T>> Function() invoke,
  Tracer? tracer,
}) async {
  if (lightspeedInstrumentationSuppressed()) {
    final r = await invoke();
    return r.value;
  }
  final t = tracer ?? OTel.tracerProvider().getTracer('otel_lightspeed');
  final span = t.startSpan('lightspeed $operation', kind: SpanKind.client);
  try {
    span.setStringAttribute('rpc.system', 'lightspeed');
    final r = await invoke();
    final res = r.result;
    if (res != null) {
      if (res.accountId != null) {
        span.setStringAttribute('lightspeed.account.id', res.accountId!);
      }
      if (res.shopId != null) {
        span.setStringAttribute('lightspeed.shop.id', res.shopId!);
      }
      if (res.locationId != null) {
        span.setStringAttribute('lightspeed.location.id', res.locationId!);
      }
      if (res.saleId != null) {
        span.setStringAttribute('lightspeed.sale.id', res.saleId!);
      }
      if (res.employeeId != null) {
        span.setStringAttribute('lightspeed.employee.id', res.employeeId!);
      }
      if (res.customerId != null) {
        span.setStringAttribute('lightspeed.customer.id', res.customerId!);
      }
      if (res.productId != null) {
        span.setStringAttribute('lightspeed.product.id', res.productId!);
      }
      if (res.amount != null) {
        span.setDoubleAttribute('lightspeed.amount', res.amount!);
      }
      if (res.currency != null) {
        span.setStringAttribute('lightspeed.currency', res.currency!);
      }
      if (res.statusCode != null) {
        span.setIntAttribute('http.response.status_code', res.statusCode!);
      }
      if (res.errorCode != null) {
        span.setStringAttribute('lightspeed.error.code', res.errorCode!);
      }
      final fail =
          res.errorCode != null ||
          (res.statusCode != null && res.statusCode! >= 400);
      if (fail) {
        span.setStringAttribute(
          ErrorResource.errorType.key,
          res.errorCode ?? 'lightspeed.error',
        );
        span.setStatus(SpanStatusCode.Error, res.errorMessage);
      }
    }
    return r.value;
  } catch (e, st) {
    span.recordException(e, stackTrace: st);
    span.setStatus(SpanStatusCode.Error, e.toString());
    rethrow;
  } finally {
    span.end();
  }
}
