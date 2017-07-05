#! /bin/bash
fly -t qa set-pipeline --pipeline beta-pulse-ui-qa --config beta-pulse-ui-qa.yml --load-vars-from beta-pulse-ui-qa-credentials.yml