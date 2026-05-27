import json
from pathlib import Path
import pandas as pd

# Create a summary table of Qwen3 features
qwen3_features = {
    "Model Variant": ["Instruct", "Thinking"],
    "Context Length": ["256K tokens", "256K tokens"],
    "Max Context": ["1M tokens", "1M tokens"],
    "Sizes": [
        "0.6B, 1.7B, 4B, 8B, 14B, 32B, 30B-A3B, 235B-A22B",
        "235B-A22B, 30B-A3B, 4B",
    ],
    "Languages": ["100+", "100+"],
    "Key Capabilities": [
        "Instruction following, reasoning, coding, tool usage",
        "Complex logical reasoning, math, science, coding",
    ],
}

df = pd.DataFrame(qwen3_features)
print(df.to_string(index=False))

# Create configuration files
model_analysis = Path("model_analysis.json")

# Save configs to files
with model_analysis.open("w") as f:
    json.dump(df.to_string(), f, indent=2)
