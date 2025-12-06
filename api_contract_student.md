# BridgeIT Student App API Contract

This document serves as a definitive reference for the Flutter team to implement API integrations with the BridgeIT backend. All endpoints, request/response formats, and error handling patterns are documented based on the actual backend implementation.

## 1. Authentication

### 1.1 Register

- URL: `/api/auth/register/`
- Method: `POST`
- Auth: No
- Request body:
  ```json
  {
    "name": "John Doe",
    "email": "student@example.com",
    "password": "Test@12345",
    "confirm_password": "Test@12345"
  }
  ```

- Success response:
  ```json
  {
    "success": true,
    "message": "Account created!",
    "access": "access_token_here",
    "refresh": "refresh_token_here",
    "user_id": 1
  }
  ```

- Error response examples:
  ```json
  {
    "success": false,
    "error": "Passwords do not match"
  }
  ```
  ```json
  {
    "success": false,
    "error": "User with this email already exists"
  }
  ```

> **Flutter note:** After successful registration, the app receives JWT tokens for immediate authentication.

### 1.2 Login

- URL: `/api/auth/login/`
- Method: `POST`
- Auth: No
- Request body:
  ```json
  {
    "email": "student@example.com",
    "password": "Test@12345"
  }
  ```

- Success response:
  ```json
  {
    "success": true,
    "message": "Login successful!",
    "access": "access_token_here",
    "refresh": "refresh_token_here",
    "user_id": 1
  }
  ```

- Error response examples:
  ```json
  {
    "success": false,
    "error": "Invalid credentials"
  }
  ```

> **Flutter note:** When implementing login, the app should read:
> - `data['access']` → access token  
> - `data['refresh']` → refresh token  
> - `data['user_id']` → user ID  

## 2. Profile

### 2.1 Setup Profile

- URL: `/api/auth/profile/setup/`
- Method: `PUT`
- Auth: Yes (Bearer token)
- Request body:
  ```json
  {
    "current_level": "12",
    "stream": "Science",
    "interests": ["AI", "Design"],
    "career_goals": "Software Engineer",
    "phone": "1234567890",
    "date_of_birth": "2000-01-01"
  }
  ```

- Success response:
  ```json
  {
    "message": "Profile saved successfully!",
    "profile": {
      "id": 5,
      "user": 1,
      "current_level": "12",
      "stream": "Science",
      "interests": ["AI", "Design"],
      "career_goals": "Software Engineer",
      "phone": "1234567890",
      "date_of_birth": "2000-01-01"
    }
  }
  ```

- Error response example:
  ```json
  {
    "detail": "Authentication credentials were not provided."
  }
  ```

### 2.2 Get Profile

- URL: `/api/auth/me/`
- Method: `GET`
- Auth: Yes (Bearer token)
- Success response:
  ```json
  {
    "user": {
      "id": 1,
      "username": "student@example.com",
      "first_name": "John",
      "last_name": "Doe",
      "email": "student@example.com"
    },
    "profile": {
      "id": 1,
      "user": 1,
      "current_level": "12",
      "stream": "Science",
      "interests": ["AI", "Design"],
      "career_goals": "Software Engineer",
      "phone": "1234567890",
      "date_of_birth": "2000-01-01"
    }
  }
  ```

## 3. Resume

### 3.1 Upload Resume

- URL: `/api/resume/upload/`
- Method: `POST`
- Auth: Yes (Bearer token)
- Content-Type: `multipart/form-data`
- Request:
  - Field name: `pdf_file`
  - Type: PDF only (max 5MB)

- Success response:
  ```json
  {
    "success": true,
    "message": "Resume analyzed successfully!",
    "data": {
      "id": 3,
      "user": 1,
      "pdf_file": "http://127.0.0.1:8000/media/resumes/resume_sample.pdf",
      "gemini_response": {
        "suitable_career_paths": ["Software Engineer", "Data Analyst"],
        "skill_gaps": ["Machine Learning", "Cloud Computing"],
        "recommended_courses": ["Advanced Python", "AWS Fundamentals"],
        "suggested_next_steps": ["Build portfolio projects", "Apply for internships"],
        "overall_summary": "Strong foundation in programming with opportunities to specialize in emerging technologies."
      },
      "created_at": "2023-06-15T10:30:00Z"
    }
  }
  ```

- Error response examples:
  ```json
  {
    "error": "No PDF file provided"
  }
  ```
  ```json
  {
    "error": "Only PDF files are allowed"
  }
  ```

### 3.2 Get Resume History

- URL: `/api/resume/history/`
- Method: `GET`
- Auth: Yes (Bearer token)
- Success response:
  ```json
  {
    "success": true,
    "data": [
      {
        "id": 3,
        "user": 1,
        "pdf_file": "http://127.0.0.1:8000/media/resumes/resume_sample.pdf",
        "gemini_response": {
          "suitable_career_paths": ["Software Engineer", "Data Analyst"],
          "skill_gaps": ["Machine Learning", "Cloud Computing"],
          "recommended_courses": ["Advanced Python", "AWS Fundamentals"],
          "suggested_next_steps": ["Build portfolio projects", "Apply for internships"],
          "overall_summary": "Strong foundation in programming with opportunities to specialize in emerging technologies."
        },
        "created_at": "2023-06-15T10:30:00Z"
      }
    ]
  }
  ```

