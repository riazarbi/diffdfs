#' Check That A Dataframe Key Col Set Is Unique
#'
#' Checks that a provided vector of column names constitue a unique key (that is, no rows are duplicated) for a dataframe.
#' @param df a dataframe
#' @param key_cols vector of column names
#' @param verbose TRUE/FALSE should we print a message?
#'
#' @return TRUE if key cols have unique rows; FALSE if not
#' @export

#' @importFrom dplyr distinct across all_of
#'
#' @examples
#' irisint = iris
#' irisint$rownum = 1:nrow(irisint)
#' key_cols = c("rownum")
#' checkkey(irisint, key_cols, TRUE)
#' checkkey(irisint, "Species", TRUE)
checkkey <- function(df, key_cols, verbose = FALSE) {
  if(verbose) {
    message("Checking that key column rows are unique")
  }
  if(nrow(dplyr::distinct(.data = df, dplyr::across(dplyr::all_of(key_cols)))) != nrow(df))  {
    return(FALSE)
  } else {
    return(TRUE)
  }
}

