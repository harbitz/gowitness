#!/bin/bash
gowitness --header "X-Forwarded-For: 127.0.0.1" --disable-db $@
