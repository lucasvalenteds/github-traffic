#!/bin/sh

assert_directory_exists() {
	if [ ! -d "$1" ]
	then
		printf "\nDirectory should exist: %s" "$1"
		exit 1
	fi
}

assert_directory_does_not_exists() {
	if [ -d "$1" ]
	then
		printf "\nDirectory should not exist: %s" "$1"
		exit 1
	fi
}

assert_directory_is_not_empty() {
	files=$(find "$1" -maxdepth 2 -name '*.json' | wc --lines)

	if [ "$files" = 0 ]
	then
		printf "\nDirectory should not be empty: %s" "$1"
		exit 1
	fi
}

assert_file_exists() {
	if [ ! -f "$1" ]
	then
		printf "\nFile should exist: %s" "$1"
		exit 1
	fi
}

assert_file_does_not_exists() {
	if [ -f "$1" ]
	then
		printf "\nFile should not exist: %s" "$1"
		exit 1
	fi
}

assert_file_is_empty() {
	if [ ! "$(cat "$1")" = "" ]
	then
		printf "\nFile should be empty: %s" "$1"
		exit 1
	fi
}

assert_file_is_not_empty() {
	if [ "$(cat "$1")" = "" ]
	then
		printf "\nFile should not be empty: %s" "$1"
		exit 1
	fi
}

container_image="github-traffic:latest"
container_name="github-traffic-stub"
container_port=8081

export API_URL="http://localhost:$container_port"

input_file="repositories.txt"
output_directory="data"

provision_api_stub() {
	docker build --tag "$container_image" ./stubbing
	docker run --rm --detach \
		--publish "$container_port":8080 \
		--name "$container_name" \
		github-traffic:latest

	exit 0
}

destroy_api_stub() {
	docker stop "$container_name"
	docker rmi "$container_image"

	exit 0
}

create_test_workspace() {
	touch "$input_file"
	{
	echo "johnsmith hello_world"
	echo "johnsmith java-playground"
	echo "johnsmith my-project-1"
	echo "johnsmith ProjectMVP"
	} >> "$input_file"

	assert_file_exists "$input_file" || printf "input file does not exists" ; exit 1
	assert_file_is_not_empty "$input_file" || printf "input file is empty"; exit 1

	exit 0
}

delete_test_workspace() {
	rm --force --recursive "$output_directory"
	rm --force "$input_file"

	assert_directory_does_not_exists "$output_directory"
	assert_file_does_not_exists "$input_file"

	exit 0
}

test_fails_when_token_not_informed() {
	(delete_test_workspace)

	(./traffic.sh) > /dev/null 2>&1

	if [ "$?" = 1 ]
	then
		printf "PASSED: test_fails_when_token_not_informed\n"
		exit 0
	else
		printf "FAILED: test_fails_when_token_not_informed\n"
		printf "\tThe script should fail to run without an access token\n"
		exit 1
	fi
}

test_creating_empty_data_and_repositories() {
	(delete_test_workspace)

	(./traffic.sh token) > /dev/null 2>&1

	if [ "$?" ]
	then
		(assert_file_exists "$input_file")
		(assert_file_is_empty "$input_file")
		(assert_directory_exists "$output_directory")
		printf "PASSED: test_creating_empty_data_and_repositories\n"
		exit 0
	else
		printf "FAILED: test_creating_empty_data_and_repositories\n"
		printf "\tThe input file and output directory should be created automatically\n"
		exit 1
	fi
}

test_extracting_metrics() {
	(delete_test_workspace)
	(create_test_workspace)

	(./traffic.sh "some-token") > /dev/null 2>&1

	if [ "$?" ]
	then
		(assert_file_exists "$input_file")
		(assert_file_is_not_empty "$input_file")
		(assert_directory_exists "$output_directory")
		(assert_directory_is_not_empty "$output_directory")
		printf "PASSED: test_extracting_metrics\n"
		exit 0
	else
		printf "FAILED: test_extracting_metrics\n"
		printf "\tThe metrics should be extracted and persisted\n"
		exit 1
	fi
}

(provision_api_stub > /dev/null 2>&1)

(test_fails_when_token_not_informed)
(test_creating_empty_data_and_repositories)
(test_extracting_metrics)

(delete_test_workspace)
(destroy_api_stub > /dev/null 2>&1)

