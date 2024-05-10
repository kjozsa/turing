#!/usr/bin/fish
set SCRIPT_NAME (basename (status current-filename))


if test "$argv" = "-h"
    echo "Usage: $SCRIPT_NAME [-h] <models>"
    exit 0
end

set default_args (string trim (ollama ls | tail -n +2 | cut -f1 ))

if test -z "$argv"
	set argv $default_args
end

set_color red
echo "Testinxxxxxxxg models: $argv"
set_color normal

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

		set_color --bold yellow
		echo "QUESTION: $question "

		set_color --bold green
		echo "ANSWER: "
		
		set_color normal
		ollama run "$model" "$question"; 
		echo "------------------------"
	end
end

