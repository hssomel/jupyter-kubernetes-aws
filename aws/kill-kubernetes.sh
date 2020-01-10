#!/bin/bash

source ./.kops.config

kops delete cluster $NAME \
    --state $KOPS_STATE_STORE \
    --yes
