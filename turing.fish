#!/usr/bin/fish
set SCRIPT_NAME (basename (status current-filename))
set EVAL_MODEL "mistral:7b-instruct-v0.2-q8_0"

if test "$argv" = "-h"
    echo "Usage: $SCRIPT_NAME [-h] <models_to_test>"
    exit 0
end

set default_args (string trim (ollama ls | tail -n +2 | cut -f1 ))

if test -z "$argv"
	set argv $default_args
end

set_color --bold red
echo -en "Testing models: \n"(echo $argv | tr ' ' '\n' | string collect) "\n\n"

for model in $argv
	set_color --bold blue
	echo "MODEL: $model"
	set_color normal

	for question in (cat questions.txt | grep -v '^$')
		if echo $question | grep "^//" &>/dev/null
			continue
		end
		if echo $question | grep "^##" &>/dev/null
			echo -en "\n$question\n"
			continue
		end

		set solution (string match -r '\((.*)\)' $question | tail -1)
        set question (string replace -r '\(.*\)' '' -- $question)

		set_color --bold yellow
		echo "QUESTION: $question "

		if test -n "$solution"
    		set_color --bold purple
		    echo "SOLUTION: $solution"
		end

		set_color --bold green
		echo "ANSWER: "
		
		set_color normal
		set answer (ollama run "$model" "$question" | tee /dev/stderr)

		if test -n "$solution"
    		set_color --bold red
		    echo "Checking solution with $EVAL_MODEL: "
    		set_color black
		    echo -en "A question was answered by a Candidate. Score her answer on a scale of 0-10 against the known solution. \n\n====\nQiestion: $question\n\n====\n Answer: $answer\n\n====\nKnown solution: $solution" | ollama run $EVAL_MODEL
        	set_color normal
        end
		echo "------------------------"
	end
end

