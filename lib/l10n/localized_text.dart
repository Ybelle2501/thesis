import 'package:flutter/material.dart' as material;

/// A drop-in Text widget that uses the active app language for known UI copy.
///
/// Keeping the English source text as the lookup key lets existing screens
/// retain their layout while the language setting changes at runtime.
class Text extends material.StatelessWidget {
  const Text(
    this.data, {
    super.key,
    this.style,
    this.strutStyle,
    this.textAlign,
    this.textDirection,
    this.locale,
    this.softWrap,
    this.overflow,
    this.textScaler,
    this.maxLines,
    this.semanticsLabel,
    this.textWidthBasis,
    this.textHeightBehavior,
    this.selectionColor,
  }) : textSpan = null;

  const Text.rich(
    material.TextSpan this.textSpan, {
    super.key,
    this.style,
    this.strutStyle,
    this.textAlign,
    this.textDirection,
    this.locale,
    this.softWrap,
    this.overflow,
    this.textScaler,
    this.maxLines,
    this.semanticsLabel,
    this.textWidthBasis,
    this.textHeightBehavior,
    this.selectionColor,
  }) : data = null;

  final String? data;
  final material.TextSpan? textSpan;
  final material.TextStyle? style;
  final material.StrutStyle? strutStyle;
  final material.TextAlign? textAlign;
  final material.TextDirection? textDirection;
  final material.Locale? locale;
  final bool? softWrap;
  final material.TextOverflow? overflow;
  final material.TextScaler? textScaler;
  final int? maxLines;
  final String? semanticsLabel;
  final material.TextWidthBasis? textWidthBasis;
  final material.TextHeightBehavior? textHeightBehavior;
  final material.Color? selectionColor;

  @override
  material.Widget build(material.BuildContext context) {
    final source = data;
    final translated = source == null ? null : localizeCopy(context, source);
    final displayText = source != null && source == source.toUpperCase()
        ? translated?.toUpperCase()
        : translated;

    if (displayText == null) {
      return material.Text.rich(
        textSpan!,
        style: style,
        strutStyle: strutStyle,
        textAlign: textAlign,
        textDirection: textDirection,
        locale: locale,
        softWrap: softWrap,
        overflow: overflow,
        textScaler: textScaler,
        maxLines: maxLines,
        semanticsLabel: semanticsLabel,
        textWidthBasis: textWidthBasis,
        textHeightBehavior: textHeightBehavior,
        selectionColor: selectionColor,
      );
    }
    return material.Text(
      displayText,
      style: style,
      strutStyle: strutStyle,
      textAlign: textAlign,
      textDirection: textDirection,
      locale: locale,
      softWrap: softWrap,
      overflow: overflow,
      textScaler: textScaler,
      maxLines: maxLines,
      semanticsLabel: semanticsLabel,
      textWidthBasis: textWidthBasis,
      textHeightBehavior: textHeightBehavior,
      selectionColor: selectionColor,
    );
  }
}

