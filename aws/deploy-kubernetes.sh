#!/bin/bash

source ${PWD}/kops-config/.kops.config

kops update cluster $NAME \
    --state $KOPS_STATE_STORE \
    --yes
