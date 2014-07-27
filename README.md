# PostgreSQL Dockerfile

A Dockerfile that produces a Docker Image for [PostgreSQL](http://www.postgresql.org/).

## PostgreSQL version

The `master` branch currently hosts PostgreSQL 9.3.

Different versions of PostgreSQL are located at the github repo [branches](https://github.com/frodenas/docker-postgresql/branches).

## Usage

### Build the image

To create the image `frodenas/postgresql`, execute the following command on the `docker-postgresql` folder:

```
$ docker build -t frodenas/postgresql .
```

### Run the image

To run the image and bind to host port 5432:

```
$ docker run -d --name postgresql -p 5432:5432 frodenas/postgresql
```

The first time you run your container, a new user `pgadmin` with all privileges will be created with a random password.
To get the password, check the logs of the container by running:

```
docker logs <CONTAINER_ID>
```

You will see an output like the following:

```
========================================================================
PostgreSQL User: "pgadmin"
PostgreSQL Password: "WH7fwqY7bJCEMYKC"
========================================================================
```

#### Credentials

If you want to preset credentials instead of a random generated ones, you can set the following environment
variables:

* `POSTGRES_USERNAME` to set a specific username
* `POSTGRES_PASSWORD` to set a specific password

On this example we will preset our custom username and password:

```
$ docker run -d \
    --name postgresql \
    -p 5432:5432 \
    -e POSTGRES_USERNAME=myuser \
    -e POSTGRES_PASSWORD=mypassword \
    frodenas/postgresql
```

#### Databases

If you want to create a database at container's boot time, you can set the following environment variables:

* `POSTGRES_DBNAME` to create a database
* `POSTGRES_EXTENSIONS` to create extensions for the above database (only takes effect is a database is specified)

On this example we will preset our custom username and password and we will create a database with a extension:

```
$ docker run -d \
    --name postgresql \
    -p 5432:5432 \
    -e POSTGRES_USERNAME=myuser \
    -e POSTGRES_PASSWORD=mypassword \
    -e POSTGRES_DBNAME=mydb \
    -e POSTGRES_EXTENSIONS=citext \
    frodenas/postgresql
```

#### Persist database data

The PostgreSQL server is configured to store data in the `/data` directory inside the container. You can map the
container's `/data` volume to a volume on the host so the data becomes independent of the running container:

```
$ mkdir -p /tmp/postgresql
$ docker run -d \
    --name postgresql \
    -p 5432:5432 \
    -v /tmp/postgresql:/data \
    frodenas/postgresql
```

## Copyright

Copyright (c) 2014 Ferran Rodenas. See [LICENSE](https://github.com/frodenas/docker-postgresql/blob/master/LICENSE) for details.
