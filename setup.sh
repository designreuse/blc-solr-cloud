#!/bin/bash

echo "***************************start to init solrCloud containers***************************"
local_host="`hostname --fqdn`"
local_ip=`host $local_host 2>/dev/null | awk '{print $NF}'`
sed -i "s/{{ HOSTIP }}/$local_ip/g" docker-compose.yml
docker-compose down
docker-compose up -d
echo "***************************solrCloud containers inited***************************"

echo "***************************start to configure solrCloud***************************"
chmod a+r ./config/catalog/solrconfig.xml ./config/catalog/managed-schema
docker exec solr1 bash -c "mkdir -p /opt/solr/server/solr/configsets/catalog/conf"
docker cp ./config/catalog/. solr1:/opt/solr/server/solr/configsets/catalog/conf/

chmod a-r ./config/catalog/solrconfig.xml ./config/catalog/managed-schema

docker exec -it solr1 /opt/solr/server/scripts/cloud-scripts/zkcli.sh -zkhost solr-zk1:2181,solr-zk2:2181,solr-zk3:2181 -cmd upconfig -confdir /opt/solr/server/solr/configsets/catalog/conf -confname blc
echo quit | docker exec -i solr-zk1 bin/zkCli.sh -server solr-zk2:2181
docker exec -it solr1 /opt/solr/server/scripts/cloud-scripts/zkcli.sh -zkhost solr-zk1:2181,solr-zk2:2181,solr-zk3:2181 -cmd putfile /configs/blc/solrconfig.xml /opt/solr/server/solr/configsets/catalog/conf/solrconfig.xml
docker exec -it solr1 /opt/solr/server/scripts/cloud-scripts/zkcli.sh -zkhost solr-zk1:2181,solr-zk2:2181,solr-zk3:2181 -cmd putfile /configs/blc/managed-schema /opt/solr/server/solr/configsets/catalog/conf/managed-schema

echo "***************************solrCloud configured done***************************"

echo "***************************start to create blcCollections***************************"
curl "$local_ip:8986/solr/admin/collections?action=CREATE&name=catalog0&numShards=2&collection.configName=blc&replicationFactor=2&maxShardsPerNode=2"
curl "$local_ip:8986/solr/admin/collections?action=CREATE&name=catalog1&numShards=2&collection.configName=blc&replicationFactor=2&maxShardsPerNode=2"
echo "***************************blcCollections created***************************"

echo "***************************start to create aliases***************************"

curl "$local_ip:8986/solr/admin/collections?action=CREATEALIAS&name=catalog&collections=catalog0"
curl "$local_ip:8986/solr/admin/collections?action=CREATEALIAS&name=catalog-reindex&collections=catalog1"
echo "***************************aliases created***************************"

echo "success"

exit 0


