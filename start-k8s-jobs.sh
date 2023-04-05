#!/bin/bash
set -aeuo pipefail

# create the dotenv file if it doesn't exist
if [ ! -f .env ]; then
	cp .env.example .env
fi

source .env

## Run nightwatchJS jobs
for job_number in $(seq 0 $((CONCURRENT - 1))); do
	./generate_k8s_job.sh job-${job_number}
done

## Run assistant teacher on Loadero
if [ "$LOADERO_ENABLED" = true ]; then
	### change the number of concurrent classes on loadero
	curl -X PUT "https://api.loadero.com/v2/projects/${LOADERO_PROJECT_ID}/tests/${LOADERO_TEST_ID}/groups/${LOADERO_GROUP_ID}/" \
		-d "{\"name\": \"Job\", \"count\": ${CONCURRENT}}" \
		-H "Content-Type: application/json" \
		-H "Authorization: ${LOADERO_ACCESS_TOKEN}"

	### Run loadero
	curl -X POST "https://api.loadero.com/v2/projects/${LOADERO_PROJECT_ID}/tests/${LOADERO_TEST_ID}/runs/" \
		-H "Authorization: ${LOADERO_ACCESS_TOKEN}"
fi
