#!/bin/bash

# Function to display usage
usage() {
  echo "Usage: $0 -n <package_name> -v <package_version> [-u <pypi_username> -p <pypi_password>] <python_files>"
  exit 1
}

# Check if any arguments are provided
if [ $# -eq 0 ]; then
  usage
fi

# Parse command line arguments
while getopts "n:v:u:p:" opt; do
  case $opt in
    n) name="$OPTARG" ;;
    v) version="$OPTARG" ;;
    u) username="$OPTARG" ;;
    p) password="$OPTARG" ;;
    *) usage ;;
  esac
done

# Remove parsed options
shift $((OPTIND-1))

# Check if package name and version are provided
if [ -z "$name" ] || [ -z "$version" ]; then
  usage
fi

# Create temporary directory and copy Python files
tmp_dir=$(mktemp -d)
package_dir="${tmp_dir}/${name}-${version}"
mkdir -p "$package_dir"
for file in "$@"; do
  # Add shebang line to the Python file
  echo "#!/usr/bin/env python" > "${package_dir}/$(basename "$file")"
  cat "$file" >> "${package_dir}/$(basename "$file")"
  chmod +x "${package_dir}/$(basename "$file")"
done

# Add requirements.txt if it exists
if [ -f ./requirements.txt ]; then
  cat ./requirements.txt > "${package_dir}/requirements.txt"
fi

# Create setup.py file
modules=""
entry_points=""
for file in "$@"; do
  base_name=$(basename -s .py "$file" | tr '-' '_')
  modules="${modules}, '${base_name}'"
  entry_points="${entry_points}${base_name} = ${base_name}:main,"
done
modules=${modules#,}
entry_points=${entry_points%,}

cat > "${package_dir}/setup.py" << EOF
from setuptools import setup, find_packages

# Read requirements.txt
with open('requirements.txt') as f:
    requirements = [line.strip() for line in f.readlines()]

setup(
    name="${name}",
    version="${version}",
    packages=find_packages(),
    py_modules=[${modules}],
    install_requires=requirements,
    entry_points={
        'console_scripts': [
            '${entry_points}',
        ],
    },
    long_description=open('README.md', 'r').read(),
    long_description_content_type='text/markdown',)
EOF

# Copy README.md to project description
if [ -f ./README.md ]; then
  cat ./README.md > "${package_dir}/README.md"
fi

# Build the package
cd "$package_dir"
python setup.py sdist bdist_wheel

# Configure PyPI credentials if provided
if [ ! -z "$username" ] && [ ! -z "$password" ]; then
  cat > ~/.pypirc << EOF
[distutils]
index-servers =
  pypi

[pypi]
repository: https://upload.pypi.org/legacy/
username: ${username}
password: ${password}
EOF
fi

# Upload the package to PyPI
twine upload dist/*
