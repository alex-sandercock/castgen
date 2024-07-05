# castgen

This package and included functions was developed for the American chestnut landscape genomics manuscript. The aim was to develop a method for estimating the number of individuals to sample from a population in order to capture a predefined percentage of diversity within a breeding population. 

The preprint for the article can be found at bioRxiv: https://doi.org/10.1101/2023.05.30.542850

## Getting Started

A vcf file or genotype matrix can be used

## Usage

To install package:
```
install.packages("devtools") #If not already installed
library(devtools)
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

## Notes
The capture_diversity functions were converted from a Python function https://github.com/alex-sandercock/Capture_genomic_diversity. These R versions of the function are much (much) faster to run and have the option to run in parallel depending on cores available.


![image](https://github.com/alex-sandercock/castgen/assets/39815775/710f947f-743f-4eb4-9cb8-fb03d1cdf4aa)



