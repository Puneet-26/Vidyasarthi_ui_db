import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'form_fields.dart';

/// Professional Form Dialog for various operations
class ProfessionalFormDialog extends StatefulWidget {
  final String title;
  final String description;
  final String submitButtonText;
  final VoidCallback? onSubmit;
  final List<FormField> formFields;
  final bool isLoading;
  final Widget? customContent;

  const ProfessionalFormDialog({
    required this.title,
    required this.formFields,
    this.description = '',
    this.submitButtonText = 'Submit',
    this.onSubmit,
    this.isLoading = false,
    this.customContent,
    super.key,
  });

  static Future<bool?> show(
    BuildContext context, {
    required String title,
    required List<FormField> formFields,
    String description = '',
    String submitButtonText = 'Submit',
    VoidCallback? onSubmit,
    bool isLoading = false,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => ProfessionalFormDialog(
        title: title,
        formFields: formFields,
        description: description,
        submitButtonText: submitButtonText,
        onSubmit: onSubmit,
        isLoading: isLoading,
      ),
    );
  }

  @override
  State<ProfessionalFormDialog> createState() => _ProfessionalFormDialogState();
}

class _ProfessionalFormDialogState extends State<ProfessionalFormDialog> {
  late Map<String, dynamic> _values;
  late Map<String, String?> _errors;

  @override
  void initState() {
    super.initState();
    _values = {};
    _errors = {};
    for (var field in widget.formFields) {
      _values[field.name] = field.initialValue;
      _errors[field.name] = null;
    }
  }

  void _validateField(String name) {
    final field = widget.formFields.firstWhere((f) => f.name == name);
    if (field.validator != null) {
      setState(() {
        _errors[name] = field.validator!(_values[name]);
      });
    }
  }

  void _validateAll() {
    for (var field in widget.formFields) {
      _validateField(field.name);
    }
  }

  bool _isFormValid() {
    return _errors.values.every((error) => error == null || error.isEmpty);
  }

