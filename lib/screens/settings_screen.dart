import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:solar_icons/solar_icons.dart';
import '../db/database_helper.dart';
import '../models/service.dart';
import '../utils/service_icons.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  List<BarberService> _services = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadServices();
  }

  Future<void> _loadServices() async {
    setState(() => _isLoading = true);
    final list = await _dbHelper.getAllServices();
    setState(() {
      _services = list;
      _isLoading = false;
    });
  }

  void _showAddEditServiceDialog([BarberService? service]) {
    final cs = Theme.of(context).colorScheme;
    final nameController = TextEditingController(text: service?.name ?? '');
    final priceController = TextEditingController(
        text: service != null ? service.price.toStringAsFixed(0) : '');
    String selectedIcon = service?.icon ?? 'scissors';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      service == null ? 'إضافة خدمة جديدة' : 'تعديل الخدمة',
                      style: TextStyle(
                          fontFamily: 'Cairo',
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: cs.onSurface),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Name field
                  Text('اسم الخدمة',
                      style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 13,
                          color: cs.onSurfaceVariant)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      hintText: 'مثال: قص شعر',
                      prefixIcon: Icon(SolarIconsOutline.scissors, color: cs.primary, size: 20),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Price field
                  Text('السعر (دج)',
                      style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 13,
                          color: cs.onSurfaceVariant)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: priceController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'مثال: 500',
                      prefixIcon: Icon(SolarIconsOutline.dollar, color: cs.primary, size: 20),
                      suffixText: 'دج',
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Icon selector
                  Text('اختر أيقونة',
                      style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 13,
                          color: cs.onSurfaceVariant)),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: ServiceIcons.options.map((opt) {
                      final isSelected = selectedIcon == opt.key;
                      return GestureDetector(
                        onTap: () =>
                            setDialogState(() => selectedIcon = opt.key),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? cs.primaryContainer
                                : cs.surfaceContainerHigh,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: isSelected
                                    ? cs.primary
                                    : cs.outlineVariant,
                                width: isSelected ? 2 : 1),
                          ),
                          child: Center(
                            child: Icon(opt.icon,
                                color: isSelected
                                    ? cs.onPrimaryContainer
                                    : cs.onSurfaceVariant,
                                size: 22),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('إلغاء'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton(
                          onPressed: () async {
                            final name = nameController.text.trim();
                            final priceText = priceController.text.trim();
                            if (name.isEmpty) return;
                            final price = double.tryParse(priceText) ?? 0.0;

                            if (service == null) {
                              await _dbHelper.insertService(BarberService(
                                  name: name,
                                  price: price,
                                  icon: selectedIcon));
                            } else {
                              await _dbHelper.updateService(BarberService(
                                  id: service.id,
                                  name: name,
                                  price: price,
                                  icon: selectedIcon));
                            }
                            if (ctx.mounted) Navigator.pop(ctx);
                            _loadServices();
                          },
                          child:
                              Text(service == null ? 'إضافة' : 'حفظ'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _deleteService(BarberService service) async {
    final cs = Theme.of(context).colorScheme;
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: cs.errorContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(SolarIconsOutline.trashBinTrash,
                  color: cs.error, size: 28),
            ),
            const SizedBox(height: 14),
            Text(
              'حذف الخدمة',
              style: TextStyle(
                  fontFamily: 'Cairo',
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: cs.error),
            ),
            const SizedBox(height: 6),
            Text(
              'هل تريد حذف خدمة "${service.name}"؟',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontFamily: 'Cairo',
                  color: cs.onSurfaceVariant),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    child: const Text('إلغاء'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: cs.error,
                      foregroundColor: cs.onError,
                    ),
                    onPressed: () => Navigator.pop(ctx, true),
                    child: const Text('حذف'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );

    if (confirmed == true && service.id != null) {
      HapticFeedback.mediumImpact();
      await _dbHelper.deleteService(service.id!);
      _loadServices();
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'إعدادات الصالون',
          style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(SolarIconsOutline.altArrowRight),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          FilledButton.tonal(
            style: FilledButton.styleFrom(
              backgroundColor: cs.primaryContainer,
              foregroundColor: cs.onPrimaryContainer,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              textStyle: const TextStyle(
                  fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 13),
            ),
            onPressed: () => _showAddEditServiceDialog(),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(SolarIconsOutline.addSquare, size: 16, color: cs.onPrimaryContainer),
                const SizedBox(width: 6),
                const Text('إضافة'),
              ],
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _services.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: cs.primaryContainer.withValues(alpha: 0.4),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(SolarIconsOutline.scissors,
                            size: 40, color: cs.primary),
                      ),
                      const SizedBox(height: 16),
                      Text('لا توجد خدمات مضافة',
                          style: TextStyle(
                              fontFamily: 'Cairo',
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: cs.onSurface)),
                      const SizedBox(height: 6),
                      Text('اضغط "إضافة" لإنشاء أول خدمة',
                          style: TextStyle(
                              fontFamily: 'Cairo', color: cs.onSurfaceVariant)),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _services.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final service = _services[index];
                    return Card(
                      color: cs.surfaceContainer,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(color: cs.outlineVariant),
                      ),
                      child: ListTile(
                        tileColor: Colors.transparent,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 6),
                        leading: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: cs.primaryContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Icon(ServiceIcons.getIcon(service.icon),
                                color: cs.onPrimaryContainer, size: 22),
                          ),
                        ),
                        title: Text(service.name,
                            style: const TextStyle(
                                fontFamily: 'Cairo',
                                fontWeight: FontWeight.bold,
                                fontSize: 15)),
                        subtitle: Text(
                          '${service.price.toStringAsFixed(0)} دج',
                          style: TextStyle(
                              fontFamily: 'Cairo',
                              color: cs.primary,
                              fontWeight: FontWeight.w600),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              onPressed: () =>
                                  _showAddEditServiceDialog(service),
                              icon: Icon(SolarIconsOutline.pen2,
                                  color: cs.primary, size: 20),
                              tooltip: 'تعديل',
                            ),
                            IconButton(
                              onPressed: () => _deleteService(service),
                              icon: Icon(SolarIconsOutline.trashBinTrash,
                                  color: cs.error, size: 20),
                              tooltip: 'حذف',
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
