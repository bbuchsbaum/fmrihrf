# Missing Documentation Report for fmrihrf Package

## Functions Missing @examples

### Core HRF Functions
1. **hrf_ident()** (hrf-functions.R) - Currently commented out, no examples
2. **hrf_toeplitz()** (hrf-functions.R:317) - Has @export but missing @examples
3. **hrf_half_cosine()** (hrf-functions.R:261) - Has @export but missing @examples
4. **hrf_fourier()** (hrf-functions.R:290) - Has @export but missing @examples

### HRF System Functions  
5. **as_hrf()** (hrf.R:14) - Missing @examples
6. **bind_basis()** (hrf.R:47) - Missing @examples
7. **empirical_hrf()** (hrf.R:183) - Missing @examples
8. **hrf_set()** (hrf.R:206) - Missing @examples
9. **hrf_library()** (hrf.R:232) - Missing @examples
10. **HRF()** (hrf.R:290) - Has examples but could be expanded
11. **list_available_hrfs()** (hrf.R:447) - Missing @examples

### HRF Decorators
12. **lag_hrf()** (hrf_decorators.R:17) - Has examples
13. **block_hrf()** (hrf_decorators.R:68) - Has examples  
14. **normalise_hrf()** (hrf_decorators.R:182) - Has examples

### Generic Functions
15. **evaluate()** (all_generic.R:13) - Missing @examples
16. **shift()** (all_generic.R:67) - Has examples
17. **hrf_from_coefficients()** (all_generic.R:86) - Missing @examples
18. **nbasis()** (all_generic.R:102) - Missing @examples
19. **penalty_matrix()** (all_generic.R:145) - Has examples
20. **reconstruction_matrix()** (all_generic.R:174) - Missing @examples
21. **durations()** (all_generic.R:184) - Missing @examples
22. **amplitudes()** (all_generic.R:194) - Missing @examples
23. **onsets()** (all_generic.R:204) - Missing @examples
24. **samples()** (all_generic.R:217) - Missing @examples
25. **global_onsets()** (all_generic.R:228) - Missing @examples
26. **blockids()** (all_generic.R:238) - Missing @examples
27. **blocklens()** (all_generic.R:248) - Missing @examples
28. **neural_input()** (all_generic.R:317) - Has examples

### Regressor Functions
29. **regressor()** (reg-constructor.R:141) - Missing @examples
30. **single_trial_regressor()** (reg-constructor.R:177) - Missing @examples
31. **regressor_set()** (regressor-set.R:18) - Missing @examples
32. **regressor_design()** (regressor-design.R:27) - Missing @examples

### Sampling Frame Functions
33. **sampling_frame()** (sampling_frame.R:39) - Has examples

### Methods (likely have examples via their generic)
34. **evaluate.HRF()** (hrf.R:803) - Missing @examples
35. **evaluate.RegSet()** (regressor-set.R:49) - Missing @examples
36. **nbasis.HRF()** (hrf.R:321) - Inherits from generic
37. **print.sampling_frame()** (sampling_frame.R:139) - Print methods typically don't need examples
38. **samples.sampling_frame()** (sampling_frame.R:90) - Missing @examples
39. **global_onsets.sampling_frame()** (sampling_frame.R:122) - Missing @examples
40. **blockids.sampling_frame()** (sampling_frame.R:164) - Missing @examples
41. **blocklens.sampling_frame()** (sampling_frame.R:173) - Missing @examples
42. **hrf_from_coefficients.HRF()** (hrf_from_coefficients.R:4) - Missing @examples

## Functions Missing @return

### Core HRF Functions
1. **hrf_half_cosine()** - Missing @return tag
2. **hrf_fourier()** - Missing @return tag
3. **hrf_toeplitz()** - Missing @return tag

### HRF System Functions
4. **empirical_hrf()** - Missing @return tag
5. **hrf_set()** - Missing @return tag
6. **hrf_library()** - Missing @return tag
7. **list_available_hrfs()** - Missing @return tag

### Generic Functions (many are missing @return)
8. **evaluate()** - Has @return
9. **shift()** - Has @return
10. **hrf_from_coefficients()** - Has @return
11. **nbasis()** - Has @return
12. **penalty_matrix()** - Has @return
13. **reconstruction_matrix()** - Has @return
14. **durations()** - Has @return
15. **amplitudes()** - Has @return
16. **onsets()** - Has @return
17. **samples()** - Has @return
18. **global_onsets()** - Has @return
19. **blockids()** - Has @return
20. **blocklens()** - Has @return
21. **neural_input()** - Has @return

### Regressor Functions
22. **regressor()** - Has @return
23. **single_trial_regressor()** - Has @return
24. **regressor_set()** - Has @return
25. **regressor_design()** - Has @return

### Methods
26. **evaluate.HRF()** - Has @return
27. **evaluate.RegSet()** - Missing @return
28. **samples.sampling_frame()** - Missing @return
29. **global_onsets.sampling_frame()** - Missing @return
30. **print.sampling_frame()** - Missing @return (print methods typically return invisibly)
31. **blockids.sampling_frame()** - Missing @return
32. **blocklens.sampling_frame()** - Has @return
33. **hrf_from_coefficients.HRF()** - Missing @return

## Priority Functions for Documentation

### High Priority (Core user-facing functions)
1. **regressor()** - Main function for creating regressors, needs examples
2. **regressor_set()** - Important for multi-condition designs, needs examples
3. **regressor_design()** - Key function for design matrices, needs examples
4. **evaluate()** - Generic evaluate function needs examples
5. **hrf_toeplitz()** - Needs both @return and @examples
6. **hrf_half_cosine()** - Needs both @return and @examples
7. **hrf_fourier()** - Needs both @return and @examples
8. **as_hrf()** - Core HRF constructor needs examples
9. **hrf_library()** - Important for creating HRF libraries, needs examples and @return
10. **empirical_hrf()** - Needs examples and @return

### Medium Priority (Supporting functions)
11. **hrf_from_coefficients()** - Needs examples
12. **nbasis()** - Generic needs examples
13. **reconstruction_matrix()** - Needs examples
14. **penalty_matrix()** - Has examples but could use more
15. **single_trial_regressor()** - Needs examples
16. **bind_basis()** - Needs examples
17. **hrf_set()** - Needs examples and @return

### Lower Priority (Accessor functions and methods)
18. **durations()**, **amplitudes()**, **onsets()** - Simple accessors, examples less critical
19. **samples()**, **global_onsets()**, **blockids()**, **blocklens()** - Sampling frame accessors
20. Method implementations that inherit documentation from their generics

## Summary

- **Total exported functions analyzed**: ~42
- **Missing @examples**: 28 functions (67%)
- **Missing @return**: 11 functions (26%)
- **Missing both**: 7 functions (17%)

The package has good documentation coverage for the main HRF types (spmg1, gamma, gaussian, etc.) but lacks examples for many core infrastructure functions like `regressor()`, `evaluate()`, and the design matrix builders.