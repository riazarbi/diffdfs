# diffdfs

A small R package to compute the difference between data frames.

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
```

```r
> diffdfs(new_df, old_df, key_cols = "key")
    operation Sepal.Length Sepal.Width Petal.Length Petal.Width    Species key
1         new          6.3         3.3          6.0         2.5  virginica 101
2         new          5.8         2.7          5.1         1.9  virginica 102
3         new          7.1         3.0          5.9         2.1  virginica 103
4         new          6.3         2.9          5.6         1.8  virginica 104
5         new          6.5         3.0          5.8         2.2  virginica 105
6         new          7.6         3.0          6.6         2.1  virginica 106
...
...
```


```r
irisint = iris
irisint$rownum = 1:nrow(irisint)
key_cols = c("rownum")
```

```r
> checkkey(irisint, key_cols, TRUE)
Checking that key column rows are unique
[1] TRUE
```

```r
> checkkey(irisint, "Species", TRUE)
Checking that key column rows are unique
[1] FALSE
```

## Contributing

[Riaz Arbi](https://github.com/riazarbi) is the maintainer of this package. If you'd like to point out a bug or make a suggestion, create an issue in this repo.
