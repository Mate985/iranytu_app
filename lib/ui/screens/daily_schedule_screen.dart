import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/routine_provider.dart';
import '../../providers/reward_provider.dart';
import '../../services/app_settings_service.dart';
import '../widgets/task_card.dart';
import '../widgets/task_alert_dialog.dart';
import 'add_task_screen.dart';
import '../widgets/parental_pin_dialog.dart';
import '../widgets/reward_celebration_dialog.dart';

class DailyScheduleScreen extends StatefulWidget {
  const DailyScheduleScreen({super.key});

  @override
  State<DailyScheduleScreen> createState() => _DailyScheduleScreenState();
}

class _DailyScheduleScreenState extends State<DailyScheduleScreen> {
  Timer? _scheduleTimer;
  final Set<String> _alertedScheduleKeys = {};

  final List<String> _dayNames = const [
    'Hétfő',
    'Kedd',
    'Szerda',
    'Csütörtök',
    'Péntek',
    'Szombat',
    'Vasárnap',
  ];

  final List<String> _dayShortNames = const [
    'H',
    'K',
    'Sze',
    'Cs',
    'P',
    'Szo',
    'V',
  ];

  @override
  void initState() {
    super.initState();
    _startScheduleChecker();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<RoutineProvider>();
      final initialDay = provider.selectedDay;
      provider.selectDay(initialDay);
    });
  }

  @override
  void dispose() {
    _scheduleTimer?.cancel();
    super.dispose();
  }

  void _startScheduleChecker() {
    _scheduleTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _checkCurrentTimeForAlerts();
    });
  }

  Future<void> _checkCurrentTimeForAlerts() async {
    if (!mounted) return;

    final isPopupEnabled = await AppSettingsService.isTaskPopupAlertEnabled();
    if (!isPopupEnabled || !mounted) return;

    final now = DateTime.now();
    final todayWeekday = now.weekday;

    final provider = context.read<RoutineProvider>();
    if (provider.selectedDay != todayWeekday) return;

    final currentHour = now.hour.toString().padLeft(2, '0');
    final currentMinute = now.minute.toString().padLeft(2, '0');
    final currentTimeStr = '$currentHour:$currentMinute';

    for (final item in provider.todayTasks) {
      final scheduledTime = item.schedule.scheduledTime;
      final scheduleId = item.schedule.id;

      if (scheduleId == null ||
          scheduledTime == null ||
          item.schedule.status == 'COMPLETED') {
        continue;
      }

      final alertKey = '${now.day}_${scheduleId}_$scheduledTime';

      if (scheduledTime == currentTimeStr &&
          !_alertedScheduleKeys.contains(alertKey)) {
        _alertedScheduleKeys.add(alertKey);

        TaskAlertDialog.show(
          context,
          task: item.task,
          scheduledTime: scheduledTime,
        );
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RoutineProvider>(
      builder: (context, provider, child) {
        final currentSelectedDay = provider.selectedDay;
        final selectedDayName = _dayNames[currentSelectedDay - 1];

        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.white,
            centerTitle: true,
            title: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                'Napirend – $selectedDayName',
                style: const TextStyle(
                  color: Color(0xFF1E293B),
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            actions: [
              Consumer<RewardProvider>(
                builder: (context, rewardProv, child) {
                  return Container(
                    margin: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 8,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF08A),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFFDE047)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          color: Color(0xFFD97706),
                          size: 18,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${rewardProv.totalStars}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Color(0xFF854D0E),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
          body: Column(
            children: [
              // Heti napválasztó sáv
              Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
                child: Row(
                  children: List.generate(7, (index) {
                    final dayNum = index + 1;
                    final isSelected = dayNum == currentSelectedDay;
                    final isToday = dayNum == DateTime.now().weekday;

                    return Expanded(
                      child: GestureDetector(
                        onTap: () => provider.selectDay(dayNum),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFF81C784)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                            border: (!isSelected && isToday)
                                ? Border.all(
                                    color: const Color(0xFF81C784),
                                    width: 1.5,
                                  )
                                : null,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _dayShortNames[index],
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected
                                      ? Colors.white
                                      : (isToday
                                            ? const Color(0xFF81C784)
                                            : const Color(0xFF64748B)),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '$dayNum',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isSelected
                                      ? Colors.white70
                                      : const Color(0xFF94A3B8),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
              const Divider(height: 1, thickness: 1, color: Color(0xFFE2E8F0)),

              // Feladatlista az adott napra
              Expanded(
                child: provider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : provider.todayTasks.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.event_note_rounded,
                              size: 64,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Erre a napra nincs feladat!',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(
                          left: 16.0,
                          right: 16.0,
                          top: 12.0,
                          bottom: 110.0,
                        ),
                        itemCount: provider.todayTasks.length,
                        itemBuilder: (context, index) {
                          final item = provider.todayTasks[index];
                          return Dismissible(
                            key: ValueKey(
                              'schedule_${item.schedule.id ?? index}',
                            ),
                            direction: DismissDirection.endToStart,
                            confirmDismiss: (direction) async {
                              final isUnlocked = await ParentalPinDialog.show(
                                context,
                              );
                              return isUnlocked;
                            },
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              margin: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEF5350),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Icon(
                                    Icons.delete_outline_rounded,
                                    color: Colors.white,
                                    size: 28,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Törlés',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            onDismissed: (direction) async {
                              final taskTitle = item.task.title;
                              final scheduleId = item.schedule.id;

                              if (scheduleId != null) {
                                await provider.removeTaskFromSchedule(
                                  scheduleId,
                                );
                              }

                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('$taskTitle törölve'),
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                              }
                            },
                            child: TaskCard(
                              item: item,
                              onToggle: () {
                                final currentlyCompleted =
                                    item.schedule.status == 'COMPLETED';
                                final willBeCompleted = !currentlyCompleted;

                                provider.toggleTaskCompletion(
                                  item.schedule.id!,
                                  currentlyCompleted,
                                );

                                final starsEarned = item.task.rewardPoints > 0
                                    ? item.task.rewardPoints
                                    : 1;

                                if (willBeCompleted) {
                                  context.read<RewardProvider>().addStars(
                                    starsEarned,
                                  );
                                  RewardCelebrationDialog.show(
                                    context,
                                    earnedStars: starsEarned,
                                    taskTitle: item.task.title,
                                  );
                                } else {
                                  context.read<RewardProvider>().removeStars(
                                    starsEarned,
                                  );
                                }
                              },
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () async {
              final isUnlocked = await ParentalPinDialog.show(context);
              if (!isUnlocked || !context.mounted) return;

              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddTaskScreen()),
              );
            },
            backgroundColor: const Color(0xFF81C784),
            foregroundColor: Colors.white,
            icon: const Icon(Icons.add_rounded),
            label: const Text(
              'Új feladat',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        );
      },
    );
  }
}
