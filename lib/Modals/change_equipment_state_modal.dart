import 'package:flutter/material.dart';

class ChangeEquipmentStateModal extends StatefulWidget {
  final String currentState;
  final List<String> possibleStates;
  final void Function(String) onSave;
  final VoidCallback onCancel;

  const ChangeEquipmentStateModal({
    super.key,
    required this.currentState,
    required this.possibleStates,
    required this.onSave,
    required this.onCancel,
  });

  @override
  State<ChangeEquipmentStateModal> createState() =>
      _ChangeEquipmentStateModalState();
}

class _ChangeEquipmentStateModalState extends State<ChangeEquipmentStateModal> {
  late String _selectedState;

  @override
  void initState() {
    super.initState();
    // If currentState is not in possibleStates, use the first possible state
    _selectedState =
        widget.possibleStates.contains(widget.currentState)
            ? widget.currentState
            : (widget.possibleStates.isNotEmpty
                ? widget.possibleStates.first
                : '');
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Cambiar estado del equipo',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedState,
              items:
                  widget.possibleStates
                      .map(
                        (state) => DropdownMenuItem(
                          value: state,
                          child: Text(state.replaceAll('_', ' ')),
                        ),
                      )
                      .toList(),
              onChanged: (value) {
                if (value != null) setState(() => _selectedState = value);
              },
              decoration: const InputDecoration(
                labelText: 'Nuevo estado',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: widget.onCancel,
                  child: const Text('Cancelar'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () => widget.onSave(_selectedState),
                  child: const Text('Guardar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
