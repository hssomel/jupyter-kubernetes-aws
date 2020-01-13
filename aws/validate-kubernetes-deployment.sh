#!/bin/bash

source ~/jupyter-kubernetes-aws/.config

kops validate cluster $NAME \
  --state $KOPS_STATE_STORE 
