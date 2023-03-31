#!/bin/bash

for secret_name in team1-user1 team2-user1 sishuo
do
    jaas=$(kubectl get secret $secret_name -o jsonpath='{.data.sasl\.jaas\.config}' | base64 -d )
    echo "sasl.jaas.config=${jaas}" > "./clients/$secret_name.properties"
    echo "security.protocol=SASL_PLAINTEXT" >> "./clients/$secret_name.properties"
    echo "sasl.mechanism=SCRAM-SHA-512" >> "./clients/$secret_name.properties"

done
