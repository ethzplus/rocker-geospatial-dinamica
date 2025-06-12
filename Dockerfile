ARG DINAMICA_TARGET_DIR="/opt/dinamica"
# Download AppImage and extract it; by doing a multi-stage build, we can discard the
# image cleanly but keep the download layer cached on the build system.
# Pin to amd64 because Dinamica only gets distributed for that platform
# Use ubuntu:noble because it is also the base image for rocker/r-ver:4.5.0
FROM --platform=amd64 ubuntu:noble AS extractor

ARG DINAMICA_EGO_DOWNLOAD_URL="https://dinamicaego.com/nui_download/1960/"
ARG DINAMICA_EGO_DOWNLOAD_CHECKSUM="sha256:22c760ff09dbfbd869834d8190491b6bee8dff5e76eeb33ad9d4051f440361a3"
ARG DINAMICA_TARGET_DIR

ADD --checksum=$DINAMICA_EGO_DOWNLOAD_CHECKSUM \
    --chmod=0755 \
    $DINAMICA_EGO_DOWNLOAD_URL \
    $DINAMICA_TARGET_DIR/DinamicaEGO.AppImage

WORKDIR ${DINAMICA_TARGET_DIR}
RUN "./DinamicaEGO.AppImage" --appimage-extract

# Build the final image
# We only install the R package and set up environment variables
FROM rocker/r-ver:4.5.0 AS final

# ensure multiarch support - adds amd64 to apt sources and installs C/C++ libs
COPY /scripts/install_amd64_libs.sh /rocker_scripts/
RUN /rocker_scripts/install_amd64_libs.sh

ENV CRAN="https://cloud.r-project.org/"
ENV PATH="$PATH:/usr/local/texlive/bin/linux"
# TODO reduce install_geospatial.sh; it is way overblown for what we need
COPY /scripts/install_geospatial.sh /rocker_scripts/install_geospatial.sh
RUN /rocker_scripts/install_geospatial.sh

ARG DINAMICA_TARGET_DIR
LABEL authors="Carlson Büth, Jan Hartman" \
    description="rocker/geospatial image bundling Dinamica EGO."

# Only copy over everything inside the squashfs-root dir
# TODO avoid copying the bundled duplicate system dependencies to reduce image size
COPY --from=extractor ${DINAMICA_TARGET_DIR}/squashfs-root/ $DINAMICA_TARGET_DIR

# Install bundled R package to system library; needs remotes because base
# install.packages does not install additional dependencies when using tarballs
COPY /scripts/install_dinamica_pkg.r /rocker_scripts/install_dinamica_pkg.r
RUN /rocker_scripts/install_dinamica_pkg.r

# Dynamically generate dinamica_ego_X.conf with X being the major version
RUN cat <<EOF > ${HOME}/.dinamica_ego_8.conf
AlternativePathForR = "/usr/local/bin/Rscript"
ClConfig = "0"
MemoryAllocationPolicy = "1"
RCranMirror = "${CRAN:-https://cloud.r-project.org/}"
EOF

# AppImages deliver their own .so files, they need to be attached on path
ENV LD_LIBRARY_PATH=$DINAMICA_TARGET_DIR/usr/lib/:$LD_LIBRARY_PATH
ENV PATH=$PATH:$DINAMICA_TARGET_DIR/usr/bin
# Rocker images override system PATH; override it back
RUN echo "PATH=${PATH}" >> ${R_HOME}/etc/Renviron.site

ENV MODEL_DIR="/model"
ENV DINAMICA_EGO_8_INSTALLATION_DIRECTORY=$DINAMICA_TARGET_DIR/usr/bin
ENV DINAMICA_EGO_CLI=$DINAMICA_TARGET_DIR/usr/bin/DinamicaConsole
ENV DINAMICA_EGO_8_TEMP_DIR="/tmp/dinamica"
ENV DINAMICA_EGO_8_HOME=${DINAMICA_TARGET_DIR}

RUN mkdir -p ${DINAMICA_EGO_8_TEMP_DIR} ${DINAMICA_EGO_8_HOME}

WORKDIR ${MODEL_DIR}

# Define CMD for the DinamicaConsole; passes all arguments given to container
ENTRYPOINT ["/bin/bash", "-c", "DinamicaConsole \"$@\"", "--"]
