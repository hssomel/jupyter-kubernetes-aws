#!/bin/bash

source ./.kops.config

kops validate cluster $NAME \
    --state $KOPS_STATE_STORE 
