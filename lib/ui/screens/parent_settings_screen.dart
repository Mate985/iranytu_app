import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/parental_service.dart';
import '../../services/app_settings_service.dart';
import '../../services/screen_time_service.dart';
import '../../providers/reward_provider.dart';
import '../../providers/routine_provider.dart';
import '../../providers/aac_provider.dart';
import '../../data/database/database_helper.dart';
import '../../data/models/reward_model.dart';
import '../widgets/add_reward_dialog.dart';
import '../widgets/session_timer_setting_card.dart';
import '../widgets/add_custom_task_dialog.dart';
import '../../providers/custom_task_provider.dart';
import '../../providers/theme_provider.dart';

class ParentSettingsScreen extends StatefulWidget {
  const ParentSettingsScreen({super.key});

  @override
  State<ParentSettingsScreen> createState() => _ParentSettingsScreenState();
}

class _ParentSettingsScreenState extends State<ParentSettingsScreen> {
  final _oldPinController = TextEditingController();
  final _newPinController = TextEditingController();
  final _confirmPinController = TextEditingController();

  final _questionController = TextEditingController();
  final _answerController = TextEditingController();

  String? _pinErrorMessage;
  String? _pinSuccessMessage;

  int _screenTimeLimit = 60;
  int _routineReminderMinutes = 30;
  bool _notificationsEnabled = true;
  bool _popupAlertEnabled = true;
  bool _alertSoundEnabled = true;
  bool _isLoadingSettings = true;

