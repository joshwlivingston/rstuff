#' Create a New R Project
#'
#' Creates a new R project with basic structure and configurations for development, version control,
#' and optional GitHub/pkgdown integration.
#'
#' @param dir A character string specifying the name of the directory to create the project in.
#'   The directory will also be used as the package name.
#' @param package_title Optional title for the package, automatically capitalized if provided.
#' @param package_description Optional description for the package.
#' @param package_license Optional license for the package, defaults to MIT when not specified. If
#'   specified, a proprietary license using the provided `package_license` is used.
#' @param package_version Optional version number for the package, e.g. `"0.1.0"`.
#' @param github_use Logical indicating whether to create a new GitHub repository and link it with
#'   the project. Defaults to TRUE.
#' @param github_pkgdown Logical indicating whether to set up GitHub Pages for pkgdown
#'   documentation. Requires `github_use` to be TRUE.
#' @param github_private Logical indicating whether the created repository should be private on
#'   GitHub. Only applicable if `github_use` is TRUE.
#' @param open Logical indicating whether to open the newly created project with RStudio
#'   (requires `rstudioapi`). Defaults to TRUE.
#'
#' @return The path to the newly created project directory as an fs_path object.
#'
#' @import rmarkdown
#' @export
create_project <- function(
	dir,
	package_title = NULL,
	package_description = NULL,
	package_license = NULL,
	package_version = NULL,
	github_use = TRUE,
	github_pkgdown = TRUE,
	github_private = FALSE,
	open = TRUE
) {
	check_character_length_one(dir)

	check_null_or_character_length_one(package_title)
	check_null_or_character_length_one(package_description)
	check_null_or_character_length_one(package_license)
	check_null_or_character_length_one(package_version)

	check_logical_length_one(github_use)
	check_logical_length_one(github_pkgdown)
	check_logical_length_one(github_private)

	check_logical_length_one(open)

	# Check valid driectory
	if (!grepl("^[a-zA-Z][a-zA-Z0-9.]*[a-zA-Z0-9]$", dir)) {
		rlang::abort(sprintf("`dir` must be a valid R package name"))
	}
	if (dir.exists(dir)) {
		rlang::abort("Directory already exists")
	}

	# Check valid github_pkgdown and github_use combination
	if (github_pkgdown && !github_use) {
		rlang::abort(c(
			x = "`github_use` must be TRUE when `github_pkgdown` is TRUE"
		))
	}

	# Check pandoc is available (for devtools::build_readme())
	if (!pandoc::pandoc_available()) {
		rlang::abort(c(
			"Pandoc not installed. Run pandoc::install() to continue."
		))
	}

	if (github_use) {
		# Identify github credentials (must be pre-set be user)
		whoami <- gh::gh_whoami(.api_url = NULL)
		if (is.null(whoami)) {
			rlang::abort(
				c(
					x = "Unable to discover a GitHub personal access token.",
					i = "A token is required in order to create and push to a new repo.",
					"Call {.run usethis::gh_token_help()} for help configuring a token.",
					"Or, provide `use_github = FALSE` to create_project() to skip creating the Github repo"
				)
			)
		}
		whoami$gh_url <- sprintf("%s/%s", whoami$html_url, dir)

		# Throw error if repo exists with provided name
		res <-
			tryCatch(
				# if GET throws error, repo does not exist. return TRUE
				gh::gh(sprintf("GET /repos/%s/%s", whoami$login, dir)),
				error = function(e) return(NULL)
			)

		if (!is.null(res)) {
			# if arrive here, repo exists. throw error
			rlang::abort(
				sprintf("Github repository already exists at %s/%s", whoami$login, dir),
				call = rlang::caller_env()
			)
		}
	}

	# Copy project template into provided dir
	new_project_path <-
		fs::dir_copy(
			path = system.file("templates/project", package = "rstuff"),
			new_path = dir,
			overwrite = FALSE
		)
	message("project created at ", new_project_path)

	# move to newly created dir
	cwd <- getwd()
	setwd(new_project_path)

	# files are loaded into R Package with TEMPLATE added to the name to prevent build conflicts
	# remove TEMPLATE from file names
	vapply(
		fs::dir_ls(all = TRUE),
		function(x) fs::file_move(x, gsub("TEMPLATE", "", x)),
		character(1)
	)

	# rename .Rproj file to provided name
	fs::file_move("project.Rproj", sprintf("%s.Rproj", dir))

	# DESCRIPTION
	description_fields <- usethis::use_description_defaults()
	description_fields$Package <- dir
	if (!is.null(package_title)) {
		description_fields$Title <- str_to_title(package_title)
	}
	if (!is.null(package_description)) {
		description_fields$Description <- package_description
	}
	if (!is.null(package_version)) {
		description_fields$Version <- package_version
	}

	description <- desc::desc(
		text = sprintf("%s: %s", names(description_fields), description_fields)
	)
	description$write(file = "DESCRIPTION")
	usethis::use_package("devtools", "Suggests")
	usethis::use_package("rmarkdown", "Suggests")

	# .git/
	system("git init")

	# NAMESPACE, man/
	devtools::document()

	# README.Rmd
	usethis::use_readme_rmd(open = FALSE)

	# README.md
	devtools::build_readme()

	# LICENSE, LICENSE.md
	if (is.null(package_license)) {
		message("Creating MIT License")
		usethis::use_mit_license()
	} else {
		message(sprintf("Creating %s License", package_license))
		usethis::use_proprietary_license(package_license)
	}

	# Commit all created files
	system("git add .")
	system("git commit -m \"Initial Commit\"")

	if (github_use) {
		repo_url <- create_github_repo(
			whoami = whoami,
			github_private = github_private
		)
		pkgdown_site_url <- if (github_pkgdown) create_github_pkgdown(whoami)
		utils::browseURL(repo_url)
	}

	if (open) {
		if (!suppressMessages(requireNamespace("rstudioapi"))) {
			rlang::warn(sprintf(
				"project created at %s, but create_project(..., open = TRUE) depends on the rstudioapi package",
				new_project_path
			))

			setwd(cwd)
			return(new_project_path)
		}

		if (!rstudioapi::isAvailable()) {
			rlang::warn(sprintf(
				"project created at %s, but create_project(..., open = TRUE) only works inside RStudio",
				new_project_path
			))

			setwd(cwd)
			return(new_project_path)
		}

		setwd(cwd)
		rstudioapi::openProject(new_project_path)
	}

	setwd(cwd)
	return(new_project_path)
}

