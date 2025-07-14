import 'package:flutter/material.dart';

class ConfirmDeleteEquipmentModal extends StatefulWidget {
  final String technicalCode;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const ConfirmDeleteEquipmentModal({
    super.key,
    required this.technicalCode,
    required this.onConfirm,
    required this.onCancel,
  });

  @override
  State<ConfirmDeleteEquipmentModal> createState() => _ConfirmDeleteEquipmentModalState();
}

class _ConfirmDeleteEquipmentModalState extends State<ConfirmDeleteEquipmentModal> {
  final TextEditingController _controller = TextEditingController();
  bool _showError = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isMatch = _controller.text.trim() == widget.technicalCode;
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Confirmar eliminación',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              'Para eliminar este equipo, escribe el código técnico a continuación:',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                widget.technicalCode,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Código técnico',
                errorText: _showError && !isMatch ? 'El código no coincide' : null,
              ),
              onChanged: (_) {
                setState(() {
                  _showError = false;
                });
              },
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
                  onPressed: isMatch
                      ? () {
                          widget.onConfirm();
                        }
                      : () {
                          setState(() {
                            _showError = true;
                          });
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  child: const Text('Eliminar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
} 