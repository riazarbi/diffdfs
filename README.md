# diffdfs

A small R package to compute the difference between dataframes

## Install

It's not on CRAN, so install via `devtools`.

`devtools::install_github("riazarbi/diffdfs")`

## Use

This package just has two functions, `checkkey` and `diffdfs`. 

`checkkey` is just a helper for `diffdfs` but you can use it if it suits your purposes.

here are some examples you can run in your `R` session:

```r
library(diffdfs)
```

```r
iris$key <- 1:nrow(iris)

old_df <- iris[1:100,]
old_df[75,1] <- 100
new_df <- iris[50:150,]
diffdfs(new_df, old_df, key_cols = "key")
```


```r
irisint = iris
irisint$rownum = 1:nrow(irisint)
key_cols = c("rownum")
checkkey(irisint, key_cols, TRUE)
checkkey(irisint, "Species", TRUE)
```

## Contributing

[Riaz Arbi](https://github.com/riazarbi) is the maintainer of this package. If you'd like to point out a bug or make a suggestion, create an issue in this repo.
