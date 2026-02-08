#' Function class and length checks
#'
#' Often in R package development, the need arises to verify values are of both
#' a specific class and length, with null's allowed conditionally. These are a
#' collection of such functions.
#'
#' @param x The value to be checked
#'
#' @returns TRUE, invisibly, if the check succeeds
#' @name class-length-checks
#'
#' @examples
#'
#' # logical: length-one
#' check_logical_length_one(TRUE)
#'
#' try(check_logical_length_one(rep(FALSE, 2)))
#'
#' try(check_logical_length_one("TRUE"))
#'
#'
#' # character: length-one
#' check_character_length_one("x")
#'
#' try(check_character_length_one(NULL))
#'
#'
#' # character: NULL or length-one
#' check_null_or_character_length_one("x")
#' check_null_or_character_length_one(NULL)
#'
#' try(check_null_or_character_length_one(TRUE))

#' @rdname class-length-checks
#' @export
check_logical_length_one <- function(x) {
	.check_class_f_length_i(x, is.logical, 1)
}

#' @rdname class-length-checks
#' @export
check_character_length_one <- function(x) {
	.check_class_f_length_i(x, is.character, 1)
}

#' @rdname class-length-checks
#' @export
check_null_or_character_length_one <- function(x) {
	.check_null_or_f_length_i(x, is.character, 1)
}

# meant to be called inside an exported check_() function
.check_class_f_length_i <- function(x, f, i, null = FALSE) {
	if (length(x) != i || !f(x)) {
		rlang::abort(
			sprintf(
				"%s%s(%s) && length(%s) == %s must be TRUE",
				if (null) sprintf("Since %s is not NULL, ", deparse(substitute(x))) else
					"",
				deparse(substitute(f)),
				deparse(.substitute_in_parent(x)),
				deparse(.substitute_in_parent(x)),
				i
			),
			call = parent.frame(2),
			class = "check_class_f_length_i"
		)
	}

	return(invisible(TRUE))
}

# meant to be called inside an exported check_() function
.check_null_or_f_length_i <- function(x, f, i) {
	if (!is.null(x) || length(x) > 1)
		.check_class_f_length_i(x, f, i, null = TRUE)
}

# meant to be called inside another function
.substitute_in_parent <- function(x, n = 2) substitute(x, parent.frame(n = n))
