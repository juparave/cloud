## fly.io


### Postgres

Create server

    $ flyctl postgres create --name pgserver

    ? Choose an app name (leave blank to generate one): pgserver
    automatically selected personal organization: My organization
    Some regions require a Launch plan or higher (bom, fra).
    See https://fly.io/plans to set up a plan.

    ? Select region: Dallas, Texas (US) (dfw)
    ? Select configuration: Development - Single node, 1x shared CPU, 256MB RAM, 1GB disk
    ? Scale single node pg to zero after one hour? No
    Creating postgres cluster in organization personal
    Creating app...
    Setting secrets on app pgserver...
    Provisioning 1 of 1 machines with image flyio/postgres-flex:15.6@sha256:38e365656dc89b059a6e3c90fd6aa254fb36727b435a811c99d6ec5
    51b28af08
    Waiting for machine to start...
    Machine 28675d6fe57078 is created

    Postgres cluster pgserver created
    Username:    postgres
    Password:    LZlnMebBJhxf1jh
    Hostname:    pgserver.internal
    Flycast:     fdaa:9:9495:0:1::2
    Proxy port:  5432
    Postgres port:  5433
    Connection string: postgres://postgres:LZlnMebBJhxf1jh@pgserver.flycast:5432

    Save your credentials in a secure place -- you won't be able to see them again!

In this example we created a `machine` named `pgserver`

Check if appears on our apps list

    $ fly apps list

Connect to database server from command line

    $ fly pg connect -a pgserver

Connect to database server from app [ref](https://fly.io/docs/postgres/connecting/app-connection-examples/)


List common machines sizes

    $ fly platform vm-sizes