const Map<String, String> _tagalog = {
  'Welcome to LeafLens': 'Maligayang pagdating sa LeafLens',
  'Quick Access': 'Mabilisang Pag-access',
  'AI Crop\nScanner': 'AI na Scanner\nng Pananim',
  'Disease\nPrevention': 'Pag-iwas sa\nSakit',
  'Treatment\nAdvice': 'Payo sa\nPaggamot',
  'Reports': 'Mga Ulat',
  'Recent Scans': 'Mga Kamakailang Scan',
  'See all': 'Tingnan lahat',
  'Loading recent scans…': 'Nilo-load ang mga kamakailang scan…',
  'No scans yet. Your latest results will appear here.':
      'Wala pang scan. Lalabas dito ang mga pinakabagong resulta mo.',
  'Scan': 'Mag-scan',
  'History': 'Kasaysayan',
  'Home': 'Home',
  'Scan Crop': 'I-scan ang Pananim',
  'Scan History': 'Kasaysayan ng mga Scan',
  'Scan Records': 'Mga Tala ng Scan',
  'Crop Reports': 'Mga Ulat ng Pananim',
  'Disease Prevention': 'Pag-iwas sa Sakit',
  'Treatment Advice': 'Payo sa Paggamot',
  'Settings': 'Mga Setting',
  'Language': 'Wika',
  'Choose your preferred language': 'Piliin ang gusto mong wika',
  'English': 'Ingles',
  'Tagalog': 'Tagalog',
  'Data Recovery': 'Pagbawi ng Data',
  'Back up your scan history': 'I-back up ang kasaysayan ng mga scan mo',
  'LeafLens saves scans on this device. Export a backup to Downloads/LeafLens Data so you can restore your records later.':
      'Iniimbak ng LeafLens ang mga scan sa device na ito. Mag-export ng backup sa Downloads/LeafLens Data para maibalik mo ang mga tala mo sa ibang pagkakataon.',
  'Save current data': 'I-save ang kasalukuyang data',
  'Export backup': 'I-export ang backup',
  'Restore from backup': 'Ibalik mula sa backup',
  'Choose a LeafLens backup file to restore scan history, dates, saved images, and report settings.':
      'Pumili ng LeafLens backup file para maibalik ang kasaysayan ng scan, mga petsa, naka-save na larawan, at mga setting ng ulat.',
  'Import backup': 'I-import ang backup',
  'Cancel': 'Kanselahin',
  'Restore': 'Ibalik',
  'Delete': 'Burahin',
  'Save': 'I-save',
  'Done': 'Tapos na',
  'Close': 'Isara',
  'Apply': 'Ilapat',
  'Healthy': 'Malusog',
  'Infected': 'May sakit',
  'Treatment': 'Paggamot',
  'Prevention': 'Pag-iwas',
  'Sources & evidence': 'Mga Sanggunian at Ebidensya',
  'Open reference': 'Buksan ang sanggunian',
  'Copy link': 'Kopyahin ang link',
  'Reference link copied': 'Nakopya ang link ng sanggunian',
  'Select scan mode': 'Pumili ng scan mode',
  'Grid Scan Results': 'Mga Resulta ng Grid Scan',
  'Open detailed cell result': 'Buksan ang detalyadong resulta ng cell',
  'Export Scouting Report': 'I-export ang Ulat sa Pagsusuri',
  'Known locations': 'Mga Kilalang Lokasyon',
  'Health rate': 'Antas ng Kalusugan',
  'Required record fields': 'Mga Kinakailangang Field ng Tala',
  'Deselect all': 'Alisin ang pagpili sa lahat',
  'Select all': 'Piliin lahat',
  'Add location': 'Magdagdag ng lokasyon',
  'Rename location': 'Palitan ang pangalan ng lokasyon',
  'Delete selected records?': 'Burahin ang mga napiling tala?',
  'No matching station': 'Walang tumugmang istasyon',
  'Your growing area': 'Lugar na tinataniman mo',
  'Cool upland growing site': 'Malamig na lugar sa kabundukan',
  'Apply seasonal settings': 'Ilapat ang mga pana-panahong setting',
  'Explore the year': 'Tingnan ang buong taon',
  'See the leaf. Understand the problem.':
      'Suriin ang dahon. Unawain ang problema.',
  'Get Started': 'Magsimula',
  'AI-assisted crop disease identification':
      'Pagkilala sa sakit ng pananim na tinutulungan ng AI',
  'AI-POWERED': 'PINAPAGANA NG AI',
  'Scan your crops\nfor diseases': 'I-scan ang mga pananim\npara sa mga sakit',
  'Get instant diagnosis and smart\ntreatment recommendations.':
      'Makakuha agad ng pagsusuri at matalinong rekomendasyon sa paggamot.',
  'Scan Now': 'Mag-scan Ngayon',
  'AI can make mistakes. Verify important results with a qualified crop specialist before treatment.':
      'Maaaring magkamali ang AI. Ipasuri sa kwalipikadong espesyalista sa pananim ang mahahalagang resulta bago magpagamot.',
  'AI can make mistakes. Verify results before treatment.':
      'Maaaring magkamali ang AI. Beripikahin ang resulta bago magpagamot.',
  'Analytics': 'Pagsusuri ng Datos',
  'Reports Coming Soon': 'Malapit Nang Ilabas ang mga Ulat',
  'Detailed analytics, disease trends, and crop health reports are being prepared for you.':
      'Inihahanda para sa iyo ang mas detalyadong pagsusuri, mga takbo ng sakit, at ulat sa kalusugan ng pananim.',
  'Disease Trend Charts': 'Mga Tsart ng Takbo ng Sakit',
  'Weekly and monthly infection rate graphs.':
      'Mga grap ng bilang ng impeksyon kada linggo at buwan.',
  'Crop Health Summary': 'Buod ng Kalusugan ng Pananim',
  'Breakdown by plant type and disease category.':
      'Pagkakahati ayon sa uri ng halaman at kategorya ng sakit.',
  'Export Reports': 'I-export ang mga Ulat',
  'Download as PDF for sharing with agronomists.':
      'I-download bilang PDF para maibahagi sa mga agronomo.',
  'Notify Me When Ready': 'Abisuhan Ako Kapag Handa Na',
  'View Scan History': 'Tingnan ang Kasaysayan ng mga Scan',
  'Soon': 'Malapit Na',
  'Your choice applies throughout LeafLens and is saved on this device.':
      'Ilalapat ang pinili mong wika sa buong LeafLens at ise-save ito sa device na ito.',
  'AI-assisted': 'Tinutulungan ng AI',
  'AI Crop Scanner': 'AI na Scanner ng Pananim',
  'Plant': 'Halaman',
  'Crop': 'Pananim',
  'Disease': 'Sakit',
  'Pest': 'Peste',
  'Confidence': 'Antas ng Katiyakan',
  'Location': 'Lokasyon',
  'Date': 'Petsa',
  'Status': 'Katayuan',
  'Source': 'Pinagmulan',
  'Scan mode': 'Mode ng pag-scan',
  'Photo': 'Larawan',
  'Camera': 'Camera',
  'Gallery': 'Gallery',
  'Choose from gallery': 'Pumili mula sa gallery',
  'Take a photo': 'Kumuha ng larawan',
  'Single scan': 'Isahang scan',
  'Grid scan': 'Grid scan',
  'Select an image': 'Pumili ng larawan',
  'Retake': 'Kuhanan Muli',
  'Analyze': 'Suriin',
  'Analyzing image…': 'Sinusuri ang larawan…',
  'Scan another': 'Mag-scan Muli',
  'Save to history': 'I-save sa kasaysayan',
  'Scan and location saved to history.':
      'Na-save sa kasaysayan ang scan at lokasyon.',
  'Results': 'Mga Resulta',
  'Scan Results': 'Mga Resulta ng Scan',
  'Diagnosis': 'Pagsusuri',
  'About this condition': 'Tungkol sa kondisyong ito',
  'What to do next': 'Mga susunod na hakbang',
  'Recommended treatment': 'Inirerekomendang paggamot',
  'Recommended prevention': 'Inirerekomendang pag-iwas',
  'No scan records yet': 'Wala pang tala ng scan',
  'No records found': 'Walang nakitang tala',
  'No reports yet': 'Wala pang mga ulat',
  'Search scans': 'Maghanap ng mga scan',
  'Search by crop, disease, or location':
      'Maghanap ayon sa pananim, sakit, o lokasyon',
  'Filter': 'Salain',
  'All': 'Lahat',
  'Clear': 'I-clear',
  'Delete selected records': 'Burahin ang mga napiling tala',
  'Crop location updated.': 'Na-update ang lokasyon ng pananim.',
  'Could not update the crop location.':
      'Hindi ma-update ang lokasyon ng pananim.',
  'This action cannot be undone.': 'Hindi na maibabalik ang pagkilos na ito.',
  'Could not delete the selected records.':
      'Hindi mabura ang mga napiling tala.',
  'record': 'tala',
  'records': 'mga tala',
  'deleted': 'nabura',
  'Cell': 'Cell',
  'cells': 'mga cell',
  'Clear all': 'Burahin lahat',
  'Export PDF': 'I-export bilang PDF',
  'Export': 'I-export',
  'PDF': 'PDF',
  'Report': 'Ulat',
  'Month': 'Buwan',
  'Week': 'Linggo',
  'Year': 'Taon',
  'January': 'Enero',
  'February': 'Pebrero',
  'March': 'Marso',
  'April': 'Abril',
  'May': 'Mayo',
  'June': 'Hunyo',
  'July': 'Hulyo',
  'August': 'Agosto',
  'September': 'Setyembre',
  'October': 'Oktubre',
  'November': 'Nobyembre',
  'December': 'Disyembre',
  'Banana': 'Saging',
  'Pineapple': 'Pinya',
  'Lettuce': 'Letsugas',
  'Tomato': 'Kamatis',
  'Healthy crop care': 'Pangangalaga sa malusog na pananim',
  'Cordana leaf spot': 'Batík ng Cordana sa dahon',
  'Panama wilt': 'Pagkalanta ng Panama',
  'Sigatoka': 'Sigatoka',
  'Fungal leaf spot': 'Batík sa dahon na dulot ng-singaw',
  'Soilborne wilt': 'Pagkalantang nagmumula sa lupa',
  'Insect damage': 'Pinsala ng insekto',
  'Leaf mold': 'Amag sa dahon',
  'Leaf miner': 'Uod na minero ng dahon',
  'Leaf curl virus': 'Virus na nagpapakulot ng dahon',
  'Bacterial disease': 'Sakit na dulot ng bakterya',
  'Fungal disease': 'Sakit na dulot ng-singaw',
  'Fungal leaf disease': 'Sakit sa dahon na dulot ng-singaw',
  'Insect pest': 'Peste ng insekto',
  'Healthy class': 'Kategoryang malusog',
  'Check the pattern': 'Suriin ang mga batik',
  'Protect useful foliage': 'Pangalagaan ang malulusog na dahon',
  'Avoid unnecessary spraying': 'Iwasan ang hindi kailangang pag-spray',
  'Follow new growth': 'Subaybayan ang bagong tubo',
  'Keep plants vigorous': 'Panatilihing malusog ang mga halaman',
  'Limit leaf injury': 'Limitahan ang pinsala sa dahon',
  'Inspect after wet weather': 'Suriin pagkatapos ng maulang panahon',
  'Keep preventive care': 'Ipagpatuloy ang pang-iwas na pangangalaga',
  'Inspect both leaf surfaces and photograph lesion edges. Seek crop-specialist confirmation when streaks, rapid yellowing or extensive leaf death occur.':
      'Siyasatin ang magkabilang panig ng dahon at kunan ng larawan ang gilid ng mga sugat. Humingi ng kumpirmasyon sa espesyalista kapag may mga guhit, mabilis na paninilaw, o malawakang pagkamatay ng dahon.',
  'Retain functioning leaves. Review general banana sanitation with your agricultural technician; avoid unnecessary cutting and injury.':
      'Panatilihin ang mga dahong gumagana pa. Talakayin sa tekniko ng agrikultura ang pangkalahatang kalinisan ng saging; iwasan ang hindi kailangang pagputol at pananakit sa halaman.',
  'A Cordana-specific fungicide is usually not justified for mild damage. Do not apply a Sigatoka spray programme solely on this label.':
      'Karaniwang hindi kailangan ang fungicide para sa banayad na pinsala ng Cordana. Huwag mag-spray laban sa Sigatoka batay lamang sa label na ito.',
  'Mark affected plants and compare new leaves at subsequent inspections. Escalate if damage spreads or bunch development declines.':
      'Markahan ang mga apektadong halaman at ihambing ang mga bagong dahon sa susunod na pagsisiyasat. Humingi ng karagdagang tulong kung kumalat ang pinsala o humina ang paglaki ng kumpol.',
  'Use soil-test-based nutrition and maintain banana mat sanitation.':
      'Iayon sa pagsusuri ng lupa ang nutrisyon at panatilihin ang kalinisan sa kumpol ng saging.',
  'Handle plants carefully and check coexisting leaf diseases that can provide infection sites.':
      'Maingat na hawakan ang mga halaman at tingnan kung may kasabay na sakit sa dahon na maaaring pagmulan ng impeksyon.',
  'Look for new lesions following wet, windy conditions; avoid assuming every spot is Cordana.':
      'Maghanap ng mga bagong sugat pagkatapos ng maulan at mahanging panahon; huwag ipagpalagay na Cordana ang bawat batik.',
  'Pacific guidance describes spread in wet, windy weather. A Philippine Cordana seasonal relationship has not been established by the sources used here.':
      'Inilalarawan ng gabay mula sa Pacific ang pagkalat sa maulan at mahanging panahon. Hindi naitatag ng mga ginamit na sanggunian ang ugnayan ng Cordana sa mga panahon sa Pilipinas.',
  'Mark the affected mat and stop moving suckers, soil and soil-contaminated equipment from it. Contact the municipal agriculturist or DA crop-protection office.':
      'Markahan ang apektadong kumpol at itigil ang paglilipat ng suwi, lupa, at kagamitang may kontaminadong lupa mula rito. Makipag-ugnayan sa agriculturist ng munisipyo o tanggapan ng DA para sa proteksiyon ng pananim.',
  'Arrange diagnosis and a supervised containment/removal plan. Avoid dragging infected material through clean parts of the farm.':
      'Magpa-diagnose at magplano ng pagpigil o pag-aalis sa ilalim ng pangangasiwa. Iwasang hilahin ang materyal na may impeksyon sa malilinis na bahagi ng bukid.',
  'Remove adhering soil from equipment before cleaning and disinfection. Manage access so dirty footwear and tools do not enter unaffected blocks.':
      'Alisin muna ang nakadikit na lupa sa kagamitan bago linisin at i-disinfect. Kontrolin ang pagpasok upang hindi madala ang maruming sapatos at kagamitan sa mga bahaging walang sakit.',
  'Discuss verified clean planting material and locally suitable tolerant cultivars. Do not rely on a biological product as a guaranteed cure.':
      'Talakayin ang paggamit ng malinis at beripikadong materyal na pananim at mga barayting angkop at mapagparaya sa lugar. Huwag ituring na tiyak na lunas ang produktong biyolohikal.',
  'Obtain healthy planting material from a reliable nursery; avoid suckers from wilt-affected farms.':
      'Kumuha ng malusog na materyal na pananim mula sa mapagkakatiwalaang punlaan; iwasan ang suwi mula sa bukid na apektado ng pagkalanta.',
  'Keep farm equipment and footwear free of contaminated soil; separate clean and affected blocks.':
      'Panatilihing walang kontaminadong lupa ang kagamitan at sapatos; ihiwalay ang malilinis at apektadong bahagi ng bukid.',
  'Keep a farm map and consult the DA before replanting an affected site.':
      'Panatilihin ang mapa ng bukid at kumonsulta sa DA bago muling magtanim sa apektadong lugar.',
  'Philippine research emphasizes contaminated soil and cultivar susceptibility. Month alone cannot determine exposure; maintain containment throughout the year.':
      'Binibigyang-diin ng pananaliksik sa Pilipinas ang kontaminadong lupa at pagiging madaling tablan ng ilang barayti. Hindi sapat ang buwan lamang para malaman ang panganib; panatilihin ang pagpigil sa pagkalat buong taon.',
  'Check the undersides of leaves for streaks and assess how much functional foliage remains.':
      'Suriin kung may mga guhit sa ilalim ng dahon at tantiyahin kung gaano karaming malusog na dahon ang natitira.',
  'Remove badly affected leaves with advice on retaining adequate healthy foliage. Keep cut material away from clean planting stock.':
      'Alisin ang mga dahong lubhang apektado sa gabay ng eksperto upang mapanatili ang sapat na malulusog na dahon. Ilayo ang pinutol na materyal sa malinis na punla.',
  'Clear blocked drains and overcrowded growth around banana mats. Correct nutrition using soil-test advice.':
      'Linisin ang mga baradong kanal at siksik na tubo sa paligid ng kumpol ng saging. Ayusin ang nutrisyon ayon sa pagsusuri ng lupa.',
  'If new leaves continue to deteriorate, ask a crop-protection technician for a registered fungicide programme and resistance-management plan.':
      'Kung patuloy na lumalala ang mga bagong dahon, humingi sa tekniko ng proteksiyon ng pananim ng rehistradong programa ng fungicide at plano para maiwasan ang resistensiya.',
  'Maintain recommended mat spacing and manage excess suckers to improve airflow.':
      'Panatilihin ang inirerekomendang pagitan ng mga kumpol at kontrolin ang sobrang suwi upang mapaganda ang daloy ng hangin.',
  'Avoid persistent waterlogging and humidity around plants, especially during wetter months.':
      'Iwasan ang palaging pagbabad sa tubig at mataas na halumigmig sa paligid ng mga halaman, lalo na sa mas maulang buwan.',
  'Combine inspections, sanitation and appropriate nutrition; check the next emerging leaves after intervention.':
      'Pagsamahin ang pagsisiyasat, paglilinis, at angkop na nutrisyon; suriin ang mga susunod na sibol na dahon pagkatapos kumilos.',
  'DA banana guidance links excess moisture and humidity with disease development. Wetter-month flags are a scouting inference, not measured infection probabilities.':
      'Iniuugnay ng gabay ng DA sa saging ang sobrang tubig at halumigmig sa pag-usbong ng sakit. Hinuha lamang para sa pagsisiyasat ang mga babala sa mas maulang buwan, hindi mga nasukat na posibilidad ng impeksyon.',
  'Confirm the diagnosis': 'Kumpirmahin ang diagnosis',
  'Inspect leaves, stem, planting material and fruit for lesions, internal discoloration or gum. Ask a plant-health technician to confirm Fusarium before treatment.':
      'Siyasatin ang dahon, tangkay, materyal na pananim, at bunga kung may sugat, pagbabago ng kulay sa loob, o dagta. Ipakumpirma muna sa tekniko ng kalusugan ng halaman ang Fusarium bago maggamot.',
  'Isolate affected material': 'Ihiwalay ang apektadong materyal',
  'Mark suspect plants and keep affected slips, fruit and crop debris out of clean planting-material lots while the cause is checked.':
      'Markahan ang mga kahina-hinalang halaman at ilayo ang apektadong suwi, bunga, at tira-tirang pananim sa malinis na materyal habang sinusuri ang sanhi.',
  'Remove confirmed sources': 'Alisin ang kumpirmadong pinagmumulan',
  'Remove confirmed diseased material using local disposal advice and clean tools before moving to healthy rows.':
      'Alisin ang kumpirmadong may sakit na materyal ayon sa lokal na payo sa pagtatapon at linisin ang mga kagamitan bago pumunta sa hanay ng malulusog na halaman.',
  'Use only matched products': 'Gumamit lamang ng angkop na produkto',
  'If Fusarium is confirmed and chemical protection is justified, use only an FPA-registered pineapple product for the diagnosed target and follow its current label.':
      'Kung nakumpirma ang Fusarium at kailangan ang proteksiyong kemikal, gumamit lamang ng produktong rehistrado sa FPA para sa natukoy na problema at sundin ang kasalukuyang etiketa nito.',
  'Use clean planting material': 'Gumamit ng malinis na materyal na pananim',
  'Select healthy crowns, slips or suckers and reject material with rot, lesions or abnormal gum exudation.':
      'Pumili ng malulusog na korona, suwi, o punla at tanggihan ang may pagkabulok, sugat, o di-pangkaraniwang paglabas ng dagta.',
  'Sanitize field operations': 'Panatilihing malinis ang mga gawain sa bukid',
  'Clean cutting and harvest tools and avoid moving contaminated plant debris into clean blocks.':
      'Linisin ang mga kagamitang pangputol at pang-ani at huwag maglipat ng kontaminadong tira-tirang halaman sa malilinis na bahagi.',
  'Reduce wounds and inspect': 'Bawasan ang mga sugat at magsiyasat',
  'Limit avoidable injury to planting material and fruit, and inspect routinely so suspect material is removed early.':
      'Bawasan ang maiiwasang pinsala sa materyal na pananim at bunga, at regular na magsiyasat upang maagap na maalis ang kahina-hinalang materyal.',
  'The supplied class does not identify the Fusarium species or affected tissue. No validated Philippine month-based risk rule was found, so diagnosis and field scouting take priority.':
      'Hindi tinutukoy ng ibinigay na kategorya ang uri ng Fusarium o apektadong tissue. Walang napatunayang tuntunin sa Pilipinas na batay sa buwan, kaya unahin ang diagnosis at pagsisiyasat sa bukid.',
  'Check the whole plant': 'Suriin ang buong halaman',
  'Inspect the heart, leaf bases, roots and drainage as well as blighted leaf tips. Submit expanding or water-soaked damage for diagnosis.':
      'Siyasatin ang gitna ng halaman, mga base ng dahon, ugat, at daluyan ng tubig pati ang nasirang dulo ng dahon. Ipa-diagnose ang lumalawak o mukhang basang pinsala.',
  'Correct excess moisture': 'Ayusin ang sobrang halumigmig',
  'Improve drainage and avoid prolonged waterlogging or water collecting in the plant heart.':
      'Pagandahin ang daluyan ng tubig at iwasan ang matagal na pagbaha o pag-ipon ng tubig sa gitna ng halaman.',
  'Contain severe damage': 'Pigilan ang malawak na pinsala',
  'Mark affected plants and remove badly rotted material according to local sanitation advice; clean tools between suspect and healthy plants.':
      'Markahan ang mga apektadong halaman at alisin ang bulok na materyal ayon sa lokal na payo sa kalinisan; linisin ang kagamitan sa pagitan ng kahina-hinala at malulusog na halaman.',
  'Match control to the cause': 'Itugma ang pagkontrol sa sanhi',
  'Do not assume every blight is fungal. Use an FPA-registered product only after the target is identified and pineapple is on the label.':
      'Huwag ipagpalagay na amag ang sanhi ng bawat blight. Gumamit lamang ng produktong rehistrado sa FPA matapos matukoy ang problema at tiyaking nakasaad sa etiketa ang pinya.',
  'Plant healthy material': 'Magtanim ng malusog na materyal',
  'Inspect crowns, slips and suckers and reject material showing rot, blight or pest injury.':
      'Siyasatin ang mga korona, suwi, at punla at tanggihan ang may pagkabulok, blight, o pinsala ng peste.',
  'Use well-drained ground and avoid irrigation practices that keep the crown and leaf bases continuously wet.':
      'Gumamit ng lupang maayos ang daluyan ng tubig at iwasan ang patubig na palaging nagpapabasa sa korona at base ng dahon.',
  'Inspect after wet periods': 'Siyasatin pagkatapos ng maulang panahon',
  'Scout low areas and check new leaves after prolonged rain; remove accumulating diseased debris from the field.':
      'Siyasatin ang mga mababang lugar at tingnan ang mga bagong dahon pagkatapos ng tuloy-tuloy na ulan; alisin sa bukid ang naiipong tirang may sakit.',
  'Wet conditions can favor several pineapple rots, but this broad image class does not identify a pathogen. The reviewed sources do not support a Philippine calendar prediction.':
      'Maaaring pabor sa ilang uri ng pagkabulok ng pinya ang basang kondisyon, ngunit hindi tinutukoy ng malawak na kategoryang ito ang pathogen. Walang batayan sa sinuring sanggunian para sa hula ayon sa kalendaryo sa Pilipinas.',
  'Verify symptoms and vectors': 'Suriin ang mga sintomas at tagapagdala',
  'Inspect leaf bases and roots for mealybugs and ants, and check nearby plants for reddening, inward leaf curling and loss of rigidity.':
      'Siyasatin ang base ng dahon at mga ugat kung may mealybug at langgam, at tingnan kung namumula, kumukulob paloob, o lumalambot ang mga dahon ng katabing halaman.',
  'Contain affected plants': 'Pigilan ang pagkalat mula sa mga apektadong halaman',
  'Remove confirmed severely affected plants and their residue using local disposal advice; do not reuse infested planting material.':
      'Alisin ang kumpirmadong lubhang apektadong halaman at mga tira nito ayon sa lokal na payo sa pagtatapon; huwag muling gamitin ang materyal na pinamugaran.',
  'Manage ants and mealybugs': 'Pamahalaan ang langgam at mealybug',
  'Reduce weeds and debris that shelter ants or mealybugs and use an integrated ant-and-mealybug plan to protect healthy plants.':
      'Bawasan ang damo at tirang halaman na pinagtataguan ng langgam o mealybug at gumamit ng pinagsamang plano sa pagkontrol upang maprotektahan ang malulusog na halaman.',
  'Select control locally': 'Pumili ng paraang angkop sa lugar',
  'If monitoring justifies pesticide use, ask the agricultural technician for an FPA-registered pineapple/mealybug product and protect natural enemies.':
      'Kung ipinapakita ng pagmamanman na kailangan ang pestisidyo, magtanong sa tekniko ng agrikultura tungkol sa produktong rehistrado sa FPA para sa pinya at mealybug, at pangalagaan ang mga likas na kalaban ng peste.',
  'Start mealybug-free': 'Magsimula sa materyal na walang mealybug',
  'Use clean planting material and inspect leaf bases and roots before moving it into a new field.':
      'Gumamit ng malinis na materyal na pananim at siyasatin ang base ng dahon at ugat bago ilipat sa bagong bukid.',
  'Control ant shelter': 'Bawasan ang pinagtataguan ng langgam',
  'Keep weeds and debris managed and monitor ant activity because ants protect mealybugs from natural enemies.':
      'Kontrolin ang mga damo at tira-tira at subaybayan ang mga langgam dahil pinoprotektahan nila ang mealybug laban sa mga likas na kalaban nito.',
  'Scout neighboring plants': 'Siyasatin ang mga katabing halaman',
  'Check adjacent rows routinely and act on new mealybug colonies before widespread wilt develops.':
      'Regular na suriin ang mga katabing hanay at kumilos kapag may bagong kolonya ng mealybug bago kumalat ang pagkalanta.',
  'Philippine sources establish mealybugs and wilt risk, but do not provide a validated month-only forecast. Field infestation, ants and planting material determine local risk.':
      'Kinukumpirma ng mga sanggunian sa Pilipinas ang mealybug at panganib ng pagkalanta ngunit walang napatunayang hula batay lamang sa buwan. Nakadepende ang lokal na panganib sa pagdami ng peste sa bukid, langgam, at materyal na pananim.',
  'Keep foliage dry': 'Panatilihing tuyo ang mga dahon',
  'Improve hygiene': 'Pagbutihin ang kalinisan',
  'Ventilate the crop': 'Pagandahin ang daloy ng hangin sa pananim',
  'Check symptoms and vectors': 'Suriin ang mga sintomas at tagapagdala',
  'Protect healthy plants': 'Pangalagaan ang malulusog na halaman',
  'Plan the next crop': 'Planuhin ang susunod na tanim',
  'Inspect transplants': 'Suriin ang mga punla bago ilipat',
  'Scout routinely': 'Regular na siyasatin ang pananim',
  'Keep fields sanitary': 'Panatilihing malinis ang bukid',
  'Treat only when justified': 'Maggamot lamang kung kinakailangan',
  'Check leaf undersides': 'Suriin ang ilalim ng mga dahon',
  'Maintain routine care': 'Ipagpatuloy ang regular na pangangalaga',
  'No cameras found on this device.': 'Walang camera sa device na ito.',
  'Capturing image…': 'Kinukunan ng larawan…',
  'Preparing grid cells…': 'Inihahanda ang mga cell ng grid…',
  'Running AI model…': 'Pinapatakbo ang AI model…',
  'Original camera scan • one result':
      'Karaniwang scan ng camera • isang resulta',
  'Place one scan target in each numbered cell':
      'Maglagay ng isang target sa bawat may numerong cell',
  'Position plant within frame': 'Iposisyon ang halaman sa loob ng frame',
  'Cells are numbered left-to-right, top-to-bottom':
      'Nakaayos ang mga numero mula kaliwa pakanan, saka itaas pababa',
  'Capture or upload a plant image to diagnose':
      'Kumuha o mag-upload ng larawan ng halaman para masuri',
  'No location': 'Walang lokasyon',
  'No scans found for this period.': 'Walang scan sa panahong ito.',
  'All cells': 'Lahat ng cell',
  'Healthy cells': 'Mga malusog na cell',
  'Infected cells': 'Mga cell na may sakit',
  'Average confidence': 'Karaniwang antas ng katiyakan',
  'Restore LeafLens data?': 'Ibalik ang data ng LeafLens?',
  'Backup restored. Your history is up to date.':
      'Naibalik ang backup. Bago na ang kasaysayan mo.',
  'Could not export the PDF:': 'Hindi ma-export ang PDF:',
  'Could not save backup:': 'Hindi ma-save ang backup:',
  'Could not restore backup:': 'Hindi maibalik ang backup:',
  'AI-generated result': 'Resultang ginawa ng AI',
  'Review this result': 'Suriin ang resultang ito',
  'View crop guide': 'Tingnan ang gabay sa pananim',
  'View treatment advice': 'Tingnan ang payo sa paggamot',
  'View prevention advice': 'Tingnan ang payo sa pag-iwas',
  'Enter location': 'Ilagay ang lokasyon',
  'Location name': 'Pangalan ng lokasyon',
  'Save location': 'I-save ang lokasyon',
  'Crop Guide': 'Gabay sa Pananim',
  'Choose a condition for treatment steps and supporting references.':
      'Pumili ng kondisyon para makita ang mga hakbang sa paggamot at mga sanggunian.',
  'Choose a condition for prevention steps and the evidence behind its seasonal outlook.':
      'Pumili ng kondisyon para makita ang mga hakbang sa pag-iwas at ebidensya tungkol sa panganib nito ayon sa panahon.',
  'Routine crop care': 'Regular na pangangalaga sa pananim',
  'Treatment plan': 'Plano ng paggamot',
  'Prevention steps': 'Mga hakbang sa pag-iwas',
  'Selecting a crop-protection product':
      'Pagpili ng produktong panangga sa pananim',
  'Check current FPA registration for the crop and pest. Follow the product label for dose, protective equipment, re-entry and time before harvest. Ask your municipal agriculturist to confirm suitability.':
      'Suriin ang kasalukuyang rehistro ng FPA para sa pananim at peste. Sundin ang etiketa ng produkto para sa dosis, kagamitang panangga, ligtas na muling pagpasok, at pagitan bago anihin. Magtanong sa agriculturist ng munisipyo kung angkop ito.',
  'References reviewed 28 September 2026':
      'Mga sangguniang sinuri noong Setyembre 28, 2026',
  'Evidence for this condition': 'Ebidensya tungkol sa kondisyong ito',
  'Tap a month. Orange: elevated concern. Green: monitoring. Gray: more evidence needed.':
      'Pumili ng buwan. Kahel: mas mataas ang alalahanin. Berde: pagmamanman. Abo: kailangan pa ng ebidensya.',
  'Routine care': 'Regular na pangangalaga',
  'A healthy scan does not forecast future disease.':
      'Hindi hinuhulaan ng malusog na scan ang sakit sa hinaharap.',
  'Evidence limited': 'Limitado ang ebidensya',
  'No supported Philippine calendar estimate. Use the evidence note and field inspections.':
      'Walang sapat na batayan para sa tantiya ayon sa kalendaryo sa Pilipinas. Gamitin ang tala ng ebidensya at siyasatin ang bukid.',
  'Field data needed': 'Kailangan ng datos mula sa bukid',
  'Month and rainfall alone cannot estimate this condition. Check humidity, vectors and the confirmed cause.':
      'Hindi sapat ang buwan at dami ng ulan lamang para matantiya ang kondisyong ito. Suriin ang halumigmig, mga tagapagdala, at kumpirmadong sanhi.',
  'Year-round watch': 'Bantayan buong taon',
  'Keep prevention in place in every month; exposure is not determined by season alone.':
      'Ipagpatuloy ang pag-iwas bawat buwan; hindi panahon lamang ang nagtatakda ng panganib.',
  'Choose an area': 'Pumili ng lugar',
  'Select a nearby PAGASA station to view seasonal guidance for your area.':
      'Pumili ng malapit na istasyon ng PAGASA para makita ang gabay ayon sa panahon sa lugar mo.',
  'This station has rainfall throughout the year. Observe actual leaf wetness and dry spells instead of assuming a dry season.':
      'Umuulan sa istasyong ito buong taon. Obserbahan kung basa ang mga dahon at kung may mga panahong tuyo sa halip na ipagpalagay na may tagtuyot.',
  'Rain throughout the year': 'Umuulan buong taon',
  'Wetter part of the year': 'Mas maulang bahagi ng taon',
  'Relatively drier month': 'Medyo mas tuyong buwan',
  'Elevated seasonal concern': 'Mas mataas na panganib ngayong panahon',
  'Routine monitoring': 'Regular na pagmamanman',
  'Typical seasonal conditions may favor this problem. Increase scouting and apply the prevention steps below.':
      'Maaaring pabor sa problemang ito ang karaniwang kondisyon ngayong panahon. Dagdagan ang pagsisiyasat at sundin ang mga hakbang sa pag-iwas sa ibaba.',
  'The seasonal flag is not elevated. Disease can still occur with local moisture, susceptible plants or infection sources.':
      'Hindi mataas ang babala ayon sa panahon. Maaari pa ring magkaroon ng sakit dahil sa halumigmig sa lugar, madaling tablan na halaman, o pinagmumulan ng impeksyon.',
  'View all sources': 'Tingnan ang lahat ng sanggunian',
  'Nearby PAGASA station': 'Malapit na istasyon ng PAGASA',
  'Record options': 'Mga opsyon sa tala',
  'Example: Greenhouse 1': 'Halimbawa: Greenhouse 1',
  'Create a Papusoy Hydrofarm report from every scan tagged with one location.':
      'Gumawa ng ulat ng Papusoy Hydrofarm mula sa lahat ng scan na may iisang tag ng lokasyon.',
  'Crop location': 'Lokasyon ng pananim',
  'Scout name': 'Pangalan ng nagsuri',
  'Name shown as Scouted by': 'Pangalang ipapakita sa “Sinuri ni”',
  'Enter a crop location.': 'Maglagay ng lokasyon ng pananim.',
  'Use letters, numbers, and spaces only.':
      'Gumamit lamang ng mga titik, numero, at espasyo.',
  'Enter the scout name.': 'Ilagay ang pangalan ng nagsuri.',
  'No scans match this location. Check the tag and try again.':
      'Walang scan na tumutugma sa lokasyong ito. Suriin ang tag at subukan muli.',
  'PDF report': 'Ulat na PDF',
  'The scouting date is set when you export. The default file name increments automatically.':
      'Itatakda ang petsa ng pagsusuri kapag nag-export ka. Awtomatikong nadaragdagan ang numero ng default na pangalan ng file.',
  'On Android, reports are saved automatically in Downloads/':
      'Sa Android, awtomatikong sine-save ang mga ulat sa Downloads/',
  'Papusoy Hydrofarm Scouting Report':
      'Ulat sa Pagsusuri ng Pananim ng Papusoy Hydrofarm',
  'Observations': 'Mga Obserbasyon',
  'Attachments': 'Mga Kalakip',
  'Location tag': 'Tag ng lokasyon',
  'Most active disease': 'Pinakakaraniwang sakit',
  'Most affected crop': 'Pinakanaaapektuhang pananim',
  'Scans': 'Mga scan',
  'Diseases': 'Mga sakit',
  'No affected crops were recorded at this location.':
      'Walang naitalang apektadong pananim sa lokasyong ito.',
  'Affected crop images are no longer available on this device.':
      'Hindi na makita sa device na ito ang mga larawan ng apektadong pananim.',
  'No Plant Leaf Detected': 'Walang Natukoy na Dahon ng Halaman',
  'The image doesn\'t appear to contain a recognizable plant leaf. Please make sure a leaf is clearly visible and well-lit.':
      'Mukhang walang makilalang dahon ng halaman sa larawan. Tiyaking malinaw na nakikita at maliwanag ang dahon.',
  'Tips for a better scan': 'Mga tip para sa mas mahusay na scan',
  'Use good natural lighting': 'Gumamit ng magandang likas na liwanag',
  'Place the leaf in the center of the frame':
      'Ilagay ang dahon sa gitna ng kuha',
  'Get close enough — fill the frame with the leaf':
      'Lumapit nang sapat — punuin ng dahon ang kuha',
  'Keep the camera steady to avoid blur': 'Panatilihing hindi gumagalaw ang camera para iwas-labo',
  'Scan only supported crops (pineapple, banana, lettuce, or tomato)':
      'I-scan lamang ang mga suportadong pananim (pinya, saging, letsugas, o kamatis)',
  'Try Again': 'Subukan Muli',
  'Go Back': 'Bumalik',
  'Unable to Identify Clearly': 'Hindi Matukoy nang Malinaw',
  'Improve your scan': 'Pagandahin ang scan mo',
  'Ensure the leaf is well-lit': 'Tiyaking maliwanag ang dahon',
  'Fill the frame with just the leaf': 'Dahon lamang ang pumuno sa kuha',
  'Hold steady — avoid motion blur': 'Hawakan nang matatag — iwasan ang labo dahil sa galaw',
  'Scan or Take a Clear Picture': 'Mag-scan o Kumuha ng Malinaw na Larawan',
  'Scan Result': 'Resulta ng Scan',
  'Plant is Healthy': 'Malusog ang Halaman',
  'Disease Detected': 'May Natukoy na Sakit',
  'Condition': 'Kondisyon',
  'Crop location saved': 'Na-save ang lokasyon ng pananim',
  'Tag this crop location': 'Lagyan ng tag ang lokasyon ng pananim',
  'This scan is included under this location in Reports.':
      'Kasama ang scan na ito sa mga ulat para sa lokasyong ito.',
  'Enter the location before leaving this result so it can be included in a scouting report.':
      'Ilagay ang lokasyon bago umalis sa resultang ito para maisama ito sa ulat ng pagsusuri.',
  'Saving scan...': 'Sine-save ang scan…',
  'Save Scan & Location': 'I-save ang Scan at Lokasyon',
  'Confidence Score': 'Iskor ng Katiyakan',
  ' High confidence — result is reliable': 'Mataas ang katiyakan — maaasahan ang resulta',
  ' Moderate confidence — result is likely correct':
      'Katamtaman ang katiyakan — malamang na tama ang resulta',
  ' Debug Info': ' Impormasyon sa Pag-debug',
  'Raw label': 'Raw na label',
  'Class index': 'Indeks ng klase',
  'Input size': 'Laki ng input',
  'Model': 'Modelo',
  'Raw score': 'Raw na iskor',
  'View Treatment Advice': 'Tingnan ang Payo sa Paggamot',
  'Scan Another Plant': 'Mag-scan ng Ibang Halaman',
  'Other Possible Diseases': 'Iba Pang Posibleng Sakit',
  'These similar conditions are for the same crop and passed the comparison threshold. Compare visible symptoms before choosing a treatment.':
      'Ang mga kahalintulad na kondisyong ito ay para sa parehong pananim at pumasa sa hangganan ng paghahambing. Ihambing muna ang nakikitang sintomas bago pumili ng paggamot.',
  'Detection Confidence': 'Katiyakan ng Pagtukoy',
  'Detailed treatment guidance for': 'Detalyadong gabay sa paggamot para sa',
  'is not yet included. Confirm this result with a qualified crop specialist before applying treatment.':
      'ay hindi pa kasama. Kumpirmahin ang resultang ito sa kwalipikadong espesyalista sa pananim bago magpagamot.',
  'Could not save this scan. Please try again.':
      'Hindi ma-save ang scan na ito. Subukan muli.',
  'The scan image is no longer available.': 'Hindi na available ang larawan ng scan.',
  'Try again': 'Subukan muli',
  'Seasonal risk': 'Panganib ayon sa panahon',
  'Wet season': 'Tag-ulan',
  'Dry season': 'Tag-init',
  'Year-round': 'Buong taon',
  'Site-dependent': 'Depende sa lugar',
  'Insufficient evidence': 'Kulang ang ebidensya',
  'No scan history yet': 'Wala pang kasaysayan ng scan',
  'Start by scanning a crop to build your records.':
      'Magsimula sa pag-scan ng pananim para makabuo ng mga tala.',
  'No results match your filters.':
      'Walang resultang tumutugma sa mga filter mo.',
  'Select records': 'Pumili ng mga tala',
  'Delete selected': 'Burahin ang mga napili',
  'Delete records?': 'Burahin ang mga tala?',
  'Are you sure you want to delete the selected records? This cannot be undone.':
      'Sigurado ka bang buburahin ang mga napiling tala? Hindi na ito maibabalik.',
  'No crop reports yet': 'Wala pang ulat ng pananim',
  'Scan a crop to start building your reports.':
      'Mag-scan ng pananim para masimulan ang mga ulat mo.',
  'Export report': 'I-export ang ulat',
  'Choose a date range': 'Pumili ng saklaw ng petsa',
  'Start date': 'Petsa ng pagsisimula',
  'End date': 'Petsa ng pagtatapos',
  'Jan': 'Ene',
  'Feb': 'Peb',
  'Apr': 'Abr',
  'Jun': 'Hun',
  'Jul': 'Hul',
  'Aug': 'Ago',
  'Sep': 'Set',
  'Oct': 'Okt',
  'Nov': 'Nob',
  'Dec': 'Dis',
  'SCOUTING REPORT': 'ULAT SA PAGSUSURI NG PANANIM',
  'Scouted date:': 'Petsa ng pagsusuri:',
  'Scouted by:': 'Sinuri ni:',
  'None': 'Wala',
  'None detected': 'Walang natukoy',
  'Crop scouting report for': 'Ulat sa pagsusuri ng pananim para sa',
  'Diseases recorded at this location': 'Mga sakit na naitala sa lokasyong ito',
  'Creating PDF...': 'Ginagawa ang PDF…',
  'Cordana leaf spot causes dark, diamond-shaped marks on banana leaves.':
      'Nagdudulot ang batik ng Cordana ng maiitim at hugis-brilyanteng marka sa dahon ng saging.',
  'The leaf looks healthy, with no clear disease signs.':
      'Mukhang malusog ang dahon at walang malinaw na palatandaan ng sakit.',
  'Panama wilt affects the plant’s water flow, causing leaves to yellow and wilt.':
      'Naaapektuhan ng pagkalanta ng Panama ang daloy ng tubig sa halaman kaya naninilaw at nalalanta ang mga dahon.',
  'Sigatoka causes dark streaks and spots that damage banana leaves.':
      'Nagdudulot ang Sigatoka ng maiitim na guhit at batik na sumisira sa mga dahon ng saging.',
  'Bacterial disease can cause wet-looking spots or soft rot on lettuce.':
      'Maaaring magdulot ang sakit na bakteryal ng mga batik na mukhang basa o malambot na pagkabulok sa letsugas.',
  'Fungal disease can cause spots, patches, or mold on lettuce leaves.':
      'Maaaring magdulot ang sakit na dulot ng amag ng mga batik, marka, o amag sa dahon ng letsugas.',
  'Insect pests feed on lettuce leaves and may leave holes or other marks.':
      'Kumakain ang mga peste ng insekto sa dahon ng letsugas at maaaring mag-iwan ng mga butas o marka.',
  'Fusarium can cause rot and wilting in pineapple plants or fruit.':
      'Maaaring magdulot ang Fusarium ng pagkabulok at pagkalanta sa halaman o bunga ng pinya.',
  'Leaf blight causes damaged or dying patches on pineapple leaves.':
      'Nagdudulot ang leaf blight ng mga bahaging nasisira o namamatay sa dahon ng pinya.',
  'Mealybugs spread this disease, which can make pineapple leaves red and wilted.':
      'Ipinapasa ng mealybug ang sakit na ito na maaaring magpamula at magpalanta sa dahon ng pinya.',
  'Blight causes spreading dark spots on tomato leaves and sometimes stems.':
      'Nagdudulot ang blight ng kumakalat na maiitim na batik sa dahon at kung minsan pati tangkay ng kamatis.',
  'Insects can chew, pierce, or mark tomato leaves in different ways.':
      'Maaaring nguyain, tusukin, o markahan ng mga insekto ang dahon ng kamatis sa iba’t ibang paraan.',
  'Leaf curl virus can make tomato leaves curl, turn yellow, and grow poorly.':
      'Maaaring magpakulot at magpanilaw ng dahon at magpahina sa paglaki ng kamatis ang leaf curl virus.',
  'Leaf miner larvae make winding tunnels inside tomato leaves.':
      'Gumagawa ng paikot-ikot na lagusan sa loob ng dahon ng kamatis ang mga uod ng leaf miner.',
  'Leaf mold can cause yellow patches and fuzzy growth under tomato leaves.':
      'Maaaring magdulot ang amag sa dahon ng mga dilaw na marka at malambot na tubo sa ilalim ng dahon ng kamatis.',
  'This condition can affect the plant’s leaves. Check the plant for other signs.':
      'Maaaring maapektuhan ng kondisyong ito ang mga dahon ng halaman. Suriin kung may iba pang palatandaan.',
  'Sigatoka leaf spot': 'Batik ng Sigatoka sa dahon',
  'Fusarium symptoms': 'Mga sintomas ng Fusarium',
  'Leaf blight': 'Leaf blight',
  'Mealybug wilt': 'Pagkalanta na dulot ng mealybug',
  'Bacterial group': 'Pangkat ng bakterya',
  'Fungal group': 'Pangkat ng amag',
  'Broad insect-pest group': 'Malawak na pangkat ng peste ng insekto',
  'Combined blight class': 'Pinagsamang kategorya ng blight',
  'Broad pest class': 'Malawak na kategorya ng peste',
  'Virus-vector disease complex': 'Sakit na kaugnay ng virus at tagapagdala nito',
  'Blight symptoms; confirm the cause': 'Mga sintomas ng blight; kumpirmahin ang sanhi',
  'Fungal disease; confirm the cause': 'Sakit na dulot ng amag; kumpirmahin ang sanhi',
  'Diamond-shaped lesions can resemble other banana leaf spots. Confirm extensive damage; mild Cordana usually needs monitoring rather than a fungicide.':
      'Maaaring mapagkamalang ibang batik sa dahon ng saging ang mga sugat na hugis-brilyante. Kumpirmahin kung malawak ang pinsala; karaniwang pagmamanman lamang ang kailangan sa banayad na Cordana, hindi fungicide.',
  'Suspected Fusarium wilt needs prompt confirmation. Containment and clean planting material are central; a leaf photo cannot identify the Fusarium race.':
      'Kailangang agad kumpirmahin ang pinaghihinalaang pagkalanta ng Fusarium. Mahalaga ang pagpigil sa pagkalat at paggamit ng malinis na pananim; hindi matutukoy sa larawan ng dahon ang lahi ng Fusarium.',
  'The model groups Sigatoka symptoms; it does not distinguish yellow from black Sigatoka. Confirm the diagnosis before planning chemical control.':
      'Pinagsasama ng modelo ang mga sintomas ng Sigatoka; hindi nito naihihiwalay ang yellow Sigatoka sa black Sigatoka. Kumpirmahin ang diagnosis bago magplano ng pagkontrol gamit ang kemikal.',
  'The model class is broad. Fusarium can affect pineapple fruit or planting material, but similar discoloration and rot require field or laboratory confirmation.':
      'Malawak ang kategorya ng modelo. Maaaring maapektuhan ng Fusarium ang bunga o materyal na pananim ng pinya, ngunit kailangang kumpirmahin sa bukid o laboratoryo ang kahalintulad na pagbabago ng kulay at pagkabulok.',
  'Leaf blight describes damaged tissue, not a confirmed organism. Rots, fungi, water stress and injury can overlap in appearance.':
      'Inilalarawan ng leaf blight ang sirang tissue, hindi ang kumpirmadong sanhi. Maaaring magkahawig ang pagkabulok, amag, kakulangan sa tubig, at pinsala.',
  'Pineapple mealybugs transmit wilt-associated viruses. Treating a wilted plant does not reverse viral infection; management focuses on confirming mealybugs and protecting healthy plants.':
      'Nagpapasa ang mealybug ng pinya ng mga virus na kaugnay ng pagkalanta. Hindi naibabalik ng paggamot ang halamang nalanta dahil sa virus; ituon ang pamamahala sa pagkumpirma ng mealybug at pagprotekta sa malulusog na halaman.',
  'The label does not distinguish leaf spot from soft rot or wilt. Identify the cause before selecting a treatment.':
      'Hindi naihihiwalay ng label ang batik sa dahon, malambot na pagkabulok, o pagkalanta. Tukuyin muna ang sanhi bago pumili ng paggamot.',
  'Different fungi can cause leaf lesions and rotting. This broad class needs confirmation before fungicide selection.':
      'Maaaring magdulot ng sugat sa dahon at pagkabulok ang iba’t ibang amag. Kailangang kumpirmahin muna ang malawak na kategoryang ito bago pumili ng fungicide.',
  'This broad label can represent aphids, semiloopers or other insects. Inspect the plant and identify the active pest before choosing a control.':
      'Maaaring tumukoy ang malawak na label na ito sa aphid, semilooper, o iba pang insekto. Siyasatin ang halaman at tukuyin ang aktibong peste bago pumili ng paraan ng pagkontrol.',
  'The model combines early and late blight. Retain both existing management plans and confirm which disease is present because late blight is an oomycete and may spread rapidly.':
      'Pinagsasama ng modelo ang early blight at late blight. Panatilihin ang mga plano para sa dalawa at kumpirmahin kung alin ang naroon dahil ang late blight ay oomycete at maaaring mabilis kumalat.',
  'The model\'s leaf-mold class is consistent with Passalora-type symptoms. Other local leaf molds can look similar; confirm the cause.':
      'Tugma sa mga sintomas na uri ng Passalora ang kategorya ng leaf mold ng modelo. Maaaring magkahawig ang ibang amag sa dahon sa lugar; kumpirmahin ang sanhi.',
  'This class recognizes visible insect-type injury but does not identify the pest. Holes, mines, stippling and sap-feeding damage require different controls.':
      'Kinikilala ng kategoryang ito ang nakikitang pinsalang dulot ng insekto ngunit hindi nito tinutukoy ang peste. Magkakaiba ang pagkontrol sa mga butas, minahan sa dahon, tuldok-tuldok na pinsala, at pagsipsip ng dagta.',
  'Curled yellow leaves can have several causes. Confirm suspected virus; controlling whiteflies protects other plants but does not cure infected ones.':
      'Maraming posibleng sanhi ang nakakulot at naninilaw na dahon. Kumpirmahin ang pinaghihinalaang virus; napoprotektahan ng pagkontrol sa whitefly ang ibang halaman ngunit hindi nito napapagaling ang may impeksyon.',
  'Winding mines indicate larvae feeding inside leaves. Confirm active larvae or pupae because old mines remain visible after the pest is gone.':
      'Palatandaan ng pagkain ng uod sa loob ng dahon ang paikot-ikot na minahan. Kumpirmahin kung may aktibong uod o pupa dahil nakikita pa rin ang lumang minahan kahit wala na ang peste.',
  'No disease treatment is indicated by this label. Continue field inspection; one healthy-looking leaf does not exclude problems elsewhere.':
      'Walang ipinahihiwatig na paggamot sa sakit ang label na ito. Ipagpatuloy ang pagsisiyasat sa bukid; hindi ibig sabihin ng isang mukhang malusog na dahon na walang problema sa ibang bahagi.',
  'Restrict movement': 'Limitahan ang paglilipat',
  'Confirm before removal': 'Kumpirmahin bago alisin',
  'Protect clean areas': 'Pangalagaan ang malilinis na bahagi',
  'Plan rehabilitation': 'Planuhin ang pagpapanumbalik ng tanim',
  'Start clean': 'Magsimula sa malinis na materyal',
  'Control soil transfer': 'Pigilan ang paglipat ng lupa',
  'Track affected mats': 'Subaybayan ang mga apektadong kumpol',
  'Inspect the canopy': 'Siyasatin ang mga dahon',
  'Reduce infected tissue': 'Bawasan ang bahaging may impeksyon',
  'Reduce humidity': 'Bawasan ang halumigmig',
  'Review control needs': 'Suriin ang pangangailangan sa pagkontrol',
  'Space banana mats': 'Bigyan ng sapat na pagitan ang mga kumpol ng saging',
  'Maintain drainage': 'Panatilihing maayos ang daluyan ng tubig',
  'Scout regularly': 'Regular na siyasatin ang tanim',
  'Confirm the problem': 'Kumpirmahin ang problema',
  'Check affected fruit': 'Suriin ang apektadong bunga',
  'Remove infected material': 'Alisin ang bahaging may impeksyon',
  'Protect planting stock': 'Pangalagaan ang materyal na pananim',
  'Inspect planting material': 'Suriin ang materyal na pananim',
  'Improve field sanitation': 'Pagbutihin ang kalinisan sa bukid',
  'Improve drainage and airflow': 'Pagandahin ang daloy ng tubig at hangin',
  'Remove mealybugs': 'Alisin ang mga mealybug',
  'Avoid excess moisture': 'Iwasan ang sobrang halumigmig',
  'Check for active pests': 'Suriin kung may aktibong peste',
  'Identify the pest': 'Tukuyin ang peste',
  'Remove local sources': 'Alisin ang mga pinagmumulan sa paligid',
  'Use targeted management': 'Gumamit ng angkop na paraan ng pamamahala',
  'Recheck new damage': 'Suriin muli kung may bagong pinsala',
  'Remove early infection sources': 'Alisin agad ang pinagmumulan ng impeksyon',
  'Keep seedlings protected': 'Pangalagaan ang mga punla',
  'Manage host plants': 'Pamahalaan ang mga halamang pinamumugaran',
  'Use field observations': 'Gamitin ang mga obserbasyon sa bukid',
  'Confirm active mining': 'Kumpirmahin kung aktibo ang minahan sa dahon',
  'Remove severe sources': 'Alisin ang mga bahaging lubhang apektado',
  'Protect natural enemies': 'Pangalagaan ang mga likas na kalaban ng peste',
  'Check transplants': 'Suriin ang mga punla bago ilipat',
  'Conserve parasitoids': 'Pangalagaan ang mga parasitoid',
  'Clear old crops': 'Alisin ang mga lumang tanim',
  'History could not be loaded': 'Hindi ma-load ang kasaysayan',
  'Check the app storage and try again.': 'Suriin ang storage ng app at subukan muli.',
  'Retry': 'Subukan muli',
  'Your successful camera and gallery scans will appear here.':
      'Lalabas dito ang matagumpay na scan mula sa camera at gallery.',
  'Start a scan': 'Magsimula ng scan',
  'Choose another category to view saved records.':
      'Pumili ng ibang kategorya para makita ang mga naka-save na tala.',
  'Total': 'Kabuuan',
  'Cancel selection': 'Kanselahin ang pagpili',
  'Location not tagged': 'Walang tag ng lokasyon',
  'Add a clear location name so this scan appears in the right report.':
      'Maglagay ng malinaw na pangalan ng lokasyon para lumabas ang scan sa tamang ulat.',
  'Update the location name for this scan. Future reports will use the new name.':
      'I-update ang pangalan ng lokasyon para sa scan na ito. Gagamitin ang bagong pangalan sa mga susunod na ulat.',
  'Save changes': 'I-save ang mga pagbabago',
  'The selected scan data and saved photos will be permanently deleted.':
      'Permanenteng buburahin ang napiling data ng scan at mga naka-save na larawan.',
  'Crop health': 'Kalusugan ng pananim',
  'Confidence by scan': 'Katiyakan sa bawat scan',
  'Condition breakdown': 'Pagkakahati ayon sa kondisyon',
  'Report insights': 'Mga pagsusuri sa ulat',
  'Total scans': 'Kabuuang scan',
  'Affected': 'Apektado',
  'Avg. confidence': 'Karaniwang katiyakan',
  'Live data from scan history. These analytics update as successful scans are saved or deleted.':
      'Live na datos mula sa kasaysayan ng scan. Maa-update ang pagsusuring ito kapag may matagumpay na scan na na-save o nabura.',
  'healthy': 'malusog',
  'No disease detected in this view': 'Walang natukoy na sakit sa view na ito',
  'Most frequent condition': 'Pinakamadalas na kondisyon',
  'Healthy share': 'Bahagi ng malulusog',
  'Highest-confidence scan': 'Scan na may pinakamataas na katiyakan',
  'Confidence shows how strongly the model matched each saved scan. It does not replace field inspection.':
      'Ipinapakita ng katiyakan kung gaano kalakas ang pagtutugma ng modelo sa bawat naka-save na scan. Hindi nito pinapalitan ang pagsisiyasat sa bukid.',
  'What to add for live reports': 'Mga idaragdag para sa live na ulat',
  'Create one scan repository used by Scanner, Grid Results, History, and Reports.':
      'Gumawa ng iisang imbakan ng scan para sa Scanner, Grid Results, History, at Reports.',
  'Save every completed single scan and every grid cell as its own record.':
      'I-save bilang magkakahiwalay na tala ang bawat nakumpletong scan at bawat cell ng grid.',
  'Replace mockScans with records loaded from SQLite, Isar, Hive, or your backend.':
      'Palitan ang mockScans ng mga talang nilo-load mula sa SQLite, Isar, Hive, o backend mo.',
  'Add farm/plot, GPS, farmer notes, treatment used, and follow-up status when available.':
      'Idagdag ang bukid/plot, GPS, mga tala ng magsasaka, ginamit na paggamot, at katayuan ng follow-up kapag mayroon.',
  'After real storage works, add date filters and PDF/CSV export.':
      'Kapag gumagana na ang imbakan, magdagdag ng filter ng petsa at pag-export ng PDF/CSV.',
  'No scans match this filter': 'Walang scan na tumutugma sa filter na ito',
  'Grid scans and location saved to history.':
      'Na-save sa kasaysayan ang mga grid scan at lokasyon.',
  'Some grid cells still need to be saved.':
      'May mga cell pa sa grid na kailangang i-save.',
  'Some cells could not be saved. Tap retry.':
      'Hindi ma-save ang ilang cell. Pindutin ang subukan muli.',
  'Each numbered cell was cropped from this one image and analyzed as an independent scan.':
      'Kinuha mula sa iisang larawan ang bawat may numerong cell at sinuri ito bilang hiwalay na scan.',
  'No plant tiles to save': 'Walang tile ng halaman na ise-save',
  'Months': 'Mga buwan',
  'Affected crop': 'Apektadong pananim',
  'Where is this crop located?': 'Saan matatagpuan ang pananim na ito?',
  'This tag groups scans into the correct scouting report.':
      'Pinagsasama ng tag na ito ang mga scan sa tamang ulat ng pagsusuri.',
  'Issues': 'Mga problema',
  'Ignored': 'Hindi isinama',
  'Review': 'Suriin',
  'Scan Another Grid': 'Mag-scan ng Ibang Grid',
  'Ignored and inconclusive tiles are not added to scan history.':
      'Hindi isinasama sa kasaysayan ng scan ang mga tile na hindi isinama o walang tiyak na resulta.',
  'Tag this crop grid': 'Lagyan ng tag ang lokasyon ng grid na ito',
  'Every recognized plant tile is saved under this location. Ignored tiles were not added.':
      'Ise-save sa lokasyong ito ang bawat nakilalang tile ng halaman. Hindi isinama ang mga binalewalang tile.',
  'One location tag will be applied to every recognized plant tile. Ignored tiles will not be saved.':
      'Ilalapat ang iisang tag ng lokasyon sa bawat nakilalang tile ng halaman. Hindi ise-save ang mga binalewalang tile.',
  'Saving grid scans...': 'Sine-save ang mga scan sa grid…',
  'Save Grid & Location': 'I-save ang Grid at Lokasyon',
  'Plant visible': 'Nakikita ang halaman',
  'Primary finding': 'Pangunahing natuklasan',
  'Other possible diseases': 'Iba pang posibleng sakit',
  'Unclear': 'Hindi malinaw',
  'Unidentified': 'Hindi nakilala',
  'Cell analysis failed': 'Nabigo ang pagsusuri sa cell',
  'This cell could not be analyzed reliably. Please rescan it with steady focus and good lighting.':
      'Hindi masuri nang maaasahan ang cell na ito. I-scan itong muli nang hindi gumagalaw ang camera at may sapat na liwanag.',
  'None identified': 'Walang nakilala',
  'Tile disregarded': 'Hindi isinama ang tile',
  'No recognizable plant material was found in this tile, so it was excluded from the grid results and will not be saved.':
      'Walang makilalang bahagi ng halaman sa tile na ito kaya hindi ito isinama sa resulta ng grid at hindi ise-save.',
  'Not confirmed': 'Hindi nakumpirma',
  'None recorded': 'Walang naitala',
  'A supported plant could not be confirmed in this tile. It was excluded from the grid results and will not be saved.':
      'Hindi nakumpirma ang suportadong halaman sa tile na ito. Hindi ito isinama sa resulta ng grid at hindi ise-save.',
  'The model recognized chewing, scarring, holes, or other visible patterns consistent with insect feeding.':
      'Nakilala ng modelo ang mga marka ng kagat, peklat, butas, o iba pang nakikitang padron na tugma sa pagkain ng insekto.',
  'Seasonal outlook': 'Pana-panahong pananaw',
  'Choose your area': 'Piliin ang lugar mo',
  'Growing site: cool upland': 'Lugar na tinataniman: malamig na kabundukan',
  'Growing site: warm / lowland': 'Lugar na tinataniman: mainit / mababang lugar',
  'Seasonal guidance uses typical rainfall, not live weather or a measured chance of infection. Local field conditions can differ.':
      'Gumagamit ang pana-panahong gabay ng karaniwang dami ng ulan, hindi ng kasalukuyang lagay ng panahon o nasukat na posibilidad ng impeksyon. Maaaring magkaiba ang aktuwal na kondisyon sa bukid.',
  'Choose area & month': 'Pumili ng lugar at buwan',
  'Change area & month': 'Palitan ang lugar at buwan',
  'Choose a nearby station with a similar climate. A station does not represent every farm in its province. If none fits, use local advice.':
      'Pumili ng malapit na istasyon na kahawig ang klima. Hindi nito kinakatawan ang lahat ng bukid sa lalawigan. Kung walang angkop, sumangguni sa lokal na eksperto.',
  'Use your farm conditions; relevant to late blight and hot-weather mite pressure.':
      'Gamitin ang kondisyon sa bukid mo; mahalaga ito sa late blight at panganib ng mite sa mainit na panahon.',
  'Reviewed 9 September 2026. Each note explains what the reference supports.':
      'Sinuri noong Setyembre 9, 2026. Ipinapaliwanag ng bawat tala kung ano ang sinusuportahan ng sanggunian.',
  'Could not open the reference. Copy its link to use in a browser.':
      'Hindi mabuksan ang sanggunian. Kopyahin ang link nito at buksan sa browser.',
  'Enter the crop location.': 'Ilagay ang lokasyon ng pananim.',
  'Create or replace': 'Gumawa o palitan',
  'in Downloads/': 'sa Downloads/',
  'dates, saved images, and report settings.':
      'mga petsa, naka-save na larawan, at mga setting ng ulat.',
  'Page': 'Pahina',
};

