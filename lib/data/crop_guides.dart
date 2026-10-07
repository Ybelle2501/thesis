import '../models/crop_guide.dart';

// Reviewed 2026-09-28. The raw labels must match assets/labels.json.
const guideSources = <String, GuideSource>{
  "ph_tomato": GuideSource(
    id: "ph_tomato",
    title: "Long-Term Harvesting of Tomato and Sweet Pepper (2026)",
    publisher: "DA / JICA / ATI Cordillera",
    url:
        "https://ati2.da.gov.ph/ati-car/content/sites/default/files/2026-01/DA%20%26%20JICA%20MV2C%20Training%20Module%20on%20Long%20Term%20Harvesting%20of%20Tomato%20and%20Sweet%20Pepper%20%28for%20online%20upload%20in%20web%29_1.pdf",
    scope: "Philippine extension",
    note:
        "Lessons 7–8, printed pp. 107–139: diagnosis, sanitation, environmental conditions and pest management. Local guidance, not a validated seasonal probability model.",
  ),
  "ph_banana": GuideSource(
    id: "ph_banana",
    title: "Philippine Banana Industry Roadmap 2021–2025",
    publisher: "Department of Agriculture",
    url:
        "https://www.da.gov.ph/wp-content/uploads/2023/05/Philippine-Banana-Industry-Roadmap.pdf",
    scope: "Philippine extension",
    note:
        "Printed pp. 16–19: banana diseases; Sigatoka sanitation, spacing and drainage.",
  ),
  "ph_sigatoka": GuideSource(
    id: "ph_sigatoka",
    title: "Banana Production Manual",
    publisher: "DA High Value Crops Development Program",
    url:
        "https://hvcdp.da.gov.ph/wp-content/uploads/2022/05/Banana-Production-Manual.pdf",
    scope: "Philippine extension",
    note:
        "Leaf and fruit diseases: Sigatoka, removal of infected leaves and drainage to reduce humidity.",
  ),
  "ph_panama": GuideSource(
    id: "ph_panama",
    title: "ACIAR–PCAARRD project: management of banana Fusarium wilt (2016)",
    publisher: "DOST-PCAARRD",
    url:
        "https://www.pcaarrd.dost.gov.ph/index.php/quick-information-dispatch-qid-articles/aciar-pcaarrd-project-provides-options-for-management-of-banana-fusarium-wilt",
    scope: "Philippine field research",
    note:
        "Davao del Norte: soil movement and cultivar response; biological products did not consistently reduce infection.",
  ),
  "ph_banana_gap": GuideSource(
    id: "ph_banana_gap",
    title:
        "Good agricultural practices reduce banana pests and diseases (2017)",
    publisher: "DOST-PCAARRD",
    url:
        "https://www.pcaarrd.dost.gov.ph/index.php/quick-information-dispatch-qid-articles/good-agricultural-practices-gap-reduces-pests-and-diseases-of-lakatan-and-cardaba",
    scope: "Philippine field research",
    note:
        "Region XII trials support sanitation, appropriate nutrition and other integrated cultural practices; not a Cordana-specific trial.",
  ),
  "cordana": GuideSource(
    id: "cordana",
    title: "Banana diamond leaf spot, fact sheet 072",
    publisher:
        "Pacific Pests, Pathogens, Weeds & Pesticides / ACIAR-supported project",
    url:
        "https://apps.lucidcentral.org/pppw_v13/text/web_full/entities/banana_diamond_leaf_spot_072.htm",
    scope: "International extension",
    note:
        "Cordana-specific symptoms and management. No Philippine seasonal calibration; routine fungicide treatment is usually unnecessary.",
  ),
  "ph_pineapple": GuideSource(
    id: "ph_pineapple",
    title: "Pineapple Production Technoguide (2024)",
    publisher: "Philippine Fiber Industry Development Authority",
    url:
        "https://philfida.da.gov.ph/images/Publications/Technoguides/pineapple-technoguide-2024.pdf",
    scope: "Philippine extension",
    note:
        "Philippine production, drainage, field sanitation and mealybug-wilt identification and control guidance.",
  ),
  "ph_pineapple_research": GuideSource(
    id: "ph_pineapple_research",
    title: "Biocontrol agents against Queen pineapple pests (2020)",
    publisher: "DOST-PCAARRD",
    url:
        "https://pcaarrd.dost.gov.ph/index.php/quick-information-dispatch-qid-articles/dost-project-identified-potential-biocontrol-agents-against-queen-pineapple-pests",
    scope: "Philippine field research",
    note:
        "Leyte and Camarines Norte work identifies pink pineapple mealybug, wilt risk and major Queen pineapple diseases.",
  ),
  "uf_pineapple_mealybug": GuideSource(
    id: "uf_pineapple_mealybug",
    title: "Pineapple Mealybug",
    publisher: "University of Florida IFAS",
    url: "https://ask.ifas.ufl.edu/publication/IN1106",
    scope: "International extension",
    note:
        "Mealybug-wilt symptoms, infected-material removal, weed sanitation and ant management; use only locally registered products.",
  ),
  "mx_pineapple_fusarium": GuideSource(
    id: "mx_pineapple_fusarium",
    title: "Pineapple fusariosis: Fusarium guttiforme (2025)",
    publisher: "SENASICA, Government of Mexico",
    url:
        "https://www.gob.mx/senasica/documentos/fusariosis-de-la-pina-fusarium-guttiforme",
    scope: "International plant-health authority",
    note:
        "Technical identification reference for pineapple fusariosis; occurrence and management must be confirmed locally.",
  ),
  "uf_pineapple": GuideSource(
    id: "uf_pineapple",
    title: "Pineapple Growing in the Florida Home Landscape",
    publisher: "University of Florida IFAS",
    url: "https://ask.ifas.ufl.edu/publication/MG055",
    scope: "International extension",
    note:
        "Clean planting material, drainage, moisture management and inspection for pineapple pests and rots.",
  ),
  "ph_lettuce": GuideSource(
    id: "ph_lettuce",
    title: "Lettuce Production for Urban and Home Gardening (2020)",
    publisher: "ATI Cordillera",
    url:
        "https://ati2.da.gov.ph/ati-car/content/sites/default/files/2022-12/urban_agriculture_for_upland.pdf",
    scope: "Philippine extension",
    note:
        "Lettuce fungal rot: spacing, sunlight, aerated growing media and avoiding waterlogging.",
  ),
  "ph_lettuce_rot": GuideSource(
    id: "ph_lettuce_rot",
    title: "Gabay sa Produksyon ng Letsugas",
    publisher: "ATI Mimaropa",
    url:
        "https://ati2.da.gov.ph/ati-4b/content/sites/default/files/2022-12/lettuce_final.pdf",
    scope: "Philippine extension",
    note:
        "Bacterial rot prevention using mulch and bed preparation. Broad bacterial labels still need diagnosis.",
  ),
  "ph_lettuce_season": GuideSource(
    id: "ph_lettuce_season",
    title: "Romaine lettuce production in Bauko (2024)",
    publisher: "ATI Cordillera",
    url:
        "https://ati2.da.gov.ph/ati-car/content/features/green-romance-romaine-lettuce-production-cloud-capped-mountains-bauko",
    scope: "Philippine field observations",
    note:
        "Bauko demonstration reported greater soft-rot severity in the wet season. Applies to observed soft rot, not every bacterial lettuce disease.",
  ),
  "ph_leafcurl": GuideSource(
    id: "ph_leafcurl",
    title:
        "Weather-based tomato leaf-curl forecasting in Northern Mindanao (2020)",
    publisher: "Borja, Pangga, Sta. Cruz & Sta. Cruz / UPLB repository",
    url: "https://www.ukdr.uplb.edu.ph/journal-articles/154/",
    scope: "Philippine field research",
    note:
        "Malaybalay and Claveria trials in 2018. Weather relationships varied by site/season; models used weather and whitefly counts, not month alone.",
  ),
  "ph_icm": GuideSource(
    id: "ph_icm",
    title:
        "Integrated crop management: vegetables in the southern Philippines (2018)",
    publisher: "ACIAR / Visayas State University and partners",
    url:
        "https://www.aciar.gov.au/sites/default/files/project-page-docs/final_report_hort.2012.020.pdf",
    scope: "Philippine field research",
    note:
        "Printed pp. 30–34, 41–42, 75: disease inventory and protected cropping. Leaf mould in the inventory is Pseudocercospora, not necessarily the model's Passalora class.",
  ),
  "uc_early": GuideSource(
    id: "uc_early",
    title: "Early Blight on Tomatoes",
    publisher: "University of California IPM",
    url: "https://ipm.ucanr.edu/home-and-landscape/early-blight-on-tomatoes/",
    scope: "International extension",
    note:
        "Early-blight symptoms, avoiding overhead irrigation and crop rotation.",
  ),
  "uf_early": GuideSource(
    id: "uf_early",
    title: "Common Tomato High-Tunnel Production Diseases",
    publisher: "University of Florida IFAS",
    url: "https://edis.ifas.ufl.edu/pp368",
    scope: "International extension",
    note: "Early blight: sanitation, staking, mulch and clean pruning tools.",
  ),
  "uc_late": GuideSource(
    id: "uc_late",
    title: "Late Blight of Tomato",
    publisher: "University of California IPM",
    url: "https://ipm.ucanr.edu/agriculture/tomato/late-blight/",
    scope: "International extension",
    note:
        "Rapid spread under moist conditions; healthy transplants, volunteer removal and appropriate disease-specific protection.",
  ),
  "umn_mold": GuideSource(
    id: "umn_mold",
    title: "Tomato leaf mold",
    publisher: "University of Minnesota Extension",
    url:
        "https://extension.umn.edu/agriculture/specialty-crops/vegetable-farming/disease-management/tomato-leaf-mold",
    scope: "International extension",
    note:
        "Passalora fulva: humidity, ventilation, drip irrigation, sanitation and locally evaluated resistance.",
  ),
  "uc_leafcurl": GuideSource(
    id: "uc_leafcurl",
    title: "Tomato Yellow Leaf Curl",
    publisher: "University of California IPM",
    url: "https://ipm.ucanr.edu/agriculture/tomato/tomato-yellow-leaf-curl/",
    scope: "International extension",
    note:
        "Resistant varieties, whitefly exclusion, clean transplants and early roguing.",
  ),
  "pagasa": GuideSource(
    id: "pagasa",
    title: "Climatological normals: monthly station rainfall",
    publisher: "DOST-PAGASA",
    url: "https://pagasa.dost.gov.ph/climate/climatological-normals",
    scope: "Philippine climate observations",
    note:
        "Thirty-year averages, not live weather. The station table does not identify its baseline years; these values are retained as published on 9 September 2026.",
  ),
  "fpa": GuideSource(
    id: "fpa",
    title: "Registered pesticide products",
    publisher: "Fertilizer and Pesticide Authority",
    url: "https://fpa.da.gov.ph/resources/reports/registered-products/",
    scope: "Philippine regulator",
    note:
        "Use the current product registration and crop/pest label when selecting pesticides.",
  ),
  "uc_lettuce": GuideSource(
    id: "uc_lettuce",
    title: "Bacterial Leaf Spot of Lettuce",
    publisher: "University of California IPM",
    url: "https://ipm.ucanr.edu/agriculture/lettuce/bacterial-leaf-spot/",
    scope: "International extension",
    note:
        "Bacterial leaf spot differs from soft rot; seed health, moisture and sanitation guidance.",
  ),
  "ph_tomato_production": GuideSource(
    id: "ph_tomato_production",
    title: "Tomato Production Guide",
    publisher: "DA Cagayan Valley",
    url:
        "https://cagayanvalley.da.gov.ph/wp-content/uploads/2018/02/Tomato.pdf",
    scope: "Philippine extension",
    note:
        "Lists tomato leaf miner and other insect pests and recommends resistance, sanitation, rotation and need-based label-compliant control.",
  ),
  "uc_leafminer": GuideSource(
    id: "uc_leafminer",
    title: "Leafminers in Tomato",
    publisher: "University of California IPM",
    url: "https://ipm.ucanr.edu/agriculture/tomato/leafminers/",
    scope: "International extension",
    note:
        "Identification, transplant inspection, monitoring and conservation of parasitoids; California treatment thresholds are not imported.",
  ),
};

