test_that("create_project() fails when `force` is not a length-one logical", {
	expect_error(create_project("dir", rep(TRUE, 2)))
	expect_error(create_project("dir", "TRUE"))
})

test_that("create_project() fails when `dir` exists and `force` is FALSE (default)", {
	fs::dir_create("tmp")
	expect_error(create_project("tmp"))
	fs::dir_delete("tmp")
})

test_that("create_project() fails when `dir` exists and `force` is FALSE", {
	fs::dir_create("tmp")
	expect_error(create_project("tmp", FALSE))
	fs::dir_delete("tmp")
})
