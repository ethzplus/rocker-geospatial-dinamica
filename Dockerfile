FROM ghcr.io/mamba-org/micromamba:1.5.1
LABEL authors="Carlson Büth" \
      version="7.4" \
      description="Docker image for Dinamica EGO."

# Environment variables
ENV MODEL_DIR="/model"
# can be mounted when running the container
ENV APP_DIR="/app"
# includes the Dinamica EGO application
ENV DINAMICA_EGO_CLI="$APP_DIR/squashfs-root/usr/bin/DinamicaConsole"
# Add shared libraries to the library path
ENV LD_LIBRARY_PATH="$APP_DIR/squashfs-root/usr/lib/:$LD_LIBRARY_PATH"
ENV DINAMICA_EGO_7_INSTALLATION_DIRECTORY="$APP_DIR/squashfs-root/usr/bin"
ENV REGISTRY_FILE="/root/.dinamica_ego_7.conf"

# Switch to root user for installation
USER root
# Create folders with
RUN mkdir -p "$MODEL_DIR" "$APP_DIR"

# Download and Unpack Dinamica EGO 7 AppImage
# https://dinamicaego.com/nui_download/1792/
WORKDIR $APP_DIR
RUN apt-get update && apt-get install -y wget=1.21.3-1+b2 bzip2=1.0.8-5+b1 \
     g++=4:12.2.0-3 --no-install-recommends \
# clean-up
 && rm -rf /var/lib/apt/lists/* \
# download and unpack Dinamica EGO
 && wget --progress=dot:giga https://dinamicaego.com/nui_download/1792/ -O \
    DinamicaEGO-740-Ubuntu-LTS.AppImage \
# make Dinamica EGO executable
 && chmod +x DinamicaEGO-740-Ubuntu-LTS.AppImage \
# unpack Dinamica EGO
 && ./DinamicaEGO-740-Ubuntu-LTS.AppImage --appimage-extract

# Create and activate conda environment for R
COPY --chown=$MAMBA_USER:$MAMBA_USER requirements.txt /tmp/requirements.txt
RUN micromamba install -y -n base -f /tmp/requirements.txt -c conda-forge \
 && micromamba clean --all --yes

# Download Dinamica EGO R package
RUN wget --progress=bar https://dinamicaego.com/dinamica/dokuwiki/lib/exe/fetch.php?media=dinamica_1.0.4.tar.gz \
    -O "$APP_DIR/dinamica_1.0.4.tar.gz"
# install Dinamica EGO R package
ARG MAMBA_DOCKERFILE_ACTIVATE=1
RUN R -e "install.packages('$APP_DIR/dinamica_1.0.4.tar.gz', repos = NULL, type = 'source')" \
# export environmentfor supervision
 && micromamba env export > "$APP_DIR"/environment.yml

# Switch back to non-root user
WORKDIR $MODEL_DIR
COPY .dinamica_ego_7.conf $REGISTRY_FILE
# Switch back to non-root user
USER $MAMBA_USER

# Define entrypoint for the DinamicaConsole in the AppImage, within Micromamba environment
# passes all arguments to the entrypoint
ENTRYPOINT ["/bin/bash", "-c", "/usr/local/bin/_entrypoint.sh $DINAMICA_EGO_CLI \"$@\"", "--"]
