rm -fr dist
python3 -m build
twine upload --config-file ~/.pypirc dist/*
