import 'package:flutter/material.dart';

typedef CreateDialogSubmitCallback =
    Future<String?> Function(Map<String, String> values);

typedef CreateFieldRule = String? Function(String? value);
typedef CreateDialogFieldConfig = Map<String, Object?>;

/// Fluent builder to compose multiple validation rules for [CreateDialog]
/// field configurations.
class CreateFieldValidator {
  CreateFieldValidator();

  final List<CreateFieldRule> _rules = [];

  /// Ensures the value is not empty after trimming whitespace.
  CreateFieldValidator required({String message = 'This field is required'}) {
    _rules.add((value) {
      final trimmed = value?.trim() ?? '';
      return trimmed.isEmpty ? message : null;
    });
    return this;
  }

  /// Ensures the value contains '@' when non-empty.
  CreateFieldValidator email({String message = 'Enter a valid email'}) {
    _rules.add((value) {
      final trimmed = value?.trim() ?? '';
      if (trimmed.isEmpty) return null;
      final hasAt = trimmed.contains('@');
      return hasAt ? null : message;
    });
    return this;
  }

  /// Enforces a minimum length. Set [trim] to true to evaluate trimmed values.
  CreateFieldValidator minLength(
    int length, {
    String message = 'Minimum length requirement not met',
    bool trim = true,
  }) {
    _rules.add((value) {
      final source = trim ? value?.trim() : value;
      return (source ?? '').length < length ? message : null;
    });
    return this;
  }

  /// Adds a custom rule to the validator chain.
  CreateFieldValidator custom(CreateFieldRule rule) {
    _rules.add(rule);
    return this;
  }

  /// Allows using the builder as a standard `FormFieldValidator<String>`.
  String? call(String? value) {
    for (final rule in _rules) {
      final result = rule(value);
      if (result != null) return result;
    }
    return null;
  }

  /// Returns the composed validator as a [FormFieldValidator].
  FormFieldValidator<String> build() => call;
}

class _CreateDialogField {
  _CreateDialogField({
    required this.id,
    required this.label,
    this.hint,
    this.initialValue,
    this.validator,
    this.keyboardType,
    this.maxLines = 1,
    this.obscureText = false,
    this.trimOnSubmit = true,
    this.autofocus = false,
    this.textCapitalization = TextCapitalization.none,
  }) : assert(maxLines > 0, 'maxLines must be greater than zero');

  factory _CreateDialogField.fromConfig(CreateDialogFieldConfig config) {
    final id = config['id'];
    final label = config['label'];

    if (id is! String || id.trim().isEmpty) {
      throw ArgumentError.value(
        id,
        'id',
        'Field id must be a non-empty string.',
      );
    }

    if (label is! String || label.trim().isEmpty) {
      throw ArgumentError.value(
        label,
        'label',
        'Field label must be a non-empty string.',
      );
    }

    final maxLines = (config['maxLines'] as int?) ?? 1;
    if (maxLines <= 0) {
      throw ArgumentError.value(
        maxLines,
        'maxLines',
        'maxLines must be greater than zero.',
      );
    }

    final textCapitalization =
        (config['textCapitalization'] as TextCapitalization?) ??
        TextCapitalization.none;

    return _CreateDialogField(
      id: id,
      label: label,
      hint: config['hint'] as String?,
      initialValue: config['initialValue'] as String?,
      validator: config['validator'] as FormFieldValidator<String>?,
      keyboardType: config['keyboardType'] as TextInputType?,
      maxLines: maxLines,
      obscureText: config['obscureText'] as bool? ?? false,
      trimOnSubmit: config['trimOnSubmit'] as bool? ?? true,
      autofocus: config['autofocus'] as bool? ?? false,
      textCapitalization: textCapitalization,
    );
  }

  final String id;
  final String label;
  final String? hint;
  final String? initialValue;
  final FormFieldValidator<String>? validator;
  final TextInputType? keyboardType;
  final int maxLines;
  final bool obscureText;
  final bool trimOnSubmit;
  final bool autofocus;
  final TextCapitalization textCapitalization;
}

