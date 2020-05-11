test_that("NA.value works for continuous scales", {
  x <- c(NA, seq(0, 1, length.out = 10), NA)
  pal <- rescale_pal()

  expect_that(cscale(x, pal)[1], equals(NA_real_))
  expect_that(cscale(x, pal)[12], equals(NA_real_))
  expect_that(cscale(x, pal, 5)[1], equals(5))
  expect_that(cscale(x, pal, 5)[12], equals(5))
})

test_that("train_continuous stops on discrete values", {
  expect_error(train_continuous(LETTERS[1:5]),
    regexp = "Discrete value supplied"
  )
})

test_that("train_continuous strips attributes", {
  expect_equal(train_continuous(1:5), c(1, 5))

  x <- as.Date("1970-01-01") + c(1, 5)
  expect_equal(train_continuous(x), c(1, 5))
})

test_that("train_continuous with new=NULL maintains existing range.", {
  expect_equal(
    train_continuous(NULL, existing = c(1, 5)),
    c(1, 5)
  )
})
