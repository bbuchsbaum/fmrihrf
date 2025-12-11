# Get sample acquisition times

Generic function retrieving sampling times from a sampling frame or
related object.

## Usage

``` r
samples(x, ...)

# S3 method for class 'sampling_frame'
samples(x, blockids = NULL, global = FALSE, ...)
```

## Arguments

- x:

  Object describing the sampling grid

- ...:

  Additional arguments passed to methods

- blockids:

  Integer vector of block identifiers to include (default: all blocks)

- global:

  Logical indicating whether to return global times (default: FALSE)

## Value

Numeric vector of sample times

## Examples

``` r
# Get sample times from a sampling frame
sframe <- sampling_frame(blocklens = c(100, 120), TR = 2)
samples(sframe, blockids = 1)  # First block only
#>   [1]   1   3   5   7   9  11  13  15  17  19  21  23  25  27  29  31  33  35
#>  [19]  37  39  41  43  45  47  49  51  53  55  57  59  61  63  65  67  69  71
#>  [37]  73  75  77  79  81  83  85  87  89  91  93  95  97  99 101 103 105 107
#>  [55] 109 111 113 115 117 119 121 123 125 127 129 131 133 135 137 139 141 143
#>  [73] 145 147 149 151 153 155 157 159 161 163 165 167 169 171 173 175 177 179
#>  [91] 181 183 185 187 189 191 193 195 197 199
samples(sframe, global = TRUE)  # All blocks, global timing
#>   [1]   1   3   5   7   9  11  13  15  17  19  21  23  25  27  29  31  33  35
#>  [19]  37  39  41  43  45  47  49  51  53  55  57  59  61  63  65  67  69  71
#>  [37]  73  75  77  79  81  83  85  87  89  91  93  95  97  99 101 103 105 107
#>  [55] 109 111 113 115 117 119 121 123 125 127 129 131 133 135 137 139 141 143
#>  [73] 145 147 149 151 153 155 157 159 161 163 165 167 169 171 173 175 177 179
#>  [91] 181 183 185 187 189 191 193 195 197 199 201 203 205 207 209 211 213 215
#> [109] 217 219 221 223 225 227 229 231 233 235 237 239 241 243 245 247 249 251
#> [127] 253 255 257 259 261 263 265 267 269 271 273 275 277 279 281 283 285 287
#> [145] 289 291 293 295 297 299 301 303 305 307 309 311 313 315 317 319 321 323
#> [163] 325 327 329 331 333 335 337 339 341 343 345 347 349 351 353 355 357 359
#> [181] 361 363 365 367 369 371 373 375 377 379 381 383 385 387 389 391 393 395
#> [199] 397 399 401 403 405 407 409 411 413 415 417 419 421 423 425 427 429 431
#> [217] 433 435 437 439
```
