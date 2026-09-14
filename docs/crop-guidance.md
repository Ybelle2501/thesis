# Crop guidance and seasonal outlook

The Treatment Advice and Disease Prevention libraries cover the exact 23 labels
in `assets/labels.json`: 19 disease/pest conditions and four healthy classes.
Broad labels remain broad. They are not silently converted into a confirmed
pathogen diagnosis.

## Content and sources

`lib/data/crop_guides.dart` contains the treatment and prevention steps, source
IDs and evidence notes. Each disease/pest has four treatment steps and three
prevention steps. The app shows the sources supporting each step, their
publisher, geographic scope, reference links and limitations. It supports
opening references in a browser and copying links if no browser is available.
Guides themselves are bundled and readable offline.

Philippine sources include DA, ATI, DOST-PCAARRD, PAGASA, UPLB-hosted research
and ACIAR/Visayas State University research in the Philippines. International
extension or technical references fill disease-specific gaps and are explicitly
identified. General local advice is not presented as pathogen-specific evidence.
Product-specific rates and foreign pesticide registrations are not imported.
The current FPA register and the local crop/pest label govern product selection.

## Seasonal method

The outlook is a transparent qualitative scouting heuristic, separate from
ResNet image inference. It is not a trained forecasting model or a calibrated
probability of disease occurrence. No percentage or accuracy claim is made.

1. Start with the device's current month; let the user choose another month.
2. Ask for a nearby PAGASA station; do not assume the user's farm location.
3. Use the published 12 monthly rainfall normals for that station. A month
   above the median of those 12 values is considered relatively wetter.
   This median rule is an application heuristic, not a PAGASA disease threshold.
4. Only conditions with relevant Philippine crop guidance receive a seasonal
   flag: Sigatoka, lettuce moisture-related conditions, tomato bacterial spot,
   early blight, late blight and mites. These are precautionary inferences.
5. Late blight requires the wetter flag and a user-confirmed cool-upland site.
   The mite dry-month flag requires the warm/lowland setting. Neither is a
   replacement for actual temperature, humidity or leaf-wetness observations.
6. Davao is kept on year-round watch because its published normals show rain
   in every month; relatively low rainfall is not called a dry season.
7. Wilt and mechanically transmitted mosaic remain on year-round watch.
   Broad insect/virus labels and diseases without sufficient Philippine
   season-specific support display an evidence limitation. Leaf mold and
   tomato yellow leaf curl require field data.
8. The 12-month view applies the same rule to each month. Selecting a month
   updates the shared settings throughout the guidance module.

The settings remain shared while the app is open. A fresh app session starts
with the current month and no assumed location. No GPS, current weather,
seasonal outlook API, ENSO adjustment or field incidence feed is used.
The station is a regional proxy, not a measurement on the user's farm.

PAGASA values were read on 9 September 2026. The public station table describes
30-year normals but does not identify the baseline years; the app does not
invent a period such as 1991–2020. The source page is retained in the bibliography.

## Specific evidence limits

- The Bauko lettuce observations concern soft rot, not all bacteria in the
  model's broad lettuce class. The UI explicitly identifies that limited scope.
- Borja et al. (2020) studied leaf curl in Malaybalay and Claveria during the
  2018 dry/wet seasons. Relationships differed by site and season, and the
  fitted models used multiple weather variables and whiteflies. The app does
  not recreate those equations from an abstract or generalize them nationally.
- Philippine leaf-mould reports include Pseudocercospora; the model's common
  leaf-mold class is associated with Passalora. These are not treated as identical.
- Philippine occurrence records for Septoria and target spot do not establish
  seasonal likelihood. International wetness guidance is shown without a
  Philippine calendar prediction.
- Healthy classifications are not future disease predictions.

A statistically validated probability feature would require a defined disease,
site, forecast horizon, field incidence labels and matched weather observations,
followed by temporal/geographic validation and calibration.

## Validation

Run `flutter analyze`, `flutter test` and `flutter build apk --debug`.
Tests check exact model-label coverage, references and local prevention sources,
regional rainfall differences, upland effects, missing-evidence behavior,
crop navigation, settings, source copying and narrow-screen layouts.

## Bibliography (reviewed 9 September 2026)

