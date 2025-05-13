[![Dinamica Version](https://img.shields.io/badge/Dinamica-v8.3-blue.svg)](https://dinamicaego.com/dinamica-8/)
[![Rocker Geospatial Version](https://img.shields.io/badge/rocker/geospatial-v4.5-blue.svg)](https://hub.docker.com/r/rocker/geospatial/tags?name=4.5)

# Dinamica EGO Docker

Dinamica EGO Docker: Run the environmental modeling platform Dinamica EGO alongside
geospatial R tooling in a Docker container for simplified deployment and development.

## Introduction

This repository provides the tooling for containerizing a
[rocker/geospatial](https://rocker-project.org/images/versioned/rstudio.html) and
[Dinamica EGO](https://www.dinamicaego.com/) environment. Dinamica EGO is a
sophisticated platform for environmental modeling, offering a wide range of modeling and
analysis capabilities.

**Please note:**
Dinamica EGO is copyrighted software, and its use is subject to the terms and 
conditions of the [Dinamica EGO License Agreement](https://dinamicaego.com/license/).
Ensure that you have the necessary permissions to use and distribute this software 
in accordance with the license.

## Getting Started

The docker image provides direct access to the
[`DinamicaConsole`](https://dinamicaego.com/dinamica/dokuwiki/doku.php?id=tutorial:dinamica_ego_script_language_and_console_launcher).

Because the Dinamica [license](https://dinamicaego.com/license/) forbids redistribution of the software, you need to build the image for yourself.

To build the image yourself, you only need to clone this repository and run:

```bash
docker build -t dinamica-ego:latest .
```

To run a script `/my/folder/example.ego` from the mounted folder, run:

```bash
docker run -v /my/folder/:/model dinamica-ego example.ego
```

### External Communication

Dinamica EGO can communicate with external applications, like `R`, by exposing a
communication session, as explained
[on the wiki](https://dinamicaego.com/dokuwiki/doku.php?id=external_communication).
For the R integration to work, the container includes a pre-installed version of R.
To install more dependencies, add them to the base environment manually.
The container does not default to starting a coupled R/Dinamica session.

### Temporary Directory

Dinamica EGO uses a temporary directory to store intermediate files.
These are stored inside the `DINAMICA_EGO_8_TEMP_DIR="/tmp/dinamica"` environment variable.
If you prefer, you can mount a host directory into the container:

```bash
docker run -v /my/temp/dir/:/tmp/dinamica dinamica-ego
```

### Detailed Usage

The second way to use the container is to start an interactive shell session:

```bash
docker run -it --rm -v /my/folder/:/model dinamica-ego bash
```

The environment variable `DINAMICA_EGO_CLI` points to the `DinamicaConsole` executable.
For further details, take a look at the [Dockerfile](Dockerfile).

### Apptainer

> [!WARNING]  
> The Apptainer definition file has not been tested with Dinamica EGO 8.3.

To use the image with [Apptainer](https://apptainer.org/docs/user/main/)
you need to convert the image to a SIF image.
To respect the various caveats migrating to Apptainer,
there exists the example definition file [`dinamica_ego.def`](dinamica_ego.def).

## Licensing

Please be aware that the use of Dinamica EGO is subject to the terms and conditions of the Dinamica EGO License Agreement. Ensure that you have the necessary permissions and comply with the licensing terms when using this software.

## Copyright

- [**Dinamica EGO**](https://dinamicaego.com/license/)
  - Copyright 1998-2024 Centro de Sensoriamento Remoto / Universidade Federal de Minas Gerais - Brazil.
  - All Rights Reserved.
  - No warranty whatsoever is provided.
- This repo is licensed under the [MIT License](LICENSE)

## Support and Contact

If you have any questions or suggestions, please write an issue in this repository.
For questions regarding Dinamica EGO, find the
[Guidebook 2.0](https://www.dinamicaego.com/dokuwiki/doku.php?id=guidebook_start),
[FAQ](https://dinamicaego.com/dokuwiki/doku.php?id=faq), and
[Google Group](https://groups.google.com/g/dinamica-ego) online.
