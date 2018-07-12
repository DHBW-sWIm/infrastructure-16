# Introduction

Dockerfile to build an [Activiti](#http://www.activiti.org/) BPM container image.

Based on [Frank Wang's work](https://github.com/eternnoir/activiti) this has been extended with support for PostgreSQL.

## Versions
* Java: 7u79-jdk
* Tomcat: 8.0.24
* Activiti: 5.18.0
* PostgreSQL driver: 9.4-1201.jdbc41 (needs >= 9.4 server)
* Mysql connector: 5.1.36

# Using
This image can be deployed with an H2 database for persistence.

**For production use it is recommended to use a remote database server.**

When linking containers, environment variables are shared into the target.  This means the database server's administrative account credentials are exposed.  If your DB instance has multiple schemas this could present a security risk.  Better to have a dedicated account that just gives the permissions needed.

## Accessing
Once deployed you can access the UI via:

```
http://<ip of docker host>:<container's 8080 port>/activiti-explorer
```

And the REST resources via:

```
http://<ip of docker host>:<container's 8080 port>/activiti-rest
```

There is no root resource, so expect to access the API via paths such as *activiti-rest/service/repository/deployments*.  See [Activiti's User Guide](http://www.activiti.org/userguide/#_rest_api) for information on the resources available.

Login with *kermit/kermit*.

## Extending
You will probably want to add custom service tasks and their dependencies to your Activiti instance.

In a nutshell you create a new Dockerfile, use `cwoodcock\docker` for the **FROM** statement and you can then add/customise your setup as you see fit.

See [this gist](https://gist.github.com/cwoodcock/9bedaa402ba79b1de13c) for some ideas.

### Ports
Some of the commands below use docker's `-P` flag which maps the exposed ports to random ports on the Docker host.  This may/may not be what you want.  You can use `-p 8080:nnnn` instead if you want it assigned to a specific port.

You can use `docker ps` to see what the mapping is.

<a id="using_postgres"></a>

# Advanced Configuration

*Please refer the docker run command options for the `--env-file` flag where you can specify all required environment variables in a single file. This will save you from writing a potentially long docker run command.*

Below is the complete list of available options that can be used to customize your Activiti installation.

## Required Parameters
- **DB_TYPE**: h2

## Optional Parameters
- **DB_HOST**: The database server hostname.
- **DB_PORT**: The database server port.  Has sane defaults depending on DB_TYPE (1521 for H2).
- **DB_NAME**: The database name. Defaults to `activiti`.
- **DB_USER**: The database user. When linking, it uses the root user for the database otherwise `activiti`.
- **DB_PASS**: The database password.  When linking this will be discovered from the environment, when remote it **must** be supplied.
- **TOMCAT\_ADMIN\_USER**: Tomcat admin user name. Defaults to `admin`.
- **TOMCAT\_ADMIN\_PASSWORD**: Tomcat admin user password. Defaults to `admin`.

The initialisation script will attempt to discover DB_* parameters (other than DB\_TYPE) however if supplied they take precedence.

# Maintenance

## Shell Access

For debugging and maintenance purposes you may want access the container shell. Since the container does not allow interactive login over the SSH protocol, you can use the [nsenter](http://man7.org/linux/man-pages/man1/nsenter.1.html) linux tool (part of the util-linux package) to access the container shell.

Some linux distros (e.g. ubuntu) use older versions of the util-linux which do not include the `nsenter` tool. To get around this @jpetazzo has created a nice docker image that allows you to install the `nsenter` utility and a helper script named `docker-enter` on these distros.

To install the nsenter tool on your host execute the following command.

```bash
docker run --rm -v /usr/local/bin:/target jpetazzo/nsenter
```

Now you can access the container shell using the command

```bash
sudo docker-enter activiti
```

For more information refer https://github.com/jpetazzo/nsenter

Another tool named `nsinit` can also be used for the same purpose. Please refer https://jpetazzo.github.io/2014/03/23/lxc-attach-nsinit-nsenter-docker-0-9/ for more information.

# References

* http://activiti.org/
* http://github.com/Activiti/Activiti
* http://tomcat.apache.org/
* http://dev.mysql.com/downloads/connector/j/5.1.html
* https://github.com/jpetazzo/nsenter
* https://jpetazzo.github.io/2014/03/23/lxc-attach-nsinit-nsenter-docker-0-9/
