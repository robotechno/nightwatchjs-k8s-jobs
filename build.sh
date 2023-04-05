#!/bin/bash

# create the dotenv file if it doesn't exist
if [ ! -f .env ]; then
	cp .env.example .env
fi

source .env

docker build -t nightwatchjs .
