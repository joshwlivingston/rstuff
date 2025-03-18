create_project <- function(dir, force = FALSE) {
	check_logical_length_one(x = force)
	if (dir.exists(dir) && !force) {
		rlang::abort(
			c(
				"Directory already exists",
				"i" = "To overwrite an existing directory, use `force = TRUE`"
			)
		)
	}
}
