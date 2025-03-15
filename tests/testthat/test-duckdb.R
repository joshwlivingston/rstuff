test_that("get_con_duckdb() returns a Pool to a duckdb instance", {
	con_duck <- get_con_duckdb()
	expect_s3_class(con_duck, "Pool")
	expect_s3_class(con_duck, "R6")
	expect_equal(
		con_duck$objClass,
		structure("duckdb_connection", "package" = "duckdb")
	)
	expect_true(con_duck$valid)
})
