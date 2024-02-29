#!/bin/bash

# Change permissions of the /var/lib/cwl/ directory at runtime
chmod -R a+w /var/lib/cwl/

exec "$@"