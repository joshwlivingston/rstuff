check_if_tmp_exists <- function() {
	if (fs::dir_exists("tmp")) rlang::abort("`tmp` directory already exists")
	return(invisible(TRUE))
}

test_that("check_if_tmp_exists() fails when directory 'tmp' exists", {
	fs::dir_create("tmp")
	expect_error(check_if_tmp_exists(), regexp = "`tmp` directory already exists")
	fs::dir_delete("tmp")
})

test_that("check_if_tmp_exists() returns TRUE when directory 'tmp' does not exist", {
	expect_true(check_if_tmp_exists())
})

test_that("create_project() fails when `force` is not a length-one logical", {
	expect_error(create_project("tmp", rep(TRUE, 2)))
	expect_false(fs::dir_exists("tmp"))

	expect_error(create_project("tmp", "TRUE"))
	expect_false(fs::dir_exists("tmp"))
})

test_that("create_project() fails when `dir` exists", {
	check_if_tmp_exists()
	fs::dir_create("tmp")

	expect_error(create_project("tmp"))

	fs::dir_delete("tmp")
})

test_that("create_project() throws a warning when `open` is TRUE outside RStudio", {
	expect_warning(create_project("tmp", open = TRUE, build_readme_md = FALSE, use_bad_rproj = TRUE))
	fs::dir_delete("tmp")
})

res <- create_project("tmp", open = FALSE, build_readme_md = FALSE, use_bad_rproj = TRUE)
expect_file_exists <- function(...) expect_true(fs::file_exists(fs::path_join(c(res, ...))))
expect_dir_exists <- function(...) expect_true(fs::dir_exists(fs::path_join(c(res, ...))))
expect_dir_length <- function(n, ...)
	expect_length(fs::dir_ls(fs::path_join(c(res, ...)), all = TRUE), n)

test_that("create_project() returns an fs_path of the new `dir`", {
	expect_s3_class(res, c("fs_path", "character"))
	expect_true(grepl("tmp$", res))
})

test_that("create_project() creates new directory", {
	expect_true(fs::dir_exists("tmp"))
})

test_that("create_project() writes all expected files", {
	expect_dir_length(11)

	expect_file_exists("_pkgdown.yml")
	expect_file_exists(".gitignore")
	expect_file_exists(".Rbuildignore")
	expect_file_exists("air.toml")
	expect_file_exists("DESCRIPTION")
	expect_file_exists("Readme.Rmd")
	expect_file_exists("project.Rproj")

	expect_dir_length(2, ".github")
	expect_file_exists(".github", ".gitignore")

	expect_dir_length(3, ".github", "workflows")
	expect_file_exists(".github", "workflows", "air.yaml")
	expect_file_exists(".github", "workflows", "pkgdown.yaml")
	expect_file_exists(".github", "workflows", "R-CMD-check.yaml")

	expect_dir_length(1, ".vscode")
	expect_file_exists(".vscode", "settings.json")

	expect_dir_length(1, "dev")
	expect_file_exists("dev", "config_attachment.yaml")

	expect_dir_length(0, "R")
	expect_dir_exists("R")
})

if (fs::dir_exists("tmp")) fs::dir_delete("tmp")
