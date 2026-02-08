# Create a New R Project

Creates a new R project with basic structure and configurations for
development, version control, and optional GitHub/pkgdown integration.

## Usage

``` r
create_project(
  dir,
  package_title = NULL,
  package_description = NULL,
  package_license = NULL,
  package_version = NULL,
  github_use = TRUE,
  github_pkgdown = TRUE,
  github_private = FALSE,
  open = TRUE
)
```

## Arguments

- dir:

  A character string specifying the name of the directory to create the
  project in. The directory will also be used as the package name.

- package_title:

  Optional title for the package, automatically capitalized if provided.

- package_description:

  Optional description for the package.

- package_license:

  Optional license for the package, defaults to MIT when not specified.
  If specified, a proprietary license using the provided
  `package_license` is used.

- package_version:

  Optional version number for the package, e.g. `"0.1.0"`.

- github_use:

  Logical indicating whether to create a new GitHub repository and link
  it with the project. Defaults to TRUE.

- github_pkgdown:

  Logical indicating whether to set up GitHub Pages for pkgdown
  documentation. Requires `github_use` to be TRUE.

- github_private:

  Logical indicating whether the created repository should be private on
  GitHub. Only applicable if `github_use` is TRUE.

- open:

  Logical indicating whether to open the newly created project with
  RStudio (requires `rstudioapi`). Defaults to TRUE.

## Value

The path to the newly created project directory as an fs_path object.
