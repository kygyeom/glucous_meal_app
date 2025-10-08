import 'package:flutter/material.dart';

class EditTextDialog extends StatefulWidget {
  final String title;
  final String initialValue;
  final String? hint;
  final TextInputType? keyboardType;

  const EditTextDialog({
    super.key,
    required this.title,
    required this.initialValue,
    this.hint,
    this.keyboardType,
  });

  @override
  State<EditTextDialog> createState() => _EditTextDialogState();
}

class _EditTextDialogState extends State<EditTextDialog> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('${widget.title} 수정'),
      content: TextField(
        controller: _controller,
        keyboardType: widget.keyboardType,
        decoration: InputDecoration(
          hintText: widget.hint,
          border: const OutlineInputBorder(),
        ),
        autofocus: true,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('취소'),
        ),
        ElevatedButton(
          onPressed: () {
            final value = _controller.text.trim();
            if (value.isNotEmpty) {
              Navigator.of(context).pop(value);
            }
          },
          child: const Text('저장'),
        ),
      ],
    );
  }
}

class EditNumberDialog extends StatefulWidget {
  final String title;
  final double initialValue;
  final String? hint;
  final String? suffix;

  const EditNumberDialog({
    super.key,
    required this.title,
    required this.initialValue,
    this.hint,
    this.suffix,
  });

  @override
  State<EditNumberDialog> createState() => _EditNumberDialogState();
}

class _EditNumberDialogState extends State<EditNumberDialog> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.initialValue.toString(),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('${widget.title} 수정'),
      content: TextField(
        controller: _controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(
          hintText: widget.hint,
          suffixText: widget.suffix,
          border: const OutlineInputBorder(),
        ),
        autofocus: true,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('취소'),
        ),
        ElevatedButton(
          onPressed: () {
            final value = double.tryParse(_controller.text.trim());
            if (value != null && value > 0) {
              Navigator.of(context).pop(value);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('유효한 숫자를 입력하세요')),
              );
            }
          },
          child: const Text('저장'),
        ),
      ],
    );
  }
}

class EditSelectionDialog extends StatelessWidget {
  final String title;
  final String currentValue;
  final List<String> options;

  const EditSelectionDialog({
    super.key,
    required this.title,
    required this.currentValue,
    required this.options,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('${title} 선택'),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: options.length,
          itemBuilder: (context, index) {
            final option = options[index];
            final isSelected = option == currentValue;
            return ListTile(
              title: Text(option),
              trailing: isSelected ? const Icon(Icons.check, color: Colors.green) : null,
              onTap: () => Navigator.of(context).pop(option),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('취소'),
        ),
      ],
    );
  }
}

class EditMultiSelectionDialog extends StatefulWidget {
  final String title;
  final List<String> currentValues;
  final List<String> options;

  const EditMultiSelectionDialog({
    super.key,
    required this.title,
    required this.currentValues,
    required this.options,
  });

  @override
  State<EditMultiSelectionDialog> createState() =>
      _EditMultiSelectionDialogState();
}

class _EditMultiSelectionDialogState extends State<EditMultiSelectionDialog> {
  late List<String> _selectedValues;

  @override
  void initState() {
    super.initState();
    _selectedValues = List.from(widget.currentValues);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('${widget.title} 선택'),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: widget.options.length,
          itemBuilder: (context, index) {
            final option = widget.options[index];
            final isSelected = _selectedValues.contains(option);
            return CheckboxListTile(
              title: Text(option),
              value: isSelected,
              onChanged: (checked) {
                setState(() {
                  if (checked == true) {
                    _selectedValues.add(option);
                  } else {
                    _selectedValues.remove(option);
                  }
                });
              },
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('취소'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_selectedValues.isNotEmpty) {
              Navigator.of(context).pop(_selectedValues);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('최소 하나 이상 선택하세요')),
              );
            }
          },
          child: const Text('저장'),
        ),
      ],
    );
  }
}
