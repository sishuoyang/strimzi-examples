#!/bin/sh
kubectl get nodes | grep -v "NAME" | awk '{print $1}' | while read name
do
  echo "$name\t"
  k describe node $name | grep "nodegroup-name"
  # Perform any desired operation on the name here
done