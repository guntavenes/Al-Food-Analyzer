import 'package:ai_food_analyzer/features/barcode_scan/domain/barcode_product.dart';
import 'package:dio/dio.dart';

enum BarcodeLookupError { notFound, unavailable, unknown }

class BarcodeLookupException implements Exception {
  const BarcodeLookupException(this.type);
  final BarcodeLookupError type;
}

class BarcodeProductService {
  const BarcodeProductService(this._dio);
  final Dio _dio;

  Future<BarcodeProduct> find(String barcode) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/v1/products/barcode/$barcode',
      );
      if (response.data == null) {
        throw const BarcodeLookupException(BarcodeLookupError.unknown);
      }
      return BarcodeProduct.fromJson(response.data!);
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) {
        throw const BarcodeLookupException(BarcodeLookupError.notFound);
      }
      if (error.response?.statusCode == 503 ||
          error.type == DioExceptionType.connectionTimeout) {
        throw const BarcodeLookupException(BarcodeLookupError.unavailable);
      }
      throw const BarcodeLookupException(BarcodeLookupError.unknown);
    }
  }
}
