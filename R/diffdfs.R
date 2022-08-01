#' Compute the Difference Between Dataframes
#'
#' Returns a dataframe describing the modifications required to transform old_df into new_df.
#' The dataframes needBugReports: 	https://github.com/tidyverse/dplyr/issues to have identical columns and column types and share unique index columns.
#'
#' @param new_df A dataframe of new data.
#' @param old_df A dataframe of old data. new_df and old_df can (and usually do) have overlapping data.
#' @param key_cols optional vector of column names that constitute a unique table key. If NA, colnames(old_df) will be used.
#' @param verbose logical, default FALSE. Should the processing be chatty?
#'
#' @return a dataframe.
#'
#' @export
#'
#' @importFrom janitor compare_df_cols_same
#' @importFrom dplyr anti_join select bind_rows everything
#' @importFrom rlang .data
#' @importFrom arrow Table
#'
#' @examples
#' iris$key <- 1:nrow(iris)
#'
#' old_df <- iris[1:100,]
#' old_df[75,1] <- 100
#' new_df <- iris[50:150,]
#' diffdfs(new_df, old_df, key_cols = "key")
diffdfs <-
  function(new_df,
           old_df = NA,
           key_cols = NA,
           verbose = FALSE) {

    # WORKAROUND FOR https://issues.apache.org/jira/browse/ARROW-16010
    if(is.data.frame(new_df)) {
      new_df <- arrow::Table$create(new_df)$to_data_frame()
    }

    if(is.data.frame(old_df)) {
      old_df <- arrow::Table$create(old_df)$to_data_frame()
    }
    # END WORKAROUND


    # Make sure we've got the correct data types to work with
    if (!(any(class(new_df) %in% c("data.frame", "data.table")))) {
      stop("First argument is not a dataframe. Exiting.")
    }

    if (any(class(old_df) %in% c("logical"))) {
      if (verbose) {
        message(
          "Old dataframe argument is NA. Will create an empty dataframe to diff..."
          )
      }
      rm("old_df")
      old_df <- new_df[0,]
    }

    if (!(any(class(old_df) %in% c("data.frame", "data.table")))) {
      stop("Second argument is not a dataframe or NA. Exiting.")
    }

    if (!janitor::compare_df_cols_same(old_df, new_df)) {
      stop("Newly retrieved table does not have the same column structure as the stored version")
    }

    if (verbose) {
      message("Computing diff dataframe...")
    }

    # create hash columns
    record_cols <- colnames(new_df)
    if (is.na(key_cols[1])) {
      key_cols <- record_cols
    }

    # check that key cols are unique
    if(verbose) {
      message("Processing new_df...")
    }
    new_df_uniqueness_check <- checkkey(new_df, key_cols, verbose)
    if(!new_df_uniqueness_check) {
      stop("The new_df key columns do not contain unique rows. Diff tables only work with key cols that have unique rows.")
    }

    # check that key cols are unique
    # check that key cols are unique
    if(verbose) {
      message("Processing old_df...")
    }
    old_df_uniqueness_check <- checkkey(old_df, key_cols, verbose)
    if(!old_df_uniqueness_check) {
      stop("The old_df key columns do not contain unique rows. Diff tables only work with key cols that have unique rows.")
    }

    # Get new and modified rows

    new_and_modified_rows <- dplyr::anti_join(new_df, old_df, by = record_cols)

    # Get new

    new_rows <- dplyr::anti_join(new_df, old_df, by = key_cols)
    new_rows$operation <- "new"

    # Get modified

    modified_rows <-
      dplyr::anti_join(new_and_modified_rows, new_rows, by = record_cols)
    modified_rows$operation <- "modified"

    # Get deleted rows

    deleted_rows <- dplyr::anti_join(old_df, new_df, by = key_cols)
    deleted_rows$operation <- "deleted"

    diff_df <- as.data.frame(dplyr::bind_rows(new_rows, modified_rows, deleted_rows))

    diff_df <- dplyr::select(diff_df, .data$operation, dplyr::everything())

    return(diff_df)
  }
