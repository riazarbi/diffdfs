# Create sample dataframe
new_df <- data.frame(a = 2:6, b = letters[2:6])
new_df[3, 2] <- "g"
old_df <- data.frame(a = 1:5, b = letters[1:5])

# Test diff function
test_that("diffdfs: Check diff with key cols works", {
  expect_equal(
    diffdfs(new_df, old_df, key_cols = "a"),
    data.frame(operation = c("new", "modified", "deleted"),
    a = c(6,4,1),
    b = c("f", "g", "a")
  ))
})

test_that("diffdfs: Check diff with key cols works VERBOSE", {
  expect_message(
    diffdfs(new_df, old_df, key_cols = "a", verbose = TRUE),
    "Computing diff dataframe"
  )
})


test_that("diffdfs: Check diff without key cols works", {
  expect_equal(
    diffdfs(new_df, old_df, key_cols = NA),
    data.frame(operation = c("new", "new", "deleted", "deleted"),
               a = c(4,6,1,4),
               b = c("g", "f", "a", "d")
    )
  )
})

test_that("diffdfs: Check diff without no old dataset passed VERBOSE",
          {
            expect_message(
              diffdfs(new_df, NA, verbose = TRUE),
              "Old dataframe argument is NA"
            )
          })

test_that("diffdfs: Check different cols results in error",
          {
            expect_error(
              diffdfs(new_df, old_df %>% dplyr::mutate(a = as.character(a))),
              "Newly retrieved table does not have the same column structure as the stored version"
            )
          })


test_that("diffdfs: Check diff without no old dataset passed",
          {
            expect_equal(
              diffdfs(new_df, NA),
              data.frame(operation = c("new", "new", "new", "new", "new"),
                         a = c(2,3,4,5,6),
                         b = c("b", "c", "g", "e", "f"))
            )
          })

test_that("diffdfs: Check diff without no old dataset passed VERBOSE",
          {
            expect_message(
              diffdfs(new_df, NA, verbose = T),
              "Old dataframe argument is NA"
            )
          })



test_that("diffdfs: Check diff when comparing two identical dfs",
          {
            expect_equal(
              diffdfs(new_df, new_df),
              data.frame(operation = character(),
                         a = integer(),
                         b = character())
            )
          })

test_that("diffdfs: Check bad first argument errors out",
          {
            expect_error(
              diffdfs("bad", new_df),
              "First argument is not a dataframe")
          })

dup_new_df <- new_df
dup_new_df[1,1] <- 3L

test_that("diffdfs: Check new_df non unique key cols error out",
          {
            expect_error(
              diffdfs(dup_new_df, NA, key_cols = "a"),
              "The new_df key columns do not contain unique rows.")
          })

test_that("diffdfs: Check old_df non unique key cols error out",
          {
            expect_error(
              diffdfs(new_df, dup_new_df, key_cols = "a"),
              "The old_df key columns do not contain unique rows.")
          })


# Test illegal usage
# Expect error
test_that("diffdfs: Check that not passing in a new df results in an error",
          {
            expect_error(diffdfs(NA, old_df),
                         "First argument is not a dataframe")
          })

test_that("diffdfs: Check that passing bad data to old_df results in error",
          {
            expect_error(diffdfs(new_df, "bad"),
                         "Second argument is not a dataframe")
          })

