import json
import os
from typing import Dict, Any


class Qwen3ConfigManager:
    def __init__(self):
        self.config_file = "qwen3_config.json"
        self.default_config = {
            "model_name": "Qwen/Qwen3-30B-A3B",
            "context_length": 262144,
            "max_model_len": 262144,
            "temperature": 0.7,
            "top_k": 20,
            "top_p": 0.95,
            "repetition_penalty": 1.05,
            "enable_thinking": True,
        }

    def load_config(self) -> Dict[str, Any]:
        """Load configuration from file or create default"""
        try:
            if os.path.exists(self.config_file):
                with open(self.config_file, "r") as f:
                    return json.load(f)
            else:
                self.save_config(self.default_config)
                return self.default_config
        except Exception as e:
            print(f"Error loading config: {e}")
            return self.default_config

    def save_config(self, config: Dict[str, Any]) -> None:
        """Save configuration to file"""
        try:
            with open(self.config_file, "w") as f:
                json.dump(config, f, indent=2)
        except Exception as e:
            print(f"Error saving config: {e}")

    def update_config(self, **kwargs) -> Dict[str, Any]:
        """Update configuration and save"""
        current = self.load_config()
        current.update(kwargs)
        self.save_config(current)
        return current

    def get_model_args(self, thinking_mode: bool = True) -> Dict[str, Any]:
        """Get arguments suitable for model initialization based on settings"""
        config = self.load_config()

        # Configure for SGLang or vLLM
        if thinking_mode:
            args = {
                "model_path": config["model_name"],
                "port": 30000,
                "context_length": config["context_length"],
                "reasoning_parser": "qwen3"
                if not config["enable_thinking"]
                else "deepseek-r1",
            }
        else:
            args = {
                "model_path": config["model_name"],
                "port": 30000,
                "context_length": config["context_length"],
                "reasoning_parser": "qwen3",
                "enable_reasoning": True,
            }

        return args


# Example usage for setting up Qwen3 configuration
def setup_qwen3_environment():
    manager = Qwen3ConfigManager()

    # Load current configuration
    config = manager.load_config()
    print("Current Configuration:", json.dumps(config, indent=2))

    # Update with specific requirements
    updated_config = manager.update_config(
        model_name="Qwen/Qwen3-30B-A3B-Instruct",
        temperature=0.7,
        top_k=20,
        top_p=0.95,
        repetition_penalty=1.05,
        enable_thinking=True,
    )

    print("\nUpdated Configuration:", json.dumps(updated_config, indent=2))

    # Get arguments for SGLang server
    sglang_args = manager.get_model_args(thinking_mode=True)
    print("\nSGLang Arguments:", json.dumps(sglang_args, indent=2))

    return updated_config


# Execute the setup
setup_qwen3_environment()
