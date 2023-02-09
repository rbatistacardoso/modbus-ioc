FROM debian:11-slim as epics-deps

# set correct timezone
ENV DEBIAN_FRONTEND noninteractive
ENV TZ=America/Sao_Paulo
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN set -ex; \
    apt update -y && \
    apt install -y --fix-missing --no-install-recommends \
        build-essential \
        git \
        procps \
        tzdata \
        vim \
        wget \
        ser2net \
        ca-certificates \
      && rm -rf /var/lib/apt/lists/*  && \
    dpkg-reconfigure --frontend noninteractive tzdata


# --- EPICS BASE ---

ENV EPICS_VERSION R3.15.8
ENV EPICS_HOST_ARCH linux-x86_64
ENV EPICS_BASE /opt/epics-${EPICS_VERSION}/base
ENV EPICS_MODULES /opt/epics-${EPICS_VERSION}/modules
ENV PATH ${EPICS_BASE}/bin/${EPICS_HOST_ARCH}:${PATH}

ENV EPICS_CA_AUTO_ADDR_LIST YES


ARG EPICS_BASE_URL=https://github.com/epics-base/epics-base/archive/${EPICS_VERSION}.tar.gz
LABEL br.cnpem.epics-base=${EPICS_BASE_URL}
RUN set -x; \
    set -e; \
    mkdir -p ${EPICS_MODULES}; \
    wget --no-check-certificate -O /opt/epics-R3.15.8/base-3.15.8.tar.gz ${EPICS_BASE_URL}; \
    cd /opt/epics-${EPICS_VERSION}; \
    tar -zxf base-3.15.8.tar.gz; \
    rm base-3.15.8.tar.gz; \
    mv epics-base-R3.15.8 base; \
    cd base; \
    make -j$(nproc)

WORKDIR /opt/epics-${EPICS_VERSION}

# --- EPICS MODULES ---

# asynDriver
ARG ASYN_VERSION=R4-41
ARG ASYN_URL=https://github.com/epics-modules/asyn/archive/${ASYN_VERSION}.tar.gz
ENV ASYN ${EPICS_MODULES}/asyn-${ASYN_VERSION}
LABEL br.cnpem.asyn=${ASYN_URL}
RUN set -ex; \
    cd ${EPICS_MODULES}; \
    wget --no-check-certificate -O ${ASYN}.tar.gz ${ASYN_URL}; \
    tar -xvzf ${ASYN}.tar.gz; \
    rm -f ${ASYN}.tar.gz; \
    cd ${ASYN}; \
    sed -i  \
        -e '3,4s/^/#/' \
        -e '7s/^/#/' \
        -e '10s/^/#/' \
        -e '19cEPICS_BASE='${EPICS_BASE}  \
        -e '15iCALC='${CALC} \
        -e '16iSSCAN='${SSCAN} \
        ${ASYN}/configure/RELEASE; \
    make -j$(nproc)

ARG GIT_SSL_NO_VERIFY=1

# modbusDriver
ARG MODBUS_VERSION=R3-2
ENV MODBUS ${EPICS_MODULES}/modbus-${MODBUS_VERSION}
RUN set -xe; \
    cd ${EPICS_MODULES}; \
    wget -O ${MODBUS}.tar.gz https://github.com/epics-modules/modbus/archive/refs/tags/R3-2.tar.gz; \
    tar -xvzf ${MODBUS}.tar.gz; \
    rm ${MODBUS}.tar.gz; \
    cd ${MODBUS}; \
    sed -i \
        -e '22cEPICS_BASE='${EPICS_BASE}  \
        -e '15cASYN='${ASYN} \
        ${MODBUS}/configure/RELEASE; \
    make -j$(nproc)

WORKDIR /root/ioc

ENTRYPOINT [ "/bin/bash", "-c", "sleep infinity" ]
