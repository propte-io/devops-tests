#!/bin/bash

#! REQUIRED: CURRENT_TAG, STAGE, ROLLBACK_DIRECTION

#! CONSTANTS
MIGRATION_SCRIPTS_PATH="./migrations"

# step 1: checkout the current tag
git fetch origin $CURRENT_TAG
git checkout $CURRENT_TAG

# step 2: get the previous tag
PREVIOUS_TAG=`git tag -l | awk -v CURRENT_TAG=$CURRENT_TAG 'version $0 < version CURRENT_TAG {print$1}' | awk '{a[i++]=$0} END {for (j=i-1; j>=0;) print a[j--] }' | awk 'NR==1 {print; exit}'`
echo "PREVIOUS_TAG: $PREVIOUS_TAG"

# step 3: checkout the previous tag
git fetch origin $PREVIOUS_TAG
git checkout $PREVIOUS_TAG

# step 4: get the latest migration file
LATEST_MIGRATION_FILE=`ls -ltr $MIGRATION_SCRIPTS_PATH | awk '{a[i++]=$0} END {for (j=i-1; j>=0;) print a[j--] }' | awk 'NR==1 {print$9; exit}'`
echo "LATEST_MIGRATION_FILE: $LATEST_MIGRATION_FILE"

# step 5: checkout the current tag
git checkout $CURRENT_TAG

# step 6: get migration scripts
MIGRATION_SCRIPTS=`ls -ltr $MIGRATION_SCRIPTS_PATH | awk -v LATEST_MIGRATION_FILE=$LATEST_MIGRATION_FILE '$9 > LATEST_MIGRATION_FILE {print $9}'`

if [[ "$ROLLBACK_DIRECTION" == "down" ]]; then
  MIGRATION_SCRIPTS=`echo "$MIGRATION_SCRIPTS" | awk '{a[i++]=$0} END {for (j=i-1; j>=0;) print a[j--] }'`
fi

echo "MIGRATION SCRIPTS ARE BEING RUN"
echo "$MIGRATION_SCRIPTS"

for MIGRATION_FILE_PATH in $MIGRATION_SCRIPTS
do
  echo "MIGRATION_FILE_PATH $MIGRATION_FILE_PATH"
  bash  $MIGRATION_SCRIPTS_PATH/$MIGRATION_FILE_PATH
done
