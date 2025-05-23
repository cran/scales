test_that("rescale_mid returns correct results", {
  x <- c(-1, 0, 1)

  expect_equal(rescale_mid(x), c(0, 0.5, 1))
  expect_equal(rescale_mid(x, mid = -1), c(0.5, 0.75, 1))
  expect_equal(rescale_mid(x, mid = 1), c(0, 0.25, 0.5))

  expect_equal(rescale_mid(x, mid = 1, to = c(0, 10)), c(0, 2.5, 5))
  expect_equal(rescale_mid(x, mid = 1, to = c(8, 10)), c(8, 8.5, 9))

  expect_equal(rescale_mid(c(1, NA, 1)), c(0.5, NA, 0.5))
})

test_that("rescale_max returns correct results", {
  expect_equal(rescale_max(0), NaN)
  expect_equal(rescale_max(1), 1)
  expect_equal(rescale_max(.3), 1)
  expect_equal(rescale_max(c(4, 5)), c(0.8, 1.0))
  expect_equal(rescale_max(c(-3, 0, -1, 2)), c(-1.5, 0, -0.5, 1))
  expect_equal(rescale_max(c(-3, 0, -1, 2)), c(-1.5, 0, -0.5, 1))
})

test_that("rescale functions handle NAs consistently", {
  expect_equal(rescale(c(2, NA, 0, -2)), c(1, NA, 0.5, 0))
  expect_equal(rescale(c(-2, NA, -2)), c(.5, NA, .5))

  expect_equal(rescale_mid(c(NA, 1, 2)), c(NA, 0.75, 1))
  expect_equal(rescale_mid(c(2, NA, 0, -2), mid = .5), c(0.8, NA, 0.4, 0))
  expect_equal(rescale_mid(c(-2, NA, -2)), c(.5, NA, .5))

  expect_equal(rescale_max(c(1, NA)), c(1, NA))
  expect_equal(rescale_max(c(2, NA, 0, -2)), c(1, NA, 0, -1))
  expect_equal(rescale_max(c(-2, NA, -2)), c(1, NA, 1))
})

test_that("rescale preserves NAs even when x has zero range", {
  expect_equal(rescale(c(1, NA)), c(0.5, NA))
})

test_that("zero range inputs return mid range", {
  expect_equal(rescale(0), 0.5)
  expect_equal(rescale(c(0, 0)), c(0.5, 0.5))
})

test_that("scaling is possible with dates and times", {
  dates <- as.Date(c("2010-01-01", "2010-01-03", "2010-01-05", "2010-01-07"))
  expect_equal(rescale(dates, from = c(dates[1], dates[4])), seq(0, 1, 1 / 3))
  expect_equal(rescale_mid(dates, mid = dates[3])[3], 0.5)

  dates <- as.POSIXct(c(
    "2010-01-01 01:40:40",
    "2010-01-01 03:40:40",
    "2010-01-01 05:40:40",
    "2010-01-01 07:40:40"
  ))
  expect_equal(rescale(dates, from = c(dates[1], dates[4])), seq(0, 1, 1 / 3))
  expect_equal(rescale_mid(dates, mid = dates[3])[3], 0.5)
})

test_that("scaling is possible with integer64 data", {
  skip_if_not_installed("bit64")
  x <- bit64::as.integer64(2^60) + c(0:3)
  expect_equal(
    rescale_mid(x, mid = bit64::as.integer64(2^60) + 1),
    c(0.25, 0.5, 0.75, 1)
  )
})

test_that("scaling is possible with NULL values", {
  expect_null(rescale(NULL))
  expect_null(rescale_mid(NULL))
})

test_that("rescaling does not alter AsIs objects", {
  expect_identical(I(1:3), rescale(I(1:3), from = c(0, 4)))
  expect_identical(I(1:3), rescale_mid(I(1:3), from = c(0, 4), mid = 1))
})

test_that("scaling is possible with logical values", {
  expect_equal(rescale(c(FALSE, TRUE)), c(0, 1))
  expect_equal(rescale_mid(c(FALSE, TRUE), mid = 0.5), c(0, 1))
})