/// Generic dialog used to build simple create forms with consistent styling
/// and behaviour (validation, submit loading state, error message rendering).
class CreateDialog extends StatefulWidget {
  CreateDialog({
    super.key,
    required this.title,
    required List<CreateDialogFieldConfig> fields,
    required this.onSubmit,
    this.submitLabel = 'Create',
    this.cancelLabel = 'Cancel',
  }) : _fields = _parseFields(fields);

  final String title;
  final List<_CreateDialogField> _fields;
  final CreateDialogSubmitCallback onSubmit;
  final String submitLabel;
  final String cancelLabel;

  @override
  State<CreateDialog> createState() => _CreateDialogState();

  static List<_CreateDialogField> _parseFields(
    List<CreateDialogFieldConfig> fieldConfigs,
  ) {
    final parsed = fieldConfigs
        .map(_CreateDialogField.fromConfig)
        .toList(growable: false);
    assert(
      parsed.length == _uniqueIds(parsed).length,
      'Each field id must be unique',
    );
    return parsed;
  }

  static Set<String> _uniqueIds(List<_CreateDialogField> fields) =>
      fields.map((field) => field.id).toSet();

  /// Convenience helper to build a [CreateDialogFieldConfig] with sane defaults.
  static CreateDialogFieldConfig field({
    required String id,
    required String label,
    String? hint,
    String? initialValue,
    FormFieldValidator<String>? validator,
    TextInputType? keyboardType,
    int maxLines = 1,
    bool obscureText = false,
    bool trimOnSubmit = true,
    bool autofocus = false,
    TextCapitalization textCapitalization = TextCapitalization.none,
  }) {
    return <String, Object?>{
      'id': id,
      'label': label,
      if (hint != null) 'hint': hint,
      if (initialValue != null) 'initialValue': initialValue,
      if (validator != null) 'validator': validator,
      if (keyboardType != null) 'keyboardType': keyboardType,
      if (maxLines != 1) 'maxLines': maxLines,
      if (obscureText) 'obscureText': obscureText,
      if (!trimOnSubmit) 'trimOnSubmit': trimOnSubmit,
      if (autofocus) 'autofocus': autofocus,
      if (textCapitalization != TextCapitalization.none)
        'textCapitalization': textCapitalization,
    };
  }
}

class _CreateDialogState extends State<CreateDialog> {
  final _formKey = GlobalKey<FormState>();
  late final Map<String, TextEditingController> _controllers;
  String? _submitError;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _controllers = {
      for (final field in widget._fields)
        field.id: TextEditingController(text: field.initialValue ?? ''),
    };
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (_isSubmitting) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() {
      _submitError = null;
      _isSubmitting = true;
    });

    final values = <String, String>{
      for (final field in widget._fields)
        field.id: field.trimOnSubmit
            ? _controllers[field.id]!.text.trim()
            : _controllers[field.id]!.text,
    };

    final result = await widget.onSubmit(values);

    if (!mounted) return;

    if (result == null) {
      Navigator.of(context).pop();
      return;
    }

    setState(() {
      _submitError = result;
      _isSubmitting = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (int i = 0; i < widget._fields.length; i++) ...[
                _buildField(widget._fields[i], isFirstField: i == 0),
                if (i != widget._fields.length - 1) const SizedBox(height: 12),
              ],
              if (_submitError != null) ...[
                const SizedBox(height: 12),
                Text(_submitError!, style: const TextStyle(color: Colors.red)),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting
              ? null
              : () {
                  Navigator.of(context).pop();
                },
          child: Text(widget.cancelLabel),
        ),
        ElevatedButton(
          onPressed: _isSubmitting ? null : _handleSubmit,
          child: _isSubmitting
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(widget.submitLabel),
        ),
      ],
    );
  }

  Widget _buildField(_CreateDialogField field, {required bool isFirstField}) {
    final controller = _controllers[field.id];

    return TextFormField(
      controller: controller,
      autofocus: isFirstField || field.autofocus,
      decoration: InputDecoration(labelText: field.label, hintText: field.hint),
      validator: field.validator,
      keyboardType: field.keyboardType,
      obscureText: field.obscureText,
      maxLines: field.maxLines,
      textCapitalization: field.textCapitalization,
      textInputAction: field.maxLines > 1
          ? TextInputAction.newline
          : TextInputAction.next,
    );
  }
}
