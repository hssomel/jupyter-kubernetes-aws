#!/bin/bash

source ~/jupyter-kubernetes-aws/.config

kops update cluster $NAME \
  --state $KOPS_STATE_STORE \
  --yes
