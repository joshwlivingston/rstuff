# Duckdb Database Connection

Create a connection pool to a duckdb database instance

## Usage

``` r
get_con_duckdb(
  dbdir = ":memory:",
  debug = getOption("duckdb.debug", FALSE),
  read_only = FALSE,
  timezone_out = "UTC",
  tz_out_convert = c("with", "force"),
  config = list(),
  bigint = "numeric",
  minSize = 1,
  maxSize = Inf,
  idleTimeout = 60,
  validationInterval = 60,
  state = NULL
)
```

## Arguments

- dbdir:

  Location for database files. Should be a path to an existing directory
  in the file system. With the default (or `""`), all data is kept in
  RAM.

- debug:

  Print additional debug information, such as queries.

- read_only:

  Set to `TRUE` for read-only operation. For file-based databases, this
  is only applied when the database file is opened for the first time.
  Subsequent connections (via the same `drv` object or a `drv` object
  pointing to the same path) will silently ignore this flag.

- timezone_out:

  The time zone returned to R, defaults to `"UTC"`, which is currently
  the only timezone supported by duckdb. If you want to display datetime
  values in the local timezone, set to
  [`Sys.timezone()`](https://rdrr.io/r/base/timezones.html) or `""`.

- tz_out_convert:

  How to convert timestamp columns to the timezone specified in
  `timezone_out`. There are two options: `"with"`, and `"force"`. If
  `"with"` is chosen, the timestamp will be returned as it would appear
  in the specified time zone. If `"force"` is chosen, the timestamp will
  have the same clock time as the timestamp in the database, but with
  the new time zone.

- config:

  Named list with DuckDB configuration flags, see
  <https://duckdb.org/docs/configuration/overview#configuration-reference>
  for the possible options. These flags are only applied when the
  database object is instantiated. Subsequent connections will silently
  ignore these flags.

- bigint:

  How 64-bit integers should be returned. There are two options:
  `"numeric"` and `"integer64"`. If `"numeric"` is selected, bigint
  integers will be treated as double/numeric. If `"integer64"` is
  selected, bigint integers will be set to bit64 encoding.

- minSize, maxSize:

  The minimum and maximum number of objects in the pool.

- idleTimeout:

  Number of seconds to wait before destroying idle objects (i.e. objects
  available for checkout over and above `minSize`).

- validationInterval:

  Number of seconds to wait between validating objects that are
  available for checkout. These objects are validated in the background
  to keep them alive.

  To force objects to be validated on every checkout, set
  `validationInterval = 0`.

- state:

  A `pool` public variable to be used by backend authors.

## Value

A database connection
[pool::Pool](http://rstudio.github.io/pool/reference/Pool-class.md) to
the specified duckdb instance
