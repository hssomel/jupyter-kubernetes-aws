#!/bin/bash

source ./.kops.config

kops update cluster $NAME \
    --state $KOPS_STATE_STORE \
    --yes
