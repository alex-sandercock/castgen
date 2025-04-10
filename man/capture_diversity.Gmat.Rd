% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/capture_diversity.Gmat.R
\name{capture_diversity.Gmat}
\alias{capture_diversity.Gmat}
\title{Estimate Minimum Number of Individuals to Sample to Capture Population Genomic Diversity (Genotype Matrix)}
\usage{
capture_diversity.Gmat(
  df,
  ploidy,
  r2_threshold = 0.9,
  iterations = 10,
  sample_list = NULL,
  parallel = FALSE,
  batch = 1,
  save.result = FALSE,
  verbose = TRUE
)
}
\arguments{
\item{df}{Genotype matrix or data.frame with the numeric count of alternate alleles (0=homozygous reference, 1 = heterozygous, 2 = homozygous alternate)}

\item{ploidy}{The ploidy of the species being analyzed}

\item{r2_threshold}{The ratio of diversity to capture (default = 0.9)}

\item{iterations}{The number of iterations to perform to estimate the average result (default = 10)}

\item{sample_list}{The list of samples to subset from the dataset (optional)}

\item{parallel}{Run the analysis in parallel (True/False) (default = FALSE)}

\item{batch}{The number of samples to draw in each bootstrap sample iteration (default = 1)}

\item{save.result}{Save the results to a .txt file? (default = FALSE)}

\item{verbose}{Print out the results to the console (default = TRUE)}
}
\value{
A data.frame with minimum number of samples required to match or exceed the input ratio
}
\description{
This function can be used to estimate the number of individuals to sample from a population
in order to capture a desired percentage of the genomic diversity.
It assumes that the samples are the columns, and the genomic markers are in rows. Missing data should
be set as NA, which will then be ignored for the calculations. All samples must have the same ploidy.
This function was adapted from a previously developed Python method (Sandercock et al., 2023)
(https://github.com/alex-sandercock/Capturing_genomic_diversity/)
}
\examples{

#Example with a tetraploid population
set.seed(123)
test_gmat <- matrix(sample(0:4, 100, replace = TRUE), nrow = 10)
colnames(test_gmat) <- paste0("Sample", 1:10)
rownames(test_gmat) <- paste0("Marker", 1:10)
test_gmat <- as.data.frame(test_gmat)

#Estimate the number of samples required to capture 90\% of the population's genomic diversity
result <- capture_diversity.Gmat(test_gmat,
                                 ploidy = 4,
                                 r2_threshold = 0.90,
                                 iterations = 10,
                                 save.result = FALSE,
                                 parallel=FALSE,
                                 verbose=FALSE)

#View results
print(result)

}
\references{
A.M. Sandercock, J.W. Westbrook, Q. Zhang, & J.A. Holliday, A genome-guided strategy for climate resilience in American chestnut
restoration populations, Proc. Natl. Acad. Sci. U.S.A. 121 (30) e2403505121, https://doi.org/10.1073/pnas.2403505121 (2024).
}
