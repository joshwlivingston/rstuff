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
	.check_valid_package_name(dir)
	if (dir.exists(dir)) rlang::abort("Directory already exists")

	check_logical_length_one(open)

	check_null_or_character_length_one(package_title)
	check_null_or_character_length_one(package_description)
	check_null_or_character_length_one(package_license)
	check_null_or_character_length_one(package_version)

	check_logical_length_one(github_use)
	check_logical_length_one(github_pkgdown)
	check_logical_length_one(github_private)

	if (github_pkgdown && !github_use)
		rlang::abort(X = "`github_use` must be TRUE when `github_pkgdown` is TRUE")

	if (github_use) {
		whoami <- gh::gh_whoami(.api_url = NULL)
		if (is.null(whoami)) {
			rlang::abort(
				c(
					x = "Unable to discover a GitHub personal access token.",
					i = "A token is required in order to create and push to a new repo.",
					`_` = "Call {.run usethis::gh_token_help()} for help configuring a token.",
					"Or, provide `use_github = FALSE` to create_project()"
				)
			)
		}

		# Throw error if repo exists with provided name
		# built as separate function to use return in error catch
		check_repo_is_new <- function() {
			tryCatch(
				# if GET throws error, repo does not exist. return TRUE
				gh::gh(sprintf("GET /repos/%s/%s", whoami$login, dir)),
				error = function(e) return(invisible(TRUE))
			)

			# if arrive here, repo exists. throw error
			rlang::abort(
				sprintf("Github repository already exists at %s/%s", whoami$login, dir),
				call = rlang::caller_env()
			)
		}
		check_repo_is_new()
	}

	new_project_path <-
		fs::dir_copy(
			path = system.file("templates/project", package = "rstuff"),
			new_path = dir,
			overwrite = FALSE
		)

	# files are loaded into R Package with TEMPLATE added to the name to prevent build conflicts
	vapply(
		fs::dir_ls(new_project_path, all = TRUE),
		function(x) fs::file_move(x, gsub("TEMPLATE", "", x)),
		character(1)
	)

	fs_join <- function(...) fs::path_join(c(new_project_path, ...))
	fs::file_move(fs_join("project.Rproj"), fs_join(sprintf("%s.Rproj", dir)))

	description_fields <- usethis::use_description_defaults()

	description_fields$Package <- dir

	if (!is.null(package_title)) description_fields$Title <- str_to_title(package_title)
	if (!is.null(package_description)) description_fields$Description <- package_description
	if (!is.null(package_version)) description_fields$Version <- package_version

	description <- desc::desc(
		text = sprintf("%s: %s", names(description_fields), description_fields)
	)
	description$write(file = fs_join("DESCRIPTION"))
	message("project created at ", new_project_path)

	cwd <- getwd()
	setwd(new_project_path)

	system("git init")

	devtools::document()
	usethis::use_readme_rmd(open = FALSE)
	usethis::use_package("devtools", "Suggests")
	usethis::use_package("rmarkdown", "Suggests")
	devtools::build_readme()
	if (is.null(package_license)) {
		message("Creating MIT License")
		usethis::use_mit_license()
	} else {
		message(sprintf("Creating %s License", package_license))
		usethis::use_proprietary_license(package_license)
	}

	system("git add .")
	system("git commit -m \"Initial Commit\"")

	if (github_use) {
		gh::gh(
			endpoint = "POST /user/repos",
			name = dir,
			description = description_fields$Description,
			private = github_private,
			.api_url = NULL
		)

		gh_url <- sprintf("%s/%s", whoami$html_url, dir)
		system(sprintf("git remote add origin %s", gh_url))
		proj_desc <- desc::desc()
		proj_desc$set_list("URL", gh_url)
		proj_desc$set_list("BugReports", sprintf("%s/issues", gh_url))
		proj_desc$write()
		system("git add .")
		system("git commit -m \"Create Repository on Github\"")

		# need to push before creating pkgdown
		system("git push -u origin main")
		if (github_pkgdown) {
			site <- usethis::use_github_pages()
			site_url <- site$html_url
			gh::gh(sprintf("PATCH /repos/%s/%s", whoami$login, dir), homepage = site_url)

			proj_desc <- desc::desc()
			proj_desc$set_list("URL", c(gh_url, site_url))
			proj_desc$write()

			system("git add .")
			system("git commit -m \"Create Package Site\"")

			usethis::use_github_actions_badge()
			devtools::build_readme()
			system("git add .")
			system("git commit -m \"Add R CMD CHECK Badge to README\"")
			system("git push")

			utils::browseURL(gh_url)
		}
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

.check_valid_package_name <- function(x) {
	if (!grepl("^[a-zA-Z][a-zA-Z0-9.]+$", x) || grepl("\\.$", x)) {
		rlang::abort(sprintf("%s must be a valid R package name", x))
	}
}
