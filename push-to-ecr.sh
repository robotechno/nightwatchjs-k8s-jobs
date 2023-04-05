#!/bin/bash

# create the dotenv file if it doesn't exist
if [ ! -f .env ]; then
	cp .env.example .env
fi

source .env

VERSION="$(cat VERSION)"
aws ecr get-login-password --region ${ECR_REGION} | docker login --username AWS --password-stdin ${ECR_DOMAIN}
docker tag ${ECR_REPO}:latest ${ECR_DOMAIN}/${ECR_REPO}:latest
docker push ${ECR_DOMAIN}/${ECR_REPO}:latest

docker tag ${ECR_REPO}:latest ${ECR_DOMAIN}/${ECR_REPO}:${VERSION}
docker push ${ECR_DOMAIN}/${ECR_REPO}:${VERSION}