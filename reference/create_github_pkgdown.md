# Create a Github Repo

From inside a project directory, for a project that has a repository on
Github, call this function to create a pkgdown site hosted on Github
Pages, and automatically deployed using Github Actions.

## Usage

``` r
create_github_pkgdown(whoami, open = FALSE)
```

## Arguments

- whoami:

  The result of
  [gh::gh_whoami](https://gh.r-lib.org/reference/gh_whoami.html)

- open:

  Should a web browser be opened to the new pkgdown site? Default is
  `FALSE`.

## Value

The URL of the newly created pkgdown site

## Details

This function uses the user-provided response from
[`gh::gh_whoami()`](https://gh.r-lib.org/reference/gh_whoami.html) to
identify the Github repo. It will also update the `URL` in the
`DESCRIPTION` to include the pkgdown site URL.
