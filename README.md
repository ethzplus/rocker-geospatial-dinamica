[![Version](https://img.shields.io/badge/version-7.4-blue.svg)](https://dinamicaego.com/dinamica-7/)
[![Build](https://github.com/cbueth/dinamica-ego-docker/actions/workflows/docker-build-test-push.yml/badge.svg)](https://github.com/cbueth/dinamica-ego-docker/actions/workflows/docker-build-test-push.yml)
[![Lint](https://github.com/cbueth/dinamica-ego-docker/actions/workflows/lint.yml/badge.svg)](https://github.com/cbueth/dinamica-ego-docker/actions/workflows/lint.yml)
[![Open Issue](https://img.shields.io/github/issues/cbueth/dinamica-ego-docker.svg)(https://github.com/cbueth/dinamica-ego-docker/issues)]
[![License](https://img.shields.io/badge/license-MIT-green.svg)](https://opensource.org/licenses/MIT)

# Dinamica EGO Docker

Dinamica EGO Docker: Run the powerful environmental modeling platform Dinamica EGO in a Docker container for simplified deployment and usage.

## Introduction

Welcome to the Dinamica EGO Docker repository. This repository provides a 
Dockerfile for building and running [Dinamica EGO](https://www.dinamicaego.com/)
within a Docker container. Dinamica EGO is a sophisticated platform for 
environmental modeling, offering a wide range of modeling and analysis capabilities.

**Please note:**
Dinamica EGO is copyrighted software, and its use is subject to the terms and 
conditions of the [Dinamica EGO License Agreement](https://dinamicaego.com/license/).
Ensure that you have the necessary permissions to use and distribute this software 
in accordance with the license.

## Getting Started

The docker image provides direct access to the
[`DinamicaConsole`](https://dinamicaego.com/dinamica/dokuwiki/doku.php?id=tutorial:dinamica_ego_script_language_and_console_launcher).
The entrypoint of the docker image is designed so that the docker image can be used as
a drop-in replacement for the `DinamicaConsole` executable.

There are two ways to use the docker image. The first is to use the pre-built image,
the second is to build the image yourself. For both, you need to have
[Docker](https://docs.docker.com/get-docker/) installed.

TODO: _Pre-built image on Docker Hub_

To build the image yourself, you only need to clone this repository and run:

```bash
docker build -t dinamica-ego .
```

To run a script `/my/folder/example.ego` from the mounted folder, run:

```bash
docker run -v /my/folder/:/model dinamica-ego example.ego
```

### External Communication

Dinamica EGO can communicate with external applications, like `R`, by exposing a 
communication session, as explained
[on the wiki](https://dinamicaego.com/dinamica/dokuwiki/doku.php?id=external_communication).
For the R integration to work, the container includes a pre-installed version of R, 
using `conda`/`micromamba`.
By default, the packages from the [`requirements.txt`](requirements.txt) are installed.
To install more dependencies, add them to the base environment manually.
As of now, the session is not exposed outside the container for further communication.


### Detailed Usage

The second way to use the container is to start an interactive shell session:

```bash
docker run -it --entrypoint /bin/bash -v /my/folder/:/model ghcr.io/cbueth/dinamica-ego-docker:latest
```

The environment variable `DINAMICA_EGO_CLI` points to the `DinamicaConsole` executable,
and `APP_DIR` to the installation directory of Dinamica EGO.
For further details, take a look at the [Dockerfile](Dockerfile).

   
## About Dinamica EGO

Dinamica EGO is a powerful, free, and non-commercial platform for environmental
modeling. It provides exceptional capabilities for designing models, ranging from 
simple static spatial models to highly complex dynamic ones. With Dinamica EGO, you 
can create models that involve nested iterations, multi-transitions, dynamic 
feedbacks, multi-region and multi-scale approaches, decision processes for 
bifurcating and joining execution pipelines, and a host of complex spatial 
algorithms for analyzing and simulating space-time phenomena.

**EGO** stands for Environment for Geoprocessing Objects.

Find more information about Dinamica EGO on the
[Dinamica EGO website](https://www.dinamicaego.com/).

## Licensing

Please be aware that the use of Dinamica EGO is subject to the terms and conditions of the Dinamica EGO License Agreement. Ensure that you have the necessary permissions and comply with the licensing terms when using this software.

## Copyright

- [**Dinamica EGO 7**](https://dinamicaego.com/license/)
  - Copyright © 1998-2023 Centro de Sensoriamento Remoto / Universidade Federal de Minas Gerais - Brazil.
  - All Rights Reserved.
  - No warranty whatsoever is provided.
- This Dockerfile is licensed under the [MIT License](LICENSE).
  - © 2023 [Carlson Büth](https://cbueth.de/) 

## Additional Information

For more information about Dinamica EGO and its features, please visit the [Dinamica EGO website](http://www.csr.ufmg.br/dinamica/).

## Support and Contact

If you have any questions or suggestions, please write an issue in this repository.
For questions regarding Dinamica EGO, find the
[Guidebook 2.0](https://www.dinamicaego.com/dokuwiki/doku.php?id=guidebook_start),
[FAQ](https://dinamicaego.com/dokuwiki/doku.php?id=faq), and
[Google Group](https://groups.google.com/g/dinamica-ego) online.