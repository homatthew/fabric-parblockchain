# fabric-parblockchain
Research Project for UCSB Distributed Systems Lab built during Spring 2020
This project is built on top of Hyperledger Fabric v1.4.7 which includes throughput optimizations based on early aborts to improve throughput.

- ### Project Description:
  The unique features of blockchain such as transparency, provenance, fault tolerance, and authenticity are used by many systems to deploy a wide range of distributed applications such as supply chain management and healthcare in a permissioned setting. Distributed applications, however, require high performance in terms of throughput and latency. The performance aspect of permission blockchains has been addressed in several studies such as Hyperledger Fabric and ParBlockchain. The goal of this project is to improve the performance of Hyperledger Fabric using the technique that has been presented in ParBlockchain permissioned blockchain.

## Code Structure
* `fabric-sdk-node` - Modified Fabric-node-sdk
* `build-network` - Scripts to start and stop network locally
* `benchmarks` - Contains Caliper v0.3.1 configuration and other benchmark scripts
* `fabric` - Modified Fabric 1.4.7 implementing the following features:
  * Endorserer read-write set short term memory
  * Orderers abort WW and reorders WR conflicts
  * __Note: This should folder chould contain repo  `homatthew/fabric` on branch `earlyAbort`__ 
  
## Important Files in fabric
* Endorser `fabric/core/endorser/`
  * `endorser.go` - Add memory for RW set. Current implementation has RW-sets expire after 2 minutes. 
    * SimulateProposal() - Add write-set to temporary memory after simulation
  * `support.go` - Methods to interact with peer code from endorser. Can use this in the future to remove rw-sets upon validation.
* Commiter `fabric/core/committer/committer.go`
  * CommitWithPvtData() - CommitWithPvtData block and private data into the ledger
* Orderer - `fabric/orderer`
  * NOTE: To understand the data-flow of ordering, please read `orderer/consensus/consensus.go` first
  * `common/blockcutter/blockcutter.go` - 
  * `common/server/main.go` - 
  * `common/broadcast/broadcast.go` - Initial handling of messages within ordering
    * ProcessMessage() - calls Ordered() from blockcutter
  * `common/consensus/etcdraft` - directory for raft consensus protocol
    * `chain.go` - Chain defines a way to inject messages for ordering.
  
* Validator - `fabric/core/peer` (Future Implementation of parallel validation could happen here)
  * `peer.go` - implementation of validator peer
    * _type chainSupport_ 
      * Struct to access ledger from peer
      * Apply() - Validates and updates the ledger

## Fabric Tutorials
1. Official Starting Guide - https://hyperledger-fabric.readthedocs.io/en/release-1.4/getting_started.html
2. Commercial paper tutorial - https://hyperledger-fabric.readthedocs.io/en/release-1.4/tutorial/commercial_paper.html
3. Caliper Installation - https://hyperledger.github.io/caliper/v0.3.1/installing-caliper

## Installation 
1. Install all prerequisites listed at https://hyperledger-fabric.readthedocs.io/en/release-1.4/prereqs.html
2. Copy contents from `fabric` repo/submodule to `$GOPATH/src/github.com/hyperledger/fabric`
4. Run the tests using the scripts and README instructions inside Benchmark

## Compilation
- The Fabric docker images can be built by running `make dist-clean all` in the root directory of `$GOPATH/src/github.com/hyperledger/fabric`
 - Further information about how to run unit-tests and build https://hyperledger-fabric.readthedocs.io/en/release-1.4/dev-setup/build.html
 - When adding new external packages to the project, copy the package to `fabric/vendor` and manually add entry to the `Gopkg.toml`.
  
## Other Related Work / Papers
- Blurring the Lines between Blockchains and Database Systems: the Case of Hyperledger Fabric (Saarland University)
  - Paper: https://bigdata.uni-saarland.de/publications/mod485-sharma.pdf
  - Code: https://github.com/sh-ankur/fabric
  - Benchmark: https://github.com/sh-ankur/benchmark-fabric
- FastFabric: Scaling Hyperledger Fabric to 20,000 Transactions per Second (UWaterloo)
  - Paper: https://arxiv.org/pdf/1901.00910.pdf
  - Code/Benchmark: https://github.com/cgorenflo/fabric
- Scaling Hyperledger Fabric Using Pipelined Execution and Sparse Peers (IBM India)
  - Paper: https://arxiv.org/pdf/2003.05113.pdf
  - Code: N/a
  - Benchmark: https://github.com/thakkarparth007/fabric-load-gen


## License
Hyperledger Project source code files are made available under the Apache License, Version 2.0 (Apache-2.0), located in the LICENSE file. Hyperledger Project documentation files are made available under the Creative Commons Attribution 4.0 International License (CC-BY-4.0), available at http://creativecommons.org/licenses/by/4.0/.
