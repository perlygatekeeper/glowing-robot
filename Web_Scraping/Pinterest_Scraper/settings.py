import os
import yaml


def load_config(path: str = "config.yaml") -> dict:
    with open(path, "r") as f:
        return yaml.safe_load(f)


def get_env_or_config(env_key: str, config: dict, *keys, default=None):
    """
    Priority:
    1. Environment variable
    2. Config file
    3. Default
    """
    if env_key in os.environ:
        return os.environ[env_key]

    value = config
    for key in keys:
        value = value.get(key)
        if value is None:
            return default

    return value or default

