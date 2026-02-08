# Function class and length checks

Often in R package development, the need arises to verify values are of
both a specific class and length, with null's allowed conditionally.
These are a collection of such functions.

## Usage

``` r
check_logical_length_one(x)

check_character_length_one(x)

check_null_or_character_length_one(x)
```

## Arguments

- x:

  The value to be checked

## Value

TRUE, invisibly, if the check succeeds

## Examples

``` r
# logical: length-one
check_logical_length_one(TRUE)

try(check_logical_length_one(rep(FALSE, 2)))
#> Error in eval(expr, envir) : 
#>   is.logical(rep(FALSE, 2)) && length(rep(FALSE, 2)) == 1 must be TRUE

try(check_logical_length_one("TRUE"))
#> Error in eval(expr, envir) : 
#>   is.logical("TRUE") && length("TRUE") == 1 must be TRUE


# character: length-one
check_character_length_one("x")

try(check_character_length_one(NULL))
#> Error in eval(expr, envir) : 
#>   is.character(NULL) && length(NULL) == 1 must be TRUE


# character: NULL or length-one
check_null_or_character_length_one("x")
check_null_or_character_length_one(NULL)

try(check_null_or_character_length_one(TRUE))
#> Error in check_null_or_character_length_one(TRUE) : 
#>   Since x is not NULL, f(x) && length(x) == 1 must be TRUE
```
