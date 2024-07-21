#!/bin/bash
cd /data/mtzr

USERNAME=qingliang
PASSWORD='dkI*Nw!3c@weCmH'
svn co svn://svn.gamedev.com/mge/common.doc --username=$USERNAME --password="$PASSWORD" 
svn co svn://svn.gamedev.com/mge/common.server --username=$USERNAME --password="$PASSWORD"
svn co svn://svn.gamedev.com/mge/db.server --username=$USERNAME --password="$PASSWORD"
svn co svn://svn.gamedev.com/mge/behavior.server --username=$USERNAME --password="$PASSWORD"
svn co svn://svn.gamedev.com/mge/chat.server --username=$USERNAME --password="$PASSWORD"
svn co svn://svn.gamedev.com/mge/login.server --username=$USERNAME --password="$PASSWORD"
svn co svn://svn.gamedev.com/mge/map.server --username=$USERNAME --password="$PASSWORD"
svn co svn://svn.gamedev.com/mge/world.server --username=$USERNAME --password="$PASSWORD"
svn co svn://svn.gamedev.com/mge/line.server --username=$USERNAME --password="$PASSWORD"
svn co svn://svn.gamedev.com/mge/port.server --username=$USERNAME --password="$PASSWORD"