#' Create a Github Repo
#'
#' From inside a project directory, call this function to create a repo in your a Github
#' repository.
#'
#' This function uses the user-provided response from [gh::gh_whoami()] to create a Github repo. It
#' will also paste the description from the `DESCRIPTION` file into the repository description on
#' Github. It will also update the `URL` and `BugReports` fields in `DESCRIPTION` with the URL's
#' from the newly created repo. If `add_cran_check_badge` is set to `TRUE`, the R-CMD-CHECK badge
#' will be added to the README.
#'
#' @param whoami The result of [gh::gh_whoami]
#' @param github_private Should the github repository be private? Default `FALSE`.
#' @param add_cran_check_badge Should the R-CMD-CHECK be added to the README? Default is `TRUE`.
#' @param open Should a web browser be opened to the new Github repository? Default is `FALSE`.
#'
#' @returns The URL of the newly created Github repository
#' @export
create_github_repo <- function(
	whoami,
	github_private = FALSE,
	add_cran_check_badge = TRUE,
	open = FALSE
) {
	.check_whoami(whoami)
	check_logical_length_one(add_cran_check_badge)
	check_logical_length_one(github_private)

	proj_desc <- desc::desc()
	# Create repo on Github
	gh::gh(
		endpoint = "POST /user/repos",
		name = dir,
		description = proj_desc$Description,
		private = github_private,
		.api_url = NULL
	)

	# Update DESCRIPTION with repo URL
	proj_desc$set_list("URL", whoami$gh_url)
	proj_desc$set_list("BugReports", sprintf("%s/issues", whoami$gh_url))
	proj_desc$write()
	system("git add .")
	system("git commit -m \"Create Repository on Github\"")

	if (add_cran_check_badge) {
		# Add badges to README.Rmd, linked to R-CMD-CHECK Github Action. Then re-build README.md
		usethis::use_github_actions_badge()
		devtools::build_readme()
		system("git add .")
		system("git commit -m \"Add R CMD CHECK Badge to README\"")
		system("git push")
	}

	# need to push before creating pkgdown
	system(sprintf("git remote add origin %s", whoami$gh_url))
	system("git push -u origin main")

	if (open) {
		utils::browseURL(whoami$gh_url)
	}

	return(invisible(whoami$gh_url))
}

#' Create a Github Repo
#'
#' From inside a project directory, for a project that has a repository on Github, call this
#' function to create a pkgdown site hosted on Github Pages, and automatically deployed using
#' Github Actions.
#'
#' This function uses the user-provided response from [gh::gh_whoami()] to identify the Github
#' repo. It will also update the `URL` in the `DESCRIPTION` to include the pkgdown site URL.
#'
#' @param whoami The result of [gh::gh_whoami]
#' @param open Should a web browser be opened to the new pkgdown site? Default is `FALSE`.
#'
#' @returns The URL of the newly created pkgdown site
#' @export
create_github_pkgdown <- function(whoami, open = FALSE) {
	.check_whoami(whoami)

	# sets up Github Pages on Github-side
	site <- usethis::use_github_pages()

	# Update repo homepage URL with github pages url
	site_url <- site$html_url
	gh::gh(sprintf("PATCH /repos/%s/%s", whoami$login, dir), homepage = site_url)

	# Update DESCRIPTION with Github pages URL
	proj_desc <- desc::desc()
	proj_desc$set_list("URL", c(whoami$gh_url, site_url))
	proj_desc$write()

	system("git add .")
	system("git commit -m \"Create Package Site\"")

	if (open) {
		utils::browseURL(site_url)
	}

	return(invisible(site_url))
}

.check_whoami <- function(whoami) {
	if (
		is.list(whoami) &&
			all(c("name", "login", "html_url", "token") %in% names(whoami))
	) {
		return(invisible(TRUE))
	}

	cli::cli_abort(
		c(
			"Input `whoami` is not valid",
			i = "Call {.run gh::gh_whoami(.api_url = NULL)} for the correct input format.",
			i = "Call {.run usethis::gh_token_help()} for help configuring a token."
		),
		call = rlang::caller_env()
	)
}
