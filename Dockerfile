FROM ubuntu:23.04
LABEL authors="Carlson Büth" \
      version="7.0" \
      description="Docker image for Dinamica EGO."

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

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
# environment location
ENV MAMBA_ROOT_PREFIX=$APP_DIR/micromamba

# Create folders
RUN mkdir -p "$MODEL_DIR" "$APP_DIR"

# Download and Unpack Dinamica EGO 7 AppImage
# https://dinamicaego.com/nui_download/1792/
WORKDIR $APP_DIR
RUN apt-get update && apt-get install -y curl=7.88.1 bzip2=1.0.8 \
    --no-install-recommends \
# clean up
 && rm -rf /var/lib/apt/lists/* \
# download and unpack Dinamica EGO
 && curl -Ls https://dinamicaego.com/nui_download/1792/ -o DinamicaEGO-740-Ubuntu-LTS.AppImage \
# make Dinamica EGO executable
 && chmod +x DinamicaEGO-740-Ubuntu-LTS.AppImage \
# unpack Dinamica EGO
 && ./DinamicaEGO-740-Ubuntu-LTS.AppImage --appimage-extract \

# Install Micromamba - for R integration
WORKDIR /
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
RUN curl -Ls https://micro.mamba.pm/api/micromamba/linux-64/latest | tar -xvj bin/micromamba \
 && eval "$(/bin/micromamba shell hook -s posix)" \
 && micromamba shell init -s bash \

# Download Dinamica EGO R package
RUN curl https://dinamicaego.com/dinamica/dokuwiki/lib/exe/fetch.php?media=dinamica_1.0.4.tar.gz \
    -o "$APP_DIR/dinamica_1.0.4.tar.gz"

# Create and activate conda environment for R
COPY requirements.txt $APP_DIR/requirements.txt
# install requirements into base environment
RUN micromamba env create --prefix "$APP_DIR/micromamba/envs/base" -c conda-forge \
    --file "$APP_DIR"/requirements.txt --yes \
# activate base environment
 && eval "$(micromamba shell hook --shell bash)" \
 && micromamba activate base \
# install R packages
 && R -e "install.packages('$APP_DIR/dinamica_1.0.4.tar.gz', repos = NULL, type = 'source')" \
# export environmentfor supervision
 && micromamba env export | grep -v "^prefix: " > "$APP_DIR"/environment.yml

WORKDIR $MODEL_DIR
COPY .dinamica_ego_7.conf $REGISTRY_FILE

# Define entrypoint for the DinamicaConsole in the AppImage, within Micromamba environment
ENTRYPOINT ["/bin/bash", "-c", "eval \"$(micromamba shell hook --shell bash)\" && micromamba activate base && exec $DINAMICA_EGO_CLI \"$@\" $MODEL_DIR/$MODEL_SCRIPT", "--"]
