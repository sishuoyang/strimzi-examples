#!/bin/sh

STACK_NAME="eksctl-sishuo-eks-cluster"
if aws cloudformation describe-stacks --stack-name "$STACK_NAME" >/dev/null 2>&1; then
    echo "Stack $STACK_NAME exists, deleting..."
    aws cloudformation delete-stack --stack-name "$STACK_NAME"
    aws cloudformation wait stack-delete-complete --stack-name "$STACK_NAME"
    echo "Stack $STACK_NAME deleted"
else
    echo "Stack $STACK_NAME does not exist"
fi