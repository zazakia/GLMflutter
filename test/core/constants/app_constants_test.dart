import 'package:flutter_test/flutter_test.dart';
import 'package:job_order_management/core/constants/app_constants.dart';

void main() {
  group('App Info Constants', () {
    test('appName equals "Job Order Management"', () {
      expect(AppConstants.appName, equals('Job Order Management'));
    });

    test('appVersion equals "1.0.0"', () {
      expect(AppConstants.appVersion, equals('1.0.0'));
    });
  });

  group('Currency Constants', () {
    test('defaultCurrency equals "PHP"', () {
      expect(AppConstants.defaultCurrency, equals('PHP'));
    });

    test('defaultCurrencySymbol equals "₱"', () {
      expect(AppConstants.defaultCurrencySymbol, equals('₱'));
    });
  });

  group('Locale Constants', () {
    test('defaultLocale equals "en_PH"', () {
      expect(AppConstants.defaultLocale, equals('en_PH'));
    });
  });

  group('Pagination Constants', () {
    test('defaultPageSize equals 20', () {
      expect(AppConstants.defaultPageSize, equals(20));
    });

    test('defaultPageSize is a positive integer', () {
      expect(AppConstants.defaultPageSize, isPositive);
    });
  });

  group('Image Upload Limits', () {
    test('maxImageSizeBytes equals 10485760 (10MB in bytes)', () {
      expect(AppConstants.maxImageSizeBytes, equals(10485760));
    });

    test('maxImageDimension equals 1600', () {
      expect(AppConstants.maxImageDimension, equals(1600));
    });

    test('imageQuality equals 70', () {
      expect(AppConstants.imageQuality, equals(70));
    });

    test('imageQuality is between 0 and 100', () {
      expect(AppConstants.imageQuality, inInclusiveRange(0, 100));
    });
  });

  group('Service Report Format', () {
    test('serviceReportNumberFormat equals "SR-YYYYMM-####"', () {
      expect(AppConstants.serviceReportNumberFormat, equals('SR-YYYYMM-####'));
    });

    test('format string contains expected placeholders', () {
      expect(AppConstants.serviceReportNumberFormat, contains('SR-'));
      expect(AppConstants.serviceReportNumberFormat, contains('YYYYMM'));
      expect(AppConstants.serviceReportNumberFormat, contains('####'));
    });
  });

  group('VAT Rate', () {
    test('defaultVatRate equals 0.12', () {
      expect(AppConstants.defaultVatRate, equals(0.12));
    });

    test('defaultVatRate is between 0 and 1', () {
      expect(AppConstants.defaultVatRate, inInclusiveRange(0.0, 1.0));
    });
  });
}