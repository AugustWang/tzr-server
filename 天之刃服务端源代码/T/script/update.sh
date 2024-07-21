#!/bin/bash

ROOT_DIR=/data/mtzr

cd $ROOT_DIR/common.doc/trunk
svn update

cd $ROOT_DIR/world.server/trunk
svn update

cd $ROOT_DIR/login.server/trunk
svn update

cd $ROOT_DIR/line.server/trunk
svn update

cd $ROOT_DIR/map.server/trunk
svn update

cd $ROOT_DIR/chat.server/trunk
svn update

cd $ROOT_DIR/port.server
svn update

cd $ROOT_DIR/db.server/trunk
svn update

cd $ROOT_DIR/common.server/trunk
svn update

cd $ROOT_DIR/behavior.server/trunk
svn update

cd $ROOT_DIR/admin.server/trunk
svn update

cd $ROOT_DIR/receiver.server/trunk
svn update
