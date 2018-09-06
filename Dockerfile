FROM centos:7

ARG OO_VERSION=3.2.0
ARG OO_TGZ_URL="http://ftp5.gwdg.de/pub/openoffice/archive/stable/${OO_VERSION}/OOo_${OO_VERSION}_Linux_x86-64_install-rpm-wJRE_en-US.tar.gz"

ENV SOFFICE_DAEMON_PORT=8100

LABEL MANTEINER="Rafael T. C. Soares <rafaelcba@gmail.com>"

RUN (curl -0 $OO_TGZ_URL | \
    tar -zx -C /tmp) && \
    yum localinstall -y /tmp/OOO*/RPMS/*.rpm \
    yum cleam all -y

RUN adduser -m -u 1001 openoffice

EXPOSE ${SOFFICE_DAEMON_PORT}

# Use a non root user to start the daemon
USER 1001

CMD ["/opt/openoffice.org3/program/soffice", "-accept=socket,host=0.0.0.0,port=8100;urp;StarOffice.ServiceManager", "-nologo", "-headless", "-nofirststartwizard"]
