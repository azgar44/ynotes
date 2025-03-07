part of settings_service;

// Don't change it to const because runtime type comparisons
// would fail.
final Map<String, dynamic> _defaultSettings = {
  "global": {
    "lastReadPatchNotes": "",
    "themeId": 0,
    "api": "ecoleDirecte",
    "batterySaver": false,
    "shakeToReport": false,
    "uuid": null
  },
  "pages": {
    "homework": {"forceMonochrome": false, "fontSize": 20, "colorVariant": 0}
  },
  "notifications": {"newEmail": false, "newGrade": false}
};
