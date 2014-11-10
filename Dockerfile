# Version: 0.0.4 Weblogic 11g 10.3.6 x64 Generic
FROM unbc/weblogic11gprereq
MAINTAINER Trevor Fuson "trevor.fuson@unbc.ca"

# Create a OFA location to put the weblogic install, create to oracle user so we can set the permissions on the location
RUN groupadd dba      -g 502 && \
    groupadd oinstall -g 501 && \
    useradd -m        -u 501 -g oinstall -G dba -d /home/oracle -s /sbin/nologin -c "Oracle Account" oracle && \
    mkdir -p /u01/app/oracle && \
    chown -R oracle:oinstall /home/oracle

# Install Weblogic 11gR1 10.3.6 Generic
ADD silent.xml          /u01/app/oracle/
# ADD wls1036_generic.jar /u01/app/oracle/
# RUN [ "java","-Dspace.detection=false", "-Xmx1024m", "-jar", "/u01/app/oracle/wls1036_generic.jar", "-mode=silent", "-silent_xml=/u01/app/oracle/silent.xml" ]
# RUN rm wls1036_generic.jar

# Find out what IP this is running from so that access to the weblogic jar file can be granted.
RUN echo $(curl http://myip.dnsomatic.com) 1>&2

# Download the weblogic jar file from an untrusted source, however only install it if the SHA1 says it's authentic.
# You must verify that the expected SHA1 checksum in this Dockerfile matches the SHA1 checksum of the jar file directly from oracle.
# It is not possible to automatically download the weblogic installer directly from oracle in an automated fashion without embedded credentials.
RUN curl http://web.unbc.ca/~fuson/docker/wls1036_generic.jar > wls1036_generic.jar;\
    downloaded_weblogic_sha1sum=$(sha1sum wls1036_generic.jar);\
    expected_weblogic_sha1sum="ffbc529d598ee4bcd1e8104191c22f1c237b4a3e  wls1036_generic.jar";\
    if [ "$expected_weblogic_sha1sum" == "$downloaded_weblogic_sha1sum" ];\
       then \
         echo "Checksum Passed, okay to install"       1>&2;\
         echo "Expected: $expected_weblogic_sha1sum"   1>&2;\
         echo "Download: $downloaded_weblogic_sha1sum" 1>&2;\
         java -Dspace.detection=false -Xmx1024m -jar wls1036_generic.jar -mode=silent -silent_xml=/u01/app/oracle/silent.xml;\
       else \
         echo "Checksum Failed"                        1>&2;\
         echo "Expected: $expected_weblogic_sha1sum"   1>&2;\
         echo "Download: $downloaded_weblogic_sha1sum" 1>&2;\
    fi;\
    rm wls1036_generic.jar