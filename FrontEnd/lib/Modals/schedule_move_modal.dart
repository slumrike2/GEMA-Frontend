import 'package:flutter/material.dart';
import 'package:frontend/Models/backend_types.dart';
// ...existing code...

class ScheduleMoveModal extends StatefulWidget {
  final Equipment equipment;
  final Map<String, TechnicalLocation> locations;
  final void Function(String? destinationId, String? date, String? notes)
  onScheduleMove;
  final void Function() onConfirmMove;

  const ScheduleMoveModal({
    super.key,
    required this.equipment,
    required this.locations,
    required this.onScheduleMove,
    required this.onConfirmMove,
  });

  @override
  State<ScheduleMoveModal> createState() => _ScheduleMoveModalState();
}

class _ScheduleMoveModalState extends State<ScheduleMoveModal> {
  late String? _destinationId;
  late String? _notes;
  String searchDestination = '';

  @override
  void initState() {
    super.initState();
    _destinationId = widget.equipment.transferLocation;
    _notes = null;
  }

  @override
  Widget build(BuildContext context) {
    final isPendingMove =
        widget.equipment.state == EquipmentState.transferencia_pendiente;
    final filteredLocations =
        widget.locations.values
            .where(
              (loc) =>
                  (loc.name.toLowerCase().contains(
                        searchDestination.toLowerCase(),
                      ) ||
                      loc.technicalCode.toLowerCase().contains(
                        searchDestination.toLowerCase(),
                      )) &&
                  loc.technicalCode != widget.equipment.technicalLocation,
            )
            .toList();
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isPendingMove ? 'Gestionar Mudanza' : 'Programar Mudanza',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              if (isPendingMove) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    border: Border.all(color: Colors.blue.shade200),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Mudanza Programada',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.blue[800],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Destino: ${_destinationId != null ? widget.locations[_destinationId!]?.name ?? "N/A" : "N/A"}',
                        style: TextStyle(color: Colors.blue[700]),
                      ),
                      // ...existing code...
                      if (_notes != null && _notes!.isNotEmpty)
                        Text(
                          'Observaciones: $_notes',
                          style: TextStyle(color: Colors.blue[700]),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: widget.onConfirmMove,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[700],
                        ),
                        child: const Text('Confirmar Mudanza Completada'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cerrar'),
                      ),
                    ),
                  ],
                ),
              ] else ...[
                Text(
                  '📍 Proceso de Mudanza',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 4, bottom: 4),
                  child: Row(
                    children: [
                      const Text(
                        'Actual: ',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (widget.equipment.technicalLocation != null &&
                          widget.locations[widget
                                  .equipment
                                  .technicalLocation!] !=
                              null)
                        Text(
                          '${widget.locations[widget.equipment.technicalLocation!]!.name} (${widget.locations[widget.equipment.technicalLocation!]!.technicalCode})',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.blue,
                            fontWeight: FontWeight.w500,
                          ),
                        )
                      else
                        const Text(
                          'Sin asignar',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.orange,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      const Text('  →  ', style: TextStyle(fontSize: 13)),
                      const Text(
                        'Destino: ',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (_destinationId != null &&
                          widget.locations[_destinationId!] != null)
                        Text(
                          '${widget.locations[_destinationId!]!.name} (${widget.locations[_destinationId!]!.technicalCode})',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.green,
                            fontWeight: FontWeight.w500,
                          ),
                        )
                      else
                        const Text(
                          'Sin seleccionar',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.orange,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                    ],
                  ),
                ),
                TextField(
                  decoration: const InputDecoration(
                    hintText: 'Buscar ubicación de destino...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged:
                      (value) => setState(() => searchDestination = value),
                ),
                const SizedBox(height: 8),
                Container(
                  constraints: const BoxConstraints(maxHeight: 200),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      ListTile(
                        title: const Text('Sin seleccionar'),
                        selected: _destinationId == null,
                        tileColor:
                            _destinationId == null
                                ? Colors.green.shade50
                                : null,
                        textColor: _destinationId == null ? Colors.green : null,
                        onTap: () {
                          setState(() => _destinationId = null);
                        },
                      ),
                      ...filteredLocations.map((loc) {
                        final isSelected = _destinationId == loc.technicalCode;
                        return ListTile(
                          title: Text('${loc.name} (${loc.technicalCode})'),
                          selected: isSelected,
                          tileColor: isSelected ? Colors.green.shade50 : null,
                          textColor: isSelected ? Colors.green : null,
                          onTap: () {
                            setState(() => _destinationId = loc.technicalCode);
                          },
                        );
                      }),
                      if (_destinationId != null &&
                          !filteredLocations.any(
                            (loc) => loc.technicalCode == _destinationId,
                          ) &&
                          widget.locations[_destinationId!] != null)
                        ListTile(
                          title: Text(
                            '${widget.locations[_destinationId!]!.name} (${widget.locations[_destinationId!]!.technicalCode})',
                          ),
                          selected: true,
                          tileColor: Colors.green.shade50,
                          textColor: Colors.green,
                          onTap: () {
                            setState(() => _destinationId = _destinationId);
                          },
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'La ubicación de destino es donde el equipo será movido.',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 12),
                // ...existing code...
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Observaciones'),
                  initialValue: _notes,
                  maxLines: 3,
                  onChanged: (value) => setState(() => _notes = value),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancelar'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        widget.onScheduleMove(_destinationId, null, _notes);
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[700],
                      ),
                      child: const Text('Programar Mudanza'),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