const cropGuides = <CropGuide>[
  CropGuide(
    rawLabel: "banana_cordana",
    crop: Crop.banana,
    name: "Cordana leaf spot",
    category: "Fungal leaf spot",
    summary:
        "Diamond-shaped lesions can resemble other banana leaf spots. Confirm extensive damage; mild Cordana usually needs monitoring rather than a fungicide.",
    healthy: false,
    treatment: [
      GuidanceStep(
        "Check the pattern",
        "Inspect both leaf surfaces and photograph lesion edges. Seek crop-specialist confirmation when streaks, rapid yellowing or extensive leaf death occur.",
        ["cordana"],
      ),
      GuidanceStep(
        "Protect useful foliage",
        "Retain functioning leaves. Review general banana sanitation with your agricultural technician; avoid unnecessary cutting and injury.",
        ["cordana", "ph_banana_gap"],
      ),
      GuidanceStep(
        "Avoid unnecessary spraying",
        "A Cordana-specific fungicide is usually not justified for mild damage. Do not apply a Sigatoka spray programme solely on this label.",
        ["cordana"],
      ),
      GuidanceStep(
        "Follow new growth",
        "Mark affected plants and compare new leaves at subsequent inspections. Escalate if damage spreads or bunch development declines.",
        ["cordana"],
      ),
    ],
    prevention: [
      GuidanceStep(
        "Keep plants vigorous",
        "Use soil-test-based nutrition and maintain banana mat sanitation.",
        ["ph_banana_gap"],
      ),
      GuidanceStep(
        "Limit leaf injury",
        "Handle plants carefully and check coexisting leaf diseases that can provide infection sites.",
        ["cordana"],
      ),
      GuidanceStep(
        "Inspect after wet weather",
        "Look for new lesions following wet, windy conditions; avoid assuming every spot is Cordana.",
        ["cordana"],
      ),
    ],
    seasonalPattern: SeasonalPattern.insufficient,
    seasonalEvidence:
        "Pacific guidance describes spread in wet, windy weather. A Philippine Cordana seasonal relationship has not been established by the sources used here.",
    seasonalSourceIds: ["cordana", "ph_banana_gap"],
  ),
  CropGuide(
    rawLabel: "banana_panama_wilt",
    crop: Crop.banana,
    name: "Panama wilt",
    category: "Soilborne wilt",
    summary:
        "Suspected Fusarium wilt needs prompt confirmation. Containment and clean planting material are central; a leaf photo cannot identify the Fusarium race.",
    healthy: false,
    treatment: [
      GuidanceStep(
        "Restrict movement",
        "Mark the affected mat and stop moving suckers, soil and soil-contaminated equipment from it. Contact the municipal agriculturist or DA crop-protection office.",
        ["ph_panama"],
      ),
      GuidanceStep(
        "Confirm before removal",
        "Arrange diagnosis and a supervised containment/removal plan. Avoid dragging infected material through clean parts of the farm.",
        ["ph_panama"],
      ),
      GuidanceStep(
        "Protect clean areas",
        "Remove adhering soil from equipment before cleaning and disinfection. Manage access so dirty footwear and tools do not enter unaffected blocks.",
        ["ph_panama"],
      ),
      GuidanceStep(
        "Plan rehabilitation",
        "Discuss verified clean planting material and locally suitable tolerant cultivars. Do not rely on a biological product as a guaranteed cure.",
        ["ph_panama"],
      ),
    ],
    prevention: [
      GuidanceStep(
        "Start clean",
        "Obtain healthy planting material from a reliable nursery; avoid suckers from wilt-affected farms.",
        ["ph_banana"],
      ),
      GuidanceStep(
        "Control soil transfer",
        "Keep farm equipment and footwear free of contaminated soil; separate clean and affected blocks.",
        ["ph_panama"],
      ),
      GuidanceStep(
        "Track affected mats",
        "Keep a farm map and consult the DA before replanting an affected site.",
        ["ph_panama"],
      ),
    ],
    seasonalPattern: SeasonalPattern.yearRound,
    seasonalEvidence:
        "Philippine research emphasizes contaminated soil and cultivar susceptibility. Month alone cannot determine exposure; maintain containment throughout the year.",
    seasonalSourceIds: ["ph_panama"],
  ),
  CropGuide(
    rawLabel: "banana_sigatoka",
    crop: Crop.banana,
    name: "Sigatoka leaf spot",
    category: "Fungal leaf disease",
    summary:
        "The model groups Sigatoka symptoms; it does not distinguish yellow from black Sigatoka. Confirm the diagnosis before planning chemical control.",
    healthy: false,
    treatment: [
      GuidanceStep(
        "Inspect the canopy",
        "Check the undersides of leaves for streaks and assess how much functional foliage remains.",
        ["ph_banana"],
      ),
      GuidanceStep(
        "Reduce infected tissue",
        "Remove badly affected leaves with advice on retaining adequate healthy foliage. Keep cut material away from clean planting stock.",
        ["ph_sigatoka"],
      ),
      GuidanceStep(
        "Reduce humidity",
        "Clear blocked drains and overcrowded growth around banana mats. Correct nutrition using soil-test advice.",
        ["ph_sigatoka"],
      ),
      GuidanceStep(
        "Review control needs",
        "If new leaves continue to deteriorate, ask a crop-protection technician for a registered fungicide programme and resistance-management plan.",
        ["ph_banana"],
      ),
    ],
    prevention: [
      GuidanceStep(
        "Space banana mats",
        "Maintain recommended mat spacing and manage excess suckers to improve airflow.",
        ["ph_banana"],
      ),
      GuidanceStep(
        "Maintain drainage",
        "Avoid persistent waterlogging and humidity around plants, especially during wetter months.",
        ["ph_sigatoka"],
      ),
      GuidanceStep(
        "Scout regularly",
        "Combine inspections, sanitation and appropriate nutrition; check the next emerging leaves after intervention.",
        ["ph_banana_gap"],
      ),
    ],
    seasonalPattern: SeasonalPattern.wet,
    seasonalEvidence:
        "DA banana guidance links excess moisture and humidity with disease development. Wetter-month flags are a scouting inference, not measured infection probabilities.",
    seasonalSourceIds: ["ph_sigatoka", "pagasa"],
  ),
  CropGuide(
    rawLabel: "Pineapple_fusarium",
    crop: Crop.pineapple,
    name: "Fusarium symptoms",
    category: "Fungal disease; confirm the cause",
    summary:
        "The model class is broad. Fusarium can affect pineapple fruit or planting material, but similar discoloration and rot require field or laboratory confirmation.",
    healthy: false,
    treatment: [
      GuidanceStep(
        "Confirm the diagnosis",
        "Inspect leaves, stem, planting material and fruit for lesions, internal discoloration or gum. Ask a plant-health technician to confirm Fusarium before treatment.",
        ["mx_pineapple_fusarium", "ph_pineapple"],
      ),
      GuidanceStep(
        "Isolate affected material",
        "Mark suspect plants and keep affected slips, fruit and crop debris out of clean planting-material lots while the cause is checked.",
        ["mx_pineapple_fusarium"],
      ),
      GuidanceStep(
        "Remove confirmed sources",
        "Remove confirmed diseased material using local disposal advice and clean tools before moving to healthy rows.",
        ["ph_pineapple", "mx_pineapple_fusarium"],
      ),
      GuidanceStep(
        "Use only matched products",
        "If Fusarium is confirmed and chemical protection is justified, use only an FPA-registered pineapple product for the diagnosed target and follow its current label.",
        ["fpa"],
      ),
    ],
    prevention: [
      GuidanceStep(
        "Use clean planting material",
        "Select healthy crowns, slips or suckers and reject material with rot, lesions or abnormal gum exudation.",
        ["ph_pineapple", "mx_pineapple_fusarium"],
      ),
      GuidanceStep(
        "Sanitize field operations",
        "Clean cutting and harvest tools and avoid moving contaminated plant debris into clean blocks.",
        ["ph_pineapple"],
      ),
      GuidanceStep(
        "Reduce wounds and inspect",
        "Limit avoidable injury to planting material and fruit, and inspect routinely so suspect material is removed early.",
        ["mx_pineapple_fusarium", "ph_pineapple"],
      ),
    ],
    seasonalPattern: SeasonalPattern.insufficient,
    seasonalEvidence:
        "The supplied class does not identify the Fusarium species or affected tissue. No validated Philippine month-based risk rule was found, so diagnosis and field scouting take priority.",
    seasonalSourceIds: ["ph_pineapple", "mx_pineapple_fusarium"],
  ),
  CropGuide(
    rawLabel: "Pineapple_leaf_blight",
    crop: Crop.pineapple,
    name: "Leaf blight",
    category: "Blight symptoms; confirm the cause",
    summary:
        "Leaf blight describes damaged tissue, not a confirmed organism. Rots, fungi, water stress and injury can overlap in appearance.",
    healthy: false,
    treatment: [
      GuidanceStep(
        "Check the whole plant",
        "Inspect the heart, leaf bases, roots and drainage as well as blighted leaf tips. Submit expanding or water-soaked damage for diagnosis.",
        ["uf_pineapple", "ph_pineapple"],
      ),
      GuidanceStep(
        "Correct excess moisture",
        "Improve drainage and avoid prolonged waterlogging or water collecting in the plant heart.",
        ["uf_pineapple", "ph_pineapple"],
      ),
      GuidanceStep(
        "Contain severe damage",
        "Mark affected plants and remove badly rotted material according to local sanitation advice; clean tools between suspect and healthy plants.",
        ["ph_pineapple"],
      ),
      GuidanceStep(
        "Match control to the cause",
        "Do not assume every blight is fungal. Use an FPA-registered product only after the target is identified and pineapple is on the label.",
        ["fpa"],
      ),
    ],
    prevention: [
      GuidanceStep(
        "Plant healthy material",
        "Inspect crowns, slips and suckers and reject material showing rot, blight or pest injury.",
        ["ph_pineapple", "uf_pineapple"],
      ),
      GuidanceStep(
        "Maintain drainage",
        "Use well-drained ground and avoid irrigation practices that keep the crown and leaf bases continuously wet.",
        ["ph_pineapple", "uf_pineapple"],
      ),
      GuidanceStep(
        "Inspect after wet periods",
        "Scout low areas and check new leaves after prolonged rain; remove accumulating diseased debris from the field.",
        ["ph_pineapple"],
      ),
    ],
    seasonalPattern: SeasonalPattern.insufficient,
    seasonalEvidence:
        "Wet conditions can favor several pineapple rots, but this broad image class does not identify a pathogen. The reviewed sources do not support a Philippine calendar prediction.",
    seasonalSourceIds: ["ph_pineapple", "uf_pineapple"],
  ),
  CropGuide(
    rawLabel: "Pineapple_mealybug_wilt",
    crop: Crop.pineapple,
    name: "Mealybug wilt",
    category: "Virus-vector disease complex",
    summary:
        "Pineapple mealybugs transmit wilt-associated viruses. Treating a wilted plant does not reverse viral infection; management focuses on confirming mealybugs and protecting healthy plants.",
    healthy: false,
    treatment: [
      GuidanceStep(
        "Verify symptoms and vectors",
        "Inspect leaf bases and roots for mealybugs and ants, and check nearby plants for reddening, inward leaf curling and loss of rigidity.",
        ["ph_pineapple", "uf_pineapple_mealybug"],
      ),
      GuidanceStep(
        "Contain affected plants",
        "Remove confirmed severely affected plants and their residue using local disposal advice; do not reuse infested planting material.",
        ["uf_pineapple_mealybug"],
      ),
      GuidanceStep(
        "Manage ants and mealybugs",
        "Reduce weeds and debris that shelter ants or mealybugs and use an integrated ant-and-mealybug plan to protect healthy plants.",
        ["ph_pineapple", "uf_pineapple_mealybug"],
      ),
      GuidanceStep(
        "Select control locally",
        "If monitoring justifies pesticide use, ask the agricultural technician for an FPA-registered pineapple/mealybug product and protect natural enemies.",
        ["fpa", "ph_pineapple_research"],
      ),
    ],
    prevention: [
      GuidanceStep(
        "Start mealybug-free",
        "Use clean planting material and inspect leaf bases and roots before moving it into a new field.",
        ["ph_pineapple", "uf_pineapple_mealybug"],
      ),
      GuidanceStep(
        "Control ant shelter",
        "Keep weeds and debris managed and monitor ant activity because ants protect mealybugs from natural enemies.",
        ["uf_pineapple_mealybug", "ph_pineapple"],
      ),
      GuidanceStep(
        "Scout neighboring plants",
        "Check adjacent rows routinely and act on new mealybug colonies before widespread wilt develops.",
        ["ph_pineapple_research", "ph_pineapple"],
      ),
    ],
    seasonalPattern: SeasonalPattern.siteDependent,
    seasonalEvidence:
        "Philippine sources establish mealybugs and wilt risk, but do not provide a validated month-only forecast. Field infestation, ants and planting material determine local risk.",
    seasonalSourceIds: ["ph_pineapple", "ph_pineapple_research"],
  ),
  CropGuide(
    rawLabel: "lettuce_Bacterial",
    crop: Crop.lettuce,
    name: "Bacterial disease",
    category: "Bacterial group",
    summary:
        "The label does not distinguish leaf spot from soft rot or wilt. Identify the cause before selecting a treatment.",
    healthy: false,
    treatment: [
      GuidanceStep(
        "Inspect and separate",
        "Check for water-soaked spots, soft tissue or wilt. Isolate affected trays and ask a technician to identify the problem.",
        ["uc_lettuce"],
      ),
      GuidanceStep(
        "Remove badly affected plants",
        "Set aside deteriorating plants and avoid spreading their wet material to healthy lettuce. Get local advice on disposal.",
        ["uc_lettuce"],
      ),
      GuidanceStep(
        "Limit leaf moisture",
        "Direct water to the growing medium and improve airflow. Avoid handling leaves while they are wet.",
        ["uc_lettuce"],
      ),
      GuidanceStep(
        "Review control options",
        "Use diagnosis to decide whether a registered product can help. Already rotted tissue cannot be restored with a spray.",
        ["uc_lettuce"],
      ),
    ],
    prevention: [
      GuidanceStep(
        "Protect the nursery",
        "Use clean planting material and inspect seedlings before transplanting.",
        ["uc_lettuce"],
      ),
      GuidanceStep(
        "Reduce soil splash",
        "Use clean mulch and prepare beds before planting; ATI Mimaropa recommends these practices for bacterial rot.",
        ["ph_lettuce_rot"],
      ),
      GuidanceStep(
        "Watch the wet season",
        "Check heads for soft rot more closely during wet periods, especially in upland production.",
        ["ph_lettuce_season"],
      ),
    ],
    seasonalPattern: SeasonalPattern.wet,
    seasonalEvidence:
        "Bauko observations reported greater wet-season soft-rot severity. This flag is a soft-rot scouting advisory; it is not validated for every disease in the bacterial class.",
    seasonalSourceIds: ["ph_lettuce_season", "pagasa"],
  ),
  CropGuide(
    rawLabel: "lettuce_fungal",
    crop: Crop.lettuce,
    name: "Fungal disease",
    category: "Fungal group",
    summary:
        "Different fungi can cause leaf lesions and rotting. This broad class needs confirmation before fungicide selection.",
    healthy: false,
    treatment: [
      GuidanceStep(
        "Check the affected tissue",
        "Inspect the base, roots and leaves and record whether damage starts in the growing medium or canopy.",
        ["ph_lettuce"],
      ),
      GuidanceStep(
        "Separate deteriorating plants",
        "Remove badly rotted plants from the growing area; keep affected material from contacting healthy lettuce.",
        ["ph_lettuce"],
      ),
      GuidanceStep(
        "Correct excess moisture",
        "Improve the growing medium's aeration and drainage. Adjust watering to avoid persistent saturation.",
        ["ph_lettuce"],
      ),
      GuidanceStep(
        "Reassess before spraying",
        "Improve spacing and sunlight exposure, then seek diagnosis if fresh plants continue to rot. Treatment depends on the fungus.",
        ["ph_lettuce"],
      ),
    ],
    prevention: [
      GuidanceStep(
        "Allow air movement",
        "Maintain proper plant distance and adequate sunlight.",
        ["ph_lettuce"],
      ),
      GuidanceStep(
        "Use a draining medium",
        "Avoid compacted soil and containers without drainage.",
        ["ph_lettuce"],
      ),
      GuidanceStep(
        "Manage water carefully",
        "Water according to crop need and check for standing water after rain.",
        ["ph_lettuce"],
      ),
    ],
    seasonalPattern: SeasonalPattern.wet,
    seasonalEvidence:
        "ATI Cordillera links lettuce fungal rot with excess moisture and waterlogging. Rainfall is only a proxy; fungal identity and growing conditions remain important.",
    seasonalSourceIds: ["ph_lettuce", "pagasa"],
  ),
  CropGuide(
    rawLabel: "tomato_early-late_blight",
    crop: Crop.tomato,
    name: "Early/late blight",
    category: "Combined blight class",
    summary:
        "The model combines early and late blight. Retain both existing management plans and confirm which disease is present because late blight is an oomycete and may spread rapidly.",
    healthy: false,
    treatment: [
      GuidanceStep(
        "Inspect lower foliage",
        "Check older leaves for ringed lesions and assess whether new leaves or stems are becoming affected.",
        ["uc_early"],
      ),
      GuidanceStep(
        "Remove infection sources",
        "Remove badly affected material without stripping the plant bare; clean pruning tools and dispose of crop residue.",
        ["uf_early"],
      ),
      GuidanceStep(
        "Keep foliage above soil",
        "Stake plants, apply clean mulch and direct irrigation to the roots to reduce splash.",
        ["uf_early"],
      ),
      GuidanceStep(
        "Protect remaining leaves",
        "If disease is advancing, discuss a registered protectant programme with the agricultural technician; monitor fresh growth after intervention.",
        ["uc_early"],
      ),
      GuidanceStep(
        "Act on rapid spread",
        "Inspect plants around the affected plant and contact a crop-protection technician promptly when lesions expand quickly.",
        ["uc_late"],
      ),
      GuidanceStep(
        "Remove late-blight sources",
        "Separate heavily affected material from the crop and remove volunteer tomatoes, potatoes and nightshade hosts nearby.",
        ["uc_late"],
      ),
      GuidanceStep(
        "Keep leaves dry",
        "Avoid sprinkler irrigation and improve canopy airflow; look for persistent wetness even under shelters.",
        ["uc_late"],
      ),
      GuidanceStep(
        "Protect unaffected growth",
        "If late blight is confirmed, ask for a locally registered late-blight programme. Products for unrelated fungi may not control this oomycete.",
        ["uc_late"],
      ),
    ],
    prevention: [
      GuidanceStep(
        "Rotate crops",
        "Avoid repeated tomato planting in infested beds; use suitable non-solanaceous crops.",
        ["uc_early"],
      ),
      GuidanceStep(
        "Reduce leaf wetness",
        "Avoid overhead watering and prune to improve airflow.",
        ["uf_early"],
      ),
      GuidanceStep(
        "Start and finish clean",
        "Use healthy seedlings and clear infected residues between crops.",
        ["ph_tomato"],
      ),
      GuidanceStep(
        "Inspect transplants",
        "Plant healthy seedlings and reject those showing suspicious lesions.",
        ["uc_late"],
      ),
      GuidanceStep(
        "Choose appropriate resistance",
        "Discuss resistant cultivars suited to locally occurring early- and late-blight pathogen populations.",
        ["uc_early", "uc_late"],
      ),
      GuidanceStep(
        "Scout cool, wet sites",
        "Scout damp upland plantings and neighboring host crops for rapidly spreading late-blight symptoms.",
        ["ph_tomato"],
      ),
    ],
    seasonalPattern: SeasonalPattern.wet,
    seasonalEvidence:
        "Early blight can be favored by warm, humid conditions while late blight is associated with cool, moist conditions. Because the model combines them, wetter months trigger added scouting but do not identify which blight is present.",
    seasonalSourceIds: ["ph_tomato", "uc_early", "uc_late", "pagasa"],
  ),
  CropGuide(
    rawLabel: "tomato_leaf_mold",
    crop: Crop.tomato,
    name: "Leaf mold",
    category: "Fungal leaf disease",
    summary:
        "The model's leaf-mold class is consistent with Passalora-type symptoms. Other local leaf molds can look similar; confirm the cause.",
    healthy: false,
    treatment: [
      GuidanceStep(
        "Check leaf undersides",
        "Look beneath yellowed areas for velvety mold and inspect neighboring plants.",
        ["umn_mold"],
      ),
      GuidanceStep(
        "Ventilate the crop",
        "Open suitable vents and increase air movement; space and prune plants to reduce trapped humidity.",
        ["umn_mold"],
      ),
      GuidanceStep(
        "Improve hygiene",
        "Remove affected crop residue and clean supports, ties and work surfaces between crops.",
        ["umn_mold"],
      ),
      GuidanceStep(
        "Review protection",
        "If new lesions continue, obtain diagnosis and local product advice. Test resistant varieties locally because resistance depends on pathogen race.",
        ["umn_mold"],
      ),
    ],
    prevention: [
      GuidanceStep(
        "Keep foliage dry",
        "Use drip or root-zone irrigation and minimize condensation inside structures.",
        ["umn_mold"],
      ),
      GuidanceStep(
        "Inspect planting stock",
        "Use healthy seedlings and clean production equipment.",
        ["ph_tomato"],
      ),
      GuidanceStep(
        "Manage sheltered humidity",
        "Maintain airflow even when rainfall is low; sheltered canopies can stay humid.",
        ["umn_mold"],
      ),
    ],
    seasonalPattern: SeasonalPattern.siteDependent,
    seasonalEvidence:
        "Philippine studies report leaf mould, but include a different organism from Passalora. Outdoor rainfall alone cannot represent greenhouse humidity; inspect conditions on site.",
    seasonalSourceIds: ["ph_icm", "umn_mold"],
  ),
  CropGuide(
    rawLabel: "tomato_insect_damage",
    crop: Crop.tomato,
    name: "Insect damage",
    category: "Broad pest class",
    summary:
        "This class recognizes visible insect-type injury but does not identify the pest. Holes, mines, stippling and sap-feeding damage require different controls.",
    healthy: false,
    treatment: [
      GuidanceStep(
        "Identify the pest",
        "Inspect both leaf surfaces, stems and fruit for live insects, eggs, frass, mines or webbing before selecting a control.",
        ["ph_tomato", "ph_tomato_production"],
      ),
      GuidanceStep(
        "Remove local sources",
        "Remove badly infested leaves or fruit when practical and clear crop residues and host weeds without over-defoliating plants.",
        ["ph_tomato", "ph_tomato_production"],
      ),
      GuidanceStep(
        "Use targeted management",
        "Preserve beneficial organisms and ask the agricultural technician to match physical, biological or chemical control to the identified pest and life stage.",
        ["ph_tomato", "fpa"],
      ),
      GuidanceStep(
        "Recheck new damage",
        "Monitor for live pests and fresh injury after intervention. Old feeding marks alone do not show that a treatment failed.",
        ["ph_tomato"],
      ),
    ],
    prevention: [
      GuidanceStep(
        "Inspect transplants",
        "Reject nursery plants carrying insects, eggs or fresh feeding damage.",
        ["ph_tomato", "ph_tomato_production"],
      ),
      GuidanceStep(
        "Keep fields sanitary",
        "Remove weeds, volunteer tomatoes and old crop residues that can shelter pests between plantings.",
        ["ph_tomato_production"],
      ),
      GuidanceStep(
        "Scout routinely",
        "Record the kind and location of injury and use need-based controls rather than calendar spraying.",
        ["ph_tomato", "ph_tomato_production"],
      ),
    ],
    seasonalPattern: SeasonalPattern.insufficient,
    seasonalEvidence:
        "The broad class may represent pests with different life cycles and weather responses. A single rainfall or month rule would be misleading until the insect is identified.",
    seasonalSourceIds: ["ph_tomato", "ph_tomato_production"],
  ),
  CropGuide(
    rawLabel: "tomato_leaf_curl_virus",
    crop: Crop.tomato,
    name: "Leaf curl virus",
    category: "Viral disease",
    summary:
        "Curled yellow leaves can have several causes. Confirm suspected virus; controlling whiteflies protects other plants but does not cure infected ones.",
    healthy: false,
    treatment: [
      GuidanceStep(
        "Check symptoms and vectors",
        "Inspect young leaves, growth and whiteflies under leaves; obtain confirmation of suspected viral disease.",
        ["uc_leafcurl"],
      ),
      GuidanceStep(
        "Remove early infection sources",
        "When only a few plants are affected, rogue confirmed diseased plants and coordinate vector control to limit spread.",
        ["uc_leafcurl"],
      ),
      GuidanceStep(
        "Protect healthy plants",
        "Use suitable insect-proof nursery covers and discuss targeted whitefly management with the agricultural technician.",
        ["uc_leafcurl"],
      ),
      GuidanceStep(
        "Plan the next crop",
        "Use locally suitable resistant varieties and clean transplants; avoid new plantings beside old infected tomato crops.",
        ["uc_leafcurl"],
      ),
    ],
    prevention: [
      GuidanceStep(
        "Keep seedlings protected",
        "Use virus-free, whitefly-free transplants and maintain nursery exclusion.",
        ["uc_leafcurl"],
      ),
      GuidanceStep(
        "Manage host plants",
        "Remove volunteers and weeds and clear old infected crops promptly.",
        ["uc_leafcurl"],
      ),
      GuidanceStep(
        "Use field observations",
        "Track whiteflies and symptoms; local research shows weather alone is not enough for a universal forecast.",
        ["ph_leafcurl"],
      ),
    ],
    seasonalPattern: SeasonalPattern.siteDependent,
    seasonalEvidence:
        "Northern Mindanao research found site- and season-dependent rainfall relationships. Its models also require temperature, humidity, wind and whiteflies; month alone cannot reproduce them.",
    seasonalSourceIds: ["ph_leafcurl"],
  ),
  CropGuide(
    rawLabel: "tomato_leaf_miner",
    crop: Crop.tomato,
    name: "Leaf miner",
    category: "Insect pest",
    summary:
        "Winding mines indicate larvae feeding inside leaves. Confirm active larvae or pupae because old mines remain visible after the pest is gone.",
    healthy: false,
    treatment: [
      GuidanceStep(
        "Confirm active mining",
        "Inspect fresh winding mines for larvae and check below plants for pupae; distinguish leaf miners from surface chewing or disease lesions.",
        ["uc_leafminer"],
      ),
      GuidanceStep(
        "Remove severe sources",
        "Remove heavily mined leaves or infested transplants when practical, while retaining enough healthy foliage for the crop.",
        ["uc_leafminer"],
      ),
      GuidanceStep(
        "Protect natural enemies",
        "Avoid unnecessary broad-spectrum insecticides because they can kill parasitoid wasps and trigger larger leaf-miner outbreaks.",
        ["uc_leafminer"],
      ),
      GuidanceStep(
        "Treat only when justified",
        "If active populations keep increasing, ask for a locally registered selective option. Do not import foreign treatment thresholds or product rates.",
        ["uc_leafminer", "fpa"],
      ),
    ],
    prevention: [
      GuidanceStep(
        "Check transplants",
        "Inspect seedlings for mines before planting and discard infested nursery plants.",
        ["uc_leafminer", "ph_tomato_production"],
      ),
      GuidanceStep(
        "Conserve parasitoids",
        "Use pest-specific, need-based controls so natural enemies can suppress leaf-miner larvae.",
        ["uc_leafminer"],
      ),
      GuidanceStep(
        "Clear old crops",
        "Remove old tomato plantings and host weeds promptly so infestations do not move directly into the next crop.",
        ["uc_leafminer", "ph_tomato_production"],
      ),
    ],
    seasonalPattern: SeasonalPattern.insufficient,
    seasonalEvidence:
        "The Philippine production guide confirms leaf miner as a tomato pest, but the reviewed sources do not validate a nationwide month-only risk rule.",
    seasonalSourceIds: ["ph_tomato_production", "uc_leafminer"],
  ),
  CropGuide(
    rawLabel: "banana_healthy",
    crop: Crop.banana,
    name: "Healthy crop care",
    category: "Healthy class",
    summary:
        "No disease treatment is indicated by this label. Continue field inspection; one healthy-looking leaf does not exclude problems elsewhere.",
    healthy: true,
    treatment: [
      GuidanceStep(
        "Maintain routine care",
        "Maintain mat sanitation, appropriate spacing and soil-test-based nutrition.",
        ["ph_banana_gap"],
      ),
    ],
    prevention: [
      GuidanceStep(
        "Keep preventive care",
        "Maintain mat sanitation, appropriate spacing and soil-test-based nutrition.",
        ["ph_banana_gap"],
      ),
    ],
    seasonalPattern: SeasonalPattern.healthy,
    seasonalEvidence:
        "Healthy is a scan class, not a disease forecast. Use the individual disease guides to plan seasonal scouting.",
    seasonalSourceIds: [],
  ),
  CropGuide(
    rawLabel: "Pineapple_healthy",
    crop: Crop.pineapple,
    name: "Healthy crop care",
    category: "Healthy class",
    summary:
        "No disease treatment is indicated by this label. Continue field inspection; one healthy-looking leaf does not exclude problems elsewhere.",
    healthy: true,
    treatment: [
      GuidanceStep(
        "Maintain routine care",
        "Maintain drainage, balanced crop care and routine checks of leaf bases, roots and fruit.",
        ["ph_pineapple"],
      ),
    ],
    prevention: [
      GuidanceStep(
        "Keep preventive care",
        "Use clean planting material, maintain drainage and keep monitoring for mealybugs and new lesions.",
        ["ph_pineapple"],
      ),
    ],
    seasonalPattern: SeasonalPattern.healthy,
    seasonalEvidence:
        "Healthy is a scan class, not a disease forecast. Use the individual disease guides to plan seasonal scouting.",
    seasonalSourceIds: [],
  ),
  CropGuide(
    rawLabel: "lettuce_healthy",
    crop: Crop.lettuce,
    name: "Healthy crop care",
    category: "Healthy class",
    summary:
        "No disease treatment is indicated by this label. Continue field inspection; one healthy-looking leaf does not exclude problems elsewhere.",
    healthy: true,
    treatment: [
      GuidanceStep(
        "Maintain routine care",
        "Maintain clean mulch and prepared beds; watch for rot and avoid crop injury.",
        ["ph_lettuce_rot"],
      ),
    ],
    prevention: [
      GuidanceStep(
        "Keep preventive care",
        "Maintain clean mulch and prepared beds; watch for rot and avoid crop injury.",
        ["ph_lettuce_rot"],
      ),
    ],
    seasonalPattern: SeasonalPattern.healthy,
    seasonalEvidence:
        "Healthy is a scan class, not a disease forecast. Use the individual disease guides to plan seasonal scouting.",
    seasonalSourceIds: [],
  ),
  CropGuide(
    rawLabel: "tomato_healthy",
    crop: Crop.tomato,
    name: "Healthy crop care",
    category: "Healthy class",
    summary:
        "No disease treatment is indicated by this label. Continue field inspection; one healthy-looking leaf does not exclude problems elsewhere.",
    healthy: true,
    treatment: [
      GuidanceStep(
        "Maintain routine care",
        "Maintain supports, mulch and airflow; keep irrigation off foliage.",
        ["uf_early"],
      ),
    ],
    prevention: [
      GuidanceStep(
        "Keep preventive care",
        "Maintain supports, mulch and airflow; keep irrigation off foliage.",
        ["uf_early"],
      ),
    ],
    seasonalPattern: SeasonalPattern.healthy,
    seasonalEvidence:
        "Healthy is a scan class, not a disease forecast. Use the individual disease guides to plan seasonal scouting.",
    seasonalSourceIds: [],
  ),
];

CropGuide? guideForLabel(String? rawLabel) {
  for (final guide in cropGuides) {
    if (guide.rawLabel == rawLabel) return guide;
  }
  return null;
}

List<CropGuide> guidesForCrop(Crop crop) =>
    cropGuides.where((guide) => guide.crop == crop).toList(growable: false);
