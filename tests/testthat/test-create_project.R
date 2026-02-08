test_that("create_project() fails when `dir` exists", {
	fs::dir_create("tmp")

	expect_error(create_project("tmp"))

	fs::dir_delete("tmp")
})

test_that("create_project() throws an error when Github repository exists", {
	skip() # requires https auth
	expect_error(create_project("rstuff"))
})

test_that("create_project() throws an error when `github_pkgdown` is TRUE and `github_use` is FALSE", {
	expect_error(create_project("tmp", github_use = FALSE, github_pkgdown = TRUE))
})

test_that("create_project() throws a warning when `open` is TRUE outside RStudio", {
	expect_warning(create_project(
		"tmp",
		open = TRUE,
		github_use = FALSE,
		github_pkgdown = FALSE
	))
	fs::dir_delete("tmp")
})

res <- create_project(
	"tmp",
	open = FALSE,
	github_use = FALSE,
	github_pkgdown = FALSE
)
expect_file_exists <- function(...) {
	expect_true(fs::file_exists(fs::path_join(c(res, ...))))
}
expect_dir_exists <- function(...) {
	expect_true(fs::dir_exists(fs::path_join(c(res, ...))))
}
expect_dir_length <- function(n, ...) {
	expect_length(fs::dir_ls(fs::path_join(c(res, ...)), all = TRUE), n)
}

test_that("create_project() returns an fs_path of the new `dir`", {
	expect_s3_class(res, c("fs_path", "character"))
	expect_true(grepl("tmp$", res))
})

test_that("create_project() creates new directory", {
	expect_true(fs::dir_exists("tmp"))
})

test_that("create_project() writes all expected files", {
	expect_dir_length(17)

	expect_file_exists("_pkgdown.yml")
	expect_file_exists(".gitignore")
	expect_file_exists(".Rbuildignore")
	expect_file_exists("air.toml")
	expect_file_exists("DESCRIPTION")
	expect_file_exists("tmp.Rproj")
	expect_file_exists("LICENSE")
	expect_file_exists("LICENSE.md")
	expect_file_exists("NAMESPACE")
	expect_file_exists("README.md")
	expect_file_exists("README.Rmd")

	expect_dir_exists(".git")

	expect_dir_length(1, ".github")

	expect_dir_length(3, ".github", "workflows")
	expect_file_exists(".github", "workflows", "air.yaml")
	expect_file_exists(".github", "workflows", "pkgdown.yaml")
	expect_file_exists(".github", "workflows", "R-CMD-check.yaml")

	expect_dir_length(1, ".vscode")
	expect_file_exists(".vscode", "settings.json")

	expect_dir_length(1, "dev")
	expect_file_exists("dev", "config_attachment.yaml")

	expect_dir_length(1, "R")
	expect_file_exists("R", "hello.R")
})

if (fs::dir_exists("tmp")) {
	fs::dir_delete("tmp")
}
