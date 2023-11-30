pwd
find . -type f \( -name "index.html" -o -name "app.py" \) -not -path "./venv/*" -exec sh -c 'echo "\n\n" && echo -- "${0##*/}" && cat "${0}"' {} \; > find.txt
echo output find.txt