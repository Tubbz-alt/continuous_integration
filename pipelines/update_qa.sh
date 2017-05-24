#! /bin/bash
fly -t qa set-pipeline --pipeline pulse-ui-qa --config pulse-ui-qa.yml --load-vars-from pulse-ui-qa-credentials.yml