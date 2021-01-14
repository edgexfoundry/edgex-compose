# Edgex releases

## Overview

This folder contains supporting files to run various current and historical versions of EdgeX in Docker.

## Table of Contents

- [Nightly Build](#nightly-build)
    - [Docker Compose](#docker-compose-for-nightly-build)
- [Geneva Release](#geneva-release)
    - [Docker Compose](#docker-compose-for-geneva-release)
- [Fuji Release](#fuji-release)
    - [Docker Compose](#docker-compose-for-fuji-release)
- [Edinburgh Release](#edinburgh-release)
    - [Docker Compose](#docker-compose-for-edinburgh-release)
- [Delhi Release](#edinburgh-release)
    - [Docker Compose](#docker-compose-for-delhi-release)
- [California Release](#california-release)
    - [Docker Compose](#docker-compose-for-california-release)
- [Barcelona Release](#barcelona-release)
    - [Docker Compose](#docker-compose-for-barcelona-release)

## Nightly Build 

### Docker Compose for Nightly Build

* Available releases include:
* [`docker-compose-nexus-redis.yml`](https://github.com/edgexfoundry/developer-scripts/blob/master/releases/nightly-build/compose-files/docker-compose-geneva-redis.yml)
      uses the latest EdgeX **master **branch container images with Redis for persistence. 
* [`docker-compose-nexus-mongo.yml`](https://github.com/edgexfoundry/developer-scripts/blob/master/releases/nightly-build/compose-files/docker-compose-geneva-mongo.yml)
      uses the latest EdgeX **master **branch container images with Mongo for persistence. 
* [`docker-compose-nexus-redis-no-secty.yml`](https://github.com/edgexfoundry/developer-scripts/blob/master/releases/nightly-build/compose-files/docker-compose-geneva-redis-no-secty.yml) 
      uses the latest EdgeX **master **branch container images with Redis for persistence and does not include security services.
* [`docker-compose-nexus-mongo-no-secty.yml`](https://github.com/edgexfoundry/developer-scripts/blob/master/releases/nightly-build/compose-files/docker-compose-geneva-mongo-no-secty.yml) 
      uses the latest EdgeX **master **branch container images with Mongo for persistence and does not include security services.
* [`docker-compose-portainer.yml`](https://github.com/edgexfoundry/developer-scripts/blob/master/releases/nightly-build/compose-files/docker-compose-portainer.yml) 
      uses the Portianer container image for optional container management

The Docker Compose files have device service elements that have all been commented out (except for the device-virtual service). Uncomment the sections for the device services you need.

Using these Docker Compose files will require you have [access to the EdgeX Nexus repository](https://docs.edgexfoundry.org/Ch-GettingStartedUsersNexus.html).

## Geneva Release

### Docker Compose for Geneva Release

Available releases include:

* [`docker-compose-geneva-redis.yml`](https://github.com/edgexfoundry/developer-scripts/blob/master/releases/geneva/compose-files/docker-compose-geneva-redis.yml)
  uses the EdgeX **Geneva release 1.2.0** container images with Redis for persistence. 
  
* [`docker-compose-geneva-mongo.yml`](https://github.com/edgexfoundry/developer-scripts/blob/master/releases/geneva/compose-files/docker-compose-geneva-mongo.yml)
  uses the EdgeX **Geneva release 1.2.0** container images with Mongo for persistence. 
  
* [`docker-compose-geneva-redis-no-secty.yml`](https://github.com/edgexfoundry/developer-scripts/blob/master/releases/geneva/compose-files/docker-compose-geneva-redis-no-secty.yml) 
  uses the EdgeX **Geneva release 1.2.0** container images with Redis for persistence and does not include security services.
  
* [`docker-compose-geneva-mongo-no-secty.yml`](https://github.com/edgexfoundry/developer-scripts/blob/master/releases/geneva/compose-files/docker-compose-geneva-mongo-no-secty.yml) 
  uses the EdgeX **Geneva release 1.2.0** container images with Mongo for persistence and does not include security services.
  
* [`docker-compose-geneva-ui.yml`](https://github.com/edgexfoundry/developer-scripts/blob/master/releases/nightly-build/compose-files/docker-compose-geneva-ui.yml)
  
  uses the optional EdgeX **Geneva release 1.2.0** UI container image for development or demo purposes.
  
* [`docker-compose-portainer.yml`](https://github.com/edgexfoundry/developer-scripts/blob/master/releases/geneva/compose-files/docker-compose-portainer.yml) 
  uses the Portianer container image for optional container management

The Docker Compose files have device service elements that have all been commented out (except for the device-virtual service). Uncomment the sections for the device services you need.

## Fuji Release

### Docker Compose for Fuji Release

Available releases include:

* [`docker-compose-fuji.yml`](https://github.com/edgexfoundry/developer-scripts/tree/master/releases/fuji/compose-files/docker-compose-fuji.yml) 
    uses the EdgeX **Fuji release 1.1.0** container images.

* [`docker-compose-fuji-no-secty.yml`](https://github.com/edgexfoundry/developer-scripts/tree/master/releases/fuji/compose-files/docker-compose-fuji-no-secty.yml) 
    uses the EdgeX **Fuji release 1.1.0** container images and does not include security services.

* [`docker-compose-redis-fuji-no-secty.yml`](https://github.com/edgexfoundry/developer-scripts/tree/master/releases/fuji/compose-files/docker-compose-redis-fuji-no-secty.yml) 
    uses the EdgeX **Fuji release 1.1.0** container images, includes the Redis container (for use when using Redis in persistence with core data, metadata or logging), and does not include security services.

The Docker Compose files have device service elements that have all been commented out (except for the device-virtual service). Uncomment the sections for the device services you need.

## Edinburgh Release

### Docker Compose for Edinburgh Release

Available releases include:

* [`docker-compose-edinburgh-1.0.1.yml`](https://github.com/edgexfoundry/developer-scripts/tree/master/releases/edinburgh/compose-files/docker-compose-edinburgh-1.0.1.yml) 
    uses the EdgeX **Edinburgh release 1.0.1** container images.

* [`docker-compose-edinburgh-no-secty-1.0.1.yml`](https://github.com/edgexfoundry/developer-scripts/tree/master/releases/edinburgh/compose-files/docker-compose-edinburgh-no-secty-1.0.1.yml) 
    uses the EdgeX **Edinburgh release 1.0.1** container images and does not include security services.

* [`docker-compose-redis-edinburgh-no-secty-1.0.1.yml`](https://github.com/edgexfoundry/developer-scripts/tree/master/releases/edinburgh/compose-files/docker-compose-redis-edinburgh-no-secty-1.0.1.yml) 
    uses the EdgeX **Edinburgh release 1.0.1** container images, includes the Redis container (for use when using Redis in persistence with core data, metadata or logging), and does not include security services.

The Docker Compose files have device service elements that have all been commented out (except for the device-virtual service). Uncomment the sections for the device services you need.

## Delhi Release

### Docker Compose for Delhi Release

Available releases include:

* [`docker-compose-redis-delhi-0.7.1.yml`](https://github.com/edgexfoundry/developer-scripts/tree/master/releases/delhi/compose-files/docker-compose-redis-delhi-0.7.1.yml) 
    uses the EdgeX **Delhi release 0.7.1** container images and includes the Redis container (for use when using Redis in persistence with core data, metadata or logging).
    
* [`docker-compose-delhi-0.7.1.yml`](https://github.com/edgexfoundry/developer-scripts/tree/master/releases/delhi/compose-files/docker-compose-delhi-0.7.1.yml) 
    uses the EdgeX **Delhi release 0.7.1** container images.

* [`docker-compose-delhi-0.7.0.yml`](https://github.com/edgexfoundry/developer-scripts/tree/master/releases/delhi/compose-files/docker-compose-delhi-0.7.0.yml) 
    uses the EdgeX **Delhi release 0.7.0** container images.

The Docker Compose files have device service elements that have all been commented out (except for the device-virtual service). Uncomment the sections for the device services you need.

## California Release

### Docker Compose for California Release

Available releases include:

* [`docker-compose-california-0.6.1.yml`](https://github.com/edgexfoundry/developer-scripts/tree/master/releases/california/compose-files/docker-compose-california-0.6.1.yml) 
    uses the EdgeX **California release 0.6.1** container images.  This release was a minor revision of the California release.  It includes the new Go notification micro service and some bug fixes (including a correction to rules engine).
    
* [`docker-compose-california-0.6.0.yml`](https://github.com/edgexfoundry/developer-scripts/tree/master/releases/california/compose-files/docker-compose-california-0.6.0.yml) 
    uses the EdgeX **California release 0.6.0** container images.

The Docker Compose files have device service elements that have all been commented out (except for the device-virtual service). Uncomment the sections for the device services you need.

## Barcelona Release

### Docker Compose for Barcelona Release

Available releases include:

* [`docker-compose-barcelona-0.2.1.yml`](https://github.com/edgexfoundry/developer-scripts/tree/master/releases/barcelona/compose-files/docker-compose-barcelona-0.2.1.yml) 
    uses the EdgeX **Barcelona release 0.2.1** container images.  Release 0.2.1 was a bug fix release to version 0.2.0; some of the 0.2.1 release containers did not require a fix and are left at version 0.2.0.
    
* [`docker-compose-barcelona-0.2.0.yml`](https://github.com/edgexfoundry/developer-scripts/tree/master/releases/barcelona/compose-files/docker-compose-barcelona-0.2.0.yml) 
    uses the EdgeX **Barcelona release 0.2.0** container images.  This release has an issue whereby the health check address for each of the micro services was not set correctly.  The release will still run and perform its duties, but Consul will not be able to appropriately know the status of all the services.

The Docker Compose files have device service elements that have all been commented out (except for the device-virtual service). Uncomment the sections for the device services you need.