# Hyperledger-parblockchain
The unique features of blockchain such as transparency, provenance, fault tolerance, and authenticity are used by many systems to deploy a wide range of distributed applications such as supply chain management and healthcare in a permissioned setting. Distributed applications, however, require high performance in terms of throughput and latency. The performance aspect of permission blockchains has been addressed in several studies such as Hyperledger Fabric and ParBlockchain. The goal of this project is to improve the performance of Hyperledger Fabric using the technique that has been presented in ParBlockchain permissioned blockchain.

Note: This project is built on top of Fabric v1.4.7

# Code Structure
* build-network - Scripts to start and stop network locally
* benchmarks - Contains Caliper v0.3.1 configuration and other benchmark scripts
* Fabric - Modified Fabric 1.4.7 implementing the following features:
  * Endorserer read-write set short term memory
  * Orderers abort WW and reorders WR conflicts

# Important Links
1. Official Starting Guide - https://hyperledger-fabric.readthedocs.io/en/release-1.4/getting_started.html

# Installation 
1. Install all prerequisites listed at https://hyperledger-fabric.readthedocs.io/en/release-1.4/prereqs.html
2. Copy contents from `fabric` directory to `$GOPATH/src/github.com/hyperledger/fabric`
3. Run the tests using the scripts and README instructions inside Benchmark

# Compilation
- The Fabric docker images can be built by running `make` in the root directory of `$GOPATH/src/github.com/hyperledger/fabric`

# Other Related Work / Papers
- Blurring the Lines between Blockchains and Database Systems: the Case of Hyperledger Fabric (Saarland University)
  - Paper: https://bigdata.uni-saarland.de/publications/mod485-sharma.pdf
  - Code: https://github.com/sh-ankur/fabric
  - Benchmark: https://github.com/sh-ankur/benchmark-fabric
- FastFabric (UWaterloo)
  - Paper: https://arxiv.org/pdf/1901.00910.pdf
  - Code/Benchmark: https://github.com/cgorenflo/fabric
- Scaling Hyperledger Fabric Using Pipelined Execution and Sparse Peers (IBM India)
  - Paper: https://arxiv.org/pdf/2003.05113.pdf
  - Code: N/a
  - Benchmark: https://github.com/thakkarparth007/fabric-load-gen


