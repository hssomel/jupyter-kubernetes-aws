#!/bin/bash

source ~/jupyter-kubernetes-aws/.config

kops delete cluster $NAME \
  --state $KOPS_STATE_STORE \
  --yes
