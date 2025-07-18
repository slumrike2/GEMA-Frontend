import 'package:flutter/material.dart';
import 'package:frontend/Models/backend_types.dart';
import 'package:frontend/Modals/delete_brand_dialog.dart';
import 'package:frontend/Services/brand_service.dart';

class MarcaDetailsPage extends StatefulWidget {
  final List<Brand> brands;
  final Map<int, int> equipmentCountByBrand; // brandId -> count
  final VoidCallback? onClose;
  final VoidCallback refetchBrands;
  const MarcaDetailsPage({
    Key? key,
    required this.brands,
    required this.equipmentCountByBrand,

    this.onClose,
    required this.refetchBrands,
  }) : super(key: key);

  @override
  State<MarcaDetailsPage> createState() => _MarcaDetailsPageState();
}

class _MarcaDetailsPageState extends State<MarcaDetailsPage> {
  void _editBrand(Brand brand) {
    String name = brand.name;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Editar Marca'),
          content: TextField(
            autofocus: true,
            decoration: const InputDecoration(labelText: 'Nombre de la marca'),
            controller: TextEditingController(text: name),
            onChanged: (value) => name = value,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                if (name.trim().isNotEmpty) {
                  setState(() {
                    final idx = widget.brands.indexWhere(
                      (b) => b.id == brand.id && b.name == brand.name,
                    );
                    if (idx != -1) {
                      widget.brands[idx] = Brand(id: brand.id, name: name.trim());
                    }
                  });
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  void _deleteBrand(Brand brand) {
    final otherBrands = widget.brands.where((b) => b.id != brand.id).toList();
    final equipmentCount =
        brand.id != null ? (widget.equipmentCountByBrand[brand.id!] ?? 0) : 0;
    showDialog(
      context: context,
      builder: (context) {
        return DeleteBrandDialog(
          brand: brand,
          equipmentCount: equipmentCount,
          otherBrands: otherBrands,
          onDelete: (moveToNoMarca, selectedBrand) {
            // Here you would update the equipment's brandId in a real app
            setState(() {
              widget.brands.removeWhere(
                (b) => b.id == brand.id && b.name == brand.name,
              );
            });
            // Optionally handle moveToNoMarca/selectedBrand
          },
        );
      },
    );
  }



  @override
  void initState() {
    super.initState();
  }

  void _showCreateDialog() {
    String name = "";
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Agregar Marca'),
          content: TextField(
            autofocus: true,
            decoration: const InputDecoration(labelText: 'Nombre de la marca'),
            onChanged: (value) => name = value,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (name.trim().isNotEmpty) {
                  try {
                    await BrandService.create({"name": name.trim()});
                    widget.refetchBrands();
                    Navigator.of(context).pop();
                  } catch (e) {
                    // Optionally show error to user
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error al agregar marca: $e')),
                    );
                  }
                }
              },
              child: const Text('Agregar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        int crossAxisCount = 3;
        double horizontalPadding = 32.0;
        double cardPadding = 20.0;
        if (width < 600) {
          crossAxisCount = 1;
          horizontalPadding = 8.0;
          cardPadding = 10.0;
        } else if (width < 900) {
          crossAxisCount = 2;
          horizontalPadding = 16.0;
          cardPadding = 14.0;
        }
        return Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 1200, maxHeight: 900),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Stack(
              children: [
                Padding(
                  padding: EdgeInsets.all(horizontalPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title and close button
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text(
                            'Marcas',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.close_rounded, size: 28),
                            tooltip: 'Cerrar',
                            onPressed: widget.onClose,
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      // Description and add button
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Text(
                              'Gestiona las marcas de equipos',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 16,
                              ),
                            ),
                          ),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.add),
                            label: const Text('Agregar Marca'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              textStyle: const TextStyle(fontSize: 15),
                            ),
                            onPressed: _showCreateDialog,
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Expanded(
                        child: SingleChildScrollView(
                          child:
                              widget.brands.isEmpty
                                  ? Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Icon(
                                          Icons.settings,
                                          size: 48,
                                          color: Colors.grey,
                                        ),
                                        const SizedBox(height: 16),
                                        const Text(
                                          'No hay marcas',
                                          style: TextStyle(fontSize: 18),
                                        ),
                                        const SizedBox(height: 8),
                                        const Text(
                                          'Crea la primera marca para comenzar a usar marcas',
                                          style: TextStyle(color: Colors.grey),
                                        ),
                                        const SizedBox(height: 16),
                                        ElevatedButton.icon(
                                          icon: const Icon(Icons.add),
                                          label: const Text(
                                            'Crear Primera Marca',
                                          ),
                                          onPressed: _showCreateDialog,
                                        ),
                                      ],
                                    ),
                                  )
                                  : GridView.builder(
                                    itemCount: widget.brands.length,
                                    gridDelegate:
                                        SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: crossAxisCount,
                                          crossAxisSpacing:
                                              width < 600 ? 8 : 12,
                                          mainAxisSpacing: width < 600 ? 8 : 12,
                                          childAspectRatio:
                                              width < 600 ? 5.5 : 7.0,
                                        ),
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemBuilder: (context, index) {
                                      final brand = widget.brands[index];
                                      final count =
                                          brand.id != null
                                              ? (widget
                                                      .equipmentCountByBrand[brand
                                                      .id!] ??
                                                  0)
                                              : 0;
                                      return Card(
                                        elevation: 1,
                                        margin: EdgeInsets.zero,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            7,
                                          ),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 7,
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.label_outline,
                                                size: 16,
                                                color: Colors.blueGrey[600],
                                              ),
                                              const SizedBox(width: 7),
                                              Expanded(
                                                child: Text(
                                                  brand.name,
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                              Container(
                                                margin: const EdgeInsets.only(
                                                  left: 8,
                                                ),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 7,
                                                      vertical: 2,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: Colors.blueGrey[50],
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                child: Text(
                                                  '$count',
                                                  style: TextStyle(
                                                    color: Colors.blueGrey[700],
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                              IconButton(
                                                icon: const Icon(
                                                  Icons.edit_outlined,
                                                  color: Colors.blueGrey,
                                                  size: 18,
                                                ),
                                                tooltip: 'Editar',
                                                onPressed:
                                                    () => _editBrand(brand),
                                              ),
                                              IconButton(
                                                icon: const Icon(
                                                  Icons.delete_outline,
                                                  color: Colors.red,
                                                  size: 18,
                                                ),
                                                tooltip: 'Eliminar',
                                                onPressed:
                                                    () => _deleteBrand(brand),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