  void _handleSubmit() {
    _validateAll();
    if (_isFormValid()) {
      widget.onSubmit?.call();
      if (mounted && !widget.isLoading) {
        Navigator.pop(context, true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryLight],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          if (widget.description.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              widget.description,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white.withOpacity(0.8),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: widget.isLoading ? null : () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Content
              Padding(
                padding: const EdgeInsets.all(20),
                child: widget.customContent ??
                    Column(
                      children: [
                        ...widget.formFields.map(
                          (field) => Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: _buildFormField(
                              field,
                              _values[field.name],
                              _errors[field.name],
                            ),
                          ),
                        ),
                      ],
                    ),
              ),

              // Actions
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: widget.isLoading ? null : () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          side: const BorderSide(color: AppColors.primary),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: widget.isLoading ? null : _handleSubmit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          disabledBackgroundColor: AppColors.primary.withOpacity(0.5),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: widget.isLoading
                            ? const SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                widget.submitButtonText,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormField(
    FormField field,
    dynamic value,
    String? error,
  ) {
    switch (field.type) {
      case FormFieldType.text:
        return ProfessionalTextField(
          controller: field.controller ?? TextEditingController(text: value?.toString() ?? ''),
          label: field.label,
          hint: field.hint ?? '',
          prefixIcon: field.icon,
          isRequired: field.isRequired,
          isLoading: widget.isLoading,
          errorText: error,
          keyboardType: field.keyboardType ?? TextInputType.text,
          onChanged: (val) {
            setState(() => _values[field.name] = val);
            if (error != null) {
              _validateField(field.name);
            }
          },
        );

      case FormFieldType.dropdown:
        return ProfessionalDropdown(
          label: field.label,
          value: value,
          items: field.items ?? [],
          isRequired: field.isRequired,
          isLoading: widget.isLoading,
          errorText: error,
          hint: field.hint ?? 'Select option',
          onChanged: (val) {
            setState(() => _values[field.name] = val);
            if (error != null) {
              _validateField(field.name);
            }
          },
        );

      case FormFieldType.date:
        return ProfessionalDateField(
          label: field.label,
          selectedDate: value as DateTime?,
          isRequired: field.isRequired,
          isLoading: widget.isLoading,
          errorText: error,
          firstDate: field.firstDate,
          lastDate: field.lastDate,
          onChanged: (val) {
            setState(() => _values[field.name] = val);
            if (error != null) {
              _validateField(field.name);
            }
          },
        );

      case FormFieldType.checkbox:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ProfessionalCheckbox(
              value: value == true,
              label: field.label,
              isLoading: widget.isLoading,
              onChanged: (val) {
                setState(() => _values[field.name] = val);
                if (error != null) {
                  _validateField(field.name);
                }
              },
            ),
            if (error != null)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  error,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.red.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        );

      case FormFieldType.radio:
        return ProfessionalRadioGroup(
          label: field.label,
          value: value,
          options: field.radioOptions ?? [],
          isRequired: field.isRequired,
          isLoading: widget.isLoading,
          onChanged: (val) {
            setState(() => _values[field.name] = val);
            if (error != null) {
              _validateField(field.name);
            }
          },
        );

      case FormFieldType.number:
        return ProfessionalNumberField(
          controller: field.controller ?? TextEditingController(text: value?.toString() ?? ''),
          label: field.label,
          hint: field.hint ?? '',
          min: field.min,
          max: field.max,
          isRequired: field.isRequired,
          isLoading: widget.isLoading,
          errorText: error,
          onChanged: (val) {
            setState(() => _values[field.name] = val);
            if (error != null) {
              _validateField(field.name);
            }
          },
        );
    }
  }
}

/// Form Field Definition
enum FormFieldType { text, dropdown, date, checkbox, radio, number }

class FormField {
  final String name;
  final String label;
  final FormFieldType type;
  final String? hint;
  final dynamic initialValue;
  final bool isRequired;
  final IconData? icon;
  final TextEditingController? controller;
  final String? Function(dynamic)? validator;

  // For dropdown
  final List<DropdownMenuItem>? items;

  // For date
  final DateTime? firstDate;
  final DateTime? lastDate;

  // For number
  final int? min;
  final int? max;

  // For text
  final TextInputType? keyboardType;

  // For radio
  final List<({dynamic value, String label})>? radioOptions;

  FormField({
    required this.name,
    required this.label,
    required this.type,
    this.hint,
    this.initialValue,
    this.isRequired = false,
    this.icon,
    this.controller,
    this.validator,
    this.items,
    this.firstDate,
    this.lastDate,
    this.min,
    this.max,
    this.keyboardType,
    this.radioOptions,
  });
}

/// Admission Form Dialog Helper
class AdmissionFormDialog {
  static Future<void> show(BuildContext context) {
    return ProfessionalFormDialog.show(
      context,
      title: 'New Student Admission',
      description: 'Register a new student in the system',
      submitButtonText: 'Register Student',
      formFields: [
        FormField(
          name: 'firstName',
          label: 'First Name',
          type: FormFieldType.text,
          hint: 'Enter first name',
          icon: Icons.person_outline,
          isRequired: true,
          validator: (val) => val?.isEmpty ?? true ? 'First name is required' : null,
        ),
        FormField(
          name: 'lastName',
          label: 'Last Name',
          type: FormFieldType.text,
          hint: 'Enter last name',
          icon: Icons.person_outline,
          isRequired: true,
          validator: (val) => val?.isEmpty ?? true ? 'Last name is required' : null,
        ),
        FormField(
          name: 'email',
          label: 'Email Address',
          type: FormFieldType.text,
          hint: 'student@example.com',
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
          isRequired: true,
          validator: (val) {
            if (val?.isEmpty ?? true) return 'Email is required';
            if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(val)) {
              return 'Please enter a valid email';
            }
            return null;
          },
        ),
        FormField(
          name: 'phone',
          label: 'Phone Number',
          type: FormFieldType.text,
          hint: '9876543210',
          icon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
          isRequired: true,
          validator: (val) => val?.isEmpty ?? true ? 'Phone number is required' : null,
        ),
        FormField(
          name: 'dateOfBirth',
          label: 'Date of Birth',
          type: FormFieldType.date,
          isRequired: true,
          lastDate: DateTime.now(),
          validator: (val) => val == null ? 'Date of birth is required' : null,
        ),
        FormField(
          name: 'class',
          label: 'Class/Grade',
          type: FormFieldType.dropdown,
          hint: 'Select class',
          isRequired: true,
          items: [
            const DropdownMenuItem(value: 'Class 1', child: Text('Class 1')),
            const DropdownMenuItem(value: 'Class 2', child: Text('Class 2')),
            const DropdownMenuItem(value: 'Class 3', child: Text('Class 3')),
            const DropdownMenuItem(value: 'Class 4', child: Text('Class 4')),
            const DropdownMenuItem(value: 'Class 5', child: Text('Class 5')),
          ],
          validator: (val) => val == null ? 'Class is required' : null,
        ),
      ],
      onSubmit: () {
        // Handle admission submission
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Student registered successfully')),
        );
      },
    );
  }
}