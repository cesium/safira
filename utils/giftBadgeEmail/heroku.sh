#!/bin/bash
heroku run POOL_SIZE=2 mix gift.badge $1 $2 --app sei19-safira-prod
