# Create a Github Repo

From inside a project directory, call this function to create a repo in
your a Github repository.

## Usage

``` r
create_github_repo(
  whoami,
  github_private = FALSE,
  add_cran_check_badge = TRUE,
  open = FALSE
)
```

## Arguments

- whoami:

  The result of
  [gh::gh_whoami](https://gh.r-lib.org/reference/gh_whoami.html)

- github_private:

  Should the github repository be private? Default `FALSE`.

- add_cran_check_badge:

  Should the R-CMD-CHECK be added to the README? Default is `TRUE`.

- open:

  Should a web browser be opened to the new Github repository? Default
  is `FALSE`.

## Value

The URL of the newly created Github repository

## Details

This function uses the user-provided response from
[`gh::gh_whoami()`](https://gh.r-lib.org/reference/gh_whoami.html) to
create a Github repo. It will also paste the description from the
`DESCRIPTION` file into the repository description on Github. It will
also update the `URL` and `BugReports` fields in `DESCRIPTION` with the
URL's from the newly created repo. If `add_cran_check_badge` is set to
`TRUE`, the R-CMD-CHECK badge will be added to the README.
