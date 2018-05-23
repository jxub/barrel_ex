## PENDING

- test this modules:
    - sysdoc
    - database
- improve the test coverage in general
- raise custom errors and return custom types (?)
- finish the moduledoc
- finish the document module and its documentation
- create the replications module 

## ARCHITECTURE

- Migrate to interface dirctly with barrel_httpc
{:barrel_httpc, git: "https://gitlab.com/barrel-db/barrel_httpc.git", branch: "master"}
As using this client is way simpler, see https://gitlab.com/barrel-db/lab/barrel-ex/tree/master

## IDEAS

- service discovery in barrel with https://github.com/uwiger/gproc
- replication with some sort of MQ: https://github.com/benoitc/couch_zmq
- Collect stats from the server header response and have a stats and health service GenServer (?)
- Some sort of rate limiting and routing on the client side (?)
- GraphQL API (?)
- Aggregation framework (?)