## 4. Aptitude

### 4.1 Get Questions

- URL: `/api/aptitude/questions/`
- Method: `GET`
- Auth: Yes (Bearer token)
- Success response:
  ```json
  {
    "success": true,
    "data": [
      {
        "id": 1,
        "question_text": "Which of the following is a programming language?",
        "option_a": "HTML",
        "option_b": "CSS",
        "option_c": "JavaScript",
        "option_d": "XML"
      }
    ]
  }
  ```

### 4.2 Submit Test

- URL: `/api/aptitude/submit/`
- Method: `POST`
- Auth: Yes (Bearer token)
- Request body:
  ```json
  {
    "answers": {
      "1": "C",
      "2": "A"
    }
  }
  ```

- Success response:
  ```json
  {
    "success": true,
    "message": "Aptitude test submitted successfully!",
    "data": {
      "id": 5,
      "user": 1,
      "score": 20,
      "answers": {
        "1": "C",
        "2": "A"
      },
      "gemini_analysis": {
        "strengths": ["Logical reasoning", "Pattern recognition"],
        "weaknesses": ["Numerical computation", "Spatial visualization"],
        "suggested_careers": ["Software Developer", "Data Scientist", "Systems Analyst"],
        "improvement_tips": ["Practice numerical problems daily", "Work on spatial puzzles"]
      },
      "attempted_at": "2023-06-15T10:30:00Z"
    }
  }
  ```

- Error response example:
  ```json
  {
    "error": "No answers provided"
  }
  ```

### 4.3 Get History

- URL: `/api/aptitude/history/`
- Method: `GET`
- Auth: Yes (Bearer token)
- Success response:
  ```json
  {
    "success": true,
    "data": [
      {
        "id": 5,
        "user": 1,
        "score": 20,
        "answers": {
          "1": "C",
          "2": "A"
        },
        "gemini_analysis": {
          "strengths": ["Logical reasoning", "Pattern recognition"],
          "weaknesses": ["Numerical computation", "Spatial visualization"],
          "suggested_careers": ["Software Developer", "Data Scientist", "Systems Analyst"],
          "improvement_tips": ["Practice numerical problems daily", "Work on spatial puzzles"]
        },
        "attempted_at": "2023-06-15T10:30:00Z"
      }
    ]
  }
  ```

## 5. Exams

### 5.1 List Exams

- URL: `/api/exams/`
- Method: `GET`
- Auth: No
- Query Parameters:
  - `level` (optional): Education level (e.g., "10", "12", "UG", "PG")
  - `stream` (optional): Stream/subject (e.g., "Science", "Commerce", "Arts")
  - `search` (optional): Search term for title, description, or category

- Success response:
  ```json
  {
    "success": true,
    "data": [
      {
        "id": 1,
        "title": "JEE Main 2023",
        "category": "Engineering",
        "level": "12",
        "last_date": "2023-12-31",
        "link": "https://jeemain.nta.nic.in/",
        "description": "Joint Entrance Examination for engineering admissions",
        "is_active": true,
        "created_at": "2023-01-01T00:00:00Z"
      }
    ]
  }
  ```

### 5.2 Save Exam

- URL: `/api/exams/{exam_id}/save/`
- Method: `POST`
- Auth: Yes (Bearer token)
- Success response:
  ```json
  {
    "success": true,
    "message": "Exam saved successfully"
  }
  ```

- Error response:
  ```json
  {
    "success": false,
    "error": "Exam not found"
  }
  ```

### 5.3 Unsave Exam

- URL: `/api/exams/{exam_id}/unsave/`
- Method: `DELETE`
- Auth: Yes (Bearer token)
- Success response:
  ```json
  {
    "success": true,
    "message": "Exam unsaved successfully"
  }
  ```

- Error response:
  ```json
  {
    "success": false,
    "error": "Saved exam not found"
  }
  ```

### 5.4 Get Saved Exams

- URL: `/api/exams/saved/`
- Method: `GET`
- Auth: Yes (Bearer token)
- Success response:
  ```json
  {
    "success": true,
    "data": [
      {
        "id": 1,
        "exam": {
          "id": 1,
          "title": "JEE Main 2023",
          "category": "Engineering",
          "level": "12",
          "last_date": "2023-12-31",
          "link": "https://jeemain.nta.nic.in/",
          "description": "Joint Entrance Examination for engineering admissions",
          "is_active": true,
          "created_at": "2023-01-01T00:00:00Z"
        },
        "saved_at": "2023-06-15T10:30:00Z"
      }
    ]
  }
  ```

## 6. Courses

### 6.1 List Courses

