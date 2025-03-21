create_project <- function(
	dir,
	open = TRUE,
	package_title = NULL,
	package_description = NULL,
	package_license = NULL,
	package_version = NULL,
	build_readme_rmd = TRUE,
	use_bad_rproj = FALSE
) {
	check_character_length_one(dir)
	.check_valid_package_name(dir)
	if (dir.exists(dir)) rlang::abort("Directory already exists")

	check_logical_length_one(open)

	check_null_or_character_length_one(package_title)
	check_null_or_character_length_one(package_description)
	check_null_or_character_length_one(package_license)
	check_null_or_character_length_one(package_version)

	check_logical_length_one(build_readme_rmd)

	new_project_path <-
		fs::dir_copy(
			path = system.file("templates/project", package = "rstuff"),
			new_path = dir,
			overwrite = FALSE
		)

	fs_join <- function(...) fs::path_join(c(new_project_path, ...))
	if (!use_bad_rproj) fs::file_move(fs_join("project.Rproj"), fs_join(sprintf("%s.Rproj", dir)))

	description_fields <- usethis::use_description_defaults()

	description_fields$Package <- dir

	if (!is.null(package_title)) description_fields$Title <- str_to_title(package_title)
	if (!is.null(package_description)) description_fields$Description <- package_description
	if (!is.null(package_version)) description_fields$Version <- package_version

	description <- desc::desc(
		text = sprintf("%s: %s", names(description_fields), description_fields)
	)
	description$write(file = fs_join("DESCRIPTION"))
	message("project created at %s", new_project_path)

	cwd <- getwd()
	setwd(new_project_path)

	usethis::use_namespace()

	if (!is.null(package_license)) {
		if (license == "mit") {
			message("Creating MIT License")
			usethis::use_mit_license()
		} else {
			message(sprintf("Creating %s License", package_license))
			usethis::use_proprietary_license(package_license)
		}
	}

	if (build_readme_rmd) {
		usethis::use_readme_rmd()
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
