#!/bin/bash

# turn on bash's job control
set -m

/usr/sbin/apachectl start &
/etc/init.d/renderd start &
exec bash