  @override
  void initState() {
    super.initState();
    _loadAllData();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CustomTaskProvider>().loadTasks();
    });
  }

  Future<void> _loadAllData() async {
    final data = await ParentalService.getSecurityQuestionAndAnswer();
    final limit = await AppSettingsService.getScreenTimeLimit();
    final reminder = await AppSettingsService.getRoutineReminderMinutes();
    final notif = await AppSettingsService.areNotificationsEnabled();
    final popup = await AppSettingsService.isTaskPopupAlertEnabled();
    final sound = await AppSettingsService.isAlertSoundEnabled();

    setState(() {
      _questionController.text = data['question']!;
      _screenTimeLimit = limit;
      _routineReminderMinutes = reminder;
      _notificationsEnabled = notif;
      _popupAlertEnabled = popup;
      _alertSoundEnabled = sound;
      _isLoadingSettings = false;
    });
  }

  @override
  void dispose() {
    _oldPinController.dispose();
    _newPinController.dispose();
    _confirmPinController.dispose();
    _questionController.dispose();
    _answerController.dispose();
    super.dispose();
  }

  Future<void> _changePin() async {
    setState(() {
      _pinErrorMessage = null;
      _pinSuccessMessage = null;
    });

    final oldPin = _oldPinController.text.trim();
    final newPin = _newPinController.text.trim();
    final confirmPin = _confirmPinController.text.trim();

    if (oldPin.length != 4 || newPin.length != 4 || confirmPin.length != 4) {
      setState(
        () => _pinErrorMessage =
            'Minden PIN kódnak pontosan 4 számjegyűnek kell lennie!',
      );
      return;
    }

    final isOldValid = await ParentalService.verifyPin(oldPin);
    if (!isOldValid) {
      setState(() => _pinErrorMessage = 'A jelenlegi PIN kód helytelen!');
      return;
    }

    if (newPin != confirmPin) {
      setState(() => _pinErrorMessage = 'Az új PIN kódok nem egyeznek meg!');
      return;
    }

    await ParentalService.setPin(newPin);

    setState(() {
      _pinSuccessMessage = 'A PIN kód sikeresen megváltoztatva!';
      _oldPinController.clear();
      _newPinController.clear();
      _confirmPinController.clear();
    });
  }

  Future<void> _saveSecurityQuestion() async {
    if (_questionController.text.trim().isEmpty ||
        _answerController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kérlek, töltsd ki a kérdést és a választ is!'),
        ),
      );
      return;
    }

    await ParentalService.setSecurityQuestionAndAnswer(
      _questionController.text.trim(),
      _answerController.text.trim(),
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Biztonsági kérdés sikeresen elmentve!'),
          backgroundColor: Color(0xFF2E7D32),
        ),
      );
      _answerController.clear();
    }
  }

  Future<void> _handleResetDefaults() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: Color(0xFFE11D48),
              size: 28,
            ),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Alaphelyzetbe állítás',
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        content: const Text(
          'Biztosan visszaállítod a gyári alapértelmezéseket?\n\n'
          'Ez újraépíti az eredeti napirendet, a lépéseket és a Beszélő Kártyákat.',
          style: TextStyle(fontSize: 15, color: Color(0xFF334155)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Mégse'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE11D48),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Visszaállítás',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      await DatabaseHelper.instance.resetToDefaults();

      if (mounted) {
        final routineProv = context.read<RoutineProvider>();
        routineProv.selectDay(routineProv.selectedDay);
        await context.read<AacProvider>().loadCards();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'A gyári beállítások és feladatok sikeresen visszaálltak! ✅',
            ),
            backgroundColor: Color(0xFF16A34A),
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Widget _buildRewardLeading(RewardModel reward) {
    if (reward.imageType == 'CUSTOM_IMAGE' &&
        File(reward.imagePath).existsSync()) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.file(
          File(reward.imagePath),
          width: 42,
          height: 42,
          fit: BoxFit.cover,
        ),
      );
    }

    IconData iconData = Icons.stars_rounded;
    switch (reward.imagePath) {
      case 'icecream':
        iconData = Icons.icecream_rounded;
        break;
      case 'tv':
        iconData = Icons.tv_rounded;
        break;
      case 'park':
        iconData = Icons.park_rounded;
        break;
      case 'toys':
        iconData = Icons.toys_rounded;
        break;
      case 'book':
        iconData = Icons.menu_book_rounded;
        break;
      case 'sports':
        iconData = Icons.sports_esports_rounded;
        break;
    }

    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: const Color(0xFFFEF3C7),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(iconData, color: const Color(0xFFD97706), size: 24),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final primaryTextColor = isDark
        ? const Color(0xFFF8FAFC)
        : const Color(0xFF1E293B);
    final secondaryTextColor = isDark
        ? const Color(0xFF94A3B8)
        : const Color(0xFF64748B);
    final cardBgColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final cardBorderColor = isDark
        ? const Color(0xFF334155)
        : const Color(0xFFE2E8F0);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Szülői beállítások',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: primaryTextColor,
          ),
        ),
        backgroundColor: cardBgColor,
        foregroundColor: primaryTextColor,
        elevation: 0.5,
      ),
      body: _isLoadingSettings
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 60),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SessionTimerSettingCard(),
                    const SizedBox(height: 24),

                    // MEGJELENÉS ÉS ÉJSZAKAI MÓD KÁRTYA
                    Consumer<ThemeProvider>(
                      builder: (context, themeProv, child) {
                        return _buildCard(
                          title: 'Megjelenés és éjszakai mód',
                          icon: Icons.dark_mode_outlined,
                          isDark: isDark,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Nyugtató, kímélő sötét felület az esti készülődéshez és a szem fáradtságának csökkentésére.',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: secondaryTextColor,
                                ),
                              ),
                              const SizedBox(height: 12),
                              SwitchListTile.adaptive(
                                contentPadding: EdgeInsets.zero,
                                title: Text(
                                  'Szenzoros éjszakai mód',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                    color: primaryTextColor,
                                  ),
                                ),
                                subtitle: Text(
                                  themeProv.isDarkMode
                                      ? 'Bekapcsolva (lágy sötétkék háttér)'
                                      : 'Kikapcsolva (nappali világos háttér)',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: secondaryTextColor,
                                  ),
                                ),
                                value: themeProv.isDarkMode,
                                activeColor: const Color(0xFF2563EB),
                                onChanged: (val) {
                                  themeProv.toggleTheme(val);
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 24),

                    // ÉRTESÍTÉSEK ÉS FIGYELMEZTETÉSEK
                    _buildCard(
                      title: 'Értesítések és figyelmeztetések',
                      icon: Icons.notifications_active_outlined,
                      isDark: isDark,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Szabályozd a felugró ablakokat, a hangjelzéseket és a rendszerértesítéseket.',
                            style: TextStyle(
                              fontSize: 13,
                              color: secondaryTextColor,
                            ),
                          ),
                          const SizedBox(height: 16),

                          SwitchListTile.adaptive(
                            contentPadding: EdgeInsets.zero,
                            title: Text(
                              'Felugró ablak napirend közben',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: primaryTextColor,
                              ),
                            ),
                            subtitle: Text(
                              'Ha elérkezik a feladat ideje, nagy kártya ugrik fel a gyermeknek.',
                              style: TextStyle(
                                fontSize: 12,
                                color: secondaryTextColor,
                              ),
                            ),
                            value: _popupAlertEnabled,
                            activeColor: const Color(0xFF2563EB),
                            onChanged: (val) async {
                              setState(() => _popupAlertEnabled = val);
                              await AppSettingsService.setTaskPopupAlertEnabled(
                                val,
                              );
                            },
                          ),
                          Divider(height: 16, color: cardBorderColor),

                          SwitchListTile.adaptive(
                            contentPadding: EdgeInsets.zero,
                            title: Text(
                              'Hangjelzés / Felolvasás riasztáskor',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: primaryTextColor,
                              ),
                            ),
                            subtitle: Text(
                              'A felugró ablak automatikusan lejátssza a felvett szülői hangot vagy TTS-t.',
                              style: TextStyle(
                                fontSize: 12,
                                color: secondaryTextColor,
                              ),
                            ),
                            value: _alertSoundEnabled,
                            activeColor: const Color(0xFF2563EB),
                            onChanged: (val) async {
                              setState(() => _alertSoundEnabled = val);
                              await AppSettingsService.setAlertSoundEnabled(
                                val,
                              );
                            },
                          ),
                          Divider(height: 16, color: cardBorderColor),

                          SwitchListTile.adaptive(
                            contentPadding: EdgeInsets.zero,
                            title: Text(
                              'Háttérbeli rendszerértesítések',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: primaryTextColor,
                              ),
                            ),
                            subtitle: Text(
                              'Értesítés az értesítési sávban, ha az app le van zárva vagy a háttérben fut.',
                              style: TextStyle(
                                fontSize: 12,
                                color: secondaryTextColor,
                              ),
                            ),
                            value: _notificationsEnabled,
                            activeColor: const Color(0xFF2563EB),
                            onChanged: (val) async {
                              setState(() => _notificationsEnabled = val);
                              await AppSettingsService.setNotificationsEnabled(
                                val,
                              );
                              if (context.mounted) {
                                await context
                                    .read<RoutineProvider>()
                                    .rescheduleAllNotifications();
                              }
                            },
                          ),
                          Divider(height: 24, color: cardBorderColor),

                          // Képernyőidő korlát dropdown
                          DropdownButtonFormField<int>(
                            value: _screenTimeLimit,
                            isExpanded: true,
                            dropdownColor: isDark
                                ? const Color(0xFF1E293B)
                                : Colors.white,
                            style: TextStyle(
                              color: primaryTextColor,
                              fontSize: 14,
                            ),
                            decoration: InputDecoration(
                              labelText: 'Képernyőidő figyelmeztetés',
                              labelStyle: TextStyle(color: secondaryTextColor),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: cardBorderColor),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 12,
                              ),
                            ),
                            items: [
                              DropdownMenuItem(
                                value: 0,
                                child: Text(
                                  'Kikapcsolva',
                                  style: TextStyle(color: primaryTextColor),
                                ),
                              ),
                              DropdownMenuItem(
                                value: 1,
                                child: Text(
                                  '1 perc (Teszteléshez ⚡)',
                                  style: TextStyle(color: primaryTextColor),
                                ),
                              ),
                              DropdownMenuItem(
                                value: 30,
                                child: Text(
                                  '30 perc után',
                                  style: TextStyle(color: primaryTextColor),
                                ),
                              ),
                              DropdownMenuItem(
                                value: 45,
                                child: Text(
                                  '45 perc után',
                                  style: TextStyle(color: primaryTextColor),
                                ),
                              ),
                              DropdownMenuItem(
                                value: 60,
                                child: Text(
                                  '1 óra után (Ajánlott)',
                                  style: TextStyle(color: primaryTextColor),
                                ),
                              ),
                              DropdownMenuItem(
                                value: 90,
                                child: Text(
                                  '1,5 óra után',
                                  style: TextStyle(color: primaryTextColor),
                                ),
                              ),
                            ],
                            onChanged: (val) async {
                              if (val != null) {
                                setState(() => _screenTimeLimit = val);
                                await AppSettingsService.setScreenTimeLimit(
                                  val,
                                );
                                if (val <= 0) {
                                  ScreenTimeService.instance.stop();
                                } else {
                                  ScreenTimeService.instance.startMonitoring();
                                }
                              }
                            },
                          ),
                          const SizedBox(height: 16),

                          // Közelgő feladat dropdown
                          DropdownButtonFormField<int>(
                            value: _routineReminderMinutes,
                            isExpanded: true,
                            dropdownColor: isDark
                                ? const Color(0xFF1E293B)
                                : Colors.white,
                            style: TextStyle(
                              color: primaryTextColor,
                              fontSize: 14,
                            ),
                            decoration: InputDecoration(
                              labelText: 'Közelgő feladat előjelzése',
                              labelStyle: TextStyle(color: secondaryTextColor),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: cardBorderColor),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 12,
                              ),
                            ),
                            items: [
                              DropdownMenuItem(
                                value: 0,
                                child: Text(
                                  'Kikapcsolva',
                                  style: TextStyle(color: primaryTextColor),
                                ),
                              ),
                              DropdownMenuItem(
                                value: 15,
                                child: Text(
                                  '15 perccel előtte',
                                  style: TextStyle(color: primaryTextColor),
                                ),
                              ),
                              DropdownMenuItem(
                                value: 30,
                                child: Text(
                                  '30 perccel előtte (Ajánlott)',
                                  style: TextStyle(color: primaryTextColor),
                                ),
                              ),
                              DropdownMenuItem(
                                value: 60,
                                child: Text(
                                  '60 perccel előtte',
                                  style: TextStyle(color: primaryTextColor),
                                ),
                              ),
                            ],
                            onChanged: (val) async {
                              if (val != null) {
                                setState(() => _routineReminderMinutes = val);
                                await AppSettingsService.setRoutineReminderMinutes(
                                  val,
                                );
                                if (context.mounted) {
                                  await context
                                      .read<RoutineProvider>()
                                      .rescheduleAllNotifications();
                                }
                              }
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // JUTALMAK BEÁLLÍTÁSA
                    _buildCard(
                      title: 'Jutalmak beállítása',
                      icon: Icons.stars_rounded,
                      isDark: isDark,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Itt kezelheted az elérhető jutalmakat és felvehetsz újakat saját képpel a telefonodról.',
                            style: TextStyle(
                              fontSize: 13,
                              color: secondaryTextColor,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Consumer<RewardProvider>(
                            builder: (context, rewardProv, child) {
                              if (rewardProv.isLoading) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              }

                              if (rewardProv.rewards.isEmpty) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  child: Text(
                                    'Nincsenek jutalmak felvéve.',
                                    style: TextStyle(color: secondaryTextColor),
                                  ),
                                );
                              }

                              return ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: rewardProv.rewards.length,
                                separatorBuilder: (_, __) =>
                                    Divider(height: 12, color: cardBorderColor),
                                itemBuilder: (context, index) {
                                  final reward = rewardProv.rewards[index];
                                  return ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    leading: _buildRewardLeading(reward),
                                    title: Text(
                                      reward.title,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 15,
                                        color: primaryTextColor,
                                      ),
                                    ),
                                    subtitle: Text(
                                      '${reward.pointsCost} csillag ⭐',
                                      style: const TextStyle(
                                        color: Color(0xFFD97706),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    trailing: IconButton(
                                      icon: const Icon(
                                        Icons.delete_outline_rounded,
                                        color: Color(0xFFEF4444),
                                      ),
                                      onPressed: () {
                                        if (reward.id != null) {
                                          rewardProv.deleteReward(reward.id!);
                                        }
                                      },
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () => AddRewardDialog.show(context),
                              icon: const Icon(
                                Icons.add_rounded,
                                color: Colors.white,
                              ),
                              label: const Text(
                                'Új jutalom hozzáadása',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFD97706),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // EGYEDI FELADATOK
                    _buildCard(
                      title: 'Egyedi Feladatok & Saját Kártyák',
                      icon: Icons.edit_note_rounded,
                      isDark: isDark,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hozz létre saját tárgyakról, fotókról és hangokról szóló kártyákat a gyermekednek.',
                            style: TextStyle(
                              fontSize: 13,
                              color: secondaryTextColor,
                            ),
                          ),
                          const SizedBox(height: 14),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () =>
                                  AddCustomTaskDialog.show(context),
                              icon: const Icon(
                                Icons.add_photo_alternate_rounded,
                                color: Colors.white,
                              ),
                              label: const Text(
                                'Új egyedi kártya készítése',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2563EB),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          Divider(height: 1, color: cardBorderColor),
                          const SizedBox(height: 8),

                          Consumer<CustomTaskProvider>(
                            builder: (context, customProv, child) {
                              final tasks = customProv.tasks;

                              if (tasks.isEmpty) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 10.0,
                                  ),
                                  child: Center(
                                    child: Text(
                                      'Még nem vettél fel saját kártyát.',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: secondaryTextColor,
                                      ),
                                    ),
                                  ),
                                );
                              }

                              return ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: tasks.length,
                                separatorBuilder: (_, __) =>
                                    Divider(height: 1, color: cardBorderColor),
                                itemBuilder: (context, index) {
                                  final task = tasks[index];
                                  final hasImage =
                                      task.imagePath != null &&
                                      File(task.imagePath!).existsSync();

                                  return ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    leading: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: hasImage
                                          ? Image.file(
                                              File(task.imagePath!),
                                              width: 42,
                                              height: 42,
                                              fit: BoxFit.cover,
                                            )
                                          : Container(
                                              width: 42,
                                              height: 42,
                                              color: isDark
                                                  ? const Color(0xFF0F172A)
                                                  : const Color(0xFFF1F5F9),
                                              child: Icon(
                                                Icons.image_outlined,
                                                color: secondaryTextColor,
                                                size: 20,
                                              ),
                                            ),
                                    ),
                                    title: Text(
                                      task.title,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: primaryTextColor,
                                      ),
                                    ),
                                    subtitle: Text(
                                      task.category,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: secondaryTextColor,
                                      ),
                                    ),
                                    trailing: IconButton(
                                      icon: const Icon(
                                        Icons.delete_outline_rounded,
                                        color: Color(0xFFEF4444),
                                        size: 22,
                                      ),
                                      tooltip: 'Kártya törlése',
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (ctx) => AlertDialog(
                                            backgroundColor: cardBgColor,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                            ),
                                            title: Text(
                                              'Kártya törlése',
                                              style: TextStyle(
                                                color: primaryTextColor,
                                              ),
                                            ),
                                            content: Text(
                                              'Biztosan törölni szeretnéd a(z) "${task.title}" kártyát?',
                                              style: TextStyle(
                                                color: secondaryTextColor,
                                              ),
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.pop(ctx),
                                                child: Text(
                                                  'Mégse',
                                                  style: TextStyle(
                                                    color: secondaryTextColor,
                                                  ),
                                                ),
                                              ),
                                              ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: const Color(
                                                    0xFFEF4444,
                                                  ),
                                                  foregroundColor: Colors.white,
                                                ),
                                                onPressed: () async {
                                                  Navigator.pop(ctx);
                                                  await customProv.deleteTask(
                                                    task.id,
                                                  );
                                                },
                                                child: const Text('Törlés'),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // GYÁRI ALAPHELYZETBE ÁLLÍTÁS KÁRTYA (Overflow védve)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: cardBgColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDark
                              ? const Color(0xFF9F1239)
                              : const Color(0xFFFECDD3),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(
                              alpha: isDark ? 0.3 : 0.03,
                            ),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.restore_rounded,
                                color: Color(0xFFE11D48),
                                size: 22,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Gyári elemek visszaállítása',
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: primaryTextColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Divider(
                            height: 24,
                            thickness: 1,
                            color: isDark
                                ? const Color(0xFF4C0519)
                                : const Color(0xFFFFF1F2),
                          ),
                          Text(
                            'Ha véletlenül kitöröltél egy beépített feladatot vagy kártyát, ezzel a gombbal visszaállíthatod az eredeti állapotot.',
                            style: TextStyle(
                              fontSize: 13,
                              color: secondaryTextColor,
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: _handleResetDefaults,
                              icon: const Icon(
                                Icons.restart_alt_rounded,
                                color: Color(0xFFE11D48),
                              ),
                              label: const Flexible(
                                child: Text(
                                  'Gyári alapértékek visszaállítása',
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Color(0xFFE11D48),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                  color: Color(0xFFE11D48),
                                  width: 1.5,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                  horizontal: 8,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // PIN KÓD MÓDOSÍTÁSA
                    _buildCard(
                      title: 'PIN kód módosítása',
                      icon: Icons.pin_rounded,
                      isDark: isDark,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Itt adhatsz meg új 4 számjegyű kódot a védett funkciókhoz.',
                            style: TextStyle(
                              fontSize: 13,
                              color: secondaryTextColor,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildPinField(
                            controller: _oldPinController,
                            label: 'Jelenlegi PIN kód',
                            isDark: isDark,
                          ),
                          const SizedBox(height: 12),
                          _buildPinField(
                            controller: _newPinController,
                            label: 'Új PIN kód (4 számjegy)',
                            isDark: isDark,
                          ),
                          const SizedBox(height: 12),
                          _buildPinField(
                            controller: _confirmPinController,
                            label: 'Új PIN megerősítése',
                            isDark: isDark,
                          ),
                          const SizedBox(height: 12),
                          if (_pinErrorMessage != null)
                            Text(
                              _pinErrorMessage!,
                              style: const TextStyle(
                                color: Color(0xFFEF4444),
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          if (_pinSuccessMessage != null)
                            Text(
                              _pinSuccessMessage!,
                              style: const TextStyle(
                                color: Color(0xFF16A34A),
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _changePin,
                              icon: const Icon(
                                Icons.check_rounded,
                                color: Colors.white,
                              ),
                              label: const Text(
                                'PIN kód mentése',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2563EB),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // BIZTONSÁGI KÉRDÉS
                    _buildCard(
                      title: 'Biztonsági kérdés',
                      icon: Icons.help_outline_rounded,
                      isDark: isDark,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Ha elfelejtenéd a PIN kódot, ennek a kérdésnek a megválaszolásával adhatsz meg új kódot.',
                            style: TextStyle(
                              fontSize: 13,
                              color: secondaryTextColor,
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _questionController,
                            style: TextStyle(color: primaryTextColor),
                            decoration: InputDecoration(
                              labelText: 'Biztonsági kérdés',
                              labelStyle: TextStyle(color: secondaryTextColor),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: cardBorderColor),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 12,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _answerController,
                            obscureText: true,
                            style: TextStyle(color: primaryTextColor),
                            decoration: InputDecoration(
                              labelText:
                                  'Válasz (nem érzékeny a kis/nagybetűkre)',
                              labelStyle: TextStyle(color: secondaryTextColor),
                              hintText: 'Pl. Kovács',
                              hintStyle: TextStyle(
                                color: secondaryTextColor.withValues(
                                  alpha: 0.6,
                                ),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: cardBorderColor),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 12,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: _saveSecurityQuestion,
                              icon: const Icon(
                                Icons.save_rounded,
                                color: Color(0xFF2563EB),
                              ),
                              label: const Text(
                                'Kérdés mentése',
                                style: TextStyle(
                                  color: Color(0xFF2563EB),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                side: const BorderSide(
                                  color: Color(0xFF2563EB),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildPinField({
    required TextEditingController controller,
    required String label,
    required bool isDark,
  }) {
    final primaryTextColor = isDark
        ? const Color(0xFFF8FAFC)
        : const Color(0xFF1E293B);
    final secondaryTextColor = isDark
        ? const Color(0xFF94A3B8)
        : const Color(0xFF64748B);
    final cardBorderColor = isDark
        ? const Color(0xFF334155)
        : const Color(0xFFE2E8F0);

    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      obscureText: true,
      maxLength: 4,
      style: TextStyle(color: primaryTextColor),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: secondaryTextColor),
        counterText: '',
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: cardBorderColor),
        ),
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required IconData icon,
    required Widget child,
    required bool isDark,
  }) {
    final cardBgColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final cardBorderColor = isDark
        ? const Color(0xFF334155)
        : const Color(0xFFE2E8F0);
    final primaryTextColor = isDark
        ? const Color(0xFFF8FAFC)
        : const Color(0xFF1E293B);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cardBorderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF2563EB), size: 22),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: primaryTextColor,
                  ),
                ),
              ),
            ],
          ),
          Divider(
            height: 24,
            thickness: 1,
            color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
          ),
          child,
        ],
      ),
    );
  }
}
