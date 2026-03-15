import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

/// Professional Text Input Field with validation
class ProfessionalTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final int maxLines;
  final int minLines;
  final String? Function(String?)? validator;
  final Function(String)? onChanged;
  final Function(String)? onSubmitted;
  final VoidCallback? onSuffixIconTap;
  final List<TextInputFormatter>? inputFormatters;
  final bool isRequired;
  final bool isLoading;
  final String? errorText;
  final Widget? prefixWidget;

  const ProfessionalTextField({
    required this.controller,
    required this.label,
    required this.hint,
    this.prefixIcon,
    this.suffixIcon,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.maxLines = 1,
    this.minLines = 1,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.onSuffixIconTap,
    this.inputFormatters,
    this.isRequired = false,
    this.isLoading = false,
    this.errorText,
    this.prefixWidget,
    super.key,
  });

  @override
  State<ProfessionalTextField> createState() => _ProfessionalTextFieldState();
}

class _ProfessionalTextFieldState extends State<ProfessionalTextField> {
  late FocusNode _focusNode;
  String? _localError;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _localError = widget.errorText;
  }

  @override
  void didUpdateWidget(ProfessionalTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    _localError = widget.errorText;
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasFocus = _focusNode.hasFocus;
    final hasError = _localError != null && _localError!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: widget.label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
              if (widget.isRequired)
                const TextSpan(
                  text: ' *',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.w700,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Focus(
          onFocusChange: (_) => setState(() {}),
          child: TextField(
            controller: widget.controller,
            focusNode: _focusNode,
            enabled: !widget.isLoading,
            keyboardType: widget.keyboardType,
            textInputAction: widget.textInputAction,
            inputFormatters: widget.inputFormatters,
            maxLines: widget.maxLines,
            minLines: widget.minLines,
            onChanged: (value) {
              if (_localError != null) {
                setState(() {
                  if (widget.validator != null) {
                    _localError = widget.validator!(value);
                  }
                });
              }
              widget.onChanged?.call(value);
            },
            onSubmitted: widget.onSubmitted,
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: TextStyle(
                color: AppColors.textLight.withOpacity(0.6),
                fontSize: 13,
              ),
              filled: true,
              fillColor: hasError
                  ? Colors.red.withOpacity(0.05)
                  : (hasFocus ? Colors.white : Colors.grey.withOpacity(0.05)),
              prefixIcon: widget.prefixWidget ??
                  (widget.prefixIcon != null
                      ? Icon(
                          widget.prefixIcon,
                          color: hasError ? Colors.red : AppColors.primary,
                          size: 20,
                        )
                      : null),
              suffixIcon: widget.suffixIcon != null
                  ? GestureDetector(
                      onTap: widget.isLoading ? null : widget.onSuffixIconTap,
                      child: Icon(
                        widget.suffixIcon,
                        color: hasError
                            ? Colors.red.withOpacity(0.7)
                            : AppColors.primary.withOpacity(0.6),
                        size: 20,
                      ),
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: hasError ? Colors.red.withOpacity(0.3) : Colors.transparent,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: hasError ? Colors.red.withOpacity(0.3) : Colors.transparent,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: hasError ? Colors.red.withOpacity(0.5) : AppColors.primary,
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              errorText: null,
              counterText: '',
            ),
          ),
        ),
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              _localError!,
              style: TextStyle(
                fontSize: 12,
                color: Colors.red.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }
}

/// Professional Dropdown Field
class ProfessionalDropdown<T> extends StatefulWidget {
  final String label;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final Function(T?)? onChanged;
  final IconData? prefixIcon;
  final bool isRequired;
  final bool isLoading;
  final String? errorText;
  final String hint;

  const ProfessionalDropdown({
    required this.label,
    required this.items,
    this.value,
    this.onChanged,
    this.prefixIcon,
    this.isRequired = false,
    this.isLoading = false,
    this.errorText,
    this.hint = 'Select option',
    super.key,
  });

  @override
  State<ProfessionalDropdown<T>> createState() => _ProfessionalDropdownState<T>();
}

class _ProfessionalDropdownState<T> extends State<ProfessionalDropdown<T>> {
  @override
  Widget build(BuildContext context) {
    final hasError = widget.errorText != null && widget.errorText!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: widget.label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
              if (widget.isRequired)
                const TextSpan(
                  text: ' *',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.w700,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: hasError ? Colors.red.withOpacity(0.05) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: hasError ? Colors.red.withOpacity(0.3) : Colors.transparent,
            ),
          ),
          child: DropdownButton<T>(
            value: widget.value,
            hint: Text(
              widget.hint,
              style: TextStyle(
                color: AppColors.textLight.withOpacity(0.6),
              ),
            ),
            items: widget.items,
            onChanged: widget.isLoading ? null : widget.onChanged,
            isExpanded: true,
            underline: const SizedBox(),
            style: const TextStyle(
              color: AppColors.textDark,
              fontSize: 13,
            ),
            icon: Icon(
              Icons.keyboard_arrow_down_rounded,
              color: AppColors.primary.withOpacity(0.6),
            ),
          ),
        ),
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              widget.errorText!,
              style: TextStyle(
                fontSize: 12,
                color: Colors.red.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }
}

