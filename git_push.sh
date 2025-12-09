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

    # Choose input method
    echo "🖊️ How do you want to enter the README note?"
    echo "1) Direct multi-line input in terminal (finish with Ctrl+D)"
    echo "2) Open nano editor"
    read -p "Choose 1 or 2: " input_method

    case "$input_method" in
        1)
            echo "✍️ Type your README note. Press Ctrl+D when done:"
            readme_note=""
            while IFS= read -r line; do
                readme_note+="$line"$'\n'
            done
            ;;
        2)
            tmpfile=$(mktemp /tmp/readme_note.XXXXXX)
            nano "$tmpfile"
            readme_note=$(<"$tmpfile")
            rm "$tmpfile"
            ;;
        *)
            echo "❌ Invalid option. Skipping README update."
            readme_note=""
            ;;
    esac

    # Original append-to-bottom code (commented out for reference)
    # if [ -n "$readme_note" ]; then
    #     {
    #         echo ""
    #         echo "### Update ($timestamp)"
    #         echo "$readme_note"
    #         echo ""
    #     } >> README.md
    # fi 

    # Prepend formatted block to README.md
    if [ -n "$readme_note" ]; then
        tmpfile=$(mktemp /tmp/readme_prepend.XXXXXX)
        {
            echo "### Update ($timestamp)"
            echo "$readme_note"
            echo ""
        } > "$tmpfile"

        # Add the existing README content below
        if [ -f README.md ]; then
            cat README.md >> "$tmpfile"
        fi

        mv "$tmpfile" README.md
    fi
fi

# Stage all changes
git add .

# If nothing changed, print a warning
if git diff --cached --quiet; then
    echo "⚠️ No changes detected. Exiting."
    exit 0
fi

# Commit and push
git commit -m "$commit_msg"
git push

echo "✔ GitHub updated!"

