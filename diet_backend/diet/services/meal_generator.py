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

    # Normal successful chat-completion text
    try:
        content = choice.message.content
        if isinstance(content, str) and content.strip():
            return content
    except Exception:
        pass

    # If model stopped because of length and never produced final content
    finish_reason = getattr(choice, "finish_reason", None)
    reasoning = getattr(choice.message, "reasoning", None) if getattr(choice, "message", None) else None

    if reasoning and finish_reason == "length":
        raise ValueError(
            "Model used all output tokens while reasoning and did not return final JSON. "
            "Use a different model or increase token budget."
        )

    raise ValueError(f"No text content found in AI response: {completion}")


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
Return ONLY valid JSON. No markdown. No explanation.

User profile:
- Age: {profile.age}
- Gender: {profile.gender}
- Height: {profile.height} cm
- Weight: {profile.weight} kg
- Goal: {profile.goal}
- Activity level: {profile.activity_level}
- Diet preference: {profile.diet_preference}
- Meal frequency: {profile.meal_frequency}
- Timeline: {profile.timeline}
- Budget: {profile.budget}
- Cuisine: {profile.cuisine}
- Allergies: {profile.allergies}
- Medical conditions: {profile.medical_conditions}

Rules:
1. Meals must match the user's diet preference, cuisine, allergies, medical conditions, and budget.
2. {meal_rule}
3. Each meal must contain one or more food items.
4. Each food item must have:
   - name
   - calories
   - protein_g
   - carbs_g
   - fats_g
5. Include total daily calories and total macros.
6. Keep meals practical and affordable.
7. Return ONLY valid JSON in this exact structure:

{{
  "day_number": 1,
  "total_calories": 1800,
  "protein_g": 90,
  "carbs_g": 220,
  "fats_g": 55,
  "meals": {{
    "breakfast": [
      {{
        "name": "example food",
        "calories": 300,
        "protein_g": 10,
        "carbs_g": 40,
        "fats_g": 8
      }}
    ]
  }}
}}
"""

    completion = client.chat.completions.create(
        model=model_name,
        messages=[
            {
                "role": "system",
                "content": "You are a diet planner. Return only valid JSON."
            },
            {
                "role": "user",
                "content": prompt
            }
        ],
        max_tokens=800,
        temperature=0.3,
    )

    raw_text = _extract_text_from_completion(completion)
    cleaned_text = _clean_json_text(raw_text)

    try:
        parsed = json.loads(cleaned_text)
    except Exception:
        raise ValueError(f"Invalid JSON from Hugging Face model: {raw_text}")

    required_top_keys = [
        "day_number",
        "total_calories",
        "protein_g",
        "carbs_g",
        "fats_g",
        "meals",
    ]

    for key in required_top_keys:
        if key not in parsed:
            raise ValueError(f"Missing required key in AI response: {key}")

    return {
        "day_number": int(parsed["day_number"]),
        "total_calories": int(parsed["total_calories"]),
        "protein_g": float(parsed["protein_g"]),
        "carbs_g": float(parsed["carbs_g"]),
        "fats_g": float(parsed["fats_g"]),
        "meals": parsed["meals"],
        "raw_ai_response": raw_text,
    }