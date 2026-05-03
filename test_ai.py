import os
import sys
from pathlib import Path

# Add the backend directory to sys.path
backend_dir = Path(r"d:\diet_planner_app\diet_backend")
sys.path.append(str(backend_dir))

# Mock the Profile object
class MockProfile:
    def __init__(self):
        self.age = 25
        self.gender = "Male"
        self.height = 175
        self.weight = 70
        self.goal = "Build Muscle"
        self.activity_level = "Active"
        self.diet_preference = "Non-Vegetarian"
        self.meal_frequency = "3 Meals"

try:
    from diet.services.meal_generator import generate_ai_meal_plan
    
    print("Testing AI Meal Generation...")
    profile = MockProfile()
    result = generate_ai_meal_plan(profile)
    
    import json
    print("\nResult:")
    print(json.dumps(result, indent=2))
    
    if result.get("raw_ai_response") == "fallback_used":
        print("\nNote: The AI returned a FALLBACK meal plan. This usually happens if the HF_TOKEN is missing or invalid.")
    else:
        print("\nSuccess! The AI generated a real meal plan.")

except Exception as e:
    print(f"\nError: {e}")
