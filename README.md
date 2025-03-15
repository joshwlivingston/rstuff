
<!-- README.md is generated from README.Rmd. Please edit that file -->

# rstuff

<!-- badges: start -->

[![R-CMD-check](https://github.com/joshwlivingston/rstuff/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/joshwlivingston/rstuff/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

rstuff is a collection of stuff I use in my day-to-day R work.

## Installation

You can install the package directly from Github:

``` r
# install.packages("pak")
# pak::pak("devtools")
devtools::install_github("joshwlivingston/rstuff")
```

## Formatting

This package uses air, an R formatter and language server available as
an extension in both vscode and positron. The IDE and extension will
pickup the settings specified in .vscode/settings.json and air.toml
