#!/usr/bin/env bash

ebooks archive thegrugq corpus/thegrugq.json
ebooks consume corpus/thegrugq.json
git commit -a -m "update"
#git push heroku master
#heroku ps:scale worker=1
#heroku ps:restart
#heroku logs

