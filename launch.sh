#! /bin/sh
JOBPATH=$1
JOB_NAME=$2

IMAGE_NAME=yuhadam/$2

sudo docker build --tag "$IMAGE_NAME" "$JOBPATH"/

sudo docker login -u yuhadam -p k9460180

sudo docker push "$IMAGE_NAME"

echo	'{' > $JOBPATH/docker.json
echo 	'"schedule": "R1/2014-09-25T17:22:00Z/PT2M",' >> $JOBPATH/docker.json
echo 	'"name":'	"\"$JOB_NAME\"," >> $JOBPATH/docker.json
echo	'"container": {' >> $JOBPATH/docker.json
echo    '"type": "DOCKER",' >> $JOBPATH/docker.json
echo    '"image":' "\"$IMAGE_NAME\"," >> $JOBPATH/docker.json
echo    '"network": "BRIDGE",' >> $JOBPATH/docker.json
echo    '"volumes": [' >> $JOBPATH/docker.json
echo    '{' >> $JOBPATH/docker.json
echo    '"containerPath": "/nfsdir",' >> $JOBPATH/docker.json
echo    '"hostPath": "/nfsdir",' >> $JOBPATH/docker.json
echo    '"mode":"RW"' >> $JOBPATH/docker.json
echo    '}' >> $JOBPATH/docker.json
echo    ']' >> $JOBPATH/docker.json
echo	'},' >> $JOBPATH/docker.json
echo  '"cpus": "0.5",' >> $JOBPATH/docker.json
echo  '"mem": "512",' >> $JOBPATH/docker.json
echo  '"uris": [],' >> $JOBPATH/docker.json
echo  '"command":' "\"$JOBPATH/innerSh.sh\"" >> $JOBPATH/docker.json
echo '}' >> $JOBPATH/docker.json
cd $JOBPATH
/scheduler/iso8601
/scheduler/job/$JOB_NAME
