import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:solar_icons/solar_icons.dart';
import 'package:url_launcher/url_launcher.dart';
import '../db/database_helper.dart';
import '../models/appointment.dart';
import '../theme/app_theme.dart';
import '../utils/arabic_dates.dart';
import 'add_edit_appointment_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  DateTime _selectedDate = DateTime.now();
  List<Appointment> _appointments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final dateStr = ArabicDates.toIsoDate(_selectedDate);
    final list = await _dbHelper.getAppointmentsByDate(dateStr);
    setState(() {
      _appointments = list;
      _isLoading = false;
    });
  }

  void _onDateChanged(DateTime newDate) {
    setState(() => _selectedDate = newDate);
    _loadData();
  }

  Future<void> _updateStatus(Appointment app, String newStatus) async {
    HapticFeedback.lightImpact();
    if (app.id != null) {
      await _dbHelper.updateAppointmentStatus(app.id!, newStatus);
      _loadData();
    }
  }

  Future<void> _confirmDelete(Appointment app) async {
    HapticFeedback.mediumImpact();
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Theme.of(ctx).colorScheme.errorContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(SolarIconsOutline.trashBinTrash,
                  color: Theme.of(ctx).colorScheme.error, size: 24),
            ),
            const SizedBox(height: 16),
            Text(
              'حذف الدور',
              style: Theme.of(ctx).textTheme.titleLarge?.copyWith(
                    fontFamily: 'Cairo',
                    fontWeight: FontWeight.bold,
                    color: Theme.of(ctx).colorScheme.error,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'هل تريد إزالة دور "${app.customerName}" من الطابور؟',
              textAlign: TextAlign.center,
              style: Theme.of(ctx).textTheme.bodyMedium?.copyWith(
                    fontFamily: 'Cairo',
                    color: Theme.of(ctx).colorScheme.onSurfaceVariant,
                  ),
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
                      backgroundColor: Theme.of(ctx).colorScheme.error,
                      foregroundColor: Theme.of(ctx).colorScheme.onError,
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

    if (confirmed == true && app.id != null) {
      await _dbHelper.deleteAppointment(app.id!);
      _loadData();
    }
  }

  Future<void> _pickCalendarDate() async {
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
            dayBackgroundColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) return cs.primary;
              return null;
            }),
            dayForegroundColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) return cs.onPrimary;
              return cs.onSurface;
            }),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) _onDateChanged(picked);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final inChairList = _appointments.where((a) => a.status == 'cutting').toList();
    final waitingList = _appointments.where((a) => a.status == 'waiting').toList();
    final doneCount = _appointments.where((a) => a.status == 'done').length;
    final activeCount = inChairList.length + waitingList.length;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // M3 Large App Bar
          SliverAppBar(
            expandedHeight: 100,
            pinned: true,
            centerTitle: true,
            backgroundColor: cs.surface,
            surfaceTintColor: cs.surfaceTint,
            scrolledUnderElevation: 3,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              titlePadding: const EdgeInsets.only(bottom: 14),
              title: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(FontAwesomeIcons.scissors,
                      color: cs.primary, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'GoldenBlade',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: cs.onSurface,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              IconButton(
                onPressed: () async {
                  await Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const SettingsScreen()));
                  _loadData();
                },
                icon: const Icon(SolarIconsOutline.settings),
                tooltip: 'الإعدادات',
              ),
              const SizedBox(width: 8),
            ],
          ),

          // Date Selector
          SliverToBoxAdapter(child: _buildDateSelector(cs)),

          // Summary chips row
          SliverToBoxAdapter(
            child: _buildSummaryRow(cs, waitingList.length, inChairList.length, doneCount),
          ),

          // Content
          if (_isLoading)
            const SliverFillRemaining(
              child: Center(
                  child: CircularProgressIndicator()),
            )
          else if (activeCount == 0)
            SliverFillRemaining(child: _buildEmptyState(cs, doneCount))
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  if (inChairList.isNotEmpty) ...[
                    _buildSectionHeader(
                        ctx: context,
                        label: 'على الكرسي الآن',
                        icon: SolarIconsOutline.armchair,
                        color: AppTheme.statusCutting),
                    ...inChairList
                        .map((a) => _buildAppointmentCard(a, cs, isChair: true)),
                    const SizedBox(height: 20),
                  ],
                  if (waitingList.isNotEmpty) ...[
                    _buildSectionHeader(
                        ctx: context,
                        label: 'طابور الانتظار (${waitingList.length})',
                        icon: SolarIconsOutline.usersGroupRounded,
                        color: AppTheme.statusWaiting),
                    ...waitingList.asMap().entries.map(
                        (e) => _buildAppointmentCard(e.value, cs, queuePos: e.key + 1)),
                  ],
                ]),
              ),
            ),
        ],
      ),

      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: cs.primaryContainer,
        foregroundColor: cs.onPrimaryContainer,
        elevation: 3,
        onPressed: () async {
          HapticFeedback.lightImpact();
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  AddEditAppointmentScreen(initialDate: _selectedDate),
            ),
          );
          if (result == true) _loadData();
        },
        icon: const Icon(SolarIconsOutline.userPlus, size: 20),
        label: const Text(
          'دور جديد',
          style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 15),
        ),
      ),
    );
  }

  Widget _buildDateSelector(ColorScheme cs) {
    final now = DateTime.now();
    final isToday = _selectedDate.year == now.year &&
        _selectedDate.month == now.month &&
        _selectedDate.day == now.day;
    final dateDisplay = isToday
        ? 'اليوم - ${ArabicDates.formatShortDate(_selectedDate)}'
        : ArabicDates.formatFullDate(_selectedDate);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Card(
        color: cs.surfaceContainerLow,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: cs.outlineVariant, width: 1),
        ),
        child: InkWell(
          onTap: _pickCalendarDate,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: cs.primaryContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(SolarIconsOutline.calendarMark,
                      color: cs.onPrimaryContainer, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(dateDisplay,
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: cs.onSurface,
                          )),
                      Text('اضغط لتغيير التاريخ',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 11,
                            color: cs.onSurfaceVariant,
                          )),
                    ],
                  ),
                ),
                Icon(SolarIconsOutline.altArrowLeft,
                    color: cs.onSurfaceVariant, size: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(
      ColorScheme cs, int waiting, int chair, int done) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 12),
      child: Row(
        children: [
          _summaryChip(cs, label: 'انتظار', count: waiting,
              color: AppTheme.statusWaiting, icon: SolarIconsOutline.usersGroupTwoRounded),
          const SizedBox(width: 8),
          _summaryChip(cs, label: 'على الكرسي', count: chair,
              color: AppTheme.statusCutting, icon: SolarIconsOutline.armchair),
          const SizedBox(width: 8),
          _summaryChip(cs, label: 'مكتمل', count: done,
              color: cs.primary, icon: SolarIconsOutline.checkCircle),
        ],
      ),
    );
  }

  Widget _summaryChip(ColorScheme cs,
      {required String label,
      required int count,
      required Color color,
      required IconData icon}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.25), width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 6),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$count',
                    style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: color)),
                Text(label,
                    style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 10,
                        color: cs.onSurfaceVariant)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
      {required BuildContext ctx,
      required String label,
      required IconData icon,
      required Color color}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, top: 4),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Text(label,
              style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: color)),
        ],
      ),
    );
  }

  Widget _buildAppointmentCard(Appointment app, ColorScheme cs,
      {bool isChair = false, int? queuePos}) {
    final color = isChair ? AppTheme.statusCutting : AppTheme.statusWaiting;
        final statusLabel = isChair
        ? 'على الكرسي'
        : (queuePos == 1 ? 'التالي' : 'رقم $queuePos');

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Card(
        color: cs.surfaceContainer,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
              color: isChair
                  ? AppTheme.statusCutting.withValues(alpha: 0.5)
                  : cs.outlineVariant,
              width: isChair ? 1.5 : 1),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AddEditAppointmentScreen(
                    appointment: app, initialDate: _selectedDate),
              ),
            );
            if (result == true) _loadData();
          },
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Avatar with queue number or scissors
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Center(
                        child: isChair
                            ? Icon(FontAwesomeIcons.scissors,
                                color: AppTheme.statusCutting, size: 22)
                            : Text('$queuePos',
                                style: TextStyle(
                                    fontFamily: 'Cairo',
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: cs.primary)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Customer info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(app.customerName,
                                    style: TextStyle(
                                        fontFamily: 'Cairo',
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: cs.onSurface)),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: color.withValues(alpha: 0.18),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(statusLabel,
                                    style: TextStyle(
                                        fontFamily: 'Cairo',
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: color)),
                              ),
                            ],
                          ),
                          if (app.notes != null && app.notes!.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(SolarIconsOutline.notes,
                                    size: 13, color: cs.onSurfaceVariant),
                                const SizedBox(width: 5),
                                Expanded(
                                  child: Text(app.notes!,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          fontFamily: 'Cairo',
                                          fontSize: 12,
                                          color: cs.onSurfaceVariant)),
                                ),
                              ],
                            ),
                          ],
                          if (app.phone != null && app.phone!.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            FilledButton.tonal(
                              style: FilledButton.styleFrom(
                                backgroundColor:
                                    cs.primary.withValues(alpha: 0.12),
                                foregroundColor: cs.primary,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                textStyle: const TextStyle(
                                    fontFamily: 'Cairo',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600),
                              ),
                              onPressed: () async {
                                HapticFeedback.selectionClick();
                                final cleanPhone = app.phone!
                                    .replaceAll(RegExp(r'\s+'), '');
                                final uri = Uri.parse('tel:$cleanPhone');
                                try {
                                  await launchUrl(uri,
                                      mode: LaunchMode.externalApplication);
                                } catch (_) {
                                  if (await canLaunchUrl(uri)) {
                                    await launchUrl(uri);
                                  }
                                }
                              },
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(SolarIconsBold.phoneCalling, size: 13),
                                  const SizedBox(width: 5),
                                  Text(app.phone!,
                                      textDirection: TextDirection.ltr),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 1),
                                    decoration: BoxDecoration(
                                      color: cs.primary,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text('اتصال',
                                        style: TextStyle(
                                            fontFamily: 'Cairo',
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: cs.onPrimary)),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Divider(color: cs.outlineVariant, height: 1),
                const SizedBox(height: 6),
                Row(
                  children: [
                    IconButton.outlined(
                      style: IconButton.styleFrom(
                        foregroundColor: cs.error,
                        side: BorderSide(
                            color: cs.error.withValues(alpha: 0.4)),
                        minimumSize: const Size(36, 36),
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () => _confirmDelete(app),
                      icon: const Icon(SolarIconsOutline.trashBinTrash, size: 17),
                      tooltip: 'حذف الدور',
                    ),
                    const Spacer(),
                    if (app.status == 'waiting') ...[
                      FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: AppTheme.statusCutting,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          textStyle: const TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 13,
                              fontWeight: FontWeight.bold),
                        ),
                        onPressed: () => _updateStatus(app, 'cutting'),
                        icon: const Icon(FontAwesomeIcons.scissors, size: 13),
                        label: const Text('ابدأ القص'),
                      ),
                    ] else if (app.status == 'cutting') ...[
                      FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: cs.primary,
                          foregroundColor: cs.onPrimary,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          textStyle: const TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 13,
                              fontWeight: FontWeight.bold),
                        ),
                        onPressed: () => _updateStatus(app, 'done'),
                        icon: const Icon(SolarIconsOutline.checkCircle, size: 16),
                        label: const Text('إنهاء الدور'),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(ColorScheme cs, int doneCount) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: cs.primaryContainer.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              child: Icon(FontAwesomeIcons.chair,
                  size: 44, color: cs.primary),
            ),
            const SizedBox(height: 20),
            Text(
              doneCount > 0
                  ? 'تم إنهاء جميع الأدوار! 🎉'
                  : 'لا توجد أدوار بعد',
              style: TextStyle(
                  fontFamily: 'Cairo',
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: cs.onSurface),
            ),
            const SizedBox(height: 8),
            Text(
              doneCount > 0
                  ? 'أنجزت $doneCount دور اليوم، أحسنت!'
                  : 'اضغط "دور جديد" لتسجيل أول عميل',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 14,
                  color: cs.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

