Bugzilla - Docker Container
===========================

Bugzilla v5.0rc3 with a (Postgresql) Database Container and data-volume.

This is mostly based upon [dklawren/docker-bugzilla](https://github.com/dklawren/docker-bugzilla) and [hbokh/docker-jira-postgresql](https://github.com/hbokh/docker-jira-postgresql). It has been changed so that the database is installed in a linked container and can be configured when the container is started. By default (and currently the only configuration I've tested) this expects a Postgresql database.


## Steps

### 1. Create a data-only container
Create a data-only container from Busybox (very small footprint) and name it "bugzilla\_datastore":
  docker run -v /data --name=bugzilla_datastore -d busybox echo "PSQL Data"

**NOTE**: data-only containers don't have to run / be active to be used.

### 2. Create a PostgreSQL container
Any database container should work. I've been using a modified version of [paintedfox/postgresql](https://registry.hub.docker.com/u/paintedfox/postgresql/) to work around an issue with a missing directory (/var/run/postgresql/9.3-main.pg_stat_tmp/). This is available from [gameldar/postgresql](https://github.com/gameldar/postgresql).

The container can be run with the following (remembering to use the volume "bugzilla\_datastore". Environment variables can be changed to whatever you like:
  docker run -d --name postgresql -e USER="bugs" -e DB="bugs" -e PASS="bugs" --volumes-from bugzilla_datastore gameldar/postgresql

### 3. Start the Bugzilla container
The bugzilla container can be started now. The following environment variables are available at instantiation of the container:
  ADMIN_EMAIL=admin@bugzilla.com
  ADMIN_PASSWORD=password
  BUGS_DB_DRIVER=Pg
  BUGS_DB_HOST=localhost
  BUGS_DB_NAME=bugs
  BUGS_DB_PASS=bugs
  BUGS_DB_USER=bugs
  BUGS_CONTEXT=http://localhost:8080


The container can be run with:
  docker run -d --name bugzilla -p 8080:80 -e ADMIN_EMAIL=test@example.com --link postgresql:db gameldar/bugzilla


Bugzilla will start up and be available on http://localhost:8080/bugzilla/. You can then log in with the ADMIN_EMAIL and ADMIN_PASSWORD values and away you go.


## Other

Tested Ubuntu Trusty.
