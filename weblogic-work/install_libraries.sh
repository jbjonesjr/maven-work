#!/bin/bash

#error codes
MISSING_MODULES_DIR=99

#Config Options
INSTALL_LOCAL_REPOSITORY="Y"
INSTALL_REMOTE_REPOSITORY="Y"

if [ $# -gt 0 ];
then
  MODULES_DIR="$1"
  echo "$0 recieved an argument, using $1 for the module directory."
else
  MODULES_DIR="/opt/Oracle/Middleware/modules/"
  LIBRARY_DIR="/opt/Oracle/Middleware/wlserver_10.3/server/lib/"
  echo "No modules directory passed in, using default resolution"
fi

if ! [ -d "$MODULES_DIR" ];
 then
 echo "Directories resolution problem. ($MODULES_DIR) or ($LIBRARY_DIR) may not exist";
 exit $MISSING_MODULES_DIR;
fi
WEBLOGIC_LIBRARIES="weblogic.jar \
webservices.jar"

MODULES="com.bea.core.utils.full_{vers}.jar \
com.bea.core.i18n_{vers}.jar \
com.bea.core.weblogic.rmi.client_{vers}.jar \
javax.enterprise.deploy_{vers}.jar \
com.bea.core.management.core_{vers}.jar \
com.bea.core.weblogic.security.wls_{vers}.jar \
com.bea.core.weblogic.security_{vers}.jar \
com.bea.core.weblogic.security.identity_{vers}.jar \
com.bea.core.weblogic.workmanager_{vers}.jar \
com.bea.core.transaction_{vers}.jar \
com.bea.core.logging_{vers}.jar \
com.bea.core.utils.classloaders_{vers}.jar \
com.bea.core.descriptor_{vers}.jar \
com.bea.core.timers_{vers}.jar \
com.bea.core.weblogic.socket.api_{vers}.jar \
com.bea.core.common.security.api_{vers}.jar \
com.bea.core.weblogic.security.digest_{vers}.jar \
com.bea.core.weblogic.lifecycle_{vers}.jar \
com.bea.core.workarea_{vers}.jar \
com.bea.core.utils.wrapper_{vers}.jar \
com.bea.core.store_{vers}.jar \
com.bea.core.management.jmx_{vers}.jar \
com.bea.core.descriptor.wl_{vers}.jar \
com.bea.core.annogen_{vers}.jar \
com.bea.core.descriptor.j2ee.binding_{vers}.jar \
com.bea.core.xml.staxb.runtime_{vers}.jar \
com.bea.core.xml.beaxmlbeans_{vers}.jar \
com.bea.core.descriptor.j2ee_{vers}.jar \
javax.ejb_{vers}.jar \
com.bea.core.xml.xmlbeans_{vers}.jar \
com.bea.core.weblogic.stax_{vers}.jar \
javax.xml.rpc_{vers}.jar \
com.bea.core.xml.staxb.buildtime_{vers}.jar \
glassfish.jaxws.rt_{vers}.jar \
com.bea.core.descriptor.wl.binding_{vers}.jar \
com.bea.core.descriptor.settable.binding_{vers}.jar \
com.bea.core.weblogic.saaj_{vers}.jar"

FILES=""

for LIBRARY in ${WEBLOGIC_LIBRARIES}
do
FILE_PATTERN=`echo $LIBRARY | sed -e 's/{vers}/*/g'`
FILE=`find $LIBRARY_DIR -name $FILE_PATTERN`
FILES="$FILES
$FILE"

done

for MODULE in ${MODULES}
do
FILE_PATTERN=`echo $MODULE | sed -e 's/{vers}/*/g'`
FILE=`find $MODULES_DIR -name $FILE_PATTERN`
if ! [ "" = "$FILE" ];
then
FILES="$FILES 
$FILE"
else
echo "File was not found (pattern: $FILE_PATTERN)"
fi

done

for FILE in ${FILES}
 do
ARTIFACTID=`echo "$FILE" | sed -e 's/.*\///g' | sed -e 's/_/||/1' | sed -e 's/\(.*\)||.*/\1/g' | sed -e 's/\.jar//g' `
VERSION=`echo "$FILE" | sed -e 's/_/||/1' | sed -e 's/.*||\(.*\)\.jar/\1/g' | sed -e 's/\//||/1' | sed -e 's/\(.*\)||.*/\1/g'`
echo "FILE LOCATION: $FILE"
echo "ARTIFACT ID: $ARTIFACTID"
echo "VERISON: $VERSION"
if [ "Y" = "$INSTALL_LOCAL_REPOSITORY" ];
 then 
mvn install:install-file -Dpackaging=jar -DgroupId=weblogic -DartifactId=$ARTIFACTID -Dversion=$VERSION -Dfile=$FILE
fi
if [ "Y" = "$INSTALL_REMOTE_REPOSITORY" ];
 then
echo "mvn deploy:deploy-file -Dpackaging=jar -DgroupId=weblogic -DartifactId=$ARTIFACTID -Dversion=$VERSION -Dfile=$FILE -DrepositoryId=releases -Durl=http://localhost:8081/nexus/content/repositories/releases/"
mvn deploy:deploy-file -Dpackaging=jar -DgroupId=weblogic -DartifactId=$ARTIFACTID -Dversion=$VERSION -Dfile=$FILE -DrepositoryId=releases -Durl=http://localhost:8081/nexus/content/repositories/releases/

fi

done
