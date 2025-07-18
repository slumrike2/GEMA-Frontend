import 'package:flutter/material.dart';
import 'package:frontend/Models/backend_types.dart';
import 'package:frontend/Modals/delete_brand_dialog.dart';
import 'package:frontend/constants/app_constnats.dart';

class MarcaDetailsPage extends StatefulWidget {
  final List<Brand> brands;
  final Map<int, int> equipmentCountByBrand; // brandId -> count
  final VoidCallback? onClose;
  const MarcaDetailsPage({
    Key? key,
    required this.brands,
    required this.equipmentCountByBrand,
    this.onClose,
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
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: const Color(0xFFF7F3FA),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.label,
                        color: Color(0xFF219653),
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Editar marca',
                        style: AppTextStyles.title(color: Color(0xFF219653)),
                      ),
                      const Spacer(),
                      InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () => Navigator.of(context).pop(),
                        child: const Icon(
                          Icons.close,
                          size: 22,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Modifica el nombre de la marca.',
                    style: AppTextStyles.bodySmall(color: Colors.black87),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Nombre',
                    style: AppTextStyles.label(color: Colors.black87),
                  ),
                  const SizedBox(height: 4),
                  TextField(
                    autofocus: true,
                    decoration: const InputDecoration(
                      hintText: 'Nombre de la marca',
                      prefixIcon: Icon(
                        Icons.label_outline,
                        color: Colors.black54,
                      ),
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 12,
                      ),
                    ),
                    controller: TextEditingController(text: name),
                    onChanged: (value) => name = value,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        style: TextButton.styleFrom(
                          backgroundColor: const Color(0xFFF2F2F2),
                          foregroundColor: Colors.black87,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 22,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(
                          'Cancelar',
                          style: AppTextStyles.button(color: Colors.black87),
                        ),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.botonGreen,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 22,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        onPressed: () {
                          if (name.trim().isNotEmpty) {
                            setState(() {
                              final idx = _brands.indexWhere(
                                (b) => b.id == brand.id && b.name == brand.name,
                              );
                              if (idx != -1) {
                                _brands[idx] = Brand(
                                  id: brand.id,
                                  name: name.trim(),
                                );
                              }
                            });
                            Navigator.of(context).pop();
                          }
                        },
                        child: Text('Guardar', style: AppTextStyles.button()),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _deleteBrand(Brand brand) {
    final otherBrands = _brands.where((b) => b.id != brand.id).toList();
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
              _brands.removeWhere(
                (b) => b.id == brand.id && b.name == brand.name,
              );
            });
            // Optionally handle moveToNoMarca/selectedBrand
          },
        );
      },
    );
  }

  late List<Brand> _brands;

  @override
  void initState() {
    super.initState();
    _brands = List.from(widget.brands);
  }

  void _showCreateDialog() {
    String name = "";
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: const Color(0xFFF7F3FA),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.label,
                        color: Color(0xFF219653),
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Agregar marca',
                        style: AppTextStyles.title(color: Color(0xFF219653)),
                      ),
                      const Spacer(),
                      InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () => Navigator.of(context).pop(),
                        child: const Icon(
                          Icons.close,
                          size: 22,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Crea una nueva marca para asociar a los equipos.',
                    style: AppTextStyles.bodySmall(color: Colors.black87),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Nombre',
                    style: AppTextStyles.label(color: Colors.black87),
                  ),
                  const SizedBox(height: 4),
                  TextField(
                    autofocus: true,
                    decoration: const InputDecoration(
                      hintText: 'Nombre de la marca',
                      prefixIcon: Icon(
                        Icons.label_outline,
                        color: Colors.black54,
                      ),
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 12,
                      ),
                    ),
                    onChanged: (value) => name = value,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        style: TextButton.styleFrom(
                          backgroundColor: const Color(0xFFF2F2F2),
                          foregroundColor: Colors.black87,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 22,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(
                          'Cancelar',
                          style: AppTextStyles.button(color: Colors.black87),
                        ),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.botonGreen,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 22,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        onPressed: () {
                          if (name.trim().isNotEmpty) {
                            setState(() {
                              _brands.add(Brand(id: null, name: name.trim()));
                            });
                            Navigator.of(context).pop();
                          }
                        },
                        child: Text('Agregar', style: AppTextStyles.button()),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
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
                              _brands.isEmpty
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
                                    itemCount: _brands.length,
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
                                      final brand = _brands[index];
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
