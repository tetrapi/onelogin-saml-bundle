#!/bin/bash

docker build -t registry.tetrapi.pt/tcs/tatrapi-sa/onelogin-saml-bundle:tests -f Dockerfile .
docker push registry.tetrapi.pt/tcs/tatrapi-sa/onelogin-saml-bundle:tests
