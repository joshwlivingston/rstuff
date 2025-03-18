#### class-length checks #################################################################
class_length_check_class <- "check_class_f_length_i"
expect_class_length_error <- function(...)
	expect_error(..., class = class_length_check_class)

test_that("check_logical_length_one() returns TRUE on length-one logicals", {
	expect_true(check_logical_length_one(TRUE))
	expect_true(check_logical_length_one(FALSE))
})

test_that("check_logical_length_one() returns an error on non-length-one-logicals", {
	expect_class_length_error(check_logical_length_one(rep(TRUE, 2)))
	expect_class_length_error(check_logical_length_one(rep(FALSE, 2)))
	expect_class_length_error(check_logical_length_one(logical()))
	expect_class_length_error(check_logical_length_one(Sys.Date()))
	expect_class_length_error(check_logical_length_one("x"))
	expect_class_length_error(check_logical_length_one(1.3))
	expect_class_length_error(check_logical_length_one(1L))
	expect_class_length_error(check_logical_length_one(list("x")))
})
