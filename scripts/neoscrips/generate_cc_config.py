import json
from pathlib import Path


def generate_codecompanion_config():
    """Generate CodeCompanion.nvim configuration for Qwen3-Coder-30B-A3B-Instruct"""

    # Configuration structure
    config = {
        "provider": "openai",
        "base_url": "http://localhost:1234/v1",
        "model": "Qwen/Qwen3-Coder-30B-A3B-Instruct",
        "temperature": 0.7,
        "max_tokens": 8192,
        "context_length": 262144,
        "settings": {
            "compact_prompt": True,
            "enable_tool_use": False,
            "enable_reasoning": False,
        },
    }

    # Generate model settings file (for LM Studio)
    lmstudio_config = {
        "model": "Qwen3-Coder-30B-A3B-Instruct",
        "context_length": 262144,
        "kv_cache_quantization": False,
        "quantization": "4bit",
    }

    # Generate VSCode settings
    vscode_settings = {
        "codecompanion.provider": "openai",
        "codecompanion.base_url": "http://localhost:1234/v1",
        "codecompanion.model": "Qwen/Qwen3-Coder-30B-A3B-Instruct",
        "codecompanion.temperature": 0.7,
        "codecompanion.max_tokens": 8192,
        "codecompanion.compact_prompt": True,
    }

    return {
        "config_json": config,
        "lmstudio_config": lmstudio_config,
        "vscode_settings": vscode_settings,
    }


# Generate configuration files
configs = generate_codecompanion_config()

print("CodeCompanion.nvim Configuration for Qwen3-Coder-30B-A3B-Instruct")
print("=" * 60)

print("\n1. Main Configuration (config.json):")
print(json.dumps(configs["config_json"], indent=2))

print("\n2. LM Studio Configuration:")
print(json.dumps(configs["lmstudio_config"], indent=2))

print("\n3. VSCode Settings:")
for key, value in configs["vscode_settings"].items():
    print(f"   {key}: {value}")

# Create configuration files
config_file = Path("config.json")
vscode_file = Path(".vscode", "settings.json")

# Ensure directories exist
vscode_dir = Path(".vscode")
vscode_dir.mkdir(exist_ok=True)

# Save configs to files
with config_file.open("w") as f:
    json.dump(configs["config_json"], f, indent=2)

print(f"\nConfiguration saved to {config_file}")

# Create VSCode settings file
vscode_settings_content = {
    "codecompanion.provider": configs["vscode_settings"]["codecompanion.provider"],
    "codecompanion.base_url": configs["vscode_settings"]["codecompanion.base_url"],
    "codecompanion.model": configs["vscode_settings"]["codecompanion.model"],
    "codecompanion.temperature": configs["vscode_settings"][
        "codecompanion.temperature"
    ],
    "codecompanion.max_tokens": configs["vscode_settings"]["codecompanion.max_tokens"],
    "codecompanion.compact_prompt": configs["vscode_settings"][
        "codecompanion.compact_prompt"
    ],
}

with (vscode_dir / "settings.json").open("w") as f:
    json.dump(vscode_settings_content, f, indent=2)

print(f"VSCode settings saved to {vscode_dir / 'settings.json'}")
