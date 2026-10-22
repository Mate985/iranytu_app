import 'package:flutter/material.dart';

class RoutineStep {
  final String id;
  final String title;
  final IconData icon;
  final String? audioPath;
  bool isCompleted;

  RoutineStep({
    required this.id,
    required this.title,
    required this.icon,
    this.audioPath,
    this.isCompleted = false,
  });
}

class Routine {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final Color themeColor;
  final List<RoutineStep> steps;

  Routine({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
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
    description: 'Tiszta és friss kezek egyszerű lépésekben.',
    icon: Icons.wash_rounded,
    themeColor: const Color(0xFF38BDF8),
    steps: [
      RoutineStep(
        id: 'hw_1',
        title: 'Tűrd fel óvatosan a ruhád ujját.',
        icon: Icons.pan_tool_rounded,
        audioPath: 'assets/audio/routines/turd_fel.mp3',
      ),
      RoutineStep(
        id: 'hw_2',
        title: 'Nyisd meg a csapot langyos vízzel.',
        icon: Icons.water_drop_rounded,
        audioPath: 'assets/audio/routines/nyisd_meg.mp3',
      ),
      RoutineStep(
        id: 'hw_3',
        title: 'Nyomj egy adag szappant a tenyeredbe.',
        icon: Icons.bubble_chart_rounded,
        audioPath: 'assets/audio/routines/nyomj_egy_adag.mp3',
      ),
      RoutineStep(
        id: 'hw_4',
        title: 'Dörzsöld össze a tenyeredet és a kézfejedet.',
        icon: Icons.timer_rounded,
        audioPath: 'assets/audio/routines/dorzsold_ossze.mp3',
      ),
      RoutineStep(
        id: 'hw_5',
        title: 'Öblítsd le a habot tiszta vízzel.',
        icon: Icons.waves_rounded,
        audioPath: 'assets/audio/routines/oblitsd_le_a.mp3',
      ),
      RoutineStep(
        id: 'hw_6',
        title: 'Töröld szárazra a kezed a törölközővel.',
        icon: Icons.dry_rounded,
        audioPath: 'assets/audio/routines/torold_szarazra.mp3',
      ),
    ],
  ),

  // 2. Fogmosás
  Routine(
    id: 'brushing',
    title: 'Fogmosás',
    description: 'Ragyogó és egészséges fogak reggel és este.',
    icon: Icons.cleaning_services_rounded,
    themeColor: const Color(0xFF2DD4BF),
    steps: [
      RoutineStep(
        id: 'br_1',
        title: 'Vedd a kezedbe a fogkefédet és a fogkrémet.',
        icon: Icons.brush_rounded,
        audioPath: 'assets/audio/routines/vedd_a_kezedbe.mp3',
      ),
      RoutineStep(
        id: 'br_2',
        title: 'Nyomj egy borsónyi fogkrémet a kefére.',
        icon: Icons.colorize_rounded,
        audioPath: 'assets/audio/routines/nyomj_egy_borsonyi.mp3',
      ),
      RoutineStep(
        id: 'br_3',
        title: 'Mosd meg a felső fogsorodat kívül és belül.',
        icon: Icons.arrow_upward_rounded,
        audioPath: 'assets/audio/routines/mosd_meg_felul.mp3',
      ),
      RoutineStep(
        id: 'br_4',
        title: 'Mosd meg az alsó fogsorodat kívül és belül.',
        icon: Icons.arrow_downward_rounded,
        audioPath: 'assets/audio/routines/mosd_meg_alul.mp3',
      ),
      RoutineStep(
        id: 'br_5',
        title: 'Köpd ki a felesleges habot a mosdókagylóba.',
        icon: Icons.keyboard_return_rounded,
        audioPath: 'assets/audio/routines/kopd_ki_a_felesleges.mp3',
      ),
      RoutineStep(
        id: 'br_6',
        title: 'Öblítsd ki a szádat vízzel, majd tisztítsd meg a fogkefét.',
        icon: Icons.water_rounded,
        audioPath: 'assets/audio/routines/oblitsd_ki_a_szad.mp3',
      ),
    ],
  ),

  // 3. Reggeli öltözködés
  Routine(
    id: 'dressing',
    title: 'Reggeli öltözködés',
    description: 'Önálló felöltözés a nap indításához.',
    icon: Icons.checkroom_rounded,
    themeColor: const Color(0xFFFB923C),
    steps: [
      RoutineStep(
        id: 'dr_1',
        title: 'Vedd fel a tiszta alsóneműt.',
        icon: Icons.accessibility_new_rounded,
        audioPath: 'assets/audio/routines/vedd_fel_a_tiszta.mp3',
      ),
      RoutineStep(
        id: 'dr_2',
        title: 'Bújj bele a nadrágba, és húzd fel a zoknit!',
        icon: Icons.boy_rounded,
        audioPath: 'assets/audio/routines/bujj_bele_a_nadrag.mp3',
      ),
      RoutineStep(
        id: 'dr_3',
        title: 'Húzd fel a zoknidat mindkét lábadra.',
        icon: Icons.wb_sunny_rounded,
        audioPath: 'assets/audio/routines/huzd_fel_a_zoknid.mp3',
      ),
      RoutineStep(
        id: 'dr_4',
        title: 'Vedd fel a pólódat úgy, hogy a címke hátul legyen.',
        icon: Icons.checkroom_rounded,
        audioPath: 'assets/audio/routines/vedd_fel_a_polod.mp3',
      ),
      RoutineStep(
        id: 'dr_5',
        title: 'Nézz a tükörbe, és igazítsd meg a ruháidat.',
        icon: Icons.face_rounded,
        audioPath: 'assets/audio/routines/nezz_a_tukorbe.mp3',
      ),
    ],
  ),

  // 4. Indulás az otthonról
  Routine(
    id: 'leaving',
    title: 'Indulás az otthonról',
    description: 'Rendezett készülődés a kilépés előtt.',
    icon: Icons.door_sliding_rounded,
    themeColor: const Color(0xFFFBBF24),
    steps: [
      RoutineStep(
        id: 'lv_1',
        title: 'Ülj le kényelmesen, és bújj bele a cipődbe.',
        icon: Icons.chair_rounded,
        audioPath: 'assets/audio/routines/ulj_le_kenyelmesen.mp3',
      ),
      RoutineStep(
        id: 'lv_2',
        title: 'Húzd meg a tépőzárat vagy kösd be a cipőfűzőt.',
        icon: Icons.straighten_rounded,
        audioPath: 'assets/audio/routines/huzd_meg_a_tepozar.mp3',
      ),
      RoutineStep(
        id: 'lv_3',
        title: 'Bújj bele a kabátod mindkét ujjába.',
        icon: Icons.checkroom_rounded,
        audioPath: 'assets/audio/routines/bujj_bele_a_kabatba.mp3',
      ),
      RoutineStep(
        id: 'lv_4',
        title: 'Húzd fel a cipzárt vagy gombolod be a kabátot.',
        icon: Icons.unfold_more_rounded,
        audioPath: 'assets/audio/routines/huzd_fel_a_zipzart.mp3',
      ),
      RoutineStep(
        id: 'lv_5',
        title: 'Hideg időben vedd fel a sapkádat és a sáladat is.',
        icon: Icons.ac_unit_rounded,
        audioPath: 'assets/audio/routines/hideg_idoben.mp3',
      ),
      RoutineStep(
        id: 'lv_6',
        title: 'Vedd fel a táskádat a hátadra.',
        icon: Icons.backpack_rounded,
        audioPath: 'assets/audio/routines/vedd_fel_a_taskad.mp3',
      ),
    ],
  ),

  // 5. Hazaérkezés
  Routine(
    id: 'coming_home',
    title: 'Hazaérkezés',
    description: 'Megnyugtató visszatérés az otthoni környezetbe.',
    icon: Icons.home_rounded,
    themeColor: const Color(0xFF34D399),
    steps: [
      RoutineStep(
        id: 'ch_1',
        title: 'Lépj be az előszobába, és csukd be a bejárati ajtót.',
        icon: Icons.sensor_door_rounded,
        audioPath: 'assets/audio/routines/lepj_be_az_eloszoba.mp3',
      ),
      RoutineStep(
        id: 'ch_2',
        title: 'Vedd le a cipődet, és tedd a cipőtartó helyére.',
        icon: Icons.dry_cleaning_rounded,
        audioPath: 'assets/audio/routines/vedd_le_a_cipodet.mp3',
      ),
      RoutineStep(
        id: 'ch_3',
        title: 'Akaszd fel a kabátodat a fogasra.',
        icon: Icons.checkroom_rounded,
        audioPath: 'assets/audio/routines/akaszd_fel_a_kabatot.mp3',
      ),
      RoutineStep(
        id: 'ch_4',
        title: 'Menj közvetlenül a fürdőszobába, és moss kezet alaposan.',
        icon: Icons.wash_rounded,
        audioPath: 'assets/audio/routines/menj_kozvetlen_a_furdobe.mp3',
      ),
      RoutineStep(
        id: 'ch_5',
        title: 'Öltözz át kényelmes otthoni ruhába.',
        icon: Icons.weekend_rounded,
        audioPath: 'assets/audio/routines/oltozz_at_kenyelmes.mp3',
      ),
    ],
  ),

  // 6. WC használat
  Routine(
    id: 'toilet',
    title: 'WC használat',
    description: 'Önálló és higiénikus mosdóhasználat.',
    icon: Icons.wc_rounded,
    themeColor: const Color(0xFF60A5FA),
    steps: [
      RoutineStep(
        id: 'wc_1',
        title: 'Csukd be magad mögött a toalett ajtaját.',
        icon: Icons.door_front_door_rounded,
        audioPath: 'assets/audio/routines/csukd_be_magad_utan.mp3',
      ),
      RoutineStep(
        id: 'wc_2',
        title: 'Húzd le a nadrágodat és az alsóneműdet.',
        icon: Icons.vertical_align_bottom_rounded,
        audioPath: 'assets/audio/routines/huzd_le_a_nadragod.mp3',
      ),
      RoutineStep(
        id: 'wc_3',
        title: 'Ülj le a deszkára, és végezd el a dolgodat nyugodtan.',
        icon: Icons.event_seat_rounded,
        audioPath: 'assets/audio/routines/ulj_le_a_deszkara.mp3',
      ),
      RoutineStep(
        id: 'wc_4',
        title: 'Használj toalettpapírt az alapos megtisztálkodáshoz.',
        icon: Icons.receipt_rounded,
        audioPath: 'assets/audio/routines/hasznalj_wc_papirt.mp3',
      ),
      RoutineStep(
        id: 'wc_5',
        title: 'Állj fel, majd húzd fel a ruháidat.',
        icon: Icons.vertical_align_top_rounded,
        audioPath: 'assets/audio/routines/allj_fel_majd_huzd_fel.mp3',
      ),
      RoutineStep(
        id: 'wc_6',
        title: 'Húzd le a toalettet.',
        icon: Icons.water_drop_rounded,
        audioPath: 'assets/audio/routines/huzd_le_a_wct.mp3',
      ),
      RoutineStep(
        id: 'wc_7',
        title: 'Moss kezet szappannal és vízzel.',
        icon: Icons.wash_rounded,
        audioPath: 'assets/audio/routines/moss_kezet_szappannal.mp3',
      ),
    ],
  ),

  // 7. Étkezés
  Routine(
    id: 'eating',
    title: 'Étkezés',
    description: 'Nyugodt, békés táplálkozás az asztalnál.',
    icon: Icons.restaurant_rounded,
    themeColor: const Color(0xFFA3E635),
    steps: [
      RoutineStep(
        id: 'et_1',
        title: 'Moss kezet közvetlenül az étkezés megkezdése előtt.',
        icon: Icons.wash_rounded,
        audioPath: 'assets/audio/routines/moss_kezet_az_etkezes_elott.mp3',
      ),
      RoutineStep(
        id: 'et_2',
        title: 'Ülj le a helyedre az étkezőasztalhoz.',
        icon: Icons.chair_rounded,
        audioPath: 'assets/audio/routines/ulj_le_a_helyedre.mp3',
      ),
      RoutineStep(
        id: 'et_3',
        title: 'Egyél kényelmes tempóban a megfelelő evőeszközzel.',
        icon: Icons.restaurant_menu_rounded,
        audioPath: 'assets/audio/routines/egyel_kenyelmes_tempoban.mp3',
      ),
      RoutineStep(
        id: 'et_4',
        title: 'Szükség esetén igyál egy korty vizet a pohárból.',
        icon: Icons.local_drink_rounded,
        audioPath: 'assets/audio/routines/szukseg_eseten_igyal.mp3',
      ),
      RoutineStep(
        id: 'et_5',
        title: 'Az étkezés végén töröld meg a szádat szalvétával.',
        icon: Icons.clean_hands_rounded,
        audioPath: 'assets/audio/routines/az_etkezes_vegen_torold.mp3',
      ),
    ],
  ),

  // 8. Étkezés utáni elpakolás
  Routine(
    id: 'clean_table',
    title: 'Étkezés utáni rendrakás',
    description: 'Az étkezőasztal közös letakarítása és elrendezése.',
    icon: Icons.soup_kitchen_rounded,
    themeColor: const Color(0xFF4ADE80),
    steps: [
      RoutineStep(
        id: 'ct_1',
        title: 'Fogd meg a tányérodat két kézzel, stabilan.',
        icon: Icons.pan_tool_rounded,
        audioPath: 'assets/audio/routines/fogd_meg_a_tanyerod.mp3',
      ),
      RoutineStep(
        id: 'ct_2',
        title: 'Vidd ki a mosogatóba vagy a konyhapultra.',
        icon: Icons.kitchen_rounded,
        audioPath: 'assets/audio/routines/vidd_ki_a_mosogatoba.mp3',
      ),
      RoutineStep(
        id: 'ct_3',
        title: 'Vidd ki a poharadat is óvatosan.',
        icon: Icons.local_drink_rounded,
        audioPath: 'assets/audio/routines/vidd_ki_a_poharadat.mp3',
      ),
      RoutineStep(
        id: 'ct_4',
        title: 'Dobd a használt szalvétát a szemetesbe.',
        icon: Icons.delete_outline_rounded,
        audioPath: 'assets/audio/routines/dobd_a_hasznalt_szalvetat.mp3',
      ),
      RoutineStep(
        id: 'ct_5',
        title: 'Töröld le a morzsákat az asztalról egy szivaccsal.',
        icon: Icons.table_restaurant_rounded,
        audioPath: 'assets/audio/routines/torold_le_a_morzsakat.mp3',
      ),
    ],
  ),

  // 9. Bepakolás a táskába
  Routine(
    id: 'backpack',
    title: 'Bepakolás a táskába',
    description: 'Gondos előkészület a következő napra.',
    icon: Icons.backpack_rounded,
    themeColor: const Color(0xFF818CF8),
    steps: [
      RoutineStep(
        id: 'bp_1',
        title: 'Nyisd ki teljesen az iskolatáskád cipzárját.',
        icon: Icons.unfold_more_rounded,
        audioPath:
            'assets/audio/routines/nyisd_ki_teljesen_az_iskolataskad.mp3',
      ),
      RoutineStep(
        id: 'bp_2',
        title: 'Helyezd el a füzeteket, a könyveket és a tolltartót.',
        icon: Icons.menu_book_rounded,
        audioPath: 'assets/audio/routines/helyezd_el_a_fuzeteket.mp3',
      ),
      RoutineStep(
        id: 'bp_3',
        title: 'Tedd be a feltöltött vizeskulacsodat a zsebbe.',
        icon: Icons.local_drink_rounded,
        audioPath: 'assets/audio/routines/tedd_be_a_kulacsot.mp3',
      ),
      RoutineStep(
        id: 'bp_4',
        title: 'Tedd a helyére az uzsonnás dobozodat is.',
        icon: Icons.lunch_dining_rounded,
        audioPath: 'assets/audio/routines/tedd_a_helyere_az_uzsonnas.mp3',
      ),
      RoutineStep(
        id: 'bp_5',
        title: 'Húzd be az összes cipzárt ellenőrzésképpen.',
        icon: Icons.lock_outline_rounded,
        audioPath: 'assets/audio/routines/huzd_be_az_osszes_zipzart.mp3',
      ),
    ],
  ),

  // 10. Játékok elpakolása
  Routine(
    id: 'tidy_up',
    title: 'Játékok elpakolása',
    description: 'A szoba rendbetétele a játékidő végén.',
    icon: Icons.toys_rounded,
    themeColor: const Color(0xFFF472B6),
    steps: [
      RoutineStep(
        id: 'tu_1',
        title: 'Állj meg, a játék ideje most lezárult.',
        icon: Icons.pause_circle_rounded,
        audioPath: 'assets/audio/routines/allj_meg_a_jatek_veget_ert.mp3',
      ),
      RoutineStep(
        id: 'tu_2',
        title: 'Gyűjtsd össze az építőkockákat a tárolódobozba.',
        icon: Icons.category_rounded,
        audioPath: 'assets/audio/routines/gyultsd_ossze_az_epito.mp3',
      ),
      RoutineStep(
        id: 'tu_3',
        title: 'Helyezd vissza a figurákat és járműveket a polcra.',
        icon: Icons.inventory_2_rounded,
        audioPath: 'assets/audio/routines/helyezd_vissza_a_figurakat.mp3',
      ),
      RoutineStep(
        id: 'tu_4',
        title: 'Tedd a könyveket a helyükre a könyvespolcon.',
        icon: Icons.auto_stories_rounded,
        audioPath: 'assets/audio/routines/tedd_a_konyveket_a_helyere.mp3',
      ),
      RoutineStep(
        id: 'tu_5',
        title: 'Nézz körül a szobában: minden játék a helyére került.',
        icon: Icons.sentiment_very_satisfied_rounded,
        audioPath: 'assets/audio/routines/nezz_korul_a_szobaban.mp3',
      ),
    ],
  ),

  // 11. Fürdés / Zuhanyzás
  Routine(
    id: 'bath',
    title: 'Fürdés és zuhanyzás',
    description: 'Kellemes esti tisztálkodás lépésről lépésre.',
    icon: Icons.bathtub_rounded,
    themeColor: const Color(0xFF38BDF8),
    steps: [
      RoutineStep(
        id: 'bt_1',
        title: 'Vetkőzz le, és tedd a szennyest a szennyestartóba.',
        icon: Icons.delete_sweep_rounded,
        audioPath: 'assets/audio/routines/vetkozz_le_es_tedd.mp3',
      ),
      RoutineStep(
        id: 'bt_2',
        title: 'Lépj be óvatosan a zuhanyzóba vagy a fürdőkádba.',
        icon: Icons.directions_walk_rounded,
        audioPath: 'assets/audio/routines/lepj_be_ovatosan_a_zuhanyba.mp3',
      ),
      RoutineStep(
        id: 'bt_3',
        title: 'Nedvesítsd be az egész testedet kellemes, langyos vízzel.',
        icon: Icons.shower_rounded,
        audioPath: 'assets/audio/routines/mosd_meg_az_egesz_tested.mp3',
      ),
      RoutineStep(
        id: 'bt_4',
        title: 'Habosítsd fel a tusfürdőt a bőrödön a szivaccsal.',
        icon: Icons.bubble_chart_rounded,
        audioPath: 'assets/audio/routines/habositsd_fel_a_tusfurdot.mp3',
      ),
      RoutineStep(
        id: 'bt_5',
        title: 'Öblítsd le a habot a testedről a zuhanyrózsával.',
        icon: Icons.waves_rounded,
        audioPath: 'assets/audio/routines/oblitsd_le_a_habot.mp3',
      ),
      RoutineStep(
        id: 'bt_6',
        title: 'Lépj a kilépőre, és töröld szárazra magad a törölközővel.',
        icon: Icons.dry_rounded,
        audioPath: 'assets/audio/routines/lepj_a_kilepore.mp3',
      ),
    ],
  ),

  // 12. Esti lecsendesedés és alvás
  Routine(
    id: 'bedtime',
    title: 'Esti készülődés és alvás',
    description: 'Megnyugtató átmenet a pihentető alváshoz.',
    icon: Icons.bedtime_rounded,
    themeColor: const Color(0xFFC084FC),
    steps: [
      RoutineStep(
        id: 'bd_1',
        title: 'Vedd fel a kényelmes alvóruhádat vagy pizsamádat.',
        icon: Icons.checkroom_rounded,
        audioPath: 'assets/audio/routines/vedd_fel_a_pizsamat.mp3',
      ),
      RoutineStep(
        id: 'bd_2',
        title: 'Látogasd meg a mosdót, és moss alaposan fogat.',
        icon: Icons.bathroom_rounded,
        audioPath: 'assets/audio/routines/mielott_lefekudnel_moss_fogat.mp3',
      ),
      RoutineStep(
        id: 'bd_3',
        title: 'Válassz ki egy kedves mesét vagy az alvós plüssödet.',
        icon: Icons.auto_stories_rounded,
        audioPath: 'assets/audio/routines/valassz_ki_egy_meset.mp3',
      ),
      RoutineStep(
        id: 'bd_4',
        title: 'Feküdj be az ágyba, és takard be magad melegen.',
        icon: Icons.hotel_rounded,
        audioPath: 'assets/audio/routines/fekudj_be_az_agyba.mp3',
      ),
      RoutineStep(
        id: 'bd_5',
        title: 'Kapcsold fel a kellemes fényű éjjeli kislámpát.',
        icon: Icons.nightlight_round,
        audioPath: 'assets/audio/routines/kapcsold_fel_az_ejjeli_lampat.mp3',
      ),
      RoutineStep(
        id: 'bd_6',
        title: 'Hunyd le a szemedet: biztonságban vagy, szép álmokat kívánunk.',
        icon: Icons.airline_seat_individual_suite_rounded,
        audioPath: 'assets/audio/routines/hunyd_le_a_szemed.mp3',
      ),
    ],
  ),

  // 13. Hajfésülés és hajápolás
  Routine(
    id: 'haircare',
    title: 'Hajfésülés és hajápolás',
    description: 'Finom, kíméletes hajrendezés a tükör előtt.',
    icon: Icons.face_retouching_natural_rounded,
    themeColor: const Color(0xFFFB7185),
    steps: [
      RoutineStep(
        id: 'hc_1',
        title: 'Ülj le kényelmesen és egyenes háttal a tükör elé.',
        icon: Icons.chair_rounded,
        audioPath: 'assets/audio/routines/ulj_le_kenyelmesen_tukor_ele.mp3',
      ),
      RoutineStep(
        id: 'hc_2',
        title: 'Vedd a kezedbe a puha sörtéjű hajkefét.',
        icon: Icons.brush_rounded,
        audioPath: 'assets/audio/routines/vedd_a_kezedbe_fesu.mp3',
      ),
      RoutineStep(
        id: 'hc_3',
        title: 'Óvatos mozdulatokkal kezdd el fésülni a hajtincsek alsó végét.',
        icon: Icons.south_rounded,
        audioPath: 'assets/audio/routines/ovatos_mozdulat_fesules.mp3',
      ),
      RoutineStep(
        id: 'hc_4',
        title: 'Simítsd végig a kefét felülről a fejtetőtől lefelé.',
        icon: Icons.format_line_spacing_rounded,
        audioPath: 'assets/audio/routines/simitsd_vegig_a_kefet.mp3',
      ),
      RoutineStep(
        id: 'hc_5',
        title: 'Tedd vissza a hajkefét a helyére.',
        icon: Icons.shopping_basket_rounded,
        audioPath: 'assets/audio/routines/tedd_vissza_a_kefet.mp3',
      ),
    ],
  ),

  // 14. Körömvágás lépésről lépésre
  Routine(
    id: 'nail_care',
    title: 'Körömvágás lépésről lépésre',
    description: 'Nyugodt, kiszámítható és biztonságos körömápolás.',
    icon: Icons.back_hand_rounded,
    themeColor: const Color(0xFFF43F5E),
    steps: [
      RoutineStep(
        id: 'nc_1',
        title: 'Üljünk le kettesben egy csendes és jól megvilágított helyen.',
        icon: Icons.people_outline_rounded,
        audioPath: 'assets/audio/routines/uljunk_le_kettesben.mp3',
      ),
      RoutineStep(
        id: 'nc_2',
        title:
            'Nézd meg a kiscsipeszt: teljesen biztonságos, csak rövidítünk vele.',
        icon: Icons.content_cut_rounded,
        audioPath: 'assets/audio/routines/nezd_meg_a_csipeszt.mp3',
      ),
      RoutineStep(
        id: 'nc_3',
        title: 'Vágjuk le az egyik kezed körmeit, miközben közösen számolunk.',
        icon: Icons.pin_invoke_rounded,
        audioPath: 'assets/audio/routines/vagjuk_le_az_egyik_kezed.mp3',
      ),
      RoutineStep(
        id: 'nc_4',
        title: 'Tartsunk egy rövid, pár másodperces pihenőt.',
        icon: Icons.celebration_rounded,
        audioPath: 'assets/audio/routines/tartsunk_egy_rovid_szunetet.mp3',
      ),
      RoutineStep(
        id: 'nc_5',
        title: 'Vágjuk le a másik kezed körmeit is ugyanilyen nyugodtan.',
        icon: Icons.front_hand_rounded,
        audioPath: 'assets/audio/routines/vagjuk_le_a_masik_kezet.mp3',
      ),
      RoutineStep(
        id: 'nc_6',
        title: 'Moss kezet langyos vízzel; remek munkát végeztél!',
        icon: Icons.stars_rounded,
        audioPath: 'assets/audio/routines/moss_kezet_langyos_vizzel.mp3',
      ),
    ],
  ),

  // 15. Nyugalom és feszültségoldás (Safe Space rutin)
  Routine(
    id: 'calm_down',
    title: 'Megnyugvás és feszültségoldás',
    description: 'Szenzoros lecsendesedés és pihenés túlingerlés esetén.',
    icon: Icons.spa_rounded,
    themeColor: const Color(0xFF34D399),
    steps: [
      RoutineStep(
        id: 'cd_1',
        title: 'Vonulj el a kijelölt csendes sarokba vagy a szobádba.',
        icon: Icons.meeting_room_rounded,
        audioPath: 'assets/audio/routines/vonulj_el_egy_kicsit.mp3',
      ),
      RoutineStep(
        id: 'cd_2',
        title:
            'Tedd fel a zajszűrő fülhallgatót vagy öleld át a kedvenc párnádat.',
        icon: Icons.headphones_rounded,
        audioPath: 'assets/audio/routines/tedd_fel_a_zajszurot.mp3',
      ),
      RoutineStep(
        id: 'cd_3',
        title:
            'Szívj be mélyen a levegőt az orrodon át négy másodpercen keresztül.',
        icon: Icons.air_rounded,
        audioPath: 'assets/audio/routines/szivj_be_nehany_levegot.mp3',
      ),
      RoutineStep(
        id: 'cd_4',
        title: 'Fújd ki lassan és egyenletesen a levegőt a szádon keresztül.',
        icon: Icons.filter_drama_rounded,
        audioPath: 'assets/audio/routines/fujd_ki_lassan.mp3',
      ),
      RoutineStep(
        id: 'cd_5',
        title: 'Igyál egy-két korty friss, hűvös vizet.',
        icon: Icons.local_drink_rounded,
        audioPath: 'assets/audio/routines/igyal_vizet.mp3',
      ),
      RoutineStep(
        id: 'cd_6',
        title: 'Maradj csendben, amíg teljesen nyugodtnak nem érzed magad.',
        icon: Icons.favorite_rounded,
        audioPath: 'assets/audio/routines/maradj_pihenj.mp3',
      ),
    ],
  ),
];
