from pathlib import Path

URL = "git@github.com:ABC/XXX.git"

NAME = (URL[:-4] if URL.endswith(".git") else URL).split("/")[-1]
BASE_PATH = Path.cwd() / "repos" / NAME

WORKFLOWS_PATH = BASE_PATH / ".github" / "workflows"