/// Professional Date Picker Field
class ProfessionalDateField extends StatefulWidget {
  final String label;
  final DateTime? selectedDate;
  final Function(DateTime?)? onChanged;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final bool isRequired;
  final bool isLoading;
  final String? errorText;

  const ProfessionalDateField({
    required this.label,
    this.selectedDate,
    this.onChanged,
    this.firstDate,
    this.lastDate,
    this.isRequired = false,
    this.isLoading = false,
    this.errorText,
    super.key,
  });

  @override
  State<ProfessionalDateField> createState() => _ProfessionalDateFieldState();
}

class _ProfessionalDateFieldState extends State<ProfessionalDateField> {
  @override
  Widget build(BuildContext context) {
    final hasError = widget.errorText != null && widget.errorText!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: widget.label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
              if (widget.isRequired)
                const TextSpan(
                  text: ' *',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.w700,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: widget.isLoading
              ? null
              : () async {
                  final pickedDate = await showDatePicker(
                    context: context,
                    initialDate: widget.selectedDate ?? DateTime.now(),
                    firstDate: widget.firstDate ?? DateTime(1900),
                    lastDate: widget.lastDate ?? DateTime.now(),
                  );
                  if (pickedDate != null) {
                    widget.onChanged?.call(pickedDate);
                  }
                },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: hasError ? Colors.red.withOpacity(0.05) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: hasError ? Colors.red.withOpacity(0.3) : Colors.transparent,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.selectedDate != null
                      ? '${widget.selectedDate!.day}/${widget.selectedDate!.month}/${widget.selectedDate!.year}'
                      : 'Select date',
                  style: TextStyle(
                    color: widget.selectedDate != null
                        ? AppColors.textDark
                        : AppColors.textLight.withOpacity(0.6),
                    fontSize: 13,
                  ),
                ),
                Icon(
                  Icons.calendar_today_rounded,
                  color: hasError ? Colors.red : AppColors.primary,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              widget.errorText!,
              style: TextStyle(
                fontSize: 12,
                color: Colors.red.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }
}

/// Professional Checkbox Field
class ProfessionalCheckbox extends StatefulWidget {
  final bool value;
  final String label;
  final Function(bool)? onChanged;
  final bool isLoading;

  const ProfessionalCheckbox({
    required this.value,
    required this.label,
    this.onChanged,
    this.isLoading = false,
    super.key,
  });

  @override
  State<ProfessionalCheckbox> createState() => _ProfessionalCheckboxState();
}

class _ProfessionalCheckboxState extends State<ProfessionalCheckbox> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.isLoading ? null : () => widget.onChanged?.call(!widget.value),
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              border: Border.all(
                color: widget.value ? AppColors.primary : AppColors.textLight.withOpacity(0.3),
                width: 2,
              ),
              borderRadius: BorderRadius.circular(6),
              color: widget.value ? AppColors.primary : Colors.transparent,
            ),
            child: widget.value
                ? const Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 14,
                  )
                : null,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              widget.label,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textMid,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Professional Radio Button Field
