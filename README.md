# eLogic Integration Server #

This application is a work-in-progress. It is a dockerized Rails app with a Postgres database.

## Docker commands ##

- `docker build` rebuilds the docker image
- `docker-compose up -d` runs the app (it will be available at `http://0.0.0.0` at the default web port 80)
- `docker ps` lists the running processes
- `docker exec -it dockerexample_app_1 /bin/bash` brings up a bash terminal where you can use `rails c` to open a rails console
- `docker stop` stops the app containers from running

## Docker setup in development ##

Create a `.env` file in the root to store environment variables.

In order to allow live updating of the rails server code in development, you'll need to create a `docker-compose.override.yml` file in the root with the following contents.

```yaml
app:
  
  # map our application source code, in full, to the application root of our container
  volumes:
    - .:/var/www/elogic_integration_root

web:

  # use whatever volumes are configured for the app container
  volumes_from:
    - app
```
