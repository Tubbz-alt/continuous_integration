#! /bin/bash
fly -t qa set-pipeline --pipeline beta-pulse-ui-dev --config beta-pulse-ui-dev.yml --load-vars-from beta-pulse-ui-dev-credentials.yml