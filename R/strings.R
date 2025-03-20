str_to_title <- function(x) {
	stopifnot(is.character(x))
	gsub("(^| )([a-z])", "\\1\\U\\2", x, perl = TRUE)
}