test_that("expand_range respects mul and add values", {
  expect_equal(expand_range(c(1, 1), mul = 0, add = 0.6), c(0.4, 1.6))
  expect_equal(expand_range(c(1, 1), mul = 1, add = 0.6), c(-0.6, 2.6))
  expect_equal(expand_range(c(1, 9), mul = 0, add = 2), c(-1, 11))
})

test_that("out of bounds functions return correct values", {
  x <- c(-Inf, -1, 0.5, 1, 2, NA, Inf)

  expect_equal(oob_censor(x), c(-Inf, NA, 0.5, 1, NA, NA, Inf))
  expect_equal(oob_censor_any(x), c(NA, NA, 0.5, 1, NA, NA, NA))
  expect_equal(oob_censor(x), censor(x))

  expect_equal(oob_squish(x), c(-Inf, 0, 0.5, 1, 1, NA, Inf))
  expect_equal(oob_squish_any(x), c(0, 0, 0.5, 1, 1, NA, 1))
  expect_equal(oob_squish_infinite(x), c(0, -1, 0.5, 1, 2, NA, 1))
  expect_equal(oob_squish(x), squish(x))

  expect_equal(oob_discard(x), c(0.5, 1, NA))
  expect_equal(oob_discard(x), discard(x))

  expect_equal(oob_keep(x), x)
})


# zero_range --------------------------------------------------------------

test_that("large numbers with small differences", {
  expect_false(zero_range(c(1330020857.8787, 1330020866.8787)))
  expect_true(zero_range(c(1330020857.8787, 1330020857.8787)))
})

test_that("small numbers with differences on order of values", {
  expect_false(zero_range(c(5.63e-147, 5.93e-123)))
  expect_false(zero_range(c(-7.254574e-11, 6.035387e-11)))
  expect_false(zero_range(c(-7.254574e-11, -6.035387e-11)))
})

test_that("ranges with 0 endpoint(s)", {
  expect_false(zero_range(c(0, 10)))
  expect_true(zero_range(c(0, 0)))
  expect_false(zero_range(c(-10, 0)))
  expect_false(zero_range(c(0, 1) * 1e-100))
  expect_false(zero_range(c(0, 1) * 1e+100))
})

test_that("symmetric ranges", {
  expect_false(zero_range(c(-1, 1)))
  expect_false(zero_range(c(-1, 1 * (1 + 1e-20))))
  expect_false(zero_range(c(-1, 1) * 1e-100))
})

test_that("length 1 ranges", {
  expect_true(zero_range(c(1)))
  expect_true(zero_range(c(0)))
  expect_true(zero_range(c(1e100)))
  expect_true(zero_range(c(1e-100)))
})

test_that("NA and Inf", {
  # Should return NA
  expect_true(is.na(zero_range(c(NA, NA))))
  expect_true(is.na(zero_range(c(1, NA))))
  expect_true(is.na(zero_range(c(1, NaN))))

  # Not zero range
  expect_false(zero_range(c(1, Inf)))
  expect_false(zero_range(c(-Inf, Inf)))

  # Can't know if these are truly zero range
  expect_true(zero_range(c(Inf, Inf)))
  expect_true(zero_range(c(-Inf, -Inf)))
})

test_that("Tolerance", {
  # By default, tolerance is 1000 times this
  eps <- .Machine$double.eps

  expect_true(zero_range(c(1, 1 + eps)))
  expect_true(zero_range(c(1, 1 + 99 * eps)))

  # Cross the threshold
  expect_false(zero_range(c(1, 1 + 1001 * eps)))
  expect_false(zero_range(c(1, 1 + 2 * eps), tol = eps))

  # Scaling up or down all the values has no effect since the values
  # are rescaled to 1 before checking against tol
  expect_true(zero_range(100000 * c(1, 1 + eps)))
  expect_true(zero_range(.00001 * c(1, 1 + eps)))
  expect_true(zero_range(100000 * c(1, 1 + 99 * eps)))
  expect_true(zero_range(.00001 * c(1, 1 + 99 * eps)))
  expect_false(zero_range(100000 * c(1, 1 + 1001 * eps)))
  expect_false(zero_range(.00001 * c(1, 1 + 1001 * eps)))
})
