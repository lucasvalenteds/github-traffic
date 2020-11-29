#!/bin/sh

api_url="${API_URL:=https://api.github.com}"
personal_access_token="$1"
if [ -z "$personal_access_token" ]
then
	printf "Error: personal access token not informed.\n"
	printf "Usage: ./traffic.sh <personal_access_token>\n"
	exit 1
fi

input_file="repositories.txt"
[ ! -f "$input_file" ] && touch "$input_file"

output_directory="data"
[ ! -d "$output_directory" ] && mkdir "$output_directory"

timestamp=$(date -u +"%Y-%m-%d %H_%M_%S")
repositories=$(awk '$1=$1' FS=" " OFS="/" "$input_file")
metrics="views clones popular/referrers popular/paths"

cd "$output_directory" || exit 1

echo "$repositories" | tr ' ' '\n' | while read -r repository
do
	echo "$metrics" | tr ' ' '\n' | while read -r metric
	do
		response=$(curl --silent \
			--header "Authorization: token $personal_access_token" \
			--header "Accept: application/vnd.github.v3+json" \
			"$api_url"/repos/"$repository"/traffic/"$metric"
		)

		directory=$(echo "$repository" | sed 's/\//_/')
		metric=$(echo "$metric" | sed 's/\//_/')
		[ ! -d "$directory" ] && mkdir "$directory"
		echo "$response" > "$directory"/"$timestamp"_"$metric".json

		printf "Extracted metric %s from %s\n" "$metric" "$repository"
	done
done

cd ..

exit 0
