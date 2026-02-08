# Set RSTUDIO_PANDOC for subprocesses (used by devtools::build_readme via callr)
Sys.setenv(RSTUDIO_PANDOC = dirname(pandoc::pandoc_bin()))
