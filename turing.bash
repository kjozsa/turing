#!/bin/bash

SCRIPT_NAME=$(basename "$0")
EVAL_MODEL="mistral:7b-instruct-v0.2-q8_0"
#EVAL_MODEL="mistral:7b-instruct-v3-q5km"

if [[ "$1" == "-h" ]]; then
    echo "Usage: $SCRIPT_NAME [-h] <models_to_test>"
    exit 0
fi

default_args=$(ollama ls | tail -n +2 | cut -f1 | xargs)

if [ -z "$1" ]; then
    set -- $default_args
fi

echo -e "\033[1;31mTesting models: \n$(echo "$*" | tr ' ' '\n')\n\n\033[0m"

for model in "$@"; do
    echo -e "\033[1;34mMODEL: $model\033[0m"

    while IFS= read -r question; do
        if [[ "$question" =~ ^// ]]; then
            continue
        fi
        if [[ "$question" =~ ^## ]]; then
            echo -e "\n$question\n"
            continue
        fi

        solution=$(echo "$question" | grep -oP '\(.*?\)' | tail -1)
        question=$(echo "$question" | sed -r 's/\(.*\)//')

        echo -e "\033[1;33mQUESTION: $question \033[0m"

        if [ -n "$solution" ]; then
            echo -e "\033[1;35mSOLUTION: $solution\033[0m"
        fi

        echo -e "\033[1;32mANSWER: \033[0m"
        
        answer=$(ollama run "$model" "$question" | tee /dev/stderr)

        if [ -n "$solution" ]; then
            echo -e "\033[1;31mChecking solution with $EVAL_MODEL: \033[0m"
            echo -e "\033[30mA question was answered by a Candidate. Score her answer on a scale of 0-10 against the known solution. \n\n====\nQuestion: $question\n\n====\n Answer: $answer\n\n====\nKnown solution: $solution" | ollama run "$EVAL_MODEL"
            echo -e "\033[0m"
        fi
        echo "------------------------"
    done < <(grep -v '^$' questions.txt)
done

