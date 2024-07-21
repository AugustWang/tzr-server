#!/bin/bash

chown -R www:www /data/tzr/web/www/*
chmod +x /data/tzr/web/www/admin/update/run_schedule_update.sh
chown www:www  /data/tzr/web/www/cache/ -R