import json
import os
import random
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
        return choice.message.content
    except Exception:
        raise ValueError(f"Unexpected AI response shape: {completion}")


def _fallback_meal_plan():
    # Real fallback with actual Indian food names
    return {
        "day_number": 1,
        "total_calories": 1800,
        "protein_g": 90,
        "carbs_g": 220,
        "fats_g": 55,
        "meals": {
            "breakfast": [{"name": "Poha with Peanuts", "calories": 350, "protein_g": 10, "carbs_g": 50, "fats_g": 12}],
            "lunch": [{"name": "Dal Tadka and Rice", "calories": 600, "protein_g": 20, "carbs_g": 85, "fats_g": 15}],
            "dinner": [{"name": "Paneer Sabzi and 2 Chapati", "calories": 550, "protein_g": 25, "carbs_g": 60, "fats_g": 20}]
        },
        "raw_ai_response": "fallback_used"
    }


def generate_ai_meal_plan(profile):
    hf_token = os.getenv("HF_TOKEN")
    model_name = os.getenv("HF_MODEL", "Qwen/Qwen2.5-7B-Instruct")
    client = InferenceClient(api_key=hf_token)

    # Simplified Indian food name generator for fixes
    indian_dishes = {
        "breakfast": ["Vegetable Upma", "Stuffed Paratha", "Idli Sambhar", "Moong Dal Chilla", "Oats Khichdi"],
        "lunch": ["Chicken Curry & Rice", "Rajma Chawal", "Bhindi Masala & Roti", "Fish Curry & Brown Rice", "Mixed Veg & Paratha"],
        "dinner": ["Paneer Bhurji & Roti", "Egg Curry & Rice", "Grilled Soya Chaap", "Boiled Dal & Sabzi", "Tofu Salad"]
    }

    prompt = f"""
Generate a 1-day Indian diet plan for a {profile.age}yo {profile.gender} ({profile.goal}).
Diet: {profile.diet_preference}.

Output ONLY JSON:
{{
  "day_number": 1,
  "total_calories": 2000,
  "protein_g": 100,
  "carbs_g": 250,
  "fats_g": 60,
  "meals": {{
    "breakfast": [{{ "name": "Dish Name", "calories": 400, "protein_g": 15, "carbs_g": 50, "fats_g": 10 }}],
    "lunch": [{{ "name": "Dish Name", "calories": 600, "protein_g": 25, "carbs_g": 80, "fats_g": 15 }}],
    "dinner": [{{ "name": "Dish Name", "calories": 500, "protein_g": 25, "carbs_g": 60, "fats_g": 12 }}]
  }}
}}
"""

    try:
        print(f"[AI] Generating for {profile.firebase_uid}...")
        completion = client.chat.completions.create(
            model=model_name,
            messages=[{"role": "system", "content": "You are a Nutritionist. Return only JSON."}, {"role": "user", "content": prompt}],
            max_tokens=800, temperature=0.3,
        )

        raw_text = _extract_text_from_completion(completion)
        cleaned_text = _clean_json_text(raw_text)
        print(f"--- RAW ---\n{cleaned_text}\n-----------")

        parsed = json.loads(cleaned_text)
        meals = parsed.get("meals", {})
        final_meals = {}

        # STRONG FIXING LOGIC
        for m_type in ["breakfast", "lunch", "dinner"]:
            val = meals.get(m_type)
            items_list = []
            
            if isinstance(val, list) and len(val) > 0:
                for item in val:
                    name = item.get("name", "")
                    if not name or "dish" in name.lower() or "name" in name.lower():
                        item["name"] = random.choice(indian_dishes[m_type])
                    items_list.append(item)
            elif isinstance(val, dict):
                name = val.get("name", "")
                if not name or "dish" in name.lower() or "name" in name.lower():
                    val["name"] = random.choice(indian_dishes[m_type])
                items_list.append(val)
            else:
                # Total failure for this meal, use random Indian dish
                items_list.append({
                    "name": random.choice(indian_dishes[m_type]),
                    "calories": parsed.get("total_calories", 2000) // 3,
                    "protein_g": parsed.get("protein_g", 100) // 3,
                    "carbs_g": parsed.get("carbs_g", 250) // 3,
                    "fats_g": parsed.get("fats_g", 60) // 3
                })
            
            final_meals[m_type] = items_list

        return {
            "day_number": int(parsed.get("day_number", 1)),
            "total_calories": int(parsed.get("total_calories", 0)),
            "protein_g": float(parsed.get("protein_g", 0)),
            "carbs_g": float(parsed.get("carbs_g", 0)),
            "fats_g": float(parsed.get("fats_g", 0)),
            "meals": final_meals,
            "raw_ai_response": raw_text,
        }

    except Exception as e:
        print(f"❌ Error: {e}")
        return _fallback_meal_plan()