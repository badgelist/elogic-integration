# eLogic Integration Server #

This application is a work-in-progress. It is a dockerized Rails app with a Postgres database.

## Docker commands ##

- `docker build` rebuilds the docker image
- `docker-compose up -d` runs the app (it will be available at `http://0.0.0.0` at the default web port 80)
- `docker ps` lists the running processes
- `docker exec -it elogicintegration_app_1 bash` brings up a bash terminal where you can use `rails c` to open a rails console or run any other commands (ex: `bundle exec rake db:migrate`)
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

## Kubernetes Commands ##

`kubectl edit secret/app-secrets` opens an editor to edit the app secrets file. The file is of the format:

```yaml
apiVersion: v1
data:
  postgres_user: base64_encoded_username
  postgres_password: base64_encoded_password
  secret_key_base: base64_encoded_secret_key
kind: Secret
type: Opaque
metadata:
  name: app-secrets
```

## Deploying Changes to Kubernetes / Google Kubernetes Engine ##

**Pre-Requisites:**
- You need to have gettext installed in order to use the `envsubst` command in `scripts/deploy.sh`. To install it on Mac, run `brew install gettext` and then `brew link --force gettext`.

**To Deploy and Run the Deploy Tasks (Do it this way always):**

Be sure to change `v42` to whatever you set the version tag to be.

```bash
# First: Go ahead and check the update web-deployment.yml by incrementing the version. This will help keep track of the lastest version.

# Rebuild the docker image file
docker build -t elogicintegration_app -f Dockerfile-production .

# Tag it and push it to google private repository
docker tag elogicintegration_app us.gcr.io/badge-list/elogicintegration_app:v42
gcloud docker -- push us.gcr.io/badge-list/elogicintegration_app:v42

scripts/deploy.sh v42
```

**A Manual Desployment Would Look Something Like This (FYI, don't do it this way though):**
```bash
# Rebuild the docker image file
docker build -t elogicintegration_app -f Dockerfile-production .

# Tag it and push it to google private repository
docker tag elogicintegration_app us.gcr.io/badge-list/elogicintegration_app:v2
gcloud docker -- push us.gcr.io/badge-list/elogicintegration_app:v2

# Then update the web-deployment.yml file to point at the latest version and apply the changes
kubectl apply -f kube/web-deployment.yml
```

### Scaling ###

To change the number of web nodes: `kubectl scale deployments/web --replicas 1` (where 1 is the number of web nodes to have). Auto-scaling is not currently implemented, but it is easy to do. Follow the instructions in the "Autoscaling" section of [this tutorial](https://engineering.adwerx.com/rails-on-kubernetes-8cd4940eacbe).

Or basically just create something like this...
```yaml
# ./kube/web-autoscaler.yml
apiVersion: extensions/v1beta1
kind: HorizontalPodAutoscaler
metadata:
  name: web
  namespace: default
spec:
  scaleRef:
    kind: Deployment
    name: web
    subresource: scale
  minReplicas: 1
  maxReplicas: 5
  cpuUtilization:
    targetPercentage: 70
```

The above example scales when the cpu utilization tops 70%. To add this just run `kubectl create -f kube/web-autoscaler.yml`.