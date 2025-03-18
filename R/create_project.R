create_project <- function(dir, open = TRUE) {
	check_character_length_one(dir)
	if (dir.exists(dir)) {
		rlang::abort(c(
			"Directory already exists",
			"i" = "To overwrite an existing directory, use `force = TRUE`"
		))
	}

	check_logical_length_one(open)
	if (open) {
		if (!suppressMessages(requireNamespace("rstudioapi"))) {
			rlang::abort(c(
				"{rstudioapi} not detected",
				"i" = "`create_project(..., open = TRUE)` depends on the rstudioapi package",
				"",
				"i" = "Run the following to install:",
				"*" = "pak::pak(\"rstudioapi\")",
				"",
				""
			))
		}

		if (!rstudioapi::isAvailable()) {
			rlang::abort(c(
				"RStudio not detected",
				"i" = "`create_project(..., open = TRUE)` only works inside RStudio"
			))
		}
	}

	res <- fs::dir_copy(
		path = system.file("templates/project", package = "rstuff"),
		new_path = dir,
		overwrite = FALSE
	)

	cwd <- getwd()
	setwd(res)

	fs::file_move("project.Rproj", sprintf("%s.Rproj", dir))
	usethis::use_description()
	usethis::use_mit_license("Josh Livingston")

	devtools::document()
	devtools::build_readme()

	setwd(cwd)

	if (open) rstudioapi::openProject(res)

	return(res)
}
