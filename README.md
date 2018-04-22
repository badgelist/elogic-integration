# eLogic Integration Server #

This application is a work-in-progress. It is a dockerized Rails app with a Postgres database.

## Docker commands ##

- `docker build` rebuilds the docker image
- `docker-compose up -d` runs the app (it will be available at `http://0.0.0.0` at the default web port 80)
- `docker ps` lists the running processes
- `docker stop` stops the app containers from running