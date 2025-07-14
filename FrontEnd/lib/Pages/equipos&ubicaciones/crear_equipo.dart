import 'package:flutter/material.dart';
import '../../Models/backend_types.dart';
import '../../Services/equipment_service.dart';

class CrearEquipo extends StatefulWidget {
  final VoidCallback? onBack;
  final void Function()? onSuccess;
  final List<Brand> brands;
  const CrearEquipo({
    super.key,
    this.onBack,
    this.onSuccess,
    required this.brands,
  });

  @override
  State<CrearEquipo> createState() => _CrearEquipoState();
}

class _CrearEquipoState extends State<CrearEquipo> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _serialController = TextEditingController();
  final TextEditingController _technicalCodeController =
      TextEditingController();
  Brand? _selectedBrand;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.brands.isNotEmpty) {
      _selectedBrand = widget.brands.first;
    }
  }

  Future<void> _onSave() async {
    setState(() => _isLoading = true);
    try {
      if (_technicalCodeController.text.isEmpty ||
          _nameController.text.isEmpty ||
          _serialController.text.isEmpty ||
          _selectedBrand == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Todos los campos son obligatorios.')),
        );
        setState(() => _isLoading = false);
        return;
      }
      final newEquipment = Equipment(
        technicalCode: _technicalCodeController.text,
        name: _nameController.text,
        serialNumber: _serialController.text,
        brandId: _selectedBrand!.id ?? 1,
      );
      await EquipmentService.create(newEquipment.toJson());
      widget.onSuccess?.call();
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _serialController.dispose();
    _technicalCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD6ECE0),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (widget.onBack != null)
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: widget.onBack,
                      ),
                    ),
                  const Expanded(
                    child: Text(
                      'Crear/Modificar Equipo',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nombre'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _serialController,
                decoration: const InputDecoration(labelText: 'Número de Serie'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _technicalCodeController,
                decoration: const InputDecoration(labelText: 'Código Técnico'),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<Brand>(
                value: _selectedBrand,
                items:
                    widget.brands
                        .map(
                          (b) => DropdownMenuItem<Brand>(
                            value: b,
                            child: Text(b.name),
                          ),
                        )
                        .toList(),
                onChanged: (brand) {
                  setState(() {
                    _selectedBrand = brand;
                  });
                },
                decoration: const InputDecoration(labelText: 'Marca'),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      if (widget.onBack != null) {
                        widget.onBack!();
                      } else if (mounted) {
                        // Use a callback to parent if possible, otherwise pop
                        // Fallback: try to call a method on parent via InheritedWidget or similar
                        // For now, just pop if possible
                        Navigator.of(context).maybePop();
                      }
                    },
                    child: const Text('Cancelar'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _onSave,
                    child:
                        _isLoading
                            ? const CircularProgressIndicator()
                            : const Text('Guardar'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
