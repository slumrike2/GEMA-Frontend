//Para eliminar

/*import 'package:flutter/material.dart';

class ChangeEquipmentStateModal extends StatefulWidget {
  final String currentState;
  final List<String> possibleStates;
  final Future<void> Function(String newState) onSave;
  final VoidCallback onCancel;

  const ChangeEquipmentStateModal({
    super.key,
    required this.currentState,
    required this.possibleStates,
    required this.onSave,
    required this.onCancel,
  });

  @override
  State<ChangeEquipmentStateModal> createState() => _ChangeEquipmentStateModalState();
}

class _ChangeEquipmentStateModalState extends State<ChangeEquipmentStateModal> {
  String? _selectedState;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _selectedState = widget.currentState;
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: GestureDetector(
        onTap: () => widget.onCancel(),
        child: Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.black54,
          child: GestureDetector(
            onTap: () {}, // Prevent closing when tapping inside the modal
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 500,
                  maxHeight: 600,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.blueGrey.shade100, width: 2),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Cambiar Estado del Equipo',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Estado actual: ${widget.currentState.replaceAll('_', ' ')}',
                          style: const TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                            labelText: 'Nuevo Estado',
                            border: OutlineInputBorder(),
                          ),
                          value: _selectedState,
                          items: widget.possibleStates
                              .map((state) => DropdownMenuItem(
                                    value: state,
                                    child: Text(state.replaceAll('_', ' ')),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedState = value;
                            });
                          },
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: _loading ? null : widget.onCancel,
                              child: const Text('Cancelar'),
                            ),
                            const SizedBox(width: 12),
                            ElevatedButton(
                              onPressed: _loading || _selectedState == null
                                  ? null
                                  : () async {
                                      if (_selectedState != null) {
                                        setState(() {
                                          _loading = true;
                                        });
                                        try {
                                          await widget.onSave(_selectedState!);
                                        } finally {
                                          setState(() {
                                            _loading = false;
                                          });
                                        }
                                      }
                                    },
                              child: _loading
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    )
                                  : const Text('Guardar'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
*/