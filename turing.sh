#!/usr/bin/bash

SCRIPT_NAME=$(basename "$0")

if [ "$1" = "-h" ]; then
    echo "Usage: $SCRIPT_NAME [-h] <models_to_test>"
    exit 0
fi

default_args=$(ollama ls | tail -n +2 | cut -f1 | tr '\n' ' ' | xargs)

if [ -z "$1" ]; then
    set -- $default_args
fi

tput bold
tput setaf 1
echo -en "Testing models: $*\n\n"
tput sgr0

for model in "$@"; do
    tput bold
    tput setaf 4
    echo "MODEL: $model"
    tput sgr0

    while IFS= read -r question; do
        if [[ $question =~ ^// ]]; then
            continue
        fi
        if [[ $question =~ ^## ]]; then
            echo -en "\n$question\n"
            continue
        fi

        tput bold
        tput setaf 3
        echo "QUESTION: $question"

        tput bold
        tput setaf 2
        echo "ANSWER:"

        tput sgr0
        ollama run "$model" "$question"
        echo "------------------------"
    done < <(grep -v '^$' questions.txt)
done

