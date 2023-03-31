#!/bin/bash

secret_name=sishuo-cluster-cluster-ca-cert

# https://strimzi.io/docs/operators/latest/configuring.html#configuring-external-clients-to-trust-cluster-ca-str
kubectl get secret $secret_name -o jsonpath='{.data.ca\.p12}' | base64 -d > ca.p12

pwd=$(kubectl get secret $secret_name -o jsonpath='{.data.ca\.password}' | base64 -d)
echo "password is:$pwd"

# write the properties to file
echo "security.protocol=SSL" > ssl.properties
echo "ssl.truststore.location=ca.p12" >> ssl.properties
echo "ssl.truststore.password=${pwd}" >> ssl.properties
echo "ssl.truststore.type=PKCS12" >> ssl.properties

echo "copy certs to jump"
scp ssl.properties jump:/home/ubuntu
scp ca.p12 jump:/home/ubuntu