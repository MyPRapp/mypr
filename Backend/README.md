For python virtual environment copy-paste these commands in a bash terminal:

        python -m venv .venv
        ./.venv/Scripts/activate
        pip install -r requirements.txt

If a new pip package is installed, run this command before pushing to GitHub:

        pip freeze > requirements.txt