class ProfessionalRadioGroup<T> extends StatelessWidget {
  final String label;
  final T value;
  final List<({T value, String label})> options;
  final Function(T)? onChanged;
  final bool isRequired;
  final bool isLoading;

  const ProfessionalRadioGroup({
    required this.label,
    required this.value,
    required this.options,
    this.onChanged,
    this.isRequired = false,
    this.isLoading = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
              if (isRequired)
                const TextSpan(
                  text: ' *',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.w700,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Column(
          children: options
              .map(
                (option) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: GestureDetector(
                    onTap: isLoading ? null : () => onChanged?.call(option.value),
                    child: Row(
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: value == option.value
                                  ? AppColors.primary
                                  : AppColors.textLight.withOpacity(0.3),
                              width: 2,
                            ),
                          ),
                          child: value == option.value
                              ? Container(
                                  margin: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.primary,
                                  ),
                                )
                              : null,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            option.label,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textMid,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

/// Professional Number Input Field with spinner
class ProfessionalNumberField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final int? min;
  final int? max;
  final Function(int?)? onChanged;
  final bool isRequired;
  final bool isLoading;
  final String? errorText;

  const ProfessionalNumberField({
    required this.controller,
    required this.label,
    required this.hint,
    this.min,
    this.max,
    this.onChanged,
    this.isRequired = false,
    this.isLoading = false,
    this.errorText,
    super.key,
  });

  @override
  State<ProfessionalNumberField> createState() => _ProfessionalNumberFieldState();
}

class _ProfessionalNumberFieldState extends State<ProfessionalNumberField> {
  late FocusNode _focusNode;
  String? _localError;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _localError = widget.errorText;
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _increment() {
    final current = int.tryParse(widget.controller.text) ?? 0;
    final newValue = current + 1;
    if (widget.max == null || newValue <= widget.max!) {
      widget.controller.text = newValue.toString();
      widget.onChanged?.call(newValue);
    }
  }

  void _decrement() {
    final current = int.tryParse(widget.controller.text) ?? 0;
    final newValue = current - 1;
    if (widget.min == null || newValue >= widget.min!) {
      widget.controller.text = newValue.toString();
      widget.onChanged?.call(newValue);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasError = _localError != null && _localError!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: widget.label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
              if (widget.isRequired)
                const TextSpan(
                  text: ' *',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.w700,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: hasError ? Colors.red.withOpacity(0.05) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: hasError ? Colors.red.withOpacity(0.3) : Colors.transparent,
            ),
          ),
          child: Row(
            children: [
              IconButton(
                onPressed: widget.isLoading ? null : _decrement,
                icon: const Icon(Icons.remove_rounded),
                color: AppColors.primary,
              ),
              Expanded(
                child: TextField(
                  controller: widget.controller,
                  focusNode: _focusNode,
                  enabled: !widget.isLoading,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  textAlign: TextAlign.center,
                  onChanged: (value) {
                    final intValue = int.tryParse(value);
                    widget.onChanged?.call(intValue);
                  },
                  decoration: InputDecoration(
                    hintText: widget.hint,
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    hintStyle: TextStyle(
                      color: AppColors.textLight.withOpacity(0.6),
                    ),
                  ),
                ),
              ),
              IconButton(
                onPressed: widget.isLoading ? null : _increment,
                icon: const Icon(Icons.add_rounded),
                color: AppColors.primary,
              ),
            ],
          ),
        ),
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              _localError!,
              style: TextStyle(
                fontSize: 12,
                color: Colors.red.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }
}