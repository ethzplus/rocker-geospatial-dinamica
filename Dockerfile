FROM r-base:4.3.1
LABEL authors="Carlson Büth" \
      version="7.5" \
      description="Docker image for Dinamica EGO."

# Environment variables
ENV MODEL_DIR="/model"
# can be mounted when running the container
ENV APP_DIR="/app"
ENV DINAMICA_EGO_7_TEMP_DIR="/tmp/dinamica_ego_7_temp"
# includes the Dinamica EGO application
ENV DINAMICA_EGO_CLI="$APP_DIR/squashfs-root/usr/bin/DinamicaConsole"
# Add shared libraries to the library path
ENV LD_LIBRARY_PATH="$APP_DIR/squashfs-root/usr/lib/:$LD_LIBRARY_PATH"
ENV DINAMICA_EGO_7_INSTALLATION_DIRECTORY="$APP_DIR/squashfs-root/usr/bin"
ENV REGISTRY_FILE="/root/.dinamica_ego_7.conf"

# Create folders with
RUN mkdir -p "$MODEL_DIR" "$APP_DIR" "$DINAMICA_EGO_7_TEMP_DIR"

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


# Install R packages - order matters
RUN install2.r --error --skipinstalled \
    Rcpp RcppProgress rbenchmark inline filelock \
# find filepath to $APP_DIR/squashfs-root/usr/bin/Data/R/Dinamica_[...].tar.gz
    "$(find $APP_DIR/squashfs-root/usr/bin/Data/R/ -name 'Dinamica_*.tar.gz')" \
 && rm -rf /tmp/downloaded_packages

# Check that R has package installed called Dinamica
RUN R -e "library(Dinamica)"

WORKDIR $MODEL_DIR
COPY .dinamica_ego_7.conf $REGISTRY_FILE

# Define entrypoint for the DinamicaConsole in the AppImage
# passes all arguments to the entrypoint
ENTRYPOINT ["/bin/bash", "-c", "$DINAMICA_EGO_CLI \"$@\"", "--"]
