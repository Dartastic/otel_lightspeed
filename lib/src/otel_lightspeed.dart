// Licensed under the Dartastic Pro Software License Agreement.
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';

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
    span.addAttributes(
        OTel.attributes([OTel.attributeString('rpc.system', 'lightspeed')]));
    final r = await invoke();
    final res = r.result;
    if (res != null) {
      if (res.accountId != null) {
        span.addAttributes(OTel.attributes(
            [OTel.attributeString('lightspeed.account.id', res.accountId!)]));
      }
      if (res.shopId != null) {
        span.addAttributes(OTel.attributes(
            [OTel.attributeString('lightspeed.shop.id', res.shopId!)]));
      }
      if (res.locationId != null) {
        span.addAttributes(OTel.attributes(
            [OTel.attributeString('lightspeed.location.id', res.locationId!)]));
      }
      if (res.saleId != null) {
        span.addAttributes(OTel.attributes(
            [OTel.attributeString('lightspeed.sale.id', res.saleId!)]));
      }
      if (res.employeeId != null) {
        span.addAttributes(OTel.attributes(
            [OTel.attributeString('lightspeed.employee.id', res.employeeId!)]));
      }
      if (res.customerId != null) {
        span.addAttributes(OTel.attributes(
            [OTel.attributeString('lightspeed.customer.id', res.customerId!)]));
      }
      if (res.productId != null) {
        span.addAttributes(OTel.attributes(
            [OTel.attributeString('lightspeed.product.id', res.productId!)]));
      }
      if (res.amount != null) {
        span.addAttributes(OTel.attributes(
            [OTel.attributeDouble('lightspeed.amount', res.amount!)]));
      }
      if (res.currency != null) {
        span.addAttributes(OTel.attributes(
            [OTel.attributeString('lightspeed.currency', res.currency!)]));
      }
      if (res.statusCode != null) {
        span.addAttributes(OTel.attributes(
            [OTel.attributeInt('http.response.status_code', res.statusCode!)]));
      }
      if (res.errorCode != null) {
        span.addAttributes(OTel.attributes(
            [OTel.attributeString('lightspeed.error.code', res.errorCode!)]));
      }
      final fail = res.errorCode != null ||
          (res.statusCode != null && res.statusCode! >= 400);
      if (fail) {
        span.addAttributes(OTel.attributes([
          OTel.attributeString(
            ErrorResource.errorType.key,
            res.errorCode ?? 'lightspeed.error',
          )
        ]));
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
