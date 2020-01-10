#!/bin/bash

source ${PWD}/kops-config/.kops.config

kops delete cluster $NAME \
    --state $KOPS_STATE_STORE \
    --yes
