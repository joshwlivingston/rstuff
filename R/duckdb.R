#' Duckdb Database Connection
#'
#' Create a connection pool to a duckdb database instance
#'
#' @inheritParams duckdb::duckdb
#' @inheritParams pool::poolCreate
#'
#' @return A database connection [pool::Pool] to the specified duckdb instance
#'
#' @export
get_con_duckdb <- function(
	dbdir = ":memory:",
	debug = getOption("duckdb.debug", FALSE),
	read_only = FALSE,
	timezone_out = "UTC",
	tz_out_convert = c("with", "force"),
	config = list(),
	bigint = "numeric",
	minSize = 1,
	maxSize = Inf,
	idleTimeout = 60,
	validationInterval = 60,
	state = NULL
) {
	pool::poolCreate(
		factory = function() {
			DBI::dbConnect(
				drv = duckdb::duckdb(),
				dbdir = dbdir,
				debug = debug,
				read_only = read_only,
				timezone_out = timezone_out,
				tz_out_convert = tz_out_convert,
				config = config,
				bigint = bigint
			)
		},
		minSize = minSize,
		maxSize = maxSize,
		idleTimeout = idleTimeout,
		validationInterval = validationInterval,
		state = state
	)
}
