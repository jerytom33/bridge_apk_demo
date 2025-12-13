"""
MegaLLM Service for AI-powered Resume Analysis and Aptitude Test Generation
Uses OpenAI-compatible API from MegaLLM (https://ai.megallm.io/v1)
"""

import os
import json
from openai import OpenAI
from typing import Dict, List, Any, Optional
import logging

logger = logging.getLogger(__name__)


class MegaLLMService:
    """Service class to handle all MegaLLM AI operations"""
    
    def __init__(self):
        """Initialize the MegaLLM client with API credentials"""
        api_key = os.getenv('MEGALLM_API_KEY')
        base_url = os.getenv('MEGALLM_BASE_URL', 'https://ai.megallm.io/v1')
        
        if not api_key:
            raise ValueError("MEGALLM_API_KEY environment variable not set")
        
        self.client = OpenAI(
            api_key=api_key,
            base_url=base_url
        )
        self.model = os.getenv('MEGALLM_MODEL', 'gpt-5')
    
    def analyze_resume(self, resume_text: str) -> Dict[str, Any]:
        """
        Analyze resume using MegaLLM AI
        
        Args:
            resume_text: Extracted text from resume PDF
            
        Returns:
            Dictionary containing:
            - extracted_skills: List of identified skills
            - career_paths: Recommended career paths
            - strengths: Key strengths identified
            - improvements: Suggestions for improvement
            - ai_summary: Overall summary
        """
        try:
            prompt = f"""Analyze the following resume and provide detailed insights in JSON format.

Resume Text:
{resume_text}

Please provide your analysis in the following JSON structure:
{{
    "extracted_skills": ["skill1", "skill2", ...],
    "technical_skills": ["technical skill1", "technical skill2", ...],
    "soft_skills": ["soft skill1", "soft skill2", ...],
    "career_paths": ["career path1", "career path2", ...],
    "strengths": ["strength1", "strength2", ...],
    "improvements": ["improvement1", "improvement2", ...],
    "ai_summary": "A comprehensive summary of the resume",
    "experience_level": "Entry/Mid/Senior level",
    "recommended_roles": ["role1", "role2", ...]
}}

Focus on:
1. Extracting both technical and soft skills
2. Suggesting realistic career paths based on experience and skills
3. Highlighting what the candidate does well
4. Providing actionable improvements (not generic advice)
5. Recommending specific job roles that match the profile
"""

            response = self.client.chat.completions.create(
                model=self.model,
                messages=[
                    {"role": "system", "content": "You are an expert career counselor and resume analyst. Provide detailed, actionable feedback."},
                    {"role": "user", "content": prompt}
                ],
                temperature=0.7,
                max_tokens=2000
            )
            
            # Parse the AI response
            ai_response = response.choices[0].message.content.strip()
            
            # Try to extract JSON from the response
            try:
                # Remove markdown code blocks if present
                if '```json' in ai_response:
                    ai_response = ai_response.split('```json')[1].split('```')[0].strip()
                elif '```' in ai_response:
                    ai_response = ai_response.split('```')[1].split('```')[0].strip()
                
                analysis = json.loads(ai_response)
            except json.JSONDecodeError:
                logger.warning("Failed to parse JSON from AI response, using fallback structure")
                # Fallback structure if JSON parsing fails
                analysis = {
                    "extracted_skills": [],
                    "technical_skills": [],
                    "soft_skills": [],
                    "career_paths": ["Further analysis needed"],
                    "strengths": ["Content reviewed"],
                    "improvements": ["Unable to provide detailed analysis"],
                    "ai_summary": ai_response[:500],  # Use first 500 chars
                    "experience_level": "Unknown",
                    "recommended_roles": []
                }
            
            return analysis
            
        except Exception as e:
            logger.error(f"Error analyzing resume with MegaLLM: {str(e)}")
            raise Exception(f"Resume analysis failed: {str(e)}")
    
    def generate_aptitude_questions(
        self, 
        education_level: str, 
        user_profile: Optional[Dict[str, Any]] = None
    ) -> List[Dict[str, Any]]:
        """
        Generate personalized aptitude test questions
        
        Args:
            education_level: '10th' or '12th'
            user_profile: Optional dict containing:
                - interests: List of interests
                - career_goals: Career aspirations
                - previous_scores: Any previous test results
                
        Returns:
            List of question dictionaries with format:
            {
                'id': int,
                'section': str (Science/Commerce/Humanities or STEM/Business/Creative),
                'question': str,
                'options': List[str],
                'correct_option': int,
                'difficulty': str (Easy/Medium/Hard),
                'why_this_question': str (explanation)
            }
        """
        try:
            # Build context from user profile
            context = f"Education Level: {education_level}"
            if user_profile:
                if user_profile.get('interests'):
                    context += f"\nInterests: {', '.join(user_profile['interests'])}"
                if user_profile.get('career_goals'):
                    context += f"\nCareer Goals: {user_profile['career_goals']}"
            
            prompt = f"""Generate 15 aptitude test questions personalized for a student.

Student Profile:
{context}

Requirements:
1. Create 5 questions each for three sections:
   - For 10th grade: Science, Commerce, Humanities
   - For 12th grade: STEM, Business, Creative
2. Questions should assess analytical thinking, problem-solving, and domain aptitude
3. Difficulty should be appropriate for {education_level} level
4. Questions should be slightly personalized based on the student's interests and goals
5. Each question must have 4 options with one correct answer

Return ONLY a JSON array with this exact structure:
[
    {{
        "id": 1,
        "section": "Science/Commerce/Humanities or STEM/Business/Creative",
        "question": "Question text here?",
        "options": ["Option A", "Option B", "Option C", "Option D"],
        "correct_option": 0,
        "difficulty": "Easy/Medium/Hard",
        "why_this_question": "Brief explanation of why this question is relevant"
    }},
    ...
]

Make sure:
- IDs are sequential from 1 to 15
- Questions are clear and unambiguous
- Options are all plausible but with one clearly correct answer
- Mix of difficulty levels (5 easy, 7 medium, 3 hard)
"""

            response = self.client.chat.completions.create(
                model=self.model,
                messages=[
                    {"role": "system", "content": "You are an expert educational psychologist and test designer. Create engaging, fair, and insightful questions."},
                    {"role": "user", "content": prompt}
                ],
                temperature=0.8,
                max_tokens=3000
            )
            
            ai_response = response.choices[0].message.content.strip()
            
            # Parse JSON response
            try:
                if '```json' in ai_response:
                    ai_response = ai_response.split('```json')[1].split('```')[0].strip()
                elif '```' in ai_response:
                    ai_response = ai_response.split('```')[1].split('```')[0].strip()
                
                questions = json.loads(ai_response)
                
                # Validate structure
                if not isinstance(questions, list) or len(questions) != 15:
                    raise ValueError("Invalid number of questions generated")
                
                return questions
                
            except (json.JSONDecodeError, ValueError) as e:
                logger.error(f"Failed to parse questions from AI: {str(e)}")
                raise Exception("Failed to generate valid questions")
                
        except Exception as e:
            logger.error(f"Error generating aptitude questions: {str(e)}")
            raise Exception(f"Question generation failed: {str(e)}")
    
    def analyze_aptitude_results(
        self,
        questions: List[Dict[str, Any]],
        answers: Dict[str, int],
        user_profile: Optional[Dict[str, Any]] = None
    ) -> Dict[str, Any]:
        """
        Analyze aptitude test results and provide personalized feedback
        
        Args:
            questions: List of questions that were asked
            answers: Dict mapping question_id to selected option index
            user_profile: Optional user profile information
            
        Returns:
            Dictionary containing:
            - strengths: List of identified strengths
            - weaknesses: List of areas for improvement
            - suggested_careers: Career recommendations
            - improvement_tips: Specific suggestions
            - overall_assessment: General feedback
        """
        try:
            # Calculate performance by section
            section_performance = {}
            for question in questions:
                section = question['section']
                if section not in section_performance:
                    section_performance[section] = {'correct': 0, 'total': 0}
                
                section_performance[section]['total'] += 1
                question_id = str(question['id'])
                
                if question_id in answers and answers[question_id] == question['correct_option']:
                    section_performance[section]['correct'] += 1
            
            # Build analysis prompt
            performance_summary = "\n".join([
                f"{section}: {perf['correct']}/{perf['total']} correct ({perf['correct']/perf['total']*100:.1f}%)"
                for section, perf in section_performance.items()
            ])
            
            context = ""
            if user_profile:
                context = f"\nUser Profile: {json.dumps(user_profile, indent=2)}"
            
            prompt = f"""Analyze the following aptitude test results and provide personalized career guidance.

Performance Summary:
{performance_summary}
{context}

Provide analysis in this JSON structure:
{{
    "strengths": ["specific strength 1", "specific strength 2", ...],
    "weaknesses": ["specific weakness 1", "specific weakness 2", ...],
    "suggested_careers": ["career 1", "career 2", ...],
    "improvement_tips": ["actionable tip 1", "actionable tip 2", ...],
    "overall_assessment": "A comprehensive assessment paragraph",
    "next_steps": ["step 1", "step 2", ...]
}}

Focus on:
1. Identifying genuine strengths based on performance
2. Suggesting realistic careers aligned with strong areas
3. Providing specific, actionable improvement tips
4. Encouraging and supportive overall assessment
"""

            response = self.client.chat.completions.create(
                model=self.model,
                messages=[
                    {"role": "system", "content": "You are a compassionate career counselor focused on helping students discover their potential."},
                    {"role": "user", "content": prompt}
                ],
                temperature=0.7,
                max_tokens=1500
            )
            
            ai_response = response.choices[0].message.content.strip()
            
            try:
                if '```json' in ai_response:
                    ai_response = ai_response.split('```json')[1].split('```')[0].strip()
                elif '```' in ai_response:
                    ai_response = ai_response.split('```')[1].split('```')[0].strip()
                
                analysis = json.loads(ai_response)
                return analysis
                
            except json.JSONDecodeError:
                logger.warning("Failed to parse analysis JSON, using minimal structure")
                return {
                    "strengths": ["Test completed successfully"],
                    "weaknesses": ["Analysis pending"],
                    "suggested_careers": ["Multiple options available"],
                    "improvement_tips": ["Continue learning and exploring"],
                    "overall_assessment": ai_response[:500],
                    "next_steps": ["Review results", "Consult with counselor"]
                }
                
        except Exception as e:
            logger.error(f"Error analyzing aptitude results: {str(e)}")
            raise Exception(f"Results analysis failed: {str(e)}")


# Singleton instance
_megallm_service = None

def get_megallm_service() -> MegaLLMService:
    """Get or create the MegaLLM service instance"""
    global _megallm_service
    if _megallm_service is None:
        _megallm_service = MegaLLMService()
    return _megallm_service
