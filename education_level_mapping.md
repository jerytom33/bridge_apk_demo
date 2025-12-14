# Education Level Mapping Reference

## Overview
This document defines the mapping between education level API parameters, display names, and backend values for the aptitude test system.

## Education Levels

| API Parameter | Display Name | Subtitle | Backend Value |
|--------------|-------------|----------|---------------|
| `'10th'` | "10th" | SSLC / Secondary School Completed | `10th` |
| `'12th'` | "12th" | Higher Secondary / Pre-University Completed | `12th` |
| `'Diploma'` | "Diploma / Polytechnic" | Diploma / Vocational Training Completed | `Diploma` |
| `'Bachelor'` | "Bachelor's" | Undergraduate Degree Completed | `Bachelor` |
| `'Master'` | "Master's" | Post-Graduate Degree Completed | `Master` |

## Usage in Code

### Education Level Selection
The `education_level_selection_screen.dart` sends the API parameter value when navigating:

```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => AptitudeTestScreen(educationLevel: 'Bachelor'), // API parameter
  ),
);
```

### Display Names
The `aptitude_test_screen.dart` uses a helper function to convert API values to display names:

```dart
String _getLevelDisplayName(String level) {
  const levelNames = {
    '10th': '10th Standard',
    '12th': '12th Standard',
    'Diploma': 'Diploma',
    'Bachelor': "Bachelor's Degree",
    'Master': "Master's Degree",
  };
  return levelNames[level] ?? level;
}
```

### API Validation
The `aptitude_ai_service.dart` validates incoming education levels:

```dart
const validLevels = ['10th', '12th', 'Diploma', 'Bachelor', 'Master'];
if (!validLevels.contains(educationLevel)) {
  throw Exception('Invalid education level: $educationLevel');
}
```

## Backend API

### Endpoint
```
GET /api/aptitude/personalized-questions/?level={level}&count={count}
```

### Example Requests
```bash
# 10th Standard
GET /api/aptitude/personalized-questions/?level=10th&count=10

# 12th Standard
GET /api/aptitude/personalized-questions/?level=12th&count=10

# Diploma
GET /api/aptitude/personalized-questions/?level=Diploma&count=10

# Bachelor's Degree
GET /api/aptitude/personalized-questions/?level=Bachelor&count=10

# Master's Degree
GET /api/aptitude/personalized-questions/?level=Master&count=10
```

## Implementation Notes

1. **Consistent Naming**: Always use the API parameter values ('10th', '12th', 'Diploma', 'Bachelor', 'Master') when making backend calls.

2. **Display vs API**: Display names are for UI/UX only. Never send display names to the API.

3. **Validation**: The API service validates all education levels before making requests to prevent invalid API calls.

4. **Error Messages**: Error messages include the education level to help with debugging level-specific issues.

5. **Backend Compatibility**: These values match the backend's expected parameters as of December 2025.

## Version History
- **v1.0** (Dec 2025): Initial mapping with 5 education levels
  - Changed from 'Degree' to 'Bachelor'
  - Changed from 'Masters' to 'Master'
  - Clarified Diploma/Polytechnic display naming
