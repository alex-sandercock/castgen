context("Capturing Diversity VCF")

library(testthat)
library(castgen)
library(vcfR)

# Create a dummy VCF file for testing
create_dummy_vcf <- function(filename = "dummy.vcf") {
  # Create a dummy vcfR object
  myVCF <- new("vcfR", meta = character(), fix = matrix(), gt = matrix(),  
               body = matrix(), var.info = data.frame())
  myVCF@meta <- c("##fileformat=VCFv4.2",
                  "##INFO=<ID=NS,Number=1,Type=Integer,Description=\"Number of Samples With Data\">")
  
  myVCF@fix <- matrix(c("chr1", "1", ".", "A", "G", ".", ".", "NS=2",
                        "chr1", "2", ".", "T", "C", ".", ".", "NS=2"),
                      ncol = 8, byrow = TRUE)
  colnames(myVCF@fix) <- c("CHROM","POS","ID","REF","ALT","QUAL","FILTER","INFO")

  myVCF@gt <- matrix(c("0/0","0/1",
                      "1/1","0/0"),
                      ncol=2,byrow=T)
  colnames(myVCF@gt) <- c("sample1","sample2")
  rownames(myVCF@gt) <- c("marker1","marker2")
  myVCF@gt <- cbind(format = rep("GT", nrow(myVCF@gt)), myVCF@gt)
  myVCF@var.info <- data.frame(Chrom=myVCF@fix[,1], Position=myVCF@fix[,2], ID=myVCF@fix[,3],
                             Ref=myVCF@fix[,4], Alt=myVCF@fix[,5])
  
  # Write to a temporary file
  write.vcf(myVCF, filename)
  return(filename)
}

# Clean up dummy VCF file
cleanup_dummy_vcf <- function(filename = "dummy.vcf") {
  if (file.exists(filename)) {
    file.remove(filename)
  }
}

# Create a temp directory for VCF


test_that("capture_diversity.VCF runs with a sample list", {
  vcf_file <- create_dummy_vcf()
  sample_list <- c("sample1")
  result <- capture_diversity.VCF(vcf = vcf_file, ploidy = 2, iterations = 2, sample_list = sample_list, save.result = FALSE, parallel=FALSE)
  expect_s3_class(result, "data.frame")
  expect_true(all(c("Individuals", "CI_Lower", "CI_Upper", "Iterations") %in% colnames(result)))
  cleanup_dummy_vcf()
})

test_that("capture_diversity.VCF runs without a sample list", {
  vcf_file <- create_dummy_vcf()
  result <- capture_diversity.VCF(vcf = vcf_file, ploidy = 2, iterations = 2, save.result = FALSE, parallel=FALSE)
  expect_s3_class(result, "data.frame")
  expect_true(all(c("Individuals", "CI_Lower", "CI_Upper", "Iterations") %in% colnames(result)))
  cleanup_dummy_vcf()
})

test_that("capture_diversity.VCF runs with parallel processing", {
  vcf_file <- create_dummy_vcf()
  result <- capture_diversity.VCF(vcf = vcf_file, ploidy = 2, iterations = 2, save.result = FALSE, parallel=TRUE)
  expect_s3_class(result, "data.frame")
  expect_true(all(c("Individuals", "CI_Lower", "CI_Upper", "Iterations") %in% colnames(result)))
  cleanup_dummy_vcf()
})

test_that("capture_diversity.VCF runs without parallel processing", {
  vcf_file <- create_dummy_vcf()
  result <- capture_diversity.VCF(vcf = vcf_file, ploidy = 2, iterations = 2, save.result = FALSE, parallel=FALSE)
  expect_s3_class(result, "data.frame")
  expect_true(all(c("Individuals", "CI_Lower", "CI_Upper", "Iterations") %in% colnames(result)))
  cleanup_dummy_vcf()
})

test_that("capture_diversity.VCF runs with saving results", {
  vcf_file <- create_dummy_vcf()
  result <- capture_diversity.VCF(vcf = vcf_file, ploidy = 2, iterations = 2, save.result = TRUE, parallel=FALSE)
    expect_s3_class(result, "data.frame")
  expect_true(file.exists("capture_diversity_output.txt"))
  file.remove("capture_diversity_output.txt")
  expect_true(all(c("Individuals", "CI_Lower", "CI_Upper", "Iterations") %in% colnames(result)))
  cleanup_dummy_vcf()
})

test_that("capture_diversity.VCF runs without saving results", {
  vcf_file <- create_dummy_vcf()
  result <- capture_diversity.VCF(vcf = vcf_file, ploidy = 2, iterations = 2, save.result = FALSE, parallel=FALSE)
  expect_false(file.exists("capture_diversity_output.txt"))
  expect_s3_class(result, "data.frame")
  expect_true(all(c("Individuals", "CI_Lower", "CI_Upper", "Iterations") %in% colnames(result)))
  cleanup_dummy_vcf()
})

test_that("capture_diversity.VCF returns the correct columns", {
    vcf_file <- create_dummy_vcf()
    result <- capture_diversity.VCF(vcf = vcf_file, ploidy = 2, iterations = 2, save.result = FALSE, parallel=FALSE)
    expect_true(all(c("Individuals", "CI_Lower", "CI_Upper", "Iterations") %in% colnames(result)))
    cleanup_dummy_vcf()
})