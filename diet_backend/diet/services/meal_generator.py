import json
import os
from dotenv import load_dotenv
from huggingface_hub import InferenceClient

load_dotenv()


def _clean_json_text(text: str) -> str:
    if not text:
        raise ValueError("Empty response text from AI")

    text = text.strip()

    if text.startswith("```json"):
        text = text[len("```json"):].strip()
    if text.startswith("```"):
        text = text[len("```"):].strip()
    if text.endswith("```"):
        text = text[:-3].strip()

    return text


def _extract_text_from_completion(completion):
    if completion is None:
        raise ValueError("AI response is None")

    try:
        choice = completion.choices[0]
    except Exception:
        raise ValueError(f"Unexpected AI response shape: {completion}")

    try:
        content = choice.message.content
        if isinstance(content, str) and content.strip():
            return content
    except Exception:
        pass

    raise ValueError(f"No valid text found in AI response: {completion}")


def _fallback_meal_plan():
    return {
        "day_number": 1,
        "total_calories": 1800,
        "protein_g": 90,
        "carbs_g": 220,
        "fats_g": 55,
        "meals": {
            "breakfast": [
                {
                    "name": "Oats with Milk",
                    "calories": 300,
                    "protein_g": 10,
                    "carbs_g": 40,
                    "fats_g": 8
                }
            ],
            "lunch": [
                {
                    "name": "Rice and Dal",
                    "calories": 500,
                    "protein_g": 20,
                    "carbs_g": 70,
                    "fats_g": 10
                }
            ],
            "dinner": [
                {
                    "name": "Chapati with Sabzi",
                    "calories": 400,
                    "protein_g": 15,
                    "carbs_g": 50,
                    "fats_g": 12
                }
            ]
        },
        "raw_ai_response": "fallback_used"
    }


def generate_ai_meal_plan(profile):
    hf_token = os.getenv("HF_TOKEN")
    model_name = os.getenv("HF_MODEL", "Qwen/Qwen2.5-7B-Instruct")

    if not hf_token:
        raise ValueError("HF_TOKEN is not set")

    client = InferenceClient(api_key=hf_token)

    meal_frequency = profile.meal_frequency or "3 Meals"

    if meal_frequency == "3 Meals":
        meal_rule = "Return exactly these meal keys: breakfast, lunch, dinner."
    elif meal_frequency == "5 Small Meals":
        meal_rule = "Return exactly these meal keys: breakfast, snack_1, lunch, snack_2, dinner."
    elif meal_frequency == "Intermittent Fasting":
        meal_rule = "Return exactly these meal keys: lunch, snack, dinner."
    else:
        meal_rule = "Return meal keys that match the user's meal frequency naturally."

    prompt = f"""
Generate a realistic 1-day diet plan for this user.
Return ONLY valid JSON.

User:
Age: {profile.age}
Gender: {profile.gender}
Height: {profile.height}
Weight: {profile.weight}
Goal: {profile.goal}
Activity: {profile.activity_level}
Diet: {profile.diet_preference}
Meals: {profile.meal_frequency}

Rules:
- {meal_rule}
- Include calories + macros
- Return only JSON

Structure:
{{
  "day_number": 1,
  "total_calories": 1800,
  "protein_g": 90,
  "carbs_g": 220,
  "fats_g": 55,
  "meals": {{}}
}}
"""

    try:
        completion = client.chat.completions.create(
            model=model_name,
            messages=[
                {"role": "system", "content": "Return only JSON"},
                {"role": "user", "content": prompt}
            ],
            max_tokens=400,
            temperature=0.3,
        )

        raw_text = _extract_text_from_completion(completion)
        cleaned_text = _clean_json_text(raw_text)

        try:
            parsed = json.loads(cleaned_text)
        except Exception as e:
            print("⚠️ JSON parse failed → fallback", e)
            return _fallback_meal_plan()

        # required keys check
        required_keys = [
            "day_number",
            "total_calories",
            "protein_g",
            "carbs_g",
            "fats_g",
            "meals",
        ]

        for key in required_keys:
            if key not in parsed:
                print(f"⚠️ Missing {key} → fallback")
                return _fallback_meal_plan()

        # safe conversion
        try:
            return {
                "day_number": int(parsed["day_number"]),
                "total_calories": int(parsed["total_calories"]),
                "protein_g": float(parsed["protein_g"]),
                "carbs_g": float(parsed["carbs_g"]),
                "fats_g": float(parsed["fats_g"]),
                "meals": parsed["meals"],
                "raw_ai_response": raw_text,
            }
        except Exception as e:
            print("⚠️ Final conversion failed → fallback", e)
            return _fallback_meal_plan()

    except Exception as e:
        print("❌ AI call failed → fallback", e)
        return _fallback_meal_plan()