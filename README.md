<!-- badges: start -->
[![R-CMD-check](https://github.com/alex-sandercock/castgen/workflows/R-CMD-check/badge.svg)](https://github.com/alex-sandercock/castgen/actions)
![GitHub Release](https://img.shields.io/github/v/release/alex-sandercock/castgen)
[![Development Status](https://img.shields.io/badge/development-active-blue.svg)](https://img.shields.io/badge/development-active-blue.svg)
![GitHub License](https://img.shields.io/github/license/alex-sandercock/castgen)

<!-- badges: end -->

# castgen

This package and included functions were developed for the American chestnut landscape genomics manuscript. The aim was to develop a method for estimating the number of individuals to sample from a population in order to capture a predefined percentage of diversity within a breeding population. 

## Getting Started

A VCF file with GT information or a genotype matrix can be used as input

## Usage

To install package:
```{R}
install.packages("devtools") #If not already installed

devtools::install_github("alex-sandercock/castgen")
library("castgen")
```

## Output data

The output will be provided in the terminal following the completion of all iterations:

```

Number of trees to sample = 22.0 

95% Confidence Intervals = (16.378127142052662, 27.621872857947338) 

Iterations performed = 5

```

## Citation

If you use this package, please cite:

A.M. Sandercock, J.W. Westbrook, Q. Zhang, & J.A. Holliday, A genome-guided strategy for climate resilience in American chestnut restoration populations, Proc. Natl. Acad. Sci. U.S.A. 121 (30) e2403505121, https://doi.org/10.1073/pnas.2403505121 (2024).

## Notes
The capture_diversity functions were converted from a Python function https://github.com/alex-sandercock/Capture_genomic_diversity. These R versions of the function are much (much) faster to run and have the option to run in parallel depending on cores available.


![image](https://github.com/alex-sandercock/castgen/assets/39815775/710f947f-743f-4eb4-9cb8-fb03d1cdf4aa)



