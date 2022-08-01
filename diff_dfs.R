#' Diff dataframes
#'
#' Returns a list of adds, updates and deletes required to transform old_df into new_df.
#' The dataframes need to have identical columns, column types and unique index columns.
#'
#' @param new_df dataframe. A dataframe of new data
#' @param old_df dataframe. A dataframe of old data. new_df and old_df can have overlapping data
#' @param key_cols optional vector of column names that constitute a unique table key.
#' @param verbose boolean, default FALSE. Should the processing be chatty?
#'
#' @return a dataframe with the structure
#'       operation col1 col2 ...
#'       new       4    g
#'       modified  6    f
#'       deleted   1    a
#'       deleted   4    d
#'       ...       ...  ...
#'
#' @export
#' @import janitor
#' @importFrom dplyr anti_join select mutate bind_rows
#'
#' @examples
#' iris$key <- 1:nrow(iris)
#'
#' old_df <- iris[1:100,]
#' old_df[75,1] <- 100
#' new_df <- iris[50:150,]
#' diff_dataframes(new_df, old_df, key_cols = "key")
diff_dfs <-
  function(new_df,
           old_df = NA,
           key_cols = NA,
           verbose = FALSE) {

    # WORKAROUND FOR https://issues.apache.org/jira/browse/ARROW-16010
    new_df <- Table$create(new_df)$to_data_frame()
    if(is.data.frame(old_df)) {
      old_df <- Table$create(old_df)$to_data_frame()
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
    new_df_uniqueness_check <- check_key_cols_unique(new_df, key_cols, verbose)
    if(!new_df_uniqueness_check) {
      stop("The new_df key columns do not contain unique rows. Diff tables only work with key cols that have unique rows.")
    }

    # check that key cols are unique
    # check that key cols are unique
    if(verbose) {
      message("Processing old_df...")
    }
    old_df_uniqueness_check <- check_key_cols_unique(old_df, key_cols, verbose)
    if(!old_df_uniqueness_check) {
      stop("The old_df key columns do not contain unique rows. Diff tables only work with key cols that have unique rows.")
    }

    # Get new and modified rows

    new_and_modified_rows <- dplyr::anti_join(new_df, old_df, by = record_cols)

    # Get new

    new_rows <- dplyr::anti_join(new_df, old_df, by = key_cols)%>%
      dplyr::mutate(operation = "new")

    # Get modified

    modified_rows <-
      dplyr::anti_join(new_and_modified_rows, new_rows, by = record_cols) %>%
      dplyr::mutate(operation = "modified")

    # Get deleted rows

    deleted_rows <- dplyr::anti_join(old_df, new_df, by = key_cols) %>%
      dplyr::mutate(operation = "deleted")

    diff_df <- as.data.frame(dplyr::bind_rows(new_rows, modified_rows, deleted_rows))

    diff_df <- diff_df %>%
      dplyr::mutate(`key_cols` = paste(key_cols, collapse = "|")) %>%
      dplyr::select(key_cols, operation, everything())

    return(diff_df)
  }
