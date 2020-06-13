## Benchmark Fabric

Simple benchmarking tool for measuring the performance of Fabric++

Tested with Node v8.4

### Scripts
1. ```scripts/chaincode.sh```: install and instantiate the chaincode.
2. ```scripts/generate_smallbank.sh```: sample experiment script which runs multiple configurations of smallbank benchmark
3. ```scripts/network.sh```: start/stop the fabric cluster
4. ```scripts/prepare-artifacts.sh```: prepare different artifacts for initializing the fabric network.
5. ```scripts/prepare-network.sh```: wrapper scripts which initializes the network, and install/instantiates the chaincode.
6. ```scripts/registry.sh```: start the docker registry service
7. ```scripts/template-gen.sh```: script to generate the yaml files used by docker, and custom configtx files.


### src
1. ```src/admin.js```: register an admin account used by the benchmark
2. ```src/client.js```: simple client which is used to invoke the chaincodes
3. ```src/benchmark.js```: simple benchmarking client which submits transactions at a specified rate to the fabric network.

### Throughput
The throughput is measured from the log files written by one of the fabric nodes.

### Distributed Benchmarking
The benchmark-fabric directory must pe copied to a NFS filesystem mounted on all nodes participating in the fabric network. sample_benchmark.sh file provides a simple example of how the benchmark can be invoked.
