#!/bin/bash

# Set the label key and value to filter on
LABEL_KEY=eks.amazonaws.com/nodegroup
LABEL_VALUE=kafka-workers

# Set the key, value, and effect of the taint to add
TAINT_KEY=dedicated
TAINT_VALUE=kafka_only
TAINT_EFFECT=NoSchedule

# Get the names of nodes that have the specified label value
NODE_NAMES=$(kubectl get nodes --selector=$LABEL_KEY=$LABEL_VALUE -o jsonpath='{.items[*].metadata.name}')

echo "Kafka worker nodes are: $NODE_NAMES"

# Loop through each selected node
for NODE_NAME in $NODE_NAMES; do
  echo "Check taint for $NODE_NAME"
  # Check if the taint already exists on the node
  kubectl describe node $NODE_NAME | grep -q "$TAINT_KEY=$TAINT_VALUE:"
  if [ $? -eq 0 ]; then
    echo "Taint already exists on node $NODE_NAME"
  else
    # Add the taint to the node
    kubectl taint nodes $NODE_NAME $TAINT_KEY=$TAINT_VALUE:$TAINT_EFFECT
    echo "Added taint to node $NODE_NAME"
  fi
done
