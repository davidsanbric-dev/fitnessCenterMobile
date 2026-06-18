import 'package:flutter_test/flutter_test.dart';
import 'package:portfolio_mobile_app/app/core/shared/schemas/capabilities/capability_dto.dart';

void main() {
  group('CapabilityDto.fromJson', () {
    test('maps the ClassTypeSummary contract', () {
      final dto = CapabilityDto.fromJson({
        'class_type_id': 22,
        'name': 'Strength Intro',
        'schedule_type': 'GROUP',
        'preparation_info': 'Bring towel',
        'pdf_code': 'STR-022',
      });

      expect(dto.id, 22);
      expect(dto.description, 'Strength Intro');
      expect(dto.scheduleType, 'GROUP');
      expect(dto.preparation, 'Bring towel');
      expect(dto.pdfCode, 'STR-022');
    });

    test('maps the ClassSubcategorySummary contract (id from subcategory_id)', () {
      final dto = CapabilityDto.fromJson({
        'subcategory_id': 11,
        'name': 'Yoga Flow',
      });

      expect(dto.id, 11);
      expect(dto.description, 'Yoga Flow');
      // Subcategory summaries carry none of the class-type-only fields.
      expect(dto.scheduleType, '');
      expect(dto.preparation, '');
      expect(dto.pdfCode, '');
    });

    test('maps the ClassCategorySummary contract (id from category_id)', () {
      final dto = CapabilityDto.fromJson({
        'category_id': 3,
        'name': 'Conditioning',
      });

      expect(dto.id, 3);
      expect(dto.description, 'Conditioning');
    });
  });
}
