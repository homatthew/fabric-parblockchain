npx caliper launch master \
  --caliper-bind-sut fabric:1.4.8 \
  --caliper-benchconfig benchmarks/ucsb-smallbank/config.yaml \
  --caliper-networkconfig networks/fabric/v1/v1.4.7/2org1peergoleveldb_raft/fabric-go-tls.yaml \
  --caliper-workspace caliper-benchmarks   
