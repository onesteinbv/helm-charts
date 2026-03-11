# CURQ Helm Chart

## Prerequisites
 - kubernetes-secret-generator (https://github.com/mittwald/kubernetes-secret-generator)
 - pg-resource-operator (https://github.com/tarteo/pg-resource-operator)

## Roadmap
 - Move or use existing chart for postgres deployment, currently the postgres deployment is included in the CURQ chart, but it should be moved to a separate chart and used as a dependency. This will allow for better separation of concerns and make it easier to manage the postgres deployment independently of the curq deployment.
 