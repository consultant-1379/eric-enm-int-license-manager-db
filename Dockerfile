ARG ERIC_ENM_SLES_BASE_IMAGE_NAME=eric-enm-sles-base
ARG ERIC_ENM_SLES_BASE_IMAGE_REPO=armdocker.rnd.ericsson.se/proj-enm
ARG ERIC_ENM_SLES_BASE_IMAGE_TAG=1.64.0-20
FROM ${ERIC_ENM_SLES_BASE_IMAGE_REPO}/${ERIC_ENM_SLES_BASE_IMAGE_NAME}:${ERIC_ENM_SLES_BASE_IMAGE_TAG}

ARG BUILD_DATE=unspecified
ARG IMAGE_BUILD_VERSION=unspecified
ARG GIT_COMMIT=unspecified
ARG ISO_VERSION=unspecified
ARG RSTATE=unspecified

ARG SGUSER=223803

LABEL \
com.ericsson.product-number="CXU 101 2599" \
com.ericsson.product-revision=$RSTATE \
enm_iso_version=$ISO_VERSION \
org.label-schema.name="ENM ADP License Manager DB" \
org.label-schema.build-date=$BUILD_DATE \
org.label-schema.vcs-ref=$GIT_COMMIT \
org.label-schema.vendor="Ericsson" \
org.label-schema.version=$IMAGE_BUILD_VERSION \
org.label-schema.schema-version="1.0.0-rc1"

ENV PG_ROOT /usr/lib/postgresql15/bin
ENV INSTALL_DIR /app/

RUN zypper install -y sles_base_os_repo:postgresql15 \
    ERICpostgresutils_CXP9038493 && \
    zypper clean -a

RUN /usr/sbin/useradd postgres > /dev/null 2>&1

COPY image_content/adplmdb_config.sh /app/adplmdb_config.sh
COPY image_content/.adplmpw /app/.adplmpw

RUN  echo "$SGUSER:x:$SGUSER:$SGUSER:An Identity for licensemanager:/nonexistent:/bin/false" >>/etc/passwd && \
     echo "$SGUSER:!::0:::::" >>/etc/shadow

RUN chmod 775 /app && \
    chmod 550 /app/*

USER $SGUSER
