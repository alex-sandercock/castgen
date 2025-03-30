## R CMD check results

0 errors | 0 warnings | 1 note

* This is a new release.

* Regarding the remaining NOTE about the use of `:::`, the call `castgen:::calculate_MAF()` is used intentionally. The `calculate_MAF` function is internal (`@noRd`) and needs to be accessed by parallel workers created via `foreach %dopar%`. Using `:::` is the recommended way to make such internal functions available in that context.
