from operator import ge
import os
from pathlib import Path
import shutil
from config import general, repository, aws

# Create ec2 instance
os.system(
    f"bash src/create_ec2.sh {aws.ACCESS_KEY_ID} {aws.SECRET_ACCESS_KEY} {repository.NAME}"
)

# await confirmation for adding secrets to github
input("Add secrets to github and press enter to continue...")


print("Cloning repository...")
# clone repo
if repository.BASE_PATH.exists():
    shutil.rmtree(repository.BASE_PATH)
os.system(
    "eval `ssh-agent`;"
    + f"ssh-add {general.SSH_FILE};"
    + f"git clone {repository.URL} {repository.BASE_PATH}"
)

# predefined workflows directory
WORKFLOWS_PATH = Path.cwd() / "workflows" / general.TYPE

print("Adding deployment files...")
# create workflows folder if not exists
if not repository.WORKFLOWS_PATH.exists():
    repository.WORKFLOWS_PATH.mkdir(parents=True)

# copy deployment files
for file in WORKFLOWS_PATH.iterdir():
    shutil.copyfile(file, repository.WORKFLOWS_PATH / file.name)

print("pushing changes to github...")
# commit and push changes to repo
os.system(
    f"cd {repository.BASE_PATH};"
    + "eval `ssh-agent`;"
    + f"ssh-add {general.SSH_FILE};"
    + "git add .github/workflows/;"
    + "git commit -m 'add deployment files';"
    + "git push"
)
