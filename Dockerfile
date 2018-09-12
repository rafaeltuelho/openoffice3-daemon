FROM centos:7

## Build Env vars
ARG OO_VERSION=3.2.0
ARG OO_TGZ_URL="http://ftp5.gwdg.de/pub/openoffice/archive/stable/${OO_VERSION}/OOo_${OO_VERSION}_Linux_x86-64_install-rpm-wJRE_en-US.tar.gz"

ENV SOFFICE_DAEMON_PORT=8100
ENV APP_ROOT=/opt/app-root
ENV PATH=${APP_ROOT}/bin:${PATH} HOME=${APP_ROOT}

### Atomic/OpenShift Labels - https://github.com/projectatomic/ContainerApplicationGenericLabels
LABEL name="rafaeltuelho/openoffice3-daemon" \
      maintainer="Rafael T. C. Soares <rafaelcba@gmail.com>" \
      version="1.0" \
      release="1" \
      summary="Openoffice 3 headless mode (soffice)" \
      description="Start the Openoffice headless daemon listening on ${SOFFICE_DAEMON_PORT}" \
      url="https://github.com/rafaeltuelho/openoffice3-daemon" \
      run='docker run -tdi --name ${NAME} -u 123456 ${IMAGE}' \
      io.k8s.description="Start the Openoffice headless daemon listening on ${SOFFICE_DAEMON_PORT}" \
      io.k8s.display-name="Openoffice headless daemon" \
      io.openshift.expose-services="soffice" \
      io.openshift.tags="openoffice,headless,daemon,starter-arbitrary-uid,starter,arbitrary,uid"

### Setup user for build execution and application runtime
COPY pkgs/ /tmp/

#RUN tar -zxf /tmp/OO*.tar.gz -C /tmp && \
RUN (curl -0 $OO_TGZ_URL | tar -zx -C /tmp) && \
    yum localinstall -y /tmp/OOO*/RPMS/*.rpm && \
    yum install -y git make && \
    yum clean all -y && \
    rm -rf /tmp/*.tar.gz /tmp/OOO*

### Install unoconv utility
RUN git clone https://github.com/dagwieers/unoconv && \
    cd unoconv && \
    make install && \
    cd ../ && rm -rf unoconv && \
    yum remove -y git make

COPY bin/ ${APP_ROOT}/bin/

RUN chmod -R u+x ${APP_ROOT}/bin && \
    chgrp -R 0 ${APP_ROOT} && \
    chmod -R g=u ${APP_ROOT} /etc/passwd

### Containers should NOT run as root as a good practice
USER 10001
WORKDIR ${APP_ROOT}

EXPOSE ${SOFFICE_DAEMON_PORT}

### user name recognition at runtime w/ an arbitrary uid - for OpenShift deployments
ENTRYPOINT [ "uid_entrypoint" ]
CMD run