#!/bin/bash 


if [ -n "$1" ]; then

    url=$1

    # Remove ".git" from the end of the URL
    url=${url%.git}

    # Extract the project name using basename and string manipulation
    project_name=$(basename "$url")

    echo "Project name: $project_name"

    gcloud auth list

    gcloud config list project

    git clone $1

    cd $project_name

    export JAVA_HOME=/usr/lib/jvm/java-1.17.0-openjdk-amd64

    ./mvnw -DskipTests package

    gcloud services enable artifactregistry.googleapis.com

    gcloud artifacts repositories create codelabrepo     --repository-format=docker --location=us-central1 

    export GOOGLE_CLOUD_PROJECT=`gcloud config list --format="value(core.project)"`

    ./mvnw -DskipTests com.google.cloud.tools:jib-maven-plugin:build -Dimage=us-central1-docker.pkg.dev/${GOOGLE_CLOUD_PROJECT}/codelabrepo/hello-java:v1

    gcloud services enable compute.googleapis.com container.googleapis.com

    gcloud container clusters create hello-java-cluster --num-nodes 1 --machine-type n1-standard-1 --zone us-central1-c

    kubectl create deployment hello-java --image=us-central1-docker.pkg.dev/$GOOGLE_CLOUD_PROJECT/codelabrepo/hello-java:v1

    kubectl get deployments

    kubectl get pods

    kubectl create service loadbalancer hello-java --tcp=80:8080

    kubectl get services

    kubectl get deployment

    kubectl scale deployment hello-java --replicas=3

    kubectl get deployment

else
  echo "You need to enter a git url!"
  exit 0
fi