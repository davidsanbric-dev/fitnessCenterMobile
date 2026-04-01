import 'package:portfolio_mobile_app/app/core/utils/format/date_time.dart';
import 'package:portfolio_mobile_app/app/core/utils/normalize.dart';
import 'package:portfolio_mobile_app/app/core/utils/parse.dart';

class RoleDto {
  const RoleDto({
    required this.id,
    required this.name,
    this.description = '',
    this.permissionIds = const <String>[],
    this.isEliminated = false,
    this.creationDate,
    this.dateLastModified,
  });

  final String id;
  final String name;
  final String description;
  final List<String> permissionIds;
  final bool isEliminated;
  final DateTime? creationDate;
  final DateTime? dateLastModified;

  factory RoleDto.fromJson(Map<String, dynamic> json) {
    final permissions =
        (json['permissionIds'] as List?)
            ?.map((dynamic value) => value.toString())
            .toList(growable: false) ??
        const <String>[];

    final rawId = json['id'] ?? json['Id'] ?? json['roleId'] ?? json['RoleId'];
    final rawName = json['name'] ?? json['Name'];

    return RoleDto(
      id: normReqString(rawId),
      name: normReqString(rawName),
      description: normReqString(json['description']),
      permissionIds: permissions,
      isEliminated: parseBool(json['isEliminated']),
      creationDate: parseDateTime(json['creationDate'] ?? json['creationDate']),
      dateLastModified: parseDateTime(
        json['dateLastModified'] ?? json['updatedAt'],
      ),
    );
  }

  RoleDto copyWith({
    String? id,
    String? name,
    String? description,
    List<String>? permissionIds,
    bool? isEliminated,
    DateTime? creationDate,
    DateTime? dateLastModified,
  }) {
    return RoleDto(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      permissionIds: permissionIds ?? this.permissionIds,
      isEliminated: isEliminated ?? this.isEliminated,
      creationDate: creationDate ?? this.creationDate,
      dateLastModified: dateLastModified ?? this.dateLastModified,
    );
  }

  Map<String, String> toTableRow() {
    final permissionsLabel = permissionIds.isEmpty
        ? 'Sin permisos asignados'
        : '${permissionIds.length} permisos';

    final roleLabel = name.trim().isEmpty ? 'Sin nombre' : name.trim();

    return {
      'id': id,
      'rol': roleLabel,
      'estado': isEliminated ? 'Eliminado' : 'Activo',
      'creado': formatNullableDateTimeLabel(creationDate),
      'actualizado': formatNullableDateTimeLabel(dateLastModified),
      'descripcion': description,
      'permisos': permissionsLabel,
    };
  }

  String get displayName => name.trim().isEmpty ? id : name.trim();
}
