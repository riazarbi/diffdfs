irisint = iris
irisint$rownum = 1:nrow(irisint)
key_cols = c("rownum")

test_that("key cols unique TRUE", {
  expect_true(checkkey(irisint, key_cols, FALSE))}
)
test_that("key cols unique FALSE", {
  expect_false(checkkey(irisint, "Species", TRUE))}
)
