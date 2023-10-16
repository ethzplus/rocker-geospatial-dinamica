FROM r-base:4.3.1
LABEL authors="Carlson Büth" \
      version="7.5" \
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

# Create folders with
RUN mkdir -p "$MODEL_DIR" "$APP_DIR"

WORKDIR $APP_DIR
# Download and Unpack Dinamica EGO 7 AppImage
# https://dinamicaego.com/nui_download/1792/
RUN wget --progress=dot:giga https://dinamicaego.com/nui_download/1792/ -O \
    DinamicaEGO-xxx-Ubuntu-LTS.AppImage \
# make Dinamica EGO executable
 && chmod +x DinamicaEGO-xxx-Ubuntu-LTS.AppImage \
# unpack Dinamica EGO
 && ./DinamicaEGO-xxx-Ubuntu-LTS.AppImage --appimage-extract \
# remove AppImage
 && rm DinamicaEGO-xxx-Ubuntu-LTS.AppImage

# Download Dinamica EGO R package
RUN wget --progress=bar https://dinamicaego.com/dinamica/dokuwiki/lib/exe/fetch.php?media=dinamica_1.0.4.tar.gz \
    -O "$APP_DIR/dinamica_1.0.4.tar.gz"

# Install R packages - order matters
RUN install2.r --error --skipinstalled \
    Rcpp RcppProgress rbenchmark inline filelock \
    "$APP_DIR/dinamica_1.0.4.tar.gz" \
 && rm -rf /tmp/downloaded_packages

WORKDIR $MODEL_DIR
COPY .dinamica_ego_7.conf $REGISTRY_FILE

# Define entrypoint for the DinamicaConsole in the AppImage
# passes all arguments to the entrypoint
ENTRYPOINT ["/bin/bash", "-c", "$DINAMICA_EGO_CLI \"$@\"", "--"]
