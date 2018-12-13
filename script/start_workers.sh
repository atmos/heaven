#!/bin/bash

rake resque:work QUEUE=deployments & > /dev/null
rake resque:work QUEUE=deployment_statuses,events & > /dev/null

