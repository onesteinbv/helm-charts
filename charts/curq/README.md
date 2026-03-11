# CURQ Helm Chart

The CURQ Helm chart is a collection of Kubernetes manifests that can be used to deploy CURQ on a Kubernetes cluster. 
The chart includes optional convenience features such as:

 - S3 storage for filestore storage in CURQ (using CSI driver or `fs_storage`)
 - mailcow configuration for incoming and outgoing email
 - keycloak configuration for single sign on and authentication,
 - Postgres deployment and management using the pg-resource-operator

In this way it's very easy to get CURQ up and running on a Kubernetes cluster. All these features are optional and can be enabled or disabled using Helm values.

## Prerequisites

 - kubernetes-secret-generator (https://github.com/mittwald/kubernetes-secret-generator)
 - pg-resource-operator (https://github.com/tarteo/pg-resource-operator)
 - s3-operator  (https://github.com/tarteo/s3-operator) for S3 bucket management, this is optional
 - mailcow-operator (https://github.com/tarteo/mailcow-operator)

## Roadmap

 - Move or use existing chart for postgres deployment, currently the postgres deployment is included in the CURQ chart, but it should be moved to a separate chart and used as a dependency. This will allow for better separation of concerns and make it easier to manage the postgres deployment independently of the curq deployment.
