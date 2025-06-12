#!/usr/bin/env r

dinamica_dir <- Sys.getenv("DINAMICA_TARGET_DIR")
dinamica_pkg <- list.files(
  file.path(dinamica_dir, "usr", "bin", "Data", "R"),
  pattern = "Dinamica_.*.tar.gz",
  recursive = TRUE,
  full.names = TRUE
)

install.packages("remotes")
remotes::install_local(dinamica_pkg)
