# Geneva Release Compose Files

EdgeX Geneva was released in May 2020.

## Minor Dot Release Inclusion
The Compose files in this folder will contain references to the EdgeX Docker images at the time of the release.  If a signficant bug was discovered, the Compose files may be updated to use the lastest dot release of the image to provide you the bug fix.  Minor (dot) releases of device services, application services or other software that is released independently (like Kuiper) of the EdgeX release ***may not*** be included in the Compose files.  You are encouraged to check for the latest releases of all EdgeX micro services and update the Compose files when you want to incorporate the latest minor releases.

## Container Access
With the Geneva release, the EdgeX Docker Compose files specify tighter default constraints around access to the containers.  By default, you must now be on the host running EdgeX in order to be able to access the APIs of any of the EdgeX micro services.  Examine all of the port definitions for each of the services and you will notice that port access is restricted to 127.0.0.1 (as shown for core data below).

``` yaml
ports:
    - "127.0.0.1:48080:48080"
    - "127.0.0.1:5563:5563"
```

Accessing the EdgeX APIs from "off-box" requires you relax these constraints; removing the localhost address restriction from the ports as shown below.  Of course, restrictions by the API Gateway (Kong) still apply when using EdgeX with security services turned on.

``` yaml
ports:
- "48080:48080"
- "5563:5563"
```

## Network name
By default, the containers are brought up on a network that is named for the owning directory or folder.  By default, it is assumed that your Compose files are in a folder called `compose-files`.  Therefore, the network name takes the folder `compose-files` as its prefix followed by `_edgex-network` for a full name of `compose-files_edgex-network`.  

When using the EdgeX UI Compose files to bring up the associated UI, note that the network configuration in these Compose files assumes the default network name.

``` yaml
networks:
  compose-files_edgex-network:
    external: true
```

Should your Compose files be in an alternate folder, make sure you change the newtork name accordingly in the UI Compose files.

## Release Notes
For more details on the EdgeX Geneva release, see the [release notes](https://wiki.edgexfoundry.org/display/FA/Geneva). 
