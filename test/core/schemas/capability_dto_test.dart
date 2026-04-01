import 'package:flutter_test/flutter_test.dart';
import 'package:portfolio_mobile_app/app/core/shared/schemas/capabilities/capability_dto.dart';

void main() {
  group('CapabilityDto.fromJson', () {
    test('parses snake_case capability payload', () {
      final dto = CapabilityDto.fromJson({
        'subcategory_id': 11,
        'name': 'Yoga Flow',
        'location_id': 1,
        'schedule_type': 'GROUP',
        'preparation_info': 'Bring a mat',
        'pdf_code': 'YOGA-001',
      });

      expect(dto.id, 11);
      expect(dto.description, 'Yoga Flow');
      expect(dto.locationId, 1);
      expect(dto.scheduleType, 'GROUP');
      expect(dto.preparation, 'Bring a mat');
      expect(dto.pdfCode, 'YOGA-001');
    });

    test('parses camelCase capability payload', () {
      final dto = CapabilityDto.fromJson({
        'classTypeId': 22,
        'description': 'Strength Intro',
        'locationId': 2,
        'scheduleType': 'GROUP',
        'preparation': 'Bring towel',
        'pdfCode': 'STR-022',
      });

      expect(dto.id, 22);
      expect(dto.description, 'Strength Intro');
      expect(dto.locationId, 2);
      expect(dto.scheduleType, 'GROUP');
      expect(dto.preparation, 'Bring towel');
      expect(dto.pdfCode, 'STR-022');
    });

    test('prioritizes explicit id when present', () {
      final dto = CapabilityDto.fromJson({
        'id': 99,
        'categoryId': 1,
        'subcategoryId': 2,
        'classTypeId': 3,
        'name': 'Any',
      });

      expect(dto.id, 99);
    });
  });
}
