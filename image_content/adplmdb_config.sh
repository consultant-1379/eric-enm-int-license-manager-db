#!/bin/bash

##########################################################################
# COPYRIGHT Ericsson 2024
#
# The copyright to the computer program(s) herein is the property of
# Ericsson Inc. The programs may be used and/or copied only with written
# permission from Ericsson Inc. or in accordance with the terms and
# conditions stipulated in the agreement/contract under which the
# program(s) have been supplied.
###########################################################################
/sbin/rsyslogd

readonly DB=licensemanager_db
logger "ADPLM_DB: Creating database and roles in $DB"

ADPLM_DDL_LOG_FILE=adplm_install_db.log

PG_SLEEP_INT=5
PG_NUM_TRIES=6
ADPLM_PW_FILE=/app/.adplmpw
readonly PG_USER=${PG_USER:-postgres}
readonly PG_HOSTNAME=${POSTGRES_SERVICE:-postgresql01}
readonly INSTALL_DIR=${INSTALL_DIR:-/opt/ericsson/pgsql/install}

PSQL_ERROR_CHECK="could not connect to server\|ERROR"
ZERO_UPDATE="UPDATE 0"
readonly LOG_TAG="ADPLM_DB"

source /ericsson/enm/pg_utils/lib/pg_syslog_library.sh
source /ericsson/enm/pg_utils/lib/pg_dbcreate_library.sh
source /ericsson/enm/pg_utils/lib/pg_rolecreate_library.sh

if [ $PG_ROOT ];
then
  PG_CLIENT=$PG_ROOT/psql
else
  PG_CLIENT=/opt/rh/postgresql/bin/psql
fi;

logInfo() {
  msg=$1
  echo "`date +[%D-%T]` $msg" &>>$INSTALL_DIR/$ADPLM_DDL_LOG_FILE
  info $msg
}

logError() {
  msg=$1
  echo "`date +[%D-%T]` $msg" &>>$INSTALL_DIR/$ADPLM_DDL_LOG_FILE
  error $msg
}

#*****************************************************************************#
# Fetch ADPLM passwords
#*****************************************************************************#
ADPLM_PASSWORD=$(head -n 1 $ADPLM_PW_FILE)

#*****************************************************************************#
##Logging & Error Checking Housekeeping
#*****************************************************************************#
if [ -f $INSTALL_DIR/$ADPLM_DDL_LOG_FILE ]
then
  LDATE=`date +[%m%d%Y%T]`
  mv $INSTALL_DIR/$ADPLM_DDL_LOG_FILE $INSTALL_DIR/$ADPLM_DDL_LOG_FILE.$LDATE
  touch  $INSTALL_DIR/$ADPLM_DDL_LOG_FILE
  chmod a+w $INSTALL_DIR/$ADPLM_DDL_LOG_FILE
else
  touch  $INSTALL_DIR/$ADPLM_DDL_LOG_FILE
  chmod a+w $INSTALL_DIR/$ADPLM_DDL_LOG_FILE
fi

checkExitCode(){
  logInfo "We should not proceed with ADP LM Installation due to issue installing $DB"
  exit 1
}

checkForError(){
  return=0
  grep "$PSQL_ERROR_CHECK" $INSTALL_DIR/$ADPLM_DDL_LOG_FILE  > /dev/null 2>&1
  if [ $? -eq 0 ]
  then
    case $1 in
      II_Check)
        logError "We should not proceed due to issue checking for initial install"
        return=1
        ;;
      *)
        logError "We should not proceed due to an unknown issue"
        return=1
        ;;
    esac
  fi
    return $return
}

#*****************************************************************************#
# create_adplm_role ()                                                        #
# create role adplm in the adplmdb                                            #
#-----------------------------------------------------------------------------#
function create_adplm_role() {
  DB_ROLE='lmuser'
  DB_ROLE_PSW=$ADPLM_PASSWORD
  logInfo "Creating ADP License Manager DB lmuser role"
  if ! role_create 'NOSUPERUSER NOCREATEDB NOCREATEROLE'; then
    logError "ADPLMDB Role lmuser creation failed."
    exit 1
  fi
}

#*****************************************************************************#
# create_roles ()                                                             #
# create all required roles in the adplmdb                                    #
#-----------------------------------------------------------------------------#
function create_roles() {
  logInfo "Creating ADP LM DB roles"
  create_adplm_role
}

function grant_privileges() {
  DB_ROLE='lmuser'

  logInfo "Grant Privileges to ADPLMDB role."

  if ! change_db_ownership; then
    logError "ADPLMDB Change DB Ownership failed."
    exit 1
  fi

  if ! grant_connect_privilege_on_database_for_role; then
    logError "ADPLMDB Grant Connect failed."
    exit 1
  fi
}

##MAIN
createDb
create_roles
grant_privileges
