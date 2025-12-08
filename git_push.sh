#!/bin/bash

echo "✏️ Enter commit message:"
read commit_msg

if [ -z "$commit_msg" ]; then
    echo "❌ Commit message cannot be empty."
    exit 1
fi

# Optional README update prompt
echo "📄 Add README log entry? (y/n)"
read add_readme

if [ "$add_readme" = "y" ]; then
    timestamp=$(date "+%Y-%m-%d %H:%M:%S")
    echo "📝 Enter README note (or leave blank):"
    read readme_note

    echo -e "\n### Update ($timestamp)\n$readme_note" >> README.md
fi

git add .

# If nothing changed, print a warning
if git diff --cached --quiet; then
    echo "⚠️ No changes detected. Exiting."
    exit 0
fi

git commit -m "$commit_msg"
git push

echo "✔ GitHub updated!"
