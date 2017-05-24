#! /bin/bash
fly -t qa set-pipeline --pipeline pulse-ui-dev --config pulse-ui-dev.yml --load-vars-from pulse-ui-dev-credentials.yml