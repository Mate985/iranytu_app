import 'package:flutter/material.dart';

class RoutineStep {
  final String id;
  final String title;
  final IconData icon;
  final String?
  imagePath; // pl. 'assets/images/routines/hw_1.png' vagy helyi fotó
  final String? audioPath;
  bool isCompleted;

  RoutineStep({
    required this.id,
    required this.title,
    required this.icon,
    this.imagePath,
    this.audioPath,
    this.isCompleted = false,
  });
}

class Routine {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final String? imagePath;
  final Color themeColor;
  final List<RoutineStep> steps;

  Routine({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    this.imagePath,
    required this.themeColor,
    required this.steps,
  });

  double get progress {
    if (steps.isEmpty) return 0.0;
    final completed = steps.where((s) => s.isCompleted).length;
    return completed / steps.length;
  }
}

final List<Routine> sampleRoutines = [
  // 1. Kézmosás
  Routine(
    id: 'handwash',
    title: 'Kézmosás',
    description: 'Tiszta kezek lépésről lépésre.',
    icon: Icons.wash_rounded,
    imagePath: 'assets/images/routines/handwash.png',
    themeColor: const Color(0xFF38BDF8),
    steps: [
      RoutineStep(
        id: 'hw_1',
        title: 'Tűrd fel az ujjad!',
        icon: Icons.pan_tool_rounded,
        imagePath: 'assets/images/routines/hw_1.png',
        audioPath: 'assets/audio/routines/turd_fel.mp3',
      ),
      RoutineStep(
        id: 'hw_2',
        title: 'Nyisd meg a vizet!',
        icon: Icons.water_drop_rounded,
        imagePath: 'assets/images/routines/hw_2.png',
        audioPath: 'assets/audio/routines/nyisd_meg.mp3',
      ),
      RoutineStep(
        id: 'hw_3',
        title: 'Nyomj szappant!',
        icon: Icons.bubble_chart_rounded,
        imagePath: 'assets/images/routines/hw_3.png',
        audioPath: 'assets/audio/routines/nyomj_egy_adag.mp3',
      ),
      RoutineStep(
        id: 'hw_4',
        title: 'Dörzsöld össze a kezed!',
        icon: Icons.timer_rounded,
        imagePath: 'assets/images/routines/hw_4.png',
        audioPath: 'assets/audio/routines/dorzsold_ossze.mp3',
      ),
      RoutineStep(
        id: 'hw_5',
        title: 'Öblítsd le a habot!',
        icon: Icons.waves_rounded,
        imagePath: 'assets/images/routines/hw_5.png',
        audioPath: 'assets/audio/routines/oblitsd_le_a.mp3',
      ),
      RoutineStep(
        id: 'hw_6',
        title: 'Töröld meg a kezed!',
        icon: Icons.dry_rounded,
        imagePath: 'assets/images/routines/hw_6.png',
        audioPath: 'assets/audio/routines/torold_szarazra.mp3',
      ),
    ],
  ),

  // 2. Fogmosás
  Routine(
    id: 'brushing',
    title: 'Fogmosás',
    description: 'Tiszta fogak reggel és este.',
    icon: Icons.cleaning_services_rounded,
    imagePath: 'assets/images/routines/brushing.png',
    themeColor: const Color(0xFF2DD4BF),
    steps: [
      RoutineStep(
        id: 'br_1',
        title: 'Fogd meg a fogkefét!',
        icon: Icons.brush_rounded,
        imagePath: 'assets/images/routines/br_1.png',
        audioPath: 'assets/audio/routines/vedd_a_kezedbe.mp3',
      ),
      RoutineStep(
        id: 'br_2',
        title: 'Nyomj rá fogkrémet!',
        icon: Icons.colorize_rounded,
        imagePath: 'assets/images/routines/br_2.png',
        audioPath: 'assets/audio/routines/nyomj_egy_borsonyi.mp3',
      ),
      RoutineStep(
        id: 'br_3',
        title: 'Mosd meg felül!',
        icon: Icons.arrow_upward_rounded,
        imagePath: 'assets/images/routines/br_3.png',
        audioPath: 'assets/audio/routines/mosd_meg_felul.mp3',
      ),
      RoutineStep(
        id: 'br_4',
        title: 'Mosd meg alul!',
        icon: Icons.arrow_downward_rounded,
        imagePath: 'assets/images/routines/br_4.png',
        audioPath: 'assets/audio/routines/mosd_meg_alul.mp3',
      ),
      RoutineStep(
        id: 'br_5',
        title: 'Köpd ki a habot!',
        icon: Icons.keyboard_return_rounded,
        imagePath: 'assets/images/routines/br_5.png',
        audioPath: 'assets/audio/routines/kopd_ki_a_felesleges.mp3',
      ),
      RoutineStep(
        id: 'br_6',
        title: 'Öblítsd ki a szád!',
        icon: Icons.water_rounded,
        imagePath: 'assets/images/routines/br_6.png',
        audioPath: 'assets/audio/routines/oblitsd_ki_a_szad.mp3',
      ),
    ],
  ),

  // 3. Reggeli öltözködés
  Routine(
    id: 'dressing',
    title: 'Reggeli öltözködés',
    description: 'Öltözz fel önállóan!',
    icon: Icons.checkroom_rounded,
    imagePath: 'assets/images/routines/dressing.png',
    themeColor: const Color(0xFFFB923C),
    steps: [
      RoutineStep(
        id: 'dr_1',
        title: 'Vedd fel az alsóneműt!',
        icon: Icons.accessibility_new_rounded,
        imagePath: 'assets/images/routines/dr_1.png',
        audioPath: 'assets/audio/routines/vedd_fel_a_tiszta.mp3',
      ),
      RoutineStep(
        id: 'dr_2',
        title: 'Bújj bele a nadrágba!',
        icon: Icons.boy_rounded,
        imagePath: 'assets/images/routines/dr_2.png',
        audioPath: 'assets/audio/routines/bujj_bele_a_nadrag.mp3',
      ),
      RoutineStep(
        id: 'dr_3',
        title: 'Húzd fel a zoknit!',
        icon: Icons.wb_sunny_rounded,
        imagePath: 'assets/images/routines/dr_3.png',
        audioPath: 'assets/audio/routines/huzd_fel_a_zoknid.mp3',
      ),
      RoutineStep(
        id: 'dr_4',
        title: 'Vedd fel a pólót!',
        icon: Icons.checkroom_rounded,
        imagePath: 'assets/images/routines/dr_4.png',
        audioPath: 'assets/audio/routines/vedd_fel_a_polod.mp3',
      ),
      RoutineStep(
        id: 'dr_5',
        title: 'Nézz a tükörbe!',
        icon: Icons.face_rounded,
        imagePath: 'assets/images/routines/dr_5.png',
        audioPath: 'assets/audio/routines/nezz_a_tukorbe.mp3',
      ),
    ],
  ),

  // 4. Indulás otthonról
  Routine(
    id: 'leaving',
    title: 'Indulás otthonról',
    description: 'Készülj az indulásra!',
    icon: Icons.door_sliding_rounded,
    imagePath: 'assets/images/routines/leaving.png',
    themeColor: const Color(0xFFFBBF24),
    steps: [
      RoutineStep(
        id: 'lv_1',
        title: 'Vedd fel a cipőt!',
        icon: Icons.chair_rounded,
        imagePath: 'assets/images/routines/lv_1.png',
        audioPath: 'assets/audio/routines/ulj_le_kenyelmesen.mp3',
      ),
      RoutineStep(
        id: 'lv_2',
        title: 'Kösd be a cipőt!',
        icon: Icons.straighten_rounded,
        imagePath: 'assets/images/routines/lv_2.png',
        audioPath: 'assets/audio/routines/huzd_meg_a_tepozar.mp3',
      ),
      RoutineStep(
        id: 'lv_3',
        title: 'Vedd fel a kabátot!',
        icon: Icons.checkroom_rounded,
        imagePath: 'assets/images/routines/lv_3.png',
        audioPath: 'assets/audio/routines/bujj_bele_a_kabatba.mp3',
      ),
      RoutineStep(
        id: 'lv_4',
        title: 'Húzd fel a cipzárt!',
        icon: Icons.unfold_more_rounded,
        imagePath: 'assets/images/routines/lv_4.png',
        audioPath: 'assets/audio/routines/huzd_fel_a_zipzart.mp3',
      ),
      RoutineStep(
        id: 'lv_5',
        title: 'Vedd fel a sapkát, sálat!',
        icon: Icons.ac_unit_rounded,
        imagePath: 'assets/images/routines/lv_5.png',
        audioPath: 'assets/audio/routines/hideg_idoben.mp3',
      ),
      RoutineStep(
        id: 'lv_6',
        title: 'Vedd fel a táskát!',
        icon: Icons.backpack_rounded,
        imagePath: 'assets/images/routines/lv_6.png',
        audioPath: 'assets/audio/routines/vedd_fel_a_taskad.mp3',
      ),
    ],
  ),

  // 5. Hazaérkezés
  Routine(
    id: 'coming_home',
    title: 'Hazaérkezés',
    description: 'Megérkeztünk haza.',
    icon: Icons.home_rounded,
    imagePath: 'assets/images/routines/coming_home.png',
    themeColor: const Color(0xFF34D399),
    steps: [
      RoutineStep(
        id: 'ch_1',
        title: 'Csukd be az ajtót!',
        icon: Icons.sensor_door_rounded,
        imagePath: 'assets/images/routines/ch_1.png',
        audioPath: 'assets/audio/routines/lepj_be_az_eloszoba.mp3',
      ),
      RoutineStep(
        id: 'ch_2',
        title: 'Vedd le a cipőt!',
        icon: Icons.dry_cleaning_rounded,
        imagePath: 'assets/images/routines/ch_2.png',
        audioPath: 'assets/audio/routines/vedd_le_a_cipodet.mp3',
      ),
      RoutineStep(
        id: 'ch_3',
        title: 'Akaszd fel a kabátot!',
        icon: Icons.checkroom_rounded,
        imagePath: 'assets/images/routines/ch_3.png',
        audioPath: 'assets/audio/routines/akaszd_fel_a_kabatot.mp3',
      ),
      RoutineStep(
        id: 'ch_4',
        title: 'Moss kezet!',
        icon: Icons.wash_rounded,
        imagePath: 'assets/images/routines/ch_4.png',
        audioPath: 'assets/audio/routines/menj_kozvetlen_a_furdobe.mp3',
      ),
      RoutineStep(
        id: 'ch_5',
        title: 'Öltözz át!',
        icon: Icons.weekend_rounded,
        imagePath: 'assets/images/routines/ch_5.png',
        audioPath: 'assets/audio/routines/oltozz_at_kenyelmes.mp3',
      ),
    ],
  ),

  // 6. WC használat
  Routine(
    id: 'toilet',
    title: 'WC használat',
    description: 'Mosdóhasználat lépései.',
    icon: Icons.wc_rounded,
    imagePath: 'assets/images/routines/toilet.png',
    themeColor: const Color(0xFF60A5FA),
    steps: [
      RoutineStep(
        id: 'wc_1',
        title: 'Csukd be az ajtót!',
        icon: Icons.door_front_door_rounded,
        imagePath: 'assets/images/routines/wc_1.png',
        audioPath: 'assets/audio/routines/csukd_be_magad_utan.mp3',
      ),
      RoutineStep(
        id: 'wc_2',
        title: 'Húzd le a nadrágot!',
        icon: Icons.vertical_align_bottom_rounded,
        imagePath: 'assets/images/routines/wc_2.png',
        audioPath: 'assets/audio/routines/huzd_le_a_nadragod.mp3',
      ),
      RoutineStep(
        id: 'wc_3',
        title: 'Ülj le a WC-re!',
        icon: Icons.event_seat_rounded,
        imagePath: 'assets/images/routines/wc_3.png',
        audioPath: 'assets/audio/routines/ulj_le_a_deszkara.mp3',
      ),
      RoutineStep(
        id: 'wc_4',
        title: 'Használj WC-papírt!',
        icon: Icons.receipt_rounded,
        imagePath: 'assets/images/routines/wc_4.png',
        audioPath: 'assets/audio/routines/hasznalj_wc_papirt.mp3',
      ),
      RoutineStep(
        id: 'wc_5',
        title: 'Húzd fel a nadrágot!',
        icon: Icons.vertical_align_top_rounded,
        imagePath: 'assets/images/routines/wc_5.png',
        audioPath: 'assets/audio/routines/allj_fel_majd_huzd_fel.mp3',
      ),
      RoutineStep(
        id: 'wc_6',
        title: 'Húzd le a WC-t!',
        icon: Icons.water_drop_rounded,
        imagePath: 'assets/images/routines/wc_6.png',
        audioPath: 'assets/audio/routines/huzd_le_a_wct.mp3',
      ),
      RoutineStep(
        id: 'wc_7',
        title: 'Moss kezet!',
        icon: Icons.wash_rounded,
        imagePath: 'assets/images/routines/wc_7.png',
        audioPath: 'assets/audio/routines/moss_kezet_szappannal.mp3',
      ),
    ],
  ),

  // 7. Étkezés
  Routine(
    id: 'eating',
    title: 'Étkezés',
    description: 'Nyugodt étkezés.',
    icon: Icons.restaurant_rounded,
    imagePath: 'assets/images/routines/eating.png',
    themeColor: const Color(0xFFA3E635),
    steps: [
      RoutineStep(
        id: 'et_1',
        title: 'Moss kezet!',
        icon: Icons.wash_rounded,
        imagePath: 'assets/images/routines/et_1.png',
        audioPath: 'assets/audio/routines/moss_kezet_az_etkezes_elott.mp3',
      ),
      RoutineStep(
        id: 'et_2',
        title: 'Ülj az asztalhoz!',
        icon: Icons.chair_rounded,
        imagePath: 'assets/images/routines/et_2.png',
        audioPath: 'assets/audio/routines/ulj_le_a_helyedre.mp3',
      ),
      RoutineStep(
        id: 'et_3',
        title: 'Egyél lassan!',
        icon: Icons.restaurant_menu_rounded,
        imagePath: 'assets/images/routines/et_3.png',
        audioPath: 'assets/audio/routines/egyel_kenyelmes_tempoban.mp3',
      ),
      RoutineStep(
        id: 'et_4',
        title: 'Igyál vizet!',
        icon: Icons.local_drink_rounded,
        imagePath: 'assets/images/routines/et_4.png',
        audioPath: 'assets/audio/routines/szukseg_eseten_igyal.mp3',
      ),
      RoutineStep(
        id: 'et_5',
        title: 'Töröld meg a szád!',
        icon: Icons.clean_hands_rounded,
        imagePath: 'assets/images/routines/et_5.png',
        audioPath: 'assets/audio/routines/az_etkezes_vegen_torold.mp3',
      ),
    ],
  ),

  // 8. Étkezés utáni rendrakás
  Routine(
    id: 'clean_table',
    title: 'Asztal letakarítása',
    description: 'Pakoljunk el evés után!',
    icon: Icons.soup_kitchen_rounded,
    imagePath: 'assets/images/routines/clean_table.png',
    themeColor: const Color(0xFF4ADE80),
    steps: [
      RoutineStep(
        id: 'ct_1',
        title: 'Fogd meg a tányért!',
        icon: Icons.pan_tool_rounded,
        imagePath: 'assets/images/routines/ct_1.png',
        audioPath: 'assets/audio/routines/fogd_meg_a_tanyerod.mp3',
      ),
      RoutineStep(
        id: 'ct_2',
        title: 'Vidd a mosogatóba!',
        icon: Icons.kitchen_rounded,
        imagePath: 'assets/images/routines/ct_2.png',
        audioPath: 'assets/audio/routines/vidd_ki_a_mosogatoba.mp3',
      ),
      RoutineStep(
        id: 'ct_3',
        title: 'Vidd ki a poharat!',
        icon: Icons.local_drink_rounded,
        imagePath: 'assets/images/routines/ct_3.png',
        audioPath: 'assets/audio/routines/vidd_ki_a_poharadat.mp3',
      ),
      RoutineStep(
        id: 'ct_4',
        title: 'Dobd ki a szalvétát!',
        icon: Icons.delete_outline_rounded,
        imagePath: 'assets/images/routines/ct_4.png',
        audioPath: 'assets/audio/routines/dobd_a_hasznalt_szalvetat.mp3',
      ),
      RoutineStep(
        id: 'ct_5',
        title: 'Töröld le az asztalt!',
        icon: Icons.table_restaurant_rounded,
        imagePath: 'assets/images/routines/ct_5.png',
        audioPath: 'assets/audio/routines/torold_le_a_morzsakat.mp3',
      ),
    ],
  ),

  // 9. Bepakolás a táskába
  Routine(
    id: 'backpack',
    title: 'Táska bepakolása',
    description: 'Készítsük össze a táskát!',
    icon: Icons.backpack_rounded,
    imagePath: 'assets/images/routines/backpack.png',
    themeColor: const Color(0xFF818CF8),
    steps: [
      RoutineStep(
        id: 'bp_1',
        title: 'Nyisd ki a táskát!',
        icon: Icons.unfold_more_rounded,
        imagePath: 'assets/images/routines/bp_1.png',
        audioPath:
            'assets/audio/routines/nyisd_ki_teljesen_az_iskolataskad.mp3',
      ),
      RoutineStep(
        id: 'bp_2',
        title: 'Tedd be a füzeteket, könyveket!',
        icon: Icons.menu_book_rounded,
        imagePath: 'assets/images/routines/bp_2.png',
        audioPath: 'assets/audio/routines/helyezd_el_a_fuzeteket.mp3',
      ),
      RoutineStep(
        id: 'bp_3',
        title: 'Tedd be a kulacsot!',
        icon: Icons.local_drink_rounded,
        imagePath: 'assets/images/routines/bp_3.png',
        audioPath: 'assets/audio/routines/tedd_be_a_kulacsot.mp3',
      ),
      RoutineStep(
        id: 'bp_4',
        title: 'Tedd be az uzsonnát!',
        icon: Icons.lunch_dining_rounded,
        imagePath: 'assets/images/routines/bp_4.png',
        audioPath: 'assets/audio/routines/tedd_a_helyere_az_uzsonnas.mp3',
      ),
      RoutineStep(
        id: 'bp_5',
        title: 'Húzd be a cipzárt!',
        icon: Icons.lock_outline_rounded,
        imagePath: 'assets/images/routines/bp_5.png',
        audioPath: 'assets/audio/routines/huzd_be_az_osszes_zipzart.mp3',
      ),
    ],
  ),

  // 10. Játékok elpakolása
  Routine(
    id: 'tidy_up',
    title: 'Játékok elpakolása',
    description: 'Tegyünk rendet!',
    icon: Icons.toys_rounded,
    imagePath: 'assets/images/routines/tidy_up.png',
    themeColor: const Color(0xFFF472B6),
    steps: [
      RoutineStep(
        id: 'tu_1',
        title: 'Vége a játéknak.',
        icon: Icons.pause_circle_rounded,
        imagePath: 'assets/images/routines/tu_1.png',
        audioPath: 'assets/audio/routines/allj_meg_a_jatek_veget_ert.mp3',
      ),
      RoutineStep(
        id: 'tu_2',
        title: 'Szedd össze a kockákat!',
        icon: Icons.category_rounded,
        imagePath: 'assets/images/routines/tu_2.png',
        audioPath: 'assets/audio/routines/gyultsd_ossze_az_epito.mp3',
      ),
      RoutineStep(
        id: 'tu_3',
        title: 'Tedd a polcra a figurákat!',
        icon: Icons.inventory_2_rounded,
        imagePath: 'assets/images/routines/tu_3.png',
        audioPath: 'assets/audio/routines/helyezd_vissza_a_figurakat.mp3',
      ),
      RoutineStep(
        id: 'tu_4',
        title: 'Tedd el a könyveket!',
        icon: Icons.auto_stories_rounded,
        imagePath: 'assets/images/routines/tu_4.png',
        audioPath: 'assets/audio/routines/tedd_a_konyveket_a_helyere.mp3',
      ),
      RoutineStep(
        id: 'tu_5',
        title: 'Szép rend lett!',
        icon: Icons.sentiment_very_satisfied_rounded,
        imagePath: 'assets/images/routines/tu_5.png',
        audioPath: 'assets/audio/routines/nezz_korul_a_szobaban.mp3',
      ),
    ],
  ),

  // 11. Fürdés / Zuhanyzás
  Routine(
    id: 'bath',
    title: 'Fürdés',
    description: 'Esti tisztálkodás.',
    icon: Icons.bathtub_rounded,
    imagePath: 'assets/images/routines/bath.png',
    themeColor: const Color(0xFF38BDF8),
    steps: [
      RoutineStep(
        id: 'bt_1',
        title: 'Vetkőzz le!',
        icon: Icons.delete_sweep_rounded,
        imagePath: 'assets/images/routines/bt_1.png',
        audioPath: 'assets/audio/routines/vetkozz_le_es_tedd.mp3',
      ),
      RoutineStep(
        id: 'bt_2',
        title: 'Lépj a kádba / zuhanyba!',
        icon: Icons.directions_walk_rounded,
        imagePath: 'assets/images/routines/bt_2.png',
        audioPath: 'assets/audio/routines/lepj_be_ovatosan_a_zuhanyba.mp3',
      ),
      RoutineStep(
        id: 'bt_3',
        title: 'Vizezd be magad!',
        icon: Icons.shower_rounded,
        imagePath: 'assets/images/routines/bt_3.png',
        audioPath: 'assets/audio/routines/mosd_meg_az_egesz_tested.mp3',
      ),
      RoutineStep(
        id: 'bt_4',
        title: 'Mosakodj meg tusfürdővel!',
        icon: Icons.bubble_chart_rounded,
        imagePath: 'assets/images/routines/bt_4.png',
        audioPath: 'assets/audio/routines/habositsd_fel_a_tusfurdot.mp3',
      ),
      RoutineStep(
        id: 'bt_5',
        title: 'Öblítsd le a habot!',
        icon: Icons.waves_rounded,
        imagePath: 'assets/images/routines/bt_5.png',
        audioPath: 'assets/audio/routines/oblitsd_le_a_habot.mp3',
      ),
      RoutineStep(
        id: 'bt_6',
        title: 'Törölközz meg!',
        icon: Icons.dry_rounded,
        imagePath: 'assets/images/routines/bt_6.png',
        audioPath: 'assets/audio/routines/lepj_a_kilepore.mp3',
      ),
    ],
  ),

  // 12. Esti lecsendesedés és alvás
  Routine(
    id: 'bedtime',
    title: 'Esti lefekvés',
    description: 'Készüljünk az alváshoz!',
    icon: Icons.bedtime_rounded,
    imagePath: 'assets/images/routines/bedtime.png',
    themeColor: const Color(0xFFC084FC),
    steps: [
      RoutineStep(
        id: 'bd_1',
        title: 'Vedd fel a pizsamát!',
        icon: Icons.checkroom_rounded,
        imagePath: 'assets/images/routines/bd_1.png',
        audioPath: 'assets/audio/routines/vedd_fel_a_pizsamat.mp3',
      ),
      RoutineStep(
        id: 'bd_2',
        title: 'Moss fogat!',
        icon: Icons.bathroom_rounded,
        imagePath: 'assets/images/routines/bd_2.png',
        audioPath: 'assets/audio/routines/mielott_lefekudnel_moss_fogat.mp3',
      ),
      RoutineStep(
        id: 'bd_3',
        title: 'Válassz mesét!',
        icon: Icons.auto_stories_rounded,
        imagePath: 'assets/images/routines/bd_3.png',
        audioPath: 'assets/audio/routines/valassz_ki_egy_meset.mp3',
      ),
      RoutineStep(
        id: 'bd_4',
        title: 'Feküdj az ágyba!',
        icon: Icons.hotel_rounded,
        imagePath: 'assets/images/routines/bd_4.png',
        audioPath: 'assets/audio/routines/fekudj_be_az_agyba.mp3',
      ),
      RoutineStep(
        id: 'bd_5',
        title: 'Kapcsold fel a kislámpát!',
        icon: Icons.nightlight_round,
        imagePath: 'assets/images/routines/bd_5.png',
        audioPath: 'assets/audio/routines/kapcsold_fel_az_ejjeli_lampat.mp3',
      ),
      RoutineStep(
        id: 'bd_6',
        title: 'Jó éjt, szép álmokat!',
        icon: Icons.airline_seat_individual_suite_rounded,
        imagePath: 'assets/images/routines/bd_6.png',
        audioPath: 'assets/audio/routines/hunyd_le_a_szemed.mp3',
      ),
    ],
  ),

  // 13. Hajfésülés
  Routine(
    id: 'haircare',
    title: 'Hajfésülés',
    description: 'Fésüljük meg a hajat!',
    icon: Icons.face_retouching_natural_rounded,
    imagePath: 'assets/images/routines/haircare.png',
    themeColor: const Color(0xFFFB7185),
    steps: [
      RoutineStep(
        id: 'hc_1',
        title: 'Ülj a tükör elé!',
        icon: Icons.chair_rounded,
        imagePath: 'assets/images/routines/hc_1.png',
        audioPath: 'assets/audio/routines/ulj_le_kenyelmesen_tukor_ele.mp3',
      ),
      RoutineStep(
        id: 'hc_2',
        title: 'Fogd meg a hajkefét!',
        icon: Icons.brush_rounded,
        imagePath: 'assets/images/routines/hc_2.png',
        audioPath: 'assets/audio/routines/vedd_a_kezedbe_fesu.mp3',
      ),
      RoutineStep(
        id: 'hc_3',
        title: 'Fésüld meg óvatosan!',
        icon: Icons.south_rounded,
        imagePath: 'assets/images/routines/hc_3.png',
        audioPath: 'assets/audio/routines/ovatos_mozdulat_fesules.mp3',
      ),
      RoutineStep(
        id: 'hc_4',
        title: 'Simítsd végig fentről lefelé!',
        icon: Icons.format_line_spacing_rounded,
        imagePath: 'assets/images/routines/hc_4.png',
        audioPath: 'assets/audio/routines/simitsd_vegig_a_kefet.mp3',
      ),
      RoutineStep(
        id: 'hc_5',
        title: 'Tedd vissza a kefét!',
        icon: Icons.shopping_basket_rounded,
        imagePath: 'assets/images/routines/hc_5.png',
        audioPath: 'assets/audio/routines/tedd_vissza_a_kefet.mp3',
      ),
    ],
  ),

  // 14. Körömvágás
  Routine(
    id: 'nail_care',
    title: 'Körömvágás',
    description: 'Nyugodt körömápolás.',
    icon: Icons.back_hand_rounded,
    imagePath: 'assets/images/routines/nail_care.png',
    themeColor: const Color(0xFFF43F5E),
    steps: [
      RoutineStep(
        id: 'nc_1',
        title: 'Üljünk le nyugodtan!',
        icon: Icons.people_outline_rounded,
        imagePath: 'assets/images/routines/nc_1.png',
        audioPath: 'assets/audio/routines/uljunk_le_kettesben.mp3',
      ),
      RoutineStep(
        id: 'nc_2',
        title: 'Nézd meg a csipeszt!',
        icon: Icons.content_cut_rounded,
        imagePath: 'assets/images/routines/nc_2.png',
        audioPath: 'assets/audio/routines/nezd_meg_a_csipeszt.mp3',
      ),
      RoutineStep(
        id: 'nc_3',
        title: 'Vágjuk le az egyik kezet!',
        icon: Icons.pin_invoke_rounded,
        imagePath: 'assets/images/routines/nc_3.png',
        audioPath: 'assets/audio/routines/vagjuk_le_az_egyik_kezed.mp3',
      ),
      RoutineStep(
        id: 'nc_4',
        title: 'Rövid pihenő.',
        icon: Icons.celebration_rounded,
        imagePath: 'assets/images/routines/nc_4.png',
        audioPath: 'assets/audio/routines/tartsunk_egy_rovid_szunetet.mp3',
      ),
      RoutineStep(
        id: 'nc_5',
        title: 'Vágjuk le a másik kezet!',
        icon: Icons.front_hand_rounded,
        imagePath: 'assets/images/routines/nc_5.png',
        audioPath: 'assets/audio/routines/vagjuk_le_a_masik_kezet.mp3',
      ),
      RoutineStep(
        id: 'nc_6',
        title: 'Moss kezet! Ügyes vagy!',
        icon: Icons.stars_rounded,
        imagePath: 'assets/images/routines/nc_6.png',
        audioPath: 'assets/audio/routines/moss_kezet_langyos_vizzel.mp3',
      ),
    ],
  ),

  // 15. Megnyugvás
  Routine(
    id: 'calm_down',
    title: 'Megnyugvás',
    description: 'Csendes pihenés.',
    icon: Icons.spa_rounded,
    imagePath: 'assets/images/routines/calm_down.png',
    themeColor: const Color(0xFF34D399),
    steps: [
      RoutineStep(
        id: 'cd_1',
        title: 'Vonulj csendes helyre!',
        icon: Icons.meeting_room_rounded,
        imagePath: 'assets/images/routines/cd_1.png',
        audioPath: 'assets/audio/routines/vonulj_el_egy_kicsit.mp3',
      ),
      RoutineStep(
        id: 'cd_2',
        title: 'Tedd fel a fülhallgatót!',
        icon: Icons.headphones_rounded,
        imagePath: 'assets/images/routines/cd_2.png',
        audioPath: 'assets/audio/routines/tedd_fel_a_zajszurot.mp3',
      ),
      RoutineStep(
        id: 'cd_3',
        title: 'Szívj mély levegőt!',
        icon: Icons.air_rounded,
        imagePath: 'assets/images/routines/cd_3.png',
        audioPath: 'assets/audio/routines/szivj_be_nehany_levegot.mp3',
      ),
      RoutineStep(
        id: 'cd_4',
        title: 'Fújd ki lassan!',
        icon: Icons.filter_drama_rounded,
        imagePath: 'assets/images/routines/cd_4.png',
        audioPath: 'assets/audio/routines/fujd_ki_lassan.mp3',
      ),
      RoutineStep(
        id: 'cd_5',
        title: 'Igyál egy korty vizet!',
        icon: Icons.local_drink_rounded,
        imagePath: 'assets/images/routines/cd_5.png',
        audioPath: 'assets/audio/routines/igyal_vizet.mp3',
      ),
      RoutineStep(
        id: 'cd_6',
        title: 'Pihenj nyugodtan!',
        icon: Icons.favorite_rounded,
        imagePath: 'assets/images/routines/cd_6.png',
        audioPath: 'assets/audio/routines/maradj_pihenj.mp3',
      ),
    ],
  ),
];
