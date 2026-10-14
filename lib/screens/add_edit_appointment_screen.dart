import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:solar_icons/solar_icons.dart';
import '../db/database_helper.dart';
import '../models/appointment.dart';
import '../theme/app_theme.dart';
import '../utils/arabic_dates.dart';

class AddEditAppointmentScreen extends StatefulWidget {
  final Appointment? appointment;
  final DateTime initialDate;

  const AddEditAppointmentScreen({
    super.key,
    this.appointment,
    required this.initialDate,
  });

  @override
  State<AddEditAppointmentScreen> createState() =>
      _AddEditAppointmentScreenState();
}

class _AddEditAppointmentScreenState
    extends State<AddEditAppointmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _notesController;

  late DateTime _selectedDate;
  String _selectedStatus = 'waiting';

  @override
  void initState() {
    super.initState();
    final app = widget.appointment;
    _nameController = TextEditingController(text: app?.customerName ?? '');
    _phoneController = TextEditingController(text: app?.phone ?? '');
    _notesController = TextEditingController(text: app?.notes ?? '');
    _selectedDate =
        app != null ? ArabicDates.parseIsoDate(app.date) : widget.initialDate;
    _selectedStatus = app?.status ?? 'waiting';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final cs = Theme.of(context).colorScheme;
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: cs,
          datePickerTheme: DatePickerThemeData(
            backgroundColor: cs.surfaceContainerHigh,
            headerBackgroundColor: cs.primaryContainer,
            headerForegroundColor: cs.onPrimaryContainer,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24)),
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _saveAppointment() async {
    if (!_formKey.currentState!.validate()) return;
    HapticFeedback.lightImpact();

    final customerName = _nameController.text.trim();
    final phone =
        _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim();
    final notes =
        _notesController.text.trim().isEmpty ? null : _notesController.text.trim();
    final dateStr = ArabicDates.toIsoDate(_selectedDate);

    final appointment = Appointment(
      id: widget.appointment?.id,
      customerName: customerName,
      phone: phone,
      serviceName: null,
      date: dateStr,
      time: '00:00',
      status: _selectedStatus,
      price: 0.0,
      notes: notes,
    );

    if (widget.appointment == null) {
      await _dbHelper.insertAppointment(appointment);
    } else {
      await _dbHelper.updateAppointment(appointment);
    }

    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isEditing = widget.appointment != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditing ? 'تعديل الدور' : 'دور جديد',
          style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(SolarIconsOutline.altArrowRight),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // ── Customer info section ──
            _sectionLabel(cs, 'معلومات العميل', SolarIconsOutline.user),
            const SizedBox(height: 10),
            TextFormField(
              controller: _nameController,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                labelText: 'اسم العميل *',
                hintText: 'أدخل اسم العميل',
                prefixIcon: Icon(SolarIconsOutline.user, color: cs.primary, size: 20),
              ),
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return 'يرجى إدخال اسم العميل';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'رقم الهاتف (اختياري)',
                hintText: '06 / 05 / 07 ...',
                prefixIcon:
                    Icon(SolarIconsOutline.phone, color: cs.primary, size: 20),
              ),
            ),

            const SizedBox(height: 24),

            // ── Date section ──
            _sectionLabel(cs, 'تاريخ الدور', SolarIconsOutline.calendar),
            const SizedBox(height: 10),
            Card(
              color: cs.surfaceContainerHigh,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: cs.outlineVariant)),
              child: InkWell(
                onTap: _pickDate,
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: cs.primaryContainer,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(SolarIconsOutline.calendar,
                            color: cs.onPrimaryContainer, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('التاريخ المختار',
                                style: TextStyle(
                                    fontFamily: 'Cairo',
                                    fontSize: 11,
                                    color: cs.onSurfaceVariant)),
                            const SizedBox(height: 2),
                            Text(
                              ArabicDates.formatShortDate(_selectedDate),
                              style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: cs.onSurface),
                            ),
                          ],
                        ),
                      ),
                      Icon(SolarIconsOutline.altArrowDown,
                          color: cs.onSurfaceVariant, size: 18),
                    ],
                  ),
                ),
              ),
            ),

            // ── Status (edit only) ──
            if (isEditing) ...[
              const SizedBox(height: 24),
              _sectionLabel(cs, 'الحالة', SolarIconsOutline.infoCircle),
              const SizedBox(height: 10),
              Row(
                children: [
                  _statusChip(cs, 'waiting', 'في الانتظار',
                      AppTheme.statusWaiting),
                  const SizedBox(width: 8),
                  _statusChip(cs, 'cutting', 'على الكرسي',
                      AppTheme.statusCutting),
                  const SizedBox(width: 8),
                  _statusChip(cs, 'done', 'مكتمل',
                      AppTheme.statusDone),
                ],
              ),
            ],

            const SizedBox(height: 24),

            // ── Notes section ──
            _sectionLabel(cs, 'ملاحظات (اختياري)', SolarIconsOutline.notes),
            const SizedBox(height: 10),
            TextFormField(
              controller: _notesController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'ملاحظات أو تفضيلات خاصة...',
                prefixIcon: Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Icon(SolarIconsOutline.notes,
                      color: cs.primary, size: 20),
                ),
                alignLabelWithHint: true,
              ),
            ),

            const SizedBox(height: 32),

            // ── Save button ──
            FilledButton.icon(
              onPressed: _saveAppointment,
              icon: Icon(
                isEditing
                    ? SolarIconsOutline.checkCircle
                    : SolarIconsOutline.userPlus,
                size: 20,
              ),
              label: Text(
                isEditing ? 'حفظ التعديلات' : 'إضافة للطابور',
                style: const TextStyle(fontSize: 16),
              ),
            ),

            const SizedBox(height: 16),

            if (!isEditing)
              OutlinedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('إلغاء'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(ColorScheme cs, String label, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: cs.primary, size: 18),
        const SizedBox(width: 8),
        Text(label,
            style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: cs.onSurface)),
      ],
    );
  }

  Widget _statusChip(
      ColorScheme cs, String key, String label, Color color) {
    final isSelected = _selectedStatus == key;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          setState(() => _selectedStatus = key);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? color.withValues(alpha: 0.2)
                : cs.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: isSelected ? color : cs.outlineVariant,
                width: isSelected ? 1.5 : 1),
          ),
          child: Center(
            child: Text(label,
                style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? color : cs.onSurfaceVariant)),
          ),
        ),
      ),
    );
  }
}
