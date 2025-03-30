context("Capturing Diversity Gmat")

library(testthat)
library(castgen)

# Create a dummy genotype matrix for testing
set.seed(123)
test_gmat <- matrix(sample(0:2, 100, replace = TRUE), nrow = 10)
colnames(test_gmat) <- paste0("Sample", 1:10)
rownames(test_gmat) <- paste0("Marker", 1:10)
test_gmat <- as.data.frame(test_gmat)

# Test with a sample list
test_that("capture_diversity.Gmat works with a sample list", {
  sample_list <- paste0("Sample", 1:5)
  result <- capture_diversity.Gmat(test_gmat, ploidy = 2, iterations = 2, sample_list = sample_list, save.result = FALSE, parallel=FALSE, verbose=FALSE)
  expect_true(all(c("Individuals", "CI_Lower", "CI_Upper", "Iterations") %in% colnames(result)))
})

# Test without a sample list
test_that("capture_diversity.Gmat works without a sample list", {
  result <- capture_diversity.Gmat(test_gmat, ploidy = 2, iterations = 2, save.result = FALSE, parallel=FALSE, verbose=FALSE)
  expect_true(all(c("Individuals", "CI_Lower", "CI_Upper", "Iterations") %in% colnames(result)))
})

# Test without parallel processing
test_that("capture_diversity.Gmat works without parallel processing", {
  result <- capture_diversity.Gmat(test_gmat, ploidy = 2, iterations = 2, save.result = FALSE, parallel=FALSE, verbose=FALSE)
  expect_true(all(c("Individuals", "CI_Lower", "CI_Upper", "Iterations") %in% colnames(result)))
})

# Test with saving results
test_that("capture_diversity.Gmat can save results", {

  result <- capture_diversity.Gmat(test_gmat, ploidy = 2, iterations = 2, save.result = TRUE, parallel=FALSE, verbose=FALSE)
  expect_true(file.exists("capture_diversity_output.txt"))
  file.remove("capture_diversity_output.txt")
})

# Test without saving results
test_that("capture_diversity.Gmat works without saving results", {
  result <- capture_diversity.Gmat(test_gmat, ploidy = 2, iterations = 2, save.result = FALSE, parallel=FALSE,verbose=FALSE)
  expect_false(file.exists("capture_diversity_output.txt"))
  expect_true(all(c("Individuals", "CI_Lower", "CI_Upper", "Iterations") %in% colnames(result)))
})

# Test if the returned data.frame has the correct columns
test_that("capture_diversity.Gmat returns a data.frame with correct columns", {
  result <- capture_diversity.Gmat(test_gmat, ploidy = 2, iterations = 2, save.result = FALSE, parallel=FALSE,verbose=FALSE)
  expect_true(is.data.frame(result))
  expect_true(all(c("Individuals", "CI_Lower", "CI_Upper", "Iterations") %in% colnames(result)))
})
