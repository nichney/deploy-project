#!/usr/bin/bash
# This script creates the default filestructure for python project.

deploy () {
    local lang="$1"
    local projectName="$2"

    if [[ -z "$projectName" ]]; then
        echo "Error: project name is required." >&2
        exit 4
    fi

    case "$lang" in
        python)
            echo "Begin python project deploymeny in $projectName...."
            mkdir -p "$projectName" "$projectName/tests" "$projectName/src/$projectName" # create the root directory and sub-dirs
            touch "$projectName/README.md"
            cat <<EOF > "$projectName/pyproject.toml"
[build-system]
requires = ["setuptools"]
build-backend = "setuptools.build_meta"

[project]
name = "$projectName"
version = "0.0.1"

[tool.setuptools.packages.find]
where = ["src"]
EOF
            touch "$projectName/src/$projectName/__init__.py"
            cd "$projectName" || exit
            git init 
            cd - || exit 
            echo "Project deployed!"
            ;;
        tox)
            echo "Begin tox deployment in $projectName..."
            cat <<EOF > "$projectName/tox.ini"
[tox]
envlist = py38, py39, py310, py311

[testenv]
commands = python -m unittest discover -s tests
EOF
            echo "Tox deployed!"
            ;;
        *)
            echo "Unsupported project type: $lang" >&2
            exit 4
            ;;
    esac
}


if [[ $# -eq 0 ]]; then
    echo "Usage: $0 [project type] -n project_name" >&2
    exit 1
fi

case "$1" in
    [pP]ython) 
        lang="python"
        shift
        ;;
    [Tt]ox)
        lang="tox"
        shift
        ;;
    (*)
        echo "$0: no such language: $1" >&2
        exit 3
        ;;
esac

if ! options=$(getopt -o n: -l name: -- "$@")
then
    exit 1
fi

eval set -- "$options"
projectName=""

while [[ $# -gt 0 ]]
do 
    case $1 in
        -n | --name) 
            projectName="$2";
            shift 2
            ;; 
        --)
            shift
            break
            ;;
        -*)
            echo "$0: unrecognized option $1" >&2
            exit 2
            ;;
        *)
            break;;
    esac
done

echo "$lang\n$projectName"
deploy "$lang" "$projectName"
