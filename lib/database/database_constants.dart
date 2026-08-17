class DatabaseConstants {
  static const String databaseName = 'pawcare.db';
  static const int databaseVersion = 1;

  // Tables
  static const String tableSettings = 'settings';
  static const String tablePets = 'pets';
  static const String tableChecklists = 'checklists';
  static const String tableReminders = 'reminders';
  static const String tableBehaviourLogs = 'behaviour_logs';
  static const String tableHealthRecords = 'health_records';

  // Common Columns
  static const String colId = 'id';
  static const String colPetId = 'petId';

  // Table Settings
  static const String colSettingsKey = 'key';
  static const String colSettingsValue = 'value';

  // Table Pets
  static const String colName = 'name';
  static const String colSpecies = 'species';
  static const String colBreed = 'breed';
  static const String colAge = 'age';
  static const String colWeight = 'weight';
  static const String colPhotoPath = 'photoPath';
  static const String colOwnerUid = 'ownerUid';
  static const String colShopId = 'shopId';
  static const String colLinkCode = 'linkCode';
  static const String colIsLinked = 'isLinked';

  // Table Checklists
  static const String colTitle = 'title';
  static const String colCategory = 'category';
  static const String colIsDone = 'isDone';

  // Table Reminders
  static const String colType = 'type';
  static const String colDateTime = 'dateTime';
  static const String colRepeatOption = 'repeatOption';

  // Table Behaviour Logs
  static const String colDate = 'date';
  static const String colEatingStatus = 'eatingStatus';
  static const String colActivityLevel = 'activityLevel';
  static const String colSleepHours = 'sleepHours';
  static const String colNotes = 'notes';

  // Table Health Records
  static const String colDetails = 'details';
  static const String colAttachmentPath = 'attachmentPath';
}
