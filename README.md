# eLogic Integration Server #

This application is a work-in-progress. It is a dockerized Rails app with a MySQL database.

## Docker commands ##

- `docker build` rebuilds the docker image
- `docker-compose up -d` runs the app (it will be available at `http://0.0.0.0` at the default web port 80)
- `docker ps` lists the running processes
- `docker exec -it elogicintegration_app_1 bash` brings up a bash terminal where you can use `rails c` to open a rails console or run any other commands (ex: `bundle exec rake db:migrate`)
- `docker stop` stops the app containers from running

### Creating the first user ###

Note that there are no user permissions levels included in this app. All users are admins. To get started you will need to create the first admin manually by running `docker-compose up -d` then `docker exec -it elogicintegration_app_1 bash` then `rails c` to bring up a rails console. Then you'll be able to create a user with the following rails command:

```ruby
User.create(email: 'test@example.com', password: 'abc123', name: 'First Admin User')
```

Note that there is no email validation. The only emails sent out by this server will be the password reset emails.

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

**To Deploy Changes to Production:**

There are two parts to this deployment, the first part might be unneeded depending on what sort of deployment this is.

### Step 0: Figure out current image version ###

First run `kubectl get pods`, then grab the name of the web pod (if there are multiples it doesn't matter which you grab unless there is a rollout pending) and put it into the command `kubectl describe pod [pod-name]`. In the describe info look under Containers > web > Image and you should see `us.gcr.io/[project-id]/elogicintegration_app:[versionTag]`. The important part is the `[versionTag]`, that is the **current version tag**. For example's sake let's say that the version tag is `v42`. When updating the rails app image we increment the version tag by one, so the **new version tag** will be `v43`.

The last part of this step is to open up `./kube/web-deployment.yml` and make sure that the `image:` key matches the **current version tag** (don't use the new tag just yet, that will happen later). The reason you need to check that the image matches the current version is because it is possible to deploy an updated version without updating the web deployment YAML, so these can get out of sync.

Assuming the image key matches the current version tag, you are ready to continue to the next step.

### Step 1: Update web-deployment yaml environment variables if needed ###

Now you need to determine if this deployment will result in updating anything other than the version of the rails image. 

Open up `./kube/web-deployment.yml` and look through the file. (Do not yet make changes to the image version, that will come in the next step.) If the only thing that needs to change is the image version of the rails app, then this is a **single-step deployment** and you can continue to step 2. If, on the other hand, you need to update some other part of the web deployment (this will most commonly happen if you added or changed environment variables), then this will be a **two-step deployment**, the first step is outlined in the rest of this section.

Note: If you have somehow updated environment variables in a way that will result in a breaking change unless the new code is present then you have found a use case which is not yet covered buy these instructions. You'll need to figure out a different process (and also update these instructions!).

Assuming that you *do* need to update the deployment file...

If you're adding new environment variables you have two options for each variable:
- If this is an environment variable which is ok to put in source control, then you can put it directly into `web-deployment.yml` file.
- If this is a secret or should otherwise not be committed to source control, then use `kubectl edit secret/app-secrets` to edit the app secrets file and add it there, then reference it in the `web-deployment.yml` file.

If you are _only_ changing the value of an existing environment variable that comes from the app-secrets file then you may need to change the value of the `forceUpdateKey:` metadata field (or any other field you like) in order to trigger a rollout. Otherwise when you apply the changes kubernetes will ignore them.

Once you've updated the web deployment file (but left the image version set to the **current version tag**), you just need to apply the updated yaml file by running the command `kubectl apply -f kube/web-deployment.yml`. 

Wait for the rollout to complete. (You can check the status by running `kubectl get pods`.) Once it is done, continue to the next step.

### Step 2: Push the new rails image version ###

Note that you can skip this step if you are only making changes to the environment variables (or the `web-deployment.yml` itself). In that case then you only need to do step 1.

Open up `./kube/web-deployment.yml` and change the `image:` key to match the **new version tag** (as determined in step 0). In our example that would mean going from `v42` to `v43`. (Note: You will not actually use the web-deployment YAML file at all in this step. The reason why it is still important to update the file is so that the current version gets committed to source control. Also it makes it less confusing the next time you need to do a two-step deployment.)

With that done you can move on to the actual deployment. Use the commands below to rebuild the docker image, push it to Google's private repository and execute the new version deployment script.

```bash
# Rebuild the docker image file
docker build -t elogicintegration_app -f Dockerfile-production .

# Tag it with the NEW verison tag and push it to google private repository
docker tag elogicintegration_app us.gcr.io/badge-list/elogicintegration_app:v43
gcloud docker -- push us.gcr.io/badge-list/elogicintegration_app:v43

# Execute the new version deployment script with the NEW version tag as a parameter
scripts/deploy-new-version.sh v43
```

You can track the rollout process by running `kubectl get pods`. Once the rollout is complete you can continue to the final step.

### Step 3: Commit changes to source control ##

The deployment is now complete, but don't forget to commit the updated `web-deployment.yml` file to source control!

## Scaling ##

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

## Initial Setup Process ##

This is a walk through of the initial process of copying this code, modifying it and then getting it to run on your own cloud instance. It assumes you will be running on Google Kubernetes Engine, but the same basic instructions should work for any Kubernetes-based system.

### Google Prep ###

To begin you'll need to make sure you have a Google Cloud project with billing enabled. Open the [Google Cloud Console](https://console.cloud.google.com/) and create a project (remember the id), then enable billing for it. Then you'll need to install the Google Cloud SDK and configure the CLI.

Before moving on you'll want to fork this repo and replace the project id `badge-list` with whatever your own Google Cloud Project Id is. The best way is to do a full text search for `badge-list` across all of the files in the repo, but it should only appear in a couple of places:
- `kube/web-deployment.yml`
- `scripts/deploy.sh`

Then you'll want to create a cluster to house all of the pieces of the integration:
```
gcloud container clusters create elogic-integration \
    --enable-cloud-logging \
    --enable-cloud-monitoring \
    --machine-type n1-standard-2 \
    --num-nodes 1
```

Then run `gcloud container clusters get-credentials rails` to give kubectl the credentials it needs to begin deploying containers. Afterwards you should be able to successfully run `kubectl cluster-info`.

Now create a separate database pool.
```
gcloud container node-pools create db-pool \
    --machine-type=n1-highmem-2 \
    --num-nodes=1 \
    --cluster=rails
```

That's it for the basic setup. Next you'll move on to creating the actual components of the integration.

### MySQL ###

First create a secure password using a password generator and then encode it in base 64. Then generate a random secret base key and encode that in base 64 as well. Record the unencoded password, the encoded password and the encoded secret key somewhere safe.

```
% echo -n 'generate a secure password and put it here' | base64 
Z2VuZXJhdGUgYSBzZWN1cmUgcGFzc3dvcmQgYW5kIHB1dCBpdCBoZXJl
% docker-compose run --rm app rake secret | base64
YzcwZTYyODdhYmIzNjE1NzI4MjkwYTA1ZjNmZDlkM2NlYWU2NzIzNGY0ZDFlYTc2OTQyODFkOTM0MTczNWEwYzA0NWEzYjAxZGVkMDEyYjBhODQxNzhmNDAxMjY2OTA2ZDJjMDM2ZTY3MWQ1MzZkNDZhZDhiZGVlOGEwYjQ5ODY=
```

Then create a file named `app-secrets.yml` in the `./kube` folder and the contents should be the like the following (but with your own values inserted):

```
# ./kube/app-secrets.yml
apiVersion: v1
data:
  mysql_password: Z2VuZXJhdGUgYSBzZWN1cmUgcGFzc3dvcmQgYW5kIHB1dCBpdCBoZXJl
  secret_key_base: YzcwZTYyODdhYmIzNjE1NzI4MjkwYTA1ZjNmZDlkM2NlYWU2NzIzNGY0ZDFlYTc2OTQyODFkOTM0MTczNWEwYzA0NWEzYjAxZGVkMDEyYjBhODQxNzhmNDAxMjY2OTA2ZDJjMDM2ZTY3MWQ1MzZkNDZhZDhiZGVlOGEwYjQ5ODY=
kind: Secret
type: Opaque
metadata:
  name: app-secrets
```

Use `kubectl create -f kube/app-secrets.yml` to create the secret object in kubernetes master. After this is successful, you **delete this file**. (If you commit this file, you will be exposing your credentials to whoever has access to your source control. **Base64 is not encryption**, you can decode it just as easily as you encoded it). You can edit the file later with `kubectl edit secret/app-secrets`. Your editor will open and you can edit the details and send the updates straight to kubernetes master in the cluster.

Define the storage class with `kubectl create -f kube/ssd-storage-class.yml`, then define the volume claim with `kubectl create -f kube/mysql-volume-claim.yml`.

Now you can create the mysql deployment itself with `kubectl create -f kube/mysql-deployment.yml`. 

Run `kubectl get pods` to see the status of your newly created pods. It might take a minute or two for the pod to go to status `Running`. If it takes to long try `kubectl describe pod [pod_name]` using the pod name from the get pods command.

Once that's done you can create the mysql service (which exposes mysql to the rest of the cluster) using `kubectl create -f kube/mysql-service.yml`. It should now be returned when you run `kubectl get services`.

If you’d like to connect to your mysql pod from your local machine, try `kubectl port-forward [pod_name] 3306:3306` and connect to localhost:3306 with a MySQL client. The pod name will be available via `kubectl get pods`.

### Rails App ###

Follow the instructions in the Deployment section above to build the docker image, push it to Google and then use the deployment script to deploy it.

### Load Balancer / Public IP Address ###

Now you need to expose the Rails app to the public internet by registering a public IP address and connecting a load balancer between the IP address and the app node(s).

First create a public IP address using `gcloud compute addresses create web-external — region=us-central1`, but change the region to be the same as that in which you've created all of the other components. You should then be able to get the ip address details using `gcloud compute addresses describe web-external`.

Now take the IP address and put it into the `./kube/web-service.yml` file. (Replace the existing value for `loadBalancerIP`.)

Now you can run `kubectl -f kube/web-service.yml` to create the load balancer.

You should now be able to go to the IP address in your web browser and see the UI!

### App Setup ###

**FIXME**

Need to add instructions for initial app setup.

## Testing ##

**Prerequisites:**

- `brew cask install chromedriver`

## Environment Variables ##

```
app_name=eLogic Integration Server
root_domain=abc.yourdomain.com # dev value = localhost
root_url=https://abc.yourdomain.com # dev value = http://localhost
MYSQL_PASSWORD=database_root_password
from_email=knowledgestreem@gmail.com
gmail_password=gmail_app_password # set this to use gmail smtp, notes: here >> http://guides.rubyonrails.org/action_mailer_basics.html#action-mailer-configuration-for-gmail
admin_email=test@example.com # Displayed on signin page
```