- [Long-Term Harvesting of Tomato and Sweet Pepper (2026)](https://ati2.da.gov.ph/ati-car/content/sites/default/files/2026-01/DA%20%26%20JICA%20MV2C%20Training%20Module%20on%20Long%20Term%20Harvesting%20of%20Tomato%20and%20Sweet%20Pepper%20%28for%20online%20upload%20in%20web%29_1.pdf) — DA / JICA / ATI Cordillera. Philippine extension.
- [Philippine Banana Industry Roadmap 2021–2025](https://www.da.gov.ph/wp-content/uploads/2023/05/Philippine-Banana-Industry-Roadmap.pdf) — Department of Agriculture. Philippine extension.
- [Banana Production Manual](https://hvcdp.da.gov.ph/wp-content/uploads/2022/05/Banana-Production-Manual.pdf) — DA High Value Crops Development Program. Philippine extension.
- [ACIAR–PCAARRD project: management of banana Fusarium wilt (2016)](https://www.pcaarrd.dost.gov.ph/index.php/quick-information-dispatch-qid-articles/aciar-pcaarrd-project-provides-options-for-management-of-banana-fusarium-wilt) — DOST-PCAARRD. Philippine field research.
- [Good agricultural practices reduce banana pests and diseases (2017)](https://www.pcaarrd.dost.gov.ph/index.php/quick-information-dispatch-qid-articles/good-agricultural-practices-gap-reduces-pests-and-diseases-of-lakatan-and-cardaba) — DOST-PCAARRD. Philippine field research.
- [Banana diamond leaf spot, fact sheet 072](https://apps.lucidcentral.org/pppw_v13/text/web_full/entities/banana_diamond_leaf_spot_072.htm) — Pacific Pests, Pathogens, Weeds & Pesticides / ACIAR-supported project. International extension.
- [Eggplant Production Guide](https://cagayanvalley.da.gov.ph/wp-content/uploads/2018/02/Eggplant.pdf) — DA Cagayan Valley. Philippine extension.
- [Urban Agriculture for Lowland Areas (2020)](https://ati2.da.gov.ph/ati-car/content/sites/default/files/2022-12/urban_agriculture_for_lowland.pdf) — ATI Cordillera. Philippine extension.
- [Eggplant production guide](https://ati2.da.gov.ph/ati-7/content/sites/default/files/users/user18/eggplant_final.pdf) — ATI Central Visayas. Philippine extension.
- [Lettuce Production for Urban and Home Gardening (2020)](https://ati2.da.gov.ph/ati-car/content/sites/default/files/2022-12/urban_agriculture_for_upland.pdf) — ATI Cordillera. Philippine extension.
- [Gabay sa Produksyon ng Letsugas](https://ati2.da.gov.ph/ati-4b/content/sites/default/files/2022-12/lettuce_final.pdf) — ATI Mimaropa. Philippine extension.
- [Romaine lettuce production in Bauko (2024)](https://ati2.da.gov.ph/ati-car/content/features/green-romance-romaine-lettuce-production-cloud-capped-mountains-bauko) — ATI Cordillera. Philippine field observations.
- [Weather-based tomato leaf-curl forecasting in Northern Mindanao (2020)](https://www.ukdr.uplb.edu.ph/journal-articles/154/) — Borja, Pangga, Sta. Cruz & Sta. Cruz / UPLB repository. Philippine field research.
- [Integrated crop management: vegetables in the southern Philippines (2018)](https://www.aciar.gov.au/sites/default/files/project-page-docs/final_report_hort.2012.020.pdf) — ACIAR / Visayas State University and partners. Philippine field research.
- [Bacterial Spot of Tomato](https://ipm.ucanr.edu/agriculture/tomato/bacterial-spot/) — University of California IPM. International extension.
- [Early Blight on Tomatoes](https://ipm.ucanr.edu/home-and-landscape/early-blight-on-tomatoes/) — University of California IPM. International extension.
- [Common Tomato High-Tunnel Production Diseases](https://edis.ifas.ufl.edu/pp368) — University of Florida IFAS. International extension.
- [Late Blight of Tomato](https://ipm.ucanr.edu/agriculture/tomato/late-blight/) — University of California IPM. International extension.
- [Tomato leaf mold](https://extension.umn.edu/agriculture/specialty-crops/vegetable-farming/disease-management/tomato-leaf-mold) — University of Minnesota Extension. International extension.
- [Septoria Leaf Spot of Tomatoes (2024)](https://www.extension.umd.edu/resource/septoria-leaf-spot-tomatoes) — University of Maryland Extension. International extension.
- [Target Spot of Tomato in Florida](https://ask.ifas.ufl.edu/publication/PP351) — University of Florida IFAS. International extension.
- [Tomato Yellow Leaf Curl](https://ipm.ucanr.edu/agriculture/tomato/tomato-yellow-leaf-curl/) — University of California IPM. International extension.
- [Tomato viruses](https://extension.umn.edu/agriculture/specialty-crops/vegetable-farming/disease-management/tomato-viruses) — University of Minnesota Extension. International extension.
- [Mosaic Viruses of Peppers and Eggplants](https://ipm.ucanr.edu/home-and-landscape/mosaic-viruses-of-peppers-and-eggplants/) — University of California IPM. International extension.
- [Eggplant disease control](https://nevegetable.org/crops/eggplant/disease-control) — UMass / New England Vegetable Management Guide. International extension.
- [Climatological normals: monthly station rainfall](https://pagasa.dost.gov.ph/climate/climatological-normals) — DOST-PAGASA. Philippine climate observations.
- [Registered pesticide products](https://fpa.da.gov.ph/resources/reports/registered-products/) — Fertilizer and Pesticide Authority. Philippine regulator.
- [Capsicum & Eggplant Disease Field Guide](https://www.vegetables.bayer.com/content/dam/bayer-vegetables/english/australia-new-zealand/product-sheets-and-pdfs/Vegetables-by-Bayer_Capsicum-Eggplant-Disease-Guide.pdf) — Seminis / Bayer Plant Health Department. International technical guide.
- [Tomato – Spider Mites (2026)](https://ipm.cahnr.uconn.edu/tomato-spider-mites/) — University of Connecticut IPM. International extension.
- [Bacterial Leaf Spot of Lettuce](https://ipm.ucanr.edu/agriculture/lettuce/bacterial-leaf-spot/) — University of California IPM. International extension.
