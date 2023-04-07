pwd
find . -type f \( -name "*.js" -o -name "*.html" -o -name "*.py" -o -name "*.sh" \) -not -path "./venv/*" -exec sh -c 'echo "\n\n" && echo -- "${0##*/}" && cat "${0}"' {} \; > find.txt
echo output find.txt