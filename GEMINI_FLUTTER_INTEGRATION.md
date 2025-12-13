# Flutter Services Updated for Google Gemini Integration

## ✅ Changes Completed

### 1. Authentication Updated
Both services now use **Token-based authentication** instead of Bearer:

```dart
// Old (MegaLLM/Bearer)
'Authorization': 'Bearer $token'

// New (Gemini/Token)
'Authorization': 'Token $token'
```

### 2. Resume API Service (`resume_api_service.dart`)
- ✅ Updated to use `Token $token` authentication
- ✅ Compatible with Gemini backend response format
- ✅ No other changes needed (already compatible)

### 3. Aptitude AI Service (`aptitude_ai_service.dart`)
Updated to work with Gemini backend:

#### Changes Made:
1. **Authentication**: Changed to Token format
2. **Question Count Parameter**: Added optional `questionCount` parameter (default: 10)
3. **Response Parsing**: Updated to handle Gemini's nested response structure:
   ```dart
   // Handles: { "success": true, "data": { "questions": [...] } }
   ```
4. **Answer Format**: Changed from `Map<String, int>` to `Map<String, String>` for letter-based answers (A, B, C, D)
5. **Helper Methods**: Added conversion utilities:
   - `indexToLetter(int)` → Converts 0→A, 1→B, etc.
   - `letterToIndex(String)` → Converts A→0, B→1, etc.

---

## 📋 How to Use in Flutter App

### Fetching Personalized Questions

```dart
final aptitudeService = AptitudeAiService();

try {
  final questions = await aptitudeService.getPersonalizedQuestions(
    educationLevel: '12th',
    questionCount: 10, // Optional, defaults to 10
  );
  
  // Questions format:
  // [
  //   {
  //     "question": "What is 2+2?",
  //     "options": ["3", "4", "5", "6"],
  //     "id": "q1"
  //   }
  // ]
  
} catch (e) {
  print('Error: $e');
}
```

### Submitting Answers

```dart
// Prepare answers - use LETTER format (A, B, C, D)
Map<String, String> answers = {
  '0': 'B',  // Question index 0, answered B
  '1': 'A',  // Question index 1, answered A
  '2': 'C',  // Question index 2, answered C
};

// OR convert from index if needed
final service = AptitudeAiService();
Map<String, String> answersFromIndex = {
  '0': service.indexToLetter(1),  // Converts 1 to 'B'
  '1': service.indexToLetter(0),  // Converts 0 to 'A'
};

// Submit for analysis
try {
  final result = await aptitudeService.analyzeResults(
    questions: questions,
    answers: answers,
  );
  
  // Result format:
  // {
  //   "score": 8,
  //   "correct_answers": 8,
  //   "total_questions": 10,
  //   "ai_analysis": {
  //     "strong_areas": ["Math", "Logic"],
  //     "career_suggestions": ["Data Analyst", "Engineer"]
  //   }
  // }
  
} catch (e) {
  print('Error: $e');
}
```

### Resume Upload (No Changes Needed)

```dart
final resumeService = ResumeApiService();

try {
  final result = await resumeService.uploadResume(pdfFile);
  
  // Response includes Gemini analysis
  print('Skills: ${result.geminiResponse.suitableCareerPaths}');
  print('Career Paths: ${result.geminiResponse.skillGaps}');
  
} catch (e) {
  print('Error: $e');
}
```

---

## 🔄 Migration Notes

### If You're Updating Existing Aptitude Test Screen

**Change answer format from index to letter:**

```dart
// Old way (index-based)
Map<String, int> _answers = {
  '0': 1,  // Selected option index 1
  '1': 0,  // Selected option index 0
};

// New way (letter-based)
Map<String, String> _answers = {
  '0': 'B',  // Selected option B
  '1': 'A',  // Selected option A
};

// Or use conversion helper
final service = AptitudeAiService();
Map<String, String> convertedAnswers = {};
_oldAnswers.forEach((key, indexValue) {
  convertedAnswers[key] = service.indexToLetter(indexValue);
});
```

---

## ✅ Testing Checklist

- [ ] Test personalized question fetching with different education levels
- [ ] Verify Token authentication works (not Bearer)
- [ ] Test answer submission with letter format (A, B, C, D)
- [ ] Verify AI analysis response is parsed correctly
- [ ] Test resume upload still works
- [ ] Test error handling (network errors, timeouts, etc.)

---

## 🐛 Troubleshooting

### "Authentication failed" Error
- Ensure you're using `Token` not `Bearer` in headers
- Verify access token is stored correctly in SharedPreferences
- Check that backend is using Token authentication

### "Invalid answer format" Error
- Answers must be in letter format: "A", "B", "C", "D"
- Use `indexToLetter()` to convert from indices if needed

### Questions Not Loading
- Check backend endpoint: `/api/aptitude/personalized-questions/`
- Verify `level` parameter is correct ("10th", "12th", "Bachelors")
- Check Django logs for errors

---

## 📝 Summary

All services are now compatible with the Google Gemini backend:
- ✅ Token authentication implemented
- ✅ Response parsing updated for Gemini format
- ✅ Answer format changed to letters (A, B, C, D)
- ✅ Helper methods added for conversions
- ✅ Question count parameter added
- ✅ Backward compatible error handling

**Ready to test with your Flutter app!** 🚀
