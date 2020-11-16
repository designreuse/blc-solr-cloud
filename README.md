# Solr Cloud with ZooKeeper Configured for Broadleaf-commerce
This repo contains following

1. Dockerfile with Solr 7.5 and Zookeeper 3.5
2. docker-compose.yml
3. setup to launch docker-compose.yml and configure catalog cores


## Steps

1. `git clone`
2. `cd blc-solr-cloud`
3. `./setup.sh`


## List of URLs:

###### SolrCloud search cluster instances
- http://docker-host-ip:8983/solr
- http://docker-host-ip:8984/solr
- http://docker-host-ip:8985/solr
- http://docker-host-ip:8986/solr

#### Check catalog core creation, with aliases

http://docker-host-ip:8983/solr/catalog/select?q=*

http://docker-host-ip:8983/solr/catalog-reindex/select?q=*

Should do the same with the other ports(8984, 8985 and 8986)

The result should look like this
{
  "responseHeader":{
    "zkConnected":true,
    "status":0,
    "QTime":77,
    "params":{
      "q":"*"}},
	  ...
	  ...
	  
#### configure host
*  add to /etc/hosts the line dev.designre.com docker-host-ip
where docker-host-ip is the IP address

#### Configure broadleaf to use this cloud core

solr.source.primary=solrServer

solr.source.reindex=solrReindexServer

solr.cloud.configName=blc

solr.cloud.defaultNumShards=3

solr.url.primary=docker-host-ip:2181,docker-host-ip:2182,docker-host-ip:2183

solr.url.reindex=docker-host-ip:2181,docker-host-ip:2182,docker-host-ip:2183
