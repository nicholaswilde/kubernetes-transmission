#!/bin/bash

if ! command -v kubectl2 &> /dev/null; then
    kubectl is not installed
    exit 1
fi
