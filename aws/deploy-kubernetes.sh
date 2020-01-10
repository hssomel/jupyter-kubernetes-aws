#!/bin/bash

TOPOLOGY=$1

case $TOPOLOGY in 
    public|private)
        source ${PWD}/kops-config/.kops.config.${TOPOLOGY}

        kops update cluster $NAME \
            --state $KOPS_STATE_STORE \
            --yes
    *) 
        echo "Invalid: cluster topology must be specified (public|private)"
esac