- URL: `/api/courses/`
- Method: `GET`
- Auth: No
- Query Parameters:
  - `level` (optional): Education level (e.g., "10", "12", "UG", "PG")
  - `stream` (optional): Stream/subject (e.g., "Science", "Commerce", "Arts")
  - `career_path` (optional): Career path filter
  - `search` (optional): Search term for title, description, or provider

- Success response:
  ```json
  {
    "success": true,
    "data": [
      {
        "id": 1,
        "title": "Python for Beginners",
        "provider": "Coursera",
        "career_path": "Software Development",
        "duration": "4 weeks",
        "price": "Free",
        "rating": 4.8,
        "link": "https://www.coursera.org/learn/python",
        "description": "Learn Python basics in 4 weeks",
        "is_certified": true,
        "is_active": true,
        "created_at": "2023-01-01T00:00:00Z"
      }
    ]
  }
  ```

### 6.2 Save Course

- URL: `/api/courses/{course_id}/save/`
- Method: `POST`
- Auth: Yes (Bearer token)
- Success response:
  ```json
  {
    "success": true,
    "message": "Course saved successfully"
  }
  ```

- Error response:
  ```json
  {
    "success": false,
    "error": "Course not found"
  }
  ```

### 6.3 Unsave Course

- URL: `/api/courses/{course_id}/unsave/`
- Method: `DELETE`
- Auth: Yes (Bearer token)
- Success response:
  ```json
  {
    "success": true,
    "message": "Course unsaved successfully"
  }
  ```

- Error response:
  ```json
  {
    "success": false,
    "error": "Saved course not found"
  }
  ```

### 6.4 Get Saved Courses

- URL: `/api/courses/saved/`
- Method: `GET`
- Auth: Yes (Bearer token)
- Success response:
  ```json
  {
    "success": true,
    "data": [
      {
        "id": 1,
        "course": {
          "id": 1,
          "title": "Python for Beginners",
          "provider": "Coursera",
          "career_path": "Software Development",
          "duration": "4 weeks",
          "price": "Free",
          "rating": 4.8,
          "link": "https://www.coursera.org/learn/python",
          "description": "Learn Python basics in 4 weeks",
          "is_certified": true,
          "is_active": true,
          "created_at": "2023-01-01T00:00:00Z"
        },
        "saved_at": "2023-06-15T10:30:00Z"
      }
    ]
  }
  ```

## 7. Feed

### 7.1 List Posts

- URL: `/api/feed/posts/`
- Method: `GET`
- Auth: Yes (Bearer token)
- Query Parameters:
  - `level` (optional): Education level filter
  - `stream` (optional): Stream filter
  - `search` (optional): Search term for content or author
  - `author_type` (optional): Filter by author type (guide, company, admin)

- Success response:
  ```json
  {
    "success": true,
    "data": [
      {
        "id": 1,
        "author": {
          "id": 2,
          "username": "careerguide",
          "first_name": "Career",
          "last_name": "Guide"
        },
        "content": "New internship opportunities available for computer science students!",
        "post_type": "opportunity",
        "media_url": null,
        "likes_count": 15,
        "comments_count": 3,
        "created_at": "2023-06-15T10:30:00Z",
        "is_active": true,
        "is_liked": false,
        "is_saved": true,
        "like_count": 15
      }
    ]
  }
  ```

### 7.2 Like Post

- URL: `/api/feed/posts/{post_id}/like/`
- Method: `POST`
- Auth: Yes (Bearer token)
- Success response (when liking):
  ```json
  {
    "success": true,
    "message": "Post liked successfully",
    "is_liked": true,
    "like_count": 16
  }
  ```

- Success response (when unliking):
  ```json
  {
    "success": true,
    "message": "Post unliked successfully",
    "is_liked": false,
    "like_count": 15
  }
  ```

### 7.3 Save Post (TO BE IMPLEMENTED)

- URL: `/api/feed/posts/{post_id}/save/`
- Method: `POST`
- Auth: Yes (Bearer token)
- Request:
  ```json
  {
    "post_id": 10
  }
  ```

- Response:
  ```json
  {
    "success": true,
    "message": "Post saved"
  }
  ```

> **Note:** This endpoint is needed by the Student App but not yet implemented in the backend. It should be implemented to match the pattern of save/unsave for exams and courses.

## Error Handling Guidelines

1. All API responses follow a consistent structure:
   - Success responses: `{ "success": true, ... }`
   - Error responses: `{ "success": false, "error": "Description" }`

2. Authentication errors typically return:
   ```json
   {
     "detail": "Authentication credentials were not provided."
   }
   ```

3. When implementing error handling in Flutter:
   - Check for `data['success']` boolean flag
   - For errors, check both `data['error']` and `data['detail']` fields
   - Handle network errors appropriately with user-friendly messages

## Implementation Notes

1. All authenticated endpoints require a Bearer token in the Authorization header:
   ```
   Authorization: Bearer <access_token>
   ```

2. Token refresh should be implemented using the refresh token when the access token expires.

3. Date/time values are in ISO 8601 format (UTC).

4. File upload endpoints expect multipart/form-data encoding.

5. Boolean values in responses should be checked explicitly (true/false) rather than truthy/falsy.