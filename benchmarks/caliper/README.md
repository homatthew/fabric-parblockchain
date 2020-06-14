### Caliper Instructions
0. Use NVM [Node version Manager] to use Node version is v10.13.0 . I had issues with node-gyp and grpc using Node v12.15.0
1. run `npx caliper bind --caliper-bind-sut fabric:1.4.7 --caliper-bind-cwd ./`
2. navigate to `fabric-parblockchain/benchmarks/caliper/caliper-benchmarks/network/config_raft`
3. run `./generate.sh`
4. run `npx caliper launch master --caliper-benchconfig benchmarks/samples/fabric/marbles/config.yaml --caliper-networkconfig networks/fabric/fabric-v1.4.7/2org1peergoleveldb/fabric-go.yaml --caliper-workspace <path_to_caliper_benchmarks_root_directory> `

## Notes
I have chosen to use the `small-bank` benchmark from [`hyperledger/caliper-benchmarks/`](https://github.com/hyperledger/caliper-benchmarks/t) since it was used in the Saarland paper. More tests can be found at the caliper-benchmark repo.

# Relevant Links
* Installation: https://hyperledger.github.io/caliper/v0.3.1/installing-caliper/
* Benchmark Creation: https://hyperledger.github.io/caliper/v0.3.1/bench-config/
* Sample Benchmarks: https://github.com/hyperledger/caliper-benchmarks