import '../models/crop_guide.dart';

// Reviewed 2026-09-09. The raw labels must match assets/labels.json.
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
  "ph_eggplant": GuideSource(
    id: "ph_eggplant",
    title: "Eggplant Production Guide",
    publisher: "DA Cagayan Valley",
    url:
        "https://cagayanvalley.da.gov.ph/wp-content/uploads/2018/02/Eggplant.pdf",
    scope: "Philippine extension",
    note:
        "Crop sanitation, pest management, resistant varieties, crop rotation, bacterial and Fusarium wilt.",
  ),
  "ph_eggplant_ati": GuideSource(
    id: "ph_eggplant_ati",
    title: "Urban Agriculture for Lowland Areas (2020)",
    publisher: "ATI Cordillera",
    url:
        "https://ati2.da.gov.ph/ati-car/content/sites/default/files/2022-12/urban_agriculture_for_lowland.pdf",
    scope: "Philippine extension",
    note:
        "Eggplant section, printed p. 23: pruning, airflow, removing damaged plant parts. General care, not pathogen-specific white-mold treatment.",
  ),
  "ph_eggplant_spacing": GuideSource(
    id: "ph_eggplant_spacing",
    title: "Eggplant production guide",
    publisher: "ATI Central Visayas",
    url:
        "https://ati2.da.gov.ph/ati-7/content/sites/default/files/users/user18/eggplant_final.pdf",
    scope: "Philippine extension",
    note:
        "Seedlings, spacing, mulch and common eggplant pests/diseases. General prevention for broad labels.",
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
  "uc_spot": GuideSource(
    id: "uc_spot",
    title: "Bacterial Spot of Tomato",
    publisher: "University of California IPM",
    url: "https://ipm.ucanr.edu/agriculture/tomato/bacterial-spot/",
    scope: "International extension",
    note:
        "Pathogen-free transplants, splash reduction, rotation and limitations of copper protectants. US product rates are not used here.",
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
  "umd_septoria": GuideSource(
    id: "umd_septoria",
    title: "Septoria Leaf Spot of Tomatoes (2024)",
    publisher: "University of Maryland Extension",
    url: "https://www.extension.umd.edu/resource/septoria-leaf-spot-tomatoes",
    scope: "International extension",
    note:
        "Wet-weather disease; spacing, clean transplants, mulch, base watering and lower-leaf management.",
  ),
  "uf_target": GuideSource(
    id: "uf_target",
    title: "Target Spot of Tomato in Florida",
    publisher: "University of Florida IFAS",
    url: "https://ask.ifas.ufl.edu/publication/PP351",
    scope: "International extension",
    note:
        "Corynespora: diagnosis, canopy inspection, rotation, sanitation and fungicide resistance. No Philippine month-specific forecast.",
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
  "umn_virus": GuideSource(
    id: "umn_virus",
    title: "Tomato viruses",
    publisher: "University of Minnesota Extension",
    url:
        "https://extension.umn.edu/agriculture/specialty-crops/vegetable-farming/disease-management/tomato-viruses",
    scope: "International extension",
    note:
        "ToMV/TMV: no curative chemical treatment; resistant varieties, hygiene and removal of affected plants.",
  ),
  "uc_eggvirus": GuideSource(
    id: "uc_eggvirus",
    title: "Mosaic Viruses of Peppers and Eggplants",
    publisher: "University of California IPM",
    url:
        "https://ipm.ucanr.edu/home-and-landscape/mosaic-viruses-of-peppers-and-eggplants/",
    scope: "International extension",
    note:
        "Virus symptoms overlap; removal, clean seedlings and vector management depend on the virus.",
  ),
  "umass_wilt": GuideSource(
    id: "umass_wilt",
    title: "Eggplant disease control",
    publisher: "UMass / New England Vegetable Management Guide",
    url: "https://nevegetable.org/crops/eggplant/disease-control",
    scope: "International extension",
    note:
        "Different wilt causes require different management; drainage, clean fields and rotation. No US chemical rates copied.",
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
  "bayer_eggplant": GuideSource(
    id: "bayer_eggplant",
    title: "Capsicum & Eggplant Disease Field Guide",
    publisher: "Seminis / Bayer Plant Health Department",
    url:
        "https://www.vegetables.bayer.com/content/dam/bayer-vegetables/english/australia-new-zealand/product-sheets-and-pdfs/Vegetables-by-Bayer_Capsicum-Eggplant-Disease-Guide.pdf",
    scope: "International technical guide",
    note:
        "Printed pp. 35 and 44: leaf spots and white mould. White mould requires confirmation; no Philippine season validation.",
  ),
  "uconn_mites": GuideSource(
    id: "uconn_mites",
    title: "Tomato – Spider Mites (2026)",
    publisher: "University of Connecticut IPM",
    url: "https://ipm.cahnr.uconn.edu/tomato-spider-mites/",
    scope: "International extension",
    note:
        "Scouting and integrated mite management; local seasonal context comes from ATI Cordillera.",
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
    rawLabel: "eggplant_insect_pest",
    crop: Crop.eggplant,
    name: "Insect damage",
    category: "Pest group",
    summary:
        "This class does not identify the insect. Eggplant shoot/fruit borers, aphids and other pests require different controls.",
    healthy: false,
    treatment: [
      GuidanceStep(
        "Identify the pest",
        "Inspect shoots, fruit holes and leaf undersides; collect photographs or a specimen before selecting an insecticide.",
        ["ph_eggplant"],
      ),
      GuidanceStep(
        "Remove infestation sources",
        "Remove damaged shoots and fruit promptly and dispose of them away from the growing crop.",
        ["ph_eggplant_ati"],
      ),
      GuidanceStep(
        "Use targeted control",
        "Start with sanitation and physical removal where practical. Ask the agricultural technician to match control to the identified pest and its stage.",
        ["ph_eggplant"],
      ),
      GuidanceStep(
        "Recheck damage",
        "Look for fresh injury and remaining live insects at each inspection. A damaged old leaf alone does not mean control failed.",
        ["ph_eggplant"],
      ),
    ],
    prevention: [
      GuidanceStep(
        "Keep the field clean",
        "Remove crop residues and weeds that sustain pest populations.",
        ["ph_eggplant"],
      ),
      GuidanceStep(
        "Harvest damaged fruit too",
        "Remove deformed and infested fruit during harvest instead of leaving it as a pest source.",
        ["ph_eggplant_ati"],
      ),
      GuidanceStep(
        "Plan the next planting",
        "Use suitable resistant varieties and rotate crops according to the pest identified.",
        ["ph_eggplant"],
      ),
    ],
    seasonalPattern: SeasonalPattern.insufficient,
    seasonalEvidence:
        "Different insects have different seasonal patterns. The broad label cannot support one Philippine seasonal forecast; identify the pest and scout year-round.",
    seasonalSourceIds: ["ph_eggplant"],
  ),
  CropGuide(
    rawLabel: "eggplant_leaf_spot",
    crop: Crop.eggplant,
    name: "Leaf spot",
    category: "Cause needs confirmation",
    summary:
        "The label covers a symptom, not a confirmed organism. Fungal and bacterial leaf spots can need different treatment.",
    healthy: false,
    treatment: [
      GuidanceStep(
        "Confirm the cause",
        "Photograph upper and lower leaf surfaces and any fruit lesions. Have expanding or unusual spots checked before choosing a product.",
        ["bayer_eggplant"],
      ),
      GuidanceStep(
        "Reduce splash",
        "Direct irrigation to the root zone and use clean mulch to keep soil off foliage.",
        ["bayer_eggplant"],
      ),
      GuidanceStep(
        "Clear infection sources",
        "Remove heavily affected tissue and crop debris while keeping enough healthy leaves. Improve airflow by appropriate pruning.",
        ["ph_eggplant_ati"],
      ),
      GuidanceStep(
        "Review progression",
        "Compare newly formed leaves after sanitation. If fresh spots continue, seek a diagnosis and targeted control plan.",
        ["ph_eggplant_ati"],
      ),
    ],
    prevention: [
      GuidanceStep(
        "Use clean seedlings",
        "Select good-quality seed and inspect transplants before planting.",
        ["ph_eggplant_spacing"],
      ),
      GuidanceStep(
        "Allow foliage to dry",
        "Maintain spacing and avoid excessive overhead watering.",
        ["bayer_eggplant"],
      ),
      GuidanceStep(
        "Break carryover",
        "Rotate crops and remove old residues and weeds between plantings.",
        ["bayer_eggplant"],
      ),
    ],
    seasonalPattern: SeasonalPattern.insufficient,
    seasonalEvidence:
        "Philippine surveys record several eggplant leaf-spot causes. Their presence does not establish a season-specific likelihood for this broad class.",
    seasonalSourceIds: ["ph_icm"],
  ),
  CropGuide(
    rawLabel: "eggplant_mosaic_virus",
    crop: Crop.eggplant,
    name: "Mosaic virus symptoms",
    category: "Virus group",
    summary:
        "Several viruses cause mosaic and curled leaves; spray injury can look similar. The model cannot identify the virus or its vector.",
    healthy: false,
    treatment: [
      GuidanceStep(
        "Confirm suspicious plants",
        "Inspect mottled new growth and fruit distortion; obtain a plant-health diagnosis before committing to a virus-specific programme.",
        ["uc_eggvirus"],
      ),
      GuidanceStep(
        "Remove infection sources",
        "Rogue confirmed affected plants early and keep their material away from healthy seedlings.",
        ["uc_eggvirus"],
      ),
      GuidanceStep(
        "Reduce mechanical spread",
        "Handle healthy plants first and minimize damage or unnecessary handling of affected plants.",
        ["uc_eggvirus"],
      ),
      GuidanceStep(
        "Address the right vector",
        "Some viruses spread by aphids, others by contact or seed. Insecticides alone may not stop aphid-transmitted mosaics and do not cure infected plants.",
        ["uc_eggvirus"],
      ),
    ],
    prevention: [
      GuidanceStep(
        "Start with healthy plants",
        "Inspect nursery plants and use good-quality seed.",
        ["ph_eggplant_spacing"],
      ),
      GuidanceStep(
        "Manage alternate hosts",
        "Remove broadleaf weeds and discuss reflective mulch where aphid-borne virus is confirmed.",
        ["uc_eggvirus"],
      ),
      GuidanceStep(
        "Choose resistance carefully",
        "Use varieties resistant to the identified virus where available; generic resistance claims are insufficient.",
        ["uc_eggvirus"],
      ),
    ],
    seasonalPattern: SeasonalPattern.insufficient,
    seasonalEvidence:
        "No Philippine seasonal relationship for this unspecified eggplant virus was established in the reviewed sources. Vector identity and infection sources matter.",
    seasonalSourceIds: ["uc_eggvirus"],
  ),
  CropGuide(
    rawLabel: "eggplant_white_mold",
    crop: Crop.eggplant,
    name: "White mold",
    category: "Confirm fungal cause",
    summary:
        "White growth alone does not prove Sclerotinia. A technician should distinguish cottony stem rot from powdery mildew and other molds.",
    healthy: false,
    treatment: [
      GuidanceStep(
        "Inspect stems and fruit",
        "Look for watery rot, cottony growth and hard dark bodies; submit an affected sample for confirmation.",
        ["bayer_eggplant"],
      ),
      GuidanceStep(
        "Contain affected material",
        "Remove severely diseased plants carefully and keep infected debris and contaminated soil out of clean beds.",
        ["bayer_eggplant"],
      ),
      GuidanceStep(
        "Dry the canopy",
        "Improve ventilation and drainage. Avoid keeping leaves and stems continuously wet.",
        ["ph_eggplant_ati"],
      ),
      GuidanceStep(
        "Plan targeted management",
        "Discuss treatment only after identifying the fungus. Do not assume a general leaf spray can restore a rotted stem.",
        ["bayer_eggplant"],
      ),
    ],
    prevention: [
      GuidanceStep(
        "Use clean beds",
        "Do not transfer soil or infected debris from affected beds.",
        ["bayer_eggplant"],
      ),
      GuidanceStep(
        "Improve spacing",
        "Prune overcrowded growth and maintain airflow around plants.",
        ["ph_eggplant_ati"],
      ),
      GuidanceStep(
        "Review crop rotation",
        "If Sclerotinia is confirmed, obtain a rotation plan accounting for its many hosts.",
        ["bayer_eggplant"],
      ),
    ],
    seasonalPattern: SeasonalPattern.insufficient,
    seasonalEvidence:
        "International guidance links white mold with prolonged moisture. No Philippine validation specific to this model class was found; no calendar risk is assigned.",
    seasonalSourceIds: ["bayer_eggplant"],
  ),
  CropGuide(
    rawLabel: "eggplant_wilt",
    crop: Crop.eggplant,
    name: "Wilt",
    category: "Cause needs confirmation",
    summary:
        "Wilting may result from bacterial wilt, Fusarium, other root diseases or water stress. The model cannot distinguish these causes.",
    healthy: false,
    treatment: [
      GuidanceStep(
        "Check roots and soil",
        "Check for waterlogging, drought and root injury. Seek diagnosis when wilting persists despite appropriate watering.",
        ["umass_wilt"],
      ),
      GuidanceStep(
        "Contain affected plants",
        "Mark the area; remove confirmed diseased plants with local disposal advice. Avoid spreading soil to healthy beds.",
        ["ph_eggplant", "umass_wilt"],
      ),
      GuidanceStep(
        "Correct water movement",
        "Improve drainage, avoid low spots and keep runoff from affected plants away from clean areas.",
        ["umass_wilt"],
      ),
      GuidanceStep(
        "Match management to cause",
        "Discuss resistant planting material or an alternative planting site. Foliar sprays cannot be assumed to cure a soilborne wilt.",
        ["ph_eggplant", "umass_wilt"],
      ),
    ],
    prevention: [
      GuidanceStep(
        "Choose planting material",
        "Use healthy transplants and locally suitable wilt-resistant varieties when the cause is known.",
        ["ph_eggplant"],
      ),
      GuidanceStep(
        "Rotate appropriately",
        "Use non-host crops selected for the diagnosed pathogen; different wilts have different persistence and host ranges.",
        ["umass_wilt"],
      ),
      GuidanceStep(
        "Avoid contaminated beds",
        "Clean soil off tools and avoid transplanting into poorly drained or previously affected sites.",
        ["umass_wilt"],
      ),
    ],
    seasonalPattern: SeasonalPattern.yearRound,
    seasonalEvidence:
        "Philippine guides identify bacterial and Fusarium wilt in eggplant. Exposure and the specific cause matter throughout the year; a month-only estimate is unsupported.",
    seasonalSourceIds: ["ph_eggplant"],
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
    rawLabel: "tomato_Bacterial_spot",
    crop: Crop.tomato,
    name: "Bacterial spot",
    category: "Bacterial leaf disease",
    summary:
        "Small water-soaked lesions can resemble other spots. Copper products protect healthy tissue only partly and do not cure established lesions.",
    healthy: false,
    treatment: [
      GuidanceStep(
        "Confirm the spots",
        "Inspect transplants, older leaves and fruit; have uncertain cases checked before applying disease-specific products.",
        ["uc_spot"],
      ),
      GuidanceStep(
        "Reduce spread",
        "Avoid sprinkler irrigation and remove infection sources such as diseased transplants and nearby cull piles.",
        ["uc_spot"],
      ),
      GuidanceStep(
        "Protect clean tissue",
        "For confirmed spreading disease, ask about a locally registered bactericide. Copper resistance and incomplete control are possible.",
        ["uc_spot"],
      ),
      GuidanceStep(
        "Monitor new infection",
        "Check new leaves and adjacent plants after management. Review irrigation and sanitation if fresh lesions appear.",
        ["uc_spot"],
      ),
    ],
    prevention: [
      GuidanceStep(
        "Use pathogen-free material",
        "Start with tested seed and healthy transplants.",
        ["uc_spot"],
      ),
      GuidanceStep(
        "Break splash transmission",
        "Water at the base and avoid working in a wet canopy.",
        ["uc_spot"],
      ),
      GuidanceStep(
        "Reduce carryover",
        "Clear crop residues and rotate with suitable non-host crops.",
        ["ph_tomato"],
      ),
    ],
    seasonalPattern: SeasonalPattern.wet,
    seasonalEvidence:
        "Philippine extension guidance identifies warm, wet conditions as favorable. This is a scouting flag.",
    seasonalSourceIds: ["ph_tomato", "pagasa"],
  ),
  CropGuide(
    rawLabel: "tomato_Early_blight",
    crop: Crop.tomato,
    name: "Early blight",
    category: "Fungal leaf disease",
    summary:
        "Concentric spots often begin on older leaves. Management aims to slow further infection and preserve healthy foliage.",
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
    ],
    seasonalPattern: SeasonalPattern.wet,
    seasonalEvidence:
        "Philippine extension guidance identifies warm, humid conditions as favorable. This is a scouting flag.",
    seasonalSourceIds: ["ph_tomato", "pagasa"],
  ),
  CropGuide(
    rawLabel: "tomato_Late_blight",
    crop: Crop.tomato,
    name: "Late blight",
    category: "Oomycete disease",
    summary:
        "Rapidly expanding water-soaked lesions and stem blight need prompt attention, particularly during cool, moist conditions.",
    healthy: false,
    treatment: [
      GuidanceStep(
        "Act on rapid spread",
        "Inspect plants around the affected plant and contact a crop-protection technician promptly when lesions expand quickly.",
        ["uc_late"],
      ),
      GuidanceStep(
        "Remove infection sources",
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
        "Ask for a locally registered late-blight programme. Products for unrelated fungi may not control this oomycete.",
        ["uc_late"],
      ),
    ],
    prevention: [
      GuidanceStep(
        "Inspect transplants",
        "Plant healthy seedlings and reject those showing suspicious lesions.",
        ["uc_late"],
      ),
      GuidanceStep(
        "Choose appropriate resistance",
        "Discuss resistant cultivars suited to locally occurring pathogen populations.",
        ["uc_late"],
      ),
      GuidanceStep(
        "Scout cool, wet sites",
        "Scout damp upland plantings and neighboring host crops.",
        ["ph_tomato"],
      ),
    ],
    seasonalPattern: SeasonalPattern.coolWet,
    seasonalEvidence:
        "DA/JICA identifies cool, moist uplands as favorable. The flag combines a wetter month with a cool-upland setting.",
    seasonalSourceIds: ["ph_tomato", "pagasa"],
  ),
  CropGuide(
    rawLabel: "tomato_Leaf_Mold",
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
    rawLabel: "tomato_Septoria_leaf_spot",
    crop: Crop.tomato,
    name: "Septoria leaf spot",
    category: "Fungal leaf disease",
    summary:
        "Numerous small spots with pale centers may start low on the plant. Confirm look-alike diseases before treatment.",
    healthy: false,
    treatment: [
      GuidanceStep(
        "Inspect early symptoms",
        "Examine lower leaves and transplants for small gray-centered lesions, sometimes containing tiny dark fruiting bodies.",
        ["umd_septoria"],
      ),
      GuidanceStep(
        "Manage lower foliage",
        "Once established plants begin fruiting, remove badly affected low leaves and avoid excessive defoliation.",
        ["umd_septoria"],
      ),
      GuidanceStep(
        "Stop soil splash",
        "Keep the soil mulched and water the base, avoiding wet foliage.",
        ["umd_septoria"],
      ),
      GuidanceStep(
        "Check continued spread",
        "Inspect remaining foliage and improve spacing. Seek local diagnosis and registered-product advice if symptoms keep advancing.",
        ["umd_septoria"],
      ),
    ],
    prevention: [
      GuidanceStep(
        "Check seedlings",
        "Do not introduce visibly spotted transplants to clean beds.",
        ["umd_septoria"],
      ),
      GuidanceStep(
        "Improve airflow",
        "Provide adequate spacing and manage shoots near the plant base.",
        ["umd_septoria"],
      ),
      GuidanceStep(
        "Follow local sanitation",
        "Use clean seedlings and remove crop residues as part of integrated disease management.",
        ["ph_tomato"],
      ),
    ],
    seasonalPattern: SeasonalPattern.insufficient,
    seasonalEvidence:
        "Philippine surveys confirm occurrence. International guidance identifies wet-weather favorability, but the reviewed Philippine work does not validate a month-based Septoria forecast.",
    seasonalSourceIds: ["ph_icm", "umd_septoria"],
  ),
  CropGuide(
    rawLabel: "tomato_Spider_mites Two-spotted_spider_mite",
    crop: Crop.tomato,
    name: "Two-spotted spider mites",
    category: "Mite pest",
    summary:
        "Stippling, bronzing and fine webbing warrant close inspection. Mites are not a fungal disease.",
    healthy: false,
    treatment: [
      GuidanceStep(
        "Verify live mites",
        "Inspect leaf undersides with magnification and compare affected areas with healthy plants.",
        ["uconn_mites"],
      ),
      GuidanceStep(
        "Reduce plant stress",
        "Maintain adequate root-zone watering; inspect dry or dusty margins and protected growing areas.",
        ["uconn_mites"],
      ),
      GuidanceStep(
        "Use targeted management",
        "Preserve beneficial organisms. If control is needed, ask for a registered miticide matched to the pest rather than a general fungicide.",
        ["uconn_mites"],
      ),
      GuidanceStep(
        "Recheck active infestation",
        "Look for live mites and new injury after treatment; follow the product label for subsequent applications.",
        ["uconn_mites"],
      ),
    ],
    prevention: [
      GuidanceStep(
        "Start with healthy seedlings",
        "Inspect nursery stock before moving it into production.",
        ["ph_tomato"],
      ),
      GuidanceStep(
        "Avoid drought stress",
        "Maintain crop-appropriate irrigation and inspect hot, dry patches.",
        ["ph_tomato"],
      ),
      GuidanceStep(
        "Scout sheltered plants",
        "Inspect warm, dry greenhouses throughout the year.",
        ["ph_tomato"],
      ),
    ],
    seasonalPattern: SeasonalPattern.dry,
    seasonalEvidence:
        "ATI reports hot, dry conditions favor mites; greenhouses can remain infested year-round.",
    seasonalSourceIds: ["ph_tomato", "pagasa"],
  ),
  CropGuide(
    rawLabel: "tomato_Target_Spot",
    crop: Crop.tomato,
    name: "Target spot",
    category: "Fungal leaf disease",
    summary:
        "Corynespora target spot can resemble early blight or bacterial spot. Inspect inside the canopy and on fruit.",
    healthy: false,
    treatment: [
      GuidanceStep(
        "Check hidden damage",
        "Part the canopy and inspect inner leaves and the shaded side of fruit for lesions; confirm the diagnosis.",
        ["uf_target"],
      ),
      GuidanceStep(
        "Reduce carryover",
        "Remove infected residue, volunteers and host weeds; keep clean transplants apart from affected crops.",
        ["uf_target"],
      ),
      GuidanceStep(
        "Reduce persistent wetness",
        "Manage canopy density and irrigation so the inner foliage does not remain wet.",
        ["uf_target"],
      ),
      GuidanceStep(
        "Review fungicide selection",
        "For confirmed disease, obtain a registered protection programme and resistance advice; repeated use of one mode of action can fail.",
        ["uf_target"],
      ),
    ],
    prevention: [
      GuidanceStep(
        "Use healthy transplants",
        "Inspect plants before field establishment and monitor them after transplanting.",
        ["uf_target"],
      ),
      GuidanceStep(
        "Rotate and sanitize",
        "Rotate away from tomato with locally advised crops, considering the pathogen's broad host range.",
        ["uf_target"],
      ),
      GuidanceStep(
        "Apply local hygiene guidance",
        "Use clean tools and remove residues as part of the DA integrated management approach.",
        ["ph_tomato"],
      ),
    ],
    seasonalPattern: SeasonalPattern.insufficient,
    seasonalEvidence:
        "Target spot is documented in southern Philippine surveys. Wet-canopy biology is supported internationally; local month-specific likelihood has not been established.",
    seasonalSourceIds: ["ph_icm", "uf_target"],
  ),
  CropGuide(
    rawLabel: "tomato_Tomato_Yellow_Leaf_Curl_Virus",
    crop: Crop.tomato,
    name: "Tomato yellow leaf curl",
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
    rawLabel: "tomato_Tomato_mosaic_virus",
    crop: Crop.tomato,
    name: "Tomato mosaic virus",
    category: "Viral disease",
    summary:
        "ToMV and other viruses can resemble each other. Laboratory confirmation may be needed; there is no curative chemical treatment for ToMV.",
    healthy: false,
    treatment: [
      GuidanceStep(
        "Confirm the diagnosis",
        "Have persistent mosaic and distorted growth assessed; herbicide injury and other viruses can look similar.",
        ["umn_virus"],
      ),
      GuidanceStep(
        "Remove affected plants",
        "Remove confirmed infected plants, including roots, and keep material away from healthy seedlings.",
        ["umn_virus"],
      ),
      GuidanceStep(
        "Prevent contact spread",
        "Work healthy plants first. Clean hands, tools and reusable supports using an appropriate sanitation procedure.",
        ["umn_virus"],
      ),
      GuidanceStep(
        "Protect the next planting",
        "Use clean seed and transplants and varieties specifically rated for ToMV resistance; insect sprays do not cure mosaic.",
        ["umn_virus"],
      ),
    ],
    prevention: [
      GuidanceStep(
        "Keep propagation clean",
        "Use reliable planting material and clean nursery equipment.",
        ["umn_virus"],
      ),
      GuidanceStep(
        "Maintain handling hygiene",
        "Avoid transferring sap between plants through hands and pruning tools.",
        ["umn_virus"],
      ),
      GuidanceStep(
        "Remove residual sources",
        "Clear volunteer plants and old crop residue; follow the DA integrated management guidance.",
        ["ph_tomato"],
      ),
    ],
    seasonalPattern: SeasonalPattern.yearRound,
    seasonalEvidence:
        "Contact, planting material and hygiene are central. No Philippine month-specific ToMV forecast was found; keep prevention in place throughout the year.",
    seasonalSourceIds: ["umn_virus"],
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
    rawLabel: "eggplant_healthy",
    crop: Crop.eggplant,
    name: "Healthy crop care",
    category: "Healthy class",
    summary:
        "No disease treatment is indicated by this label. Continue field inspection; one healthy-looking leaf does not exclude problems elsewhere.",
    healthy: true,
    treatment: [
      GuidanceStep(
        "Maintain routine care",
        "Use healthy seedlings, suitable spacing and clean mulch; inspect shoots and fruit.",
        ["ph_eggplant_spacing"],
      ),
    ],
    prevention: [
      GuidanceStep(
        "Keep preventive care",
        "Use healthy seedlings, suitable spacing and clean mulch; inspect shoots and fruit.",
        ["ph_eggplant_spacing"],
      ),
    ],
    seasonalPattern: SeasonalPattern.healthy,
    seasonalEvidence:
        "Healthy is a scan class, not a disease forecast. Use the individual disease guides to plan seasonal scouting.",
    seasonalSourceIds: [],
  ),
  CropGuide(
    rawLabel: "lettuce_healthy_new",
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
