import 'papusoy_forecasting.dart';

/// Maps the exact normalized human-readable disease values stored by
/// ClassificationResult.conditionName to Notebook 03 disease class IDs.
/// Canonical labels are also accepted for backups or future schema changes.
const papusoyDiseaseAliases = <DiseaseKey, String>{
  (crop: 'banana', disease: 'cordana'): 'banana_cordana',
  (crop: 'banana', disease: 'banana_cordana'): 'banana_cordana',
  (crop: 'banana', disease: 'panama wilt'): 'banana_panama_wilt',
  (crop: 'banana', disease: 'banana_panama_wilt'): 'banana_panama_wilt',
  (crop: 'banana', disease: 'sigatoka'): 'banana_sigatoka',
  (crop: 'banana', disease: 'banana_sigatoka'): 'banana_sigatoka',
  (crop: 'lettuce', disease: 'bacterial'): 'lettuce_bacterial',
  (crop: 'lettuce', disease: 'lettuce_bacterial'): 'lettuce_bacterial',
  (crop: 'lettuce', disease: 'fungal'): 'lettuce_fungal',
  (crop: 'lettuce', disease: 'lettuce_fungal'): 'lettuce_fungal',
  (crop: 'lettuce', disease: 'insect pest'): 'lettuce_insect_pest',
  (crop: 'lettuce', disease: 'lettuce_insect_pest'): 'lettuce_insect_pest',
  (crop: 'pineapple', disease: 'fusarium'): 'pineapple_fusarium',
  (crop: 'pineapple', disease: 'pineapple_fusarium'): 'pineapple_fusarium',
  (crop: 'pineapple', disease: 'leaf blight'): 'pineapple_leaf_blight',
  (crop: 'pineapple', disease: 'pineapple_leaf_blight'):
      'pineapple_leaf_blight',
  (crop: 'pineapple', disease: 'mealybug wilt'): 'pineapple_mealybug_wilt',
  (crop: 'pineapple', disease: 'pineapple_mealybug_wilt'):
      'pineapple_mealybug_wilt',
  (crop: 'tomato', disease: 'early/late blight'): 'tomato_early-late_blight',
  (crop: 'tomato', disease: 'tomato_early-late_blight'):
      'tomato_early-late_blight',
  (crop: 'tomato', disease: 'insect damage'): 'tomato_insect_damage',
  (crop: 'tomato', disease: 'tomato_insect_damage'): 'tomato_insect_damage',
  (crop: 'tomato', disease: 'leaf curl virus'): 'tomato_leaf_curl_virus',
  (crop: 'tomato', disease: 'tomato_leaf_curl_virus'): 'tomato_leaf_curl_virus',
  (crop: 'tomato', disease: 'leaf miner'): 'tomato_leaf_miner',
  (crop: 'tomato', disease: 'tomato_leaf_miner'): 'tomato_leaf_miner',
  (crop: 'tomato', disease: 'leaf mold'): 'tomato_leaf_mold',
  (crop: 'tomato', disease: 'tomato_leaf_mold'): 'tomato_leaf_mold',
};

const papusoyDiseaseDisplayNames = <String, String>{
  'banana_cordana': 'Cordana leaf spot',
  'banana_panama_wilt': 'Panama wilt',
  'banana_sigatoka': 'Sigatoka',
  'lettuce_bacterial': 'Bacterial disease',
  'lettuce_fungal': 'Fungal disease',
  'lettuce_insect_pest': 'Insect pest damage',
  'pineapple_fusarium': 'Fusarium',
  'pineapple_leaf_blight': 'Leaf blight',
  'pineapple_mealybug_wilt': 'Mealybug wilt',
  'tomato_early-late_blight': 'Early/late blight',
  'tomato_insect_damage': 'Insect damage',
  'tomato_leaf_curl_virus': 'Leaf curl virus',
  'tomato_leaf_miner': 'Leaf miner',
  'tomato_leaf_mold': 'Leaf mold',
};
