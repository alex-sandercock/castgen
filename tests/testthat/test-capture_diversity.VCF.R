context("Capturing Diversity VCF")

library(testthat)
library(castgen)
library(vcfR)

# Create a dummy VCF file for testing
example_vcf <- tempfile(fileext = ".vcf")
create_dummy_vcf <- function(filename = example_vcf) {
  # If no filename provided, create a temporary one
  if (is.null(filename)) {
    # Create a guaranteed unique temporary file path
    # Adding pattern can help identify files if they leak
    filename <- tempfile(pattern = "dummy_vcf_", fileext = ".vcf")
  }

  # --- (Rest of the code to create myVCF object remains the same) ---
  myVCF <- new("vcfR")
  myVCF@meta <- c("##fileformat=VCFv4.2",
                  "##INFO=<ID=NS,Number=1,Type=Integer,Description=\"Number of Samples With Data\">",
                  "##FORMAT=<ID=GT,Number=1,Type=String,Description=\"Genotype\">")
  myVCF@fix <- matrix(c("chr1", "1", ".", "A", "G", ".", ".", "NS=2",
                        "chr1", "2", ".", "T", "C", ".", ".", "NS=2"),
                      ncol = 8, byrow = TRUE)
  colnames(myVCF@fix) <- c("CHROM", "POS", "ID", "REF", "ALT", "QUAL", "FILTER", "INFO")
  samples <- c("sample1", "sample2", "sample3", "sample4", "sample5")
  num_markers <- nrow(myVCF@fix)
  gt_matrix <- matrix(c("GT", "0/0", "0/1","0/0", "0/1", "1/1",
                        "GT", "1/1", "0/0", "0/1", "1/1", "0/0"),
                      nrow = num_markers,
                      ncol = 1 + length(samples),
                      byrow = TRUE)
  colnames(gt_matrix) <- c("FORMAT", samples)
  myVCF@gt <- gt_matrix

  # Write to the specified (potentially temporary) file
  vcfR::write.vcf(myVCF, filename)

  # Return the actual filename used (important if tempfile was generated)
  return(filename)
}

test_that("capture_diversity.VCF runs with a sample list", {
  vcf_file <- create_dummy_vcf()
  sample_list <- c("sample1","sample3","sample4")
  result <- capture_diversity.VCF(vcf = vcf_file, ploidy = 2, iterations = 2, sample_list = sample_list, save.result = FALSE, parallel=FALSE, verbose=FALSE)
  expect_s3_class(result, "data.frame")
  expect_true(all(c("Individuals", "CI_Lower", "CI_Upper", "Iterations") %in% colnames(result)))
  rm(vcf_file)
})

test_that("capture_diversity.VCF runs without a sample list", {
  vcf_file <- create_dummy_vcf()
  result <- capture_diversity.VCF(vcf = vcf_file, ploidy = 2, iterations = 2, save.result = FALSE, parallel=FALSE, verbose=FALSE)
  expect_s3_class(result, "data.frame")
  expect_true(all(c("Individuals", "CI_Lower", "CI_Upper", "Iterations") %in% colnames(result)))
  rm(vcf_file)
})

test_that("capture_diversity.VCF runs without parallel processing", {
  vcf_file <- create_dummy_vcf()
  result <- capture_diversity.VCF(vcf = vcf_file, ploidy = 2, iterations = 2, save.result = FALSE, parallel=FALSE,verbose=FALSE)
  expect_s3_class(result, "data.frame")
  expect_true(all(c("Individuals", "CI_Lower", "CI_Upper", "Iterations") %in% colnames(result)))
  rm(vcf_file)
})

test_that("capture_diversity.VCF runs with saving results", {
  vcf_file <- create_dummy_vcf()
  result <- capture_diversity.VCF(vcf = vcf_file, ploidy = 2, iterations = 2, save.result = TRUE, parallel=FALSE, verbose=FALSE)
    expect_s3_class(result, "data.frame")
  expect_true(file.exists("capture_diversity_output.txt"))
  file.remove("capture_diversity_output.txt")
  expect_true(all(c("Individuals", "CI_Lower", "CI_Upper", "Iterations") %in% colnames(result)))
  rm(vcf_file)
})

test_that("capture_diversity.VCF runs without saving results", {
  vcf_file <- create_dummy_vcf()
  result <- capture_diversity.VCF(vcf = vcf_file, ploidy = 2, iterations = 2, save.result = FALSE, parallel=FALSE, verbose=FALSE)
  expect_false(file.exists("capture_diversity_output.txt"))
  expect_s3_class(result, "data.frame")
  expect_true(all(c("Individuals", "CI_Lower", "CI_Upper", "Iterations") %in% colnames(result)))
  rm(vcf_file)
})

test_that("capture_diversity.VCF returns the correct columns", {
    vcf_file <- create_dummy_vcf()
    result <- capture_diversity.VCF(vcf = vcf_file, ploidy = 2, iterations = 2, save.result = FALSE, parallel=FALSE, verbose=FALSE)
    expect_true(all(c("Individuals", "CI_Lower", "CI_Upper", "Iterations") %in% colnames(result)))
    rm(vcf_file)
})
