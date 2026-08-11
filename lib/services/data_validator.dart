class DataValidator {
  static final List<String> supportedSpecies = ['dog', 'cat', 'bird', 'rabbit', 'hamster'];

  static String normalizeSpecies(String species) {
    return species.trim().toLowerCase();
  }

  static bool isValidSpecies(String species) {
    return supportedSpecies.contains(normalizeSpecies(species));
  }

  static bool isValidClassification(String classification) {
    const validClassifications = ['safe', 'caution', 'toxic'];
    return validClassifications.contains(classification.trim().toLowerCase());
  }

  static bool isValidRiskLevel(String riskLevel) {
    const validRiskLevels = ['low', 'moderate', 'high'];
    return validRiskLevels.contains(riskLevel.trim().toLowerCase());
  }

  static bool validateBreedRecord(Map<String, dynamic> record) {
    if (record['id'] == null || record['id'].toString().isEmpty) return false;
    if (record['breed'] == null || record['breed'].toString().isEmpty) return false;
    if (record['species'] == null || !isValidSpecies(record['species'].toString())) return false;
    return true;
  }

  static bool validateFoodRecord(Map<String, dynamic> record) {
    if (record['id'] == null || record['id'].toString().isEmpty) return false;
    if (record['foodName'] == null || record['foodName'].toString().isEmpty) return false;
    
    final classification = record['classification']?.toString() ?? '';
    if (!isValidClassification(classification)) return false;

    final riskLevel = record['riskLevel']?.toString() ?? '';
    if (!isValidRiskLevel(riskLevel)) return false;

    return true;
  }

  static bool validateVaccineRecord(Map<String, dynamic> record) {
    if (record['id'] == null || record['id'].toString().isEmpty) return false;
    if (record['vaccineName'] == null || record['vaccineName'].toString().isEmpty) return false;
    if (record['species'] == null || !isValidSpecies(record['species'].toString())) return false;
    return true;
  }

  static bool validateDiseaseRecord(Map<String, dynamic> record) {
    if (record['id'] == null || record['id'].toString().isEmpty) return false;
    if (record['diseaseName'] == null || record['diseaseName'].toString().isEmpty) return false;
    if (record['species'] == null || !isValidSpecies(record['species'].toString())) return false;
    return true;
  }

  static bool validateBehaviourRecord(Map<String, dynamic> record) {
    if (record['id'] == null || record['id'].toString().isEmpty) return false;
    if (record['behaviour'] == null || record['behaviour'].toString().isEmpty) return false;
    if (record['species'] == null || !isValidSpecies(record['species'].toString())) return false;
    return true;
  }

  static bool validateEnvironmentRecord(Map<String, dynamic> record) {
    if (record['id'] == null || record['id'].toString().isEmpty) return false;
    if (record['species'] == null || !isValidSpecies(record['species'].toString())) return false;
    return true;
  }

  static bool validateGrowthStageRecord(Map<String, dynamic> record) {
    if (record['id'] == null || record['id'].toString().isEmpty) return false;
    if (record['stage'] == null || record['stage'].toString().isEmpty) return false;
    if (record['species'] == null || !isValidSpecies(record['species'].toString())) return false;
    return true;
  }

  static bool validateCareGuideRecord(Map<String, dynamic> record) {
    if (record['id'] == null || record['id'].toString().isEmpty) return false;
    if (record['title'] == null || record['title'].toString().isEmpty) return false;
    if (record['species'] == null || !isValidSpecies(record['species'].toString())) return false;
    return true;
  }
}