String localizeCopy(material.BuildContext context, String source) {
  return material.Localizations.localeOf(context).languageCode == 'tl'
      ? translateToTagalog(source)
      : source;
}

String translateToTagalog(String source) => _translate(source);

String _translate(String source) {
  final direct = _tagalogNormalized[source.toLowerCase()];
  if (direct != null) return direct;

  final today = RegExp(r'^Today, (.+)$').firstMatch(source);
  if (today != null) return 'Ngayon, ${today.group(1)}';
  final yesterday = RegExp(r'^Yesterday, (.+)$').firstMatch(source);
  if (yesterday != null) return 'Kahapon, ${yesterday.group(1)}';
  final datedScan = RegExp(
    r'^(Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec) (\d+)(, \d{4})?, (.+)$',
  ).firstMatch(source);
  if (datedScan != null) {
    final month = _tagalogNormalized[datedScan.group(1)!.toLowerCase()];
    return '$month ${datedScan.group(2)}${datedScan.group(3) ?? ''}, ${datedScan.group(4)}';
  }

  final pageMatch = RegExp(r'^Page (\d+) of (\d+)$').firstMatch(source);
  if (pageMatch != null) {
    return 'Pahina ${pageMatch.group(1)} sa ${pageMatch.group(2)}';
  }
  final locationMatch = RegExp(r'^Location: (.+)$').firstMatch(source);
  if (locationMatch != null) return 'Lokasyon: ${locationMatch.group(1)}';
  final dateMatch = RegExp(r'^Scouted date: (.+)$').firstMatch(source);
  if (dateMatch != null) return 'Petsa ng pagsusuri: ${dateMatch.group(1)}';
  final scouterMatch = RegExp(r'^Scouted by: (.+)$').firstMatch(source);
  if (scouterMatch != null) return 'Sinuri ni: ${scouterMatch.group(1)}';
  final pdfPathMatch = RegExp(r'^PDF saved to (.+)$').firstMatch(source);
  if (pdfPathMatch != null)
    return 'Na-save ang PDF sa ${pdfPathMatch.group(1)}';
  final attachmentMatch = RegExp(r'^(\d+)\. (.+) - (.+)$').firstMatch(source);
  if (attachmentMatch != null) {
    return '${attachmentMatch.group(1)}. ${_translate(attachmentMatch.group(2)!)} - ${_translate(attachmentMatch.group(3)!)}';
  }
  final reportSubject = RegExp(
    r'^Crop scouting report for (.+)$',
  ).firstMatch(source);
  if (reportSubject != null) {
    return 'Ulat sa pagsusuri ng pananim para sa ${reportSubject.group(1)}';
  }
  final numberedStep = RegExp(r'^(\d+)\. (.+)$').firstMatch(source);
  if (numberedStep != null) {
    return '${numberedStep.group(1)}. ${_translate(numberedStep.group(2)!)}';
  }
  final lowConfidence = RegExp(
    r'^This may not be a supported plant, or the photo may be unclear\. The classifier confidence was ([\d.]+%)\. Please scan again or take a clear picture\.$',
  ).firstMatch(source);
  if (lowConfidence != null) {
    return 'Maaaring hindi suportadong halaman ito o malabo ang larawan. ${lowConfidence.group(1)} ang katiyakan ng classifier. Mag-scan muli o kumuha ng malinaw na larawan.';
  }
  final detailedAdvice = RegExp(
    r'^Detailed treatment guidance for (.+) is not yet included\. Confirm this result with a qualified crop specialist before applying treatment\.$',
  ).firstMatch(source);
  if (detailedAdvice != null) {
    return 'Hindi pa kasama ang detalyadong gabay sa paggamot para sa ${_translate(detailedAdvice.group(1)!)}. Kumpirmahin ang resultang ito sa kwalipikadong espesyalista sa pananim bago magpagamot.';
  }
  final debugLabel = RegExp(r'^(.+):\s+$').firstMatch(source);
  if (debugLabel != null) return '${_translate(debugLabel.group(1)!)}:  ';
  final scoutedDate = RegExp(r'^Scouted date: (.+)$').firstMatch(source);
  if (scoutedDate != null) {
    return 'Petsa ng pagsusuri: ${scoutedDate.group(1)}';
  }
  final scoutedBy = RegExp(r'^Scouted by: (.+)$').firstMatch(source);
  if (scoutedBy != null) return 'Sinuri ni: ${scoutedBy.group(1)}';
  final location = RegExp(r'^Location: (.+)$').firstMatch(source);
  if (location != null) return 'Lokasyon: ${location.group(1)}';
  final pdfSaved = RegExp(r'^PDF saved to (.+)$').firstMatch(source);
  if (pdfSaved != null) return 'Na-save ang PDF sa ${pdfSaved.group(1)}';

  final combinedLabel = source.split(' — ');
  if (combinedLabel.length == 2) {
    return '${_translate(combinedLabel.first)} — ${_translate(combinedLabel.last)}';
  }
  final bulletParts = source.split(' • ');
  if (bulletParts.length == 2) {
    final month = _tagalogNormalized[bulletParts.first.toLowerCase()];
    if (month != null) return '$month • ${bulletParts.last}';
  }

  final cropCare = RegExp(
    r'^(Banana|Pineapple|Lettuce|Tomato) care$',
  ).firstMatch(source);
  if (cropCare != null) {
    return 'Pangangalaga sa ${_translate(cropCare.group(1)!)}';
  }

  final guideCount = RegExp(
    r'^(\d+) disease or pest guides • Healthy crop care$',
  ).firstMatch(source);
  if (guideCount != null) {
    return '${guideCount.group(1)} gabay sa sakit o peste • Pangangalaga sa malusog na pananim';
  }

  final contextLabel = RegExp(
    r'^(.+) - (.+?)(?: - Cell (\d+))?$',
  ).firstMatch(source);
  if (contextLabel != null) {
    final cell = contextLabel.group(3);
    return '${_translate(contextLabel.group(1)!)} - ${_translate(contextLabel.group(2)!)}${cell == null ? '' : ' - Cell $cell'}';
  }

  final cameraMatch = RegExp(
    r'^Camera failed to start: (.+)$',
  ).firstMatch(source);
  if (cameraMatch != null) {
    return 'Hindi ma-start ang camera: ${cameraMatch.group(1)}';
  }

  final restoreMatch = RegExp(
    r'^Restoring (.+) will replace the scan history and report settings currently on this device\. This cannot be undone\.$',
  ).firstMatch(source);
  if (restoreMatch != null) {
    return 'Kapag ibinalik ang ${restoreMatch.group(1)}, mapapalitan ang kasaysayan ng scan at mga setting ng ulat sa device na ito. Hindi na ito maibabalik.';
  }

  final progressMatch = RegExp(
    r'^Analyzing cell (\d+) of (\d+)…$',
  ).firstMatch(source);
  if (progressMatch != null) {
    return 'Sinusuri ang cell ${progressMatch.group(1)} sa ${progressMatch.group(2)}…';
  }

  final deleteMatch = RegExp(
    r'^Delete (\d+) (record|records)\?$',
  ).firstMatch(source);
  if (deleteMatch != null) {
    final count = deleteMatch.group(1);
    return 'Burahin ang $count ${count == '1' ? 'tala' : 'mga tala'}?';
  }
  final deletedMatch = RegExp(
    r'^(\d+) (record|records) deleted$',
  ).firstMatch(source);
  if (deletedMatch != null) {
    final count = deletedMatch.group(1);
    return 'Nabura ang $count ${count == '1' ? 'tala' : 'mga tala'}';
  }
  final deleteChip = RegExp(r'^Delete \((\d+)\)$').firstMatch(source);
  if (deleteChip != null) return 'Burahin (${deleteChip.group(1)})';
  final selectionCount = RegExp(r'^(\d+) selected$').firstMatch(source);
  if (selectionCount != null) return 'Napili: ${selectionCount.group(1)}';
  final sourceCount = RegExp(r'^Sources \((\d+)\)$').firstMatch(source);
  if (sourceCount != null) return 'Mga sanggunian (${sourceCount.group(1)})';
  final emptyFilter = RegExp(r'^No (.+) scans$').firstMatch(source);
  if (emptyFilter != null) {
    return 'Walang scan sa kategoryang ${_translate(emptyFilter.group(1)!)}';
  }
  final cellLabel = RegExp(r'^Cell (\d+)$').firstMatch(source);
  if (cellLabel != null) return 'Cell ${cellLabel.group(1)}';
  final backupDescription = RegExp(
    r'^Create or replace (.+) in Downloads/(.+)\.$',
  ).firstMatch(source);
  if (backupDescription != null) {
    return 'Gumawa o palitan ang ${backupDescription.group(1)} sa Downloads/${backupDescription.group(2)}.';
  }
  final rainfall = RegExp(
    r'^(.+) • ([\d.]+) mm typical rainfall$',
  ).firstMatch(source);
  if (rainfall != null) {
    return '${_translate(rainfall.group(1)!)} • ${rainfall.group(2)} mm ang karaniwang ulan';
  }
  final selectedHealthy = RegExp(r'^Healthy (\d+)$').firstMatch(source);
  if (selectedHealthy != null) return 'Malusog ${selectedHealthy.group(1)}';
  final selectedAffected = RegExp(
    r'^Affected (\d+) \((\d+%)\)$',
  ).firstMatch(source);
  if (selectedAffected != null) {
    return 'Apektado ${selectedAffected.group(1)} (${selectedAffected.group(2)})';
  }
  final percentHealthy = RegExp(r'^(\d+)% healthy$').firstMatch(source);
  if (percentHealthy != null) return '${percentHealthy.group(1)}% malusog';
  final percentShare = RegExp(r'^(\d+)% of selected scans$').firstMatch(source);
  if (percentShare != null) {
    return '${percentShare.group(1)}% ng mga napiling scan';
  }
  final sourceDate = RegExp(r'^Reviewed (.+)\. Each note (.+)$')
      .firstMatch(source);
  if (sourceDate != null) {
    return 'Sinuri noong ${sourceDate.group(1)}. Ipinapaliwanag ng bawat tala kung ano ang sinusuportahan ng sanggunian.';
  }

  const prefixes = <String, String>{
    'Backup saved to ': 'Na-save ang backup sa ',
    'Could not save backup: ': 'Hindi ma-save ang backup: ',
    'Could not restore backup: ': 'Hindi maibalik ang backup: ',
    'Could not export the PDF: ': 'Hindi ma-export ang PDF: ',
    'Capture failed: ': 'Hindi makuha ang larawan: ',
    'On Android, reports are saved automatically in Downloads/':
        'Sa Android, awtomatikong sine-save ang mga ulat sa Downloads/',
    'Camera failed to start: ': 'Hindi ma-start ang camera: ',
    'Crop scouting report for ': 'Ulat sa pagsusuri ng pananim para sa ',
  };
  for (final entry in prefixes.entries) {
    if (source.startsWith(entry.key)) {
      return '${entry.value}${source.substring(entry.key.length)}';
    }
  }
  return source;
}

final Map<String, String> _tagalogNormalized = {
  for (final entry in _tagalog.entries) entry.key.toLowerCase(): entry.value,
};
