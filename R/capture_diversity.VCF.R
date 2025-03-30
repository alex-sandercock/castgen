#' Estimate Minimum Number of Individuals to Sample to Capture Population Genomic Diversity (VCF)
#'
#' This function can be used to estimate the number of individuals to sample from a population
#' in order to capture a desired percentage of the genomic diversity.
#' VCF files can be either unzipped or gzipped. All samples must have the same ploidy and the VCF must contain
#' GT information. This function was adapted from a previously developed Python method (Sandercock et al., 2024)
#' (https://github.com/alex-sandercock/Capturing_genomic_diversity/)
#'
#' @param vcf Path to VCF file (.vcf or .vcf.gz) with genotype information
#' @param ploidy The ploidy of the species being analyzed
#' @param r2_threshold The ratio of diversity to capture (default = 0.9)
#' @param iterations The number of iterations to perform to estimate the average result (default = 10)
#' @param sample_list The list of samples to subset from the dataset (optional)
#' @param parallel Run the analysis in parallel (True/False) (default = FALSE)
#' @param batch The number of samples to draw in each bootstrap sample iteration (default = 1)
#' @param save.result Save the results to a .txt file? (default = TRUE)
#' @param verbose Print out the results to the console (default = TRUE)
#' @return A data.frame with minimum number of samples required to match or exceed the input ratio
#' @import foreach
#' @import doParallel
#' @import dplyr
#' @importFrom Rdpack reprompt
#' @importFrom parallel detectCores makeCluster stopCluster
#' @importFrom stats lm qt sd
#' @importFrom utils write.table
#' @importFrom vcfR read.vcfR extract.gt
#' @references
#' A.M. Sandercock, J.W. Westbrook, Q. Zhang, & J.A. Holliday, A genome-guided strategy for climate resilience in American chestnut
#' restoration populations, Proc. Natl. Acad. Sci. U.S.A. 121 (30) e2403505121, https://doi.org/10.1073/pnas.2403505121 (2024).
#'
#' @examples
#' #Example with a diploid vcf
#'
#' # Example vcf
#' vcf_file <- system.file("diploid_example.vcf.gz", package = "castgen")
#'
#' #Estimate the number of samples required to capture 95% of the population's genomic diversity
#' result <- capture_diversity.VCF(vcf_file,
#'                                  ploidy = 2,
#'                                  r2_threshold = 0.95,
#'                                  iterations = 10,
#'                                  save.result = FALSE,
#'                                  parallel=FALSE,
#'                                  verbose=FALSE)
#'
#' #View results
#' print(result)
#'
#' @export
capture_diversity.VCF <- function(vcf, ploidy, r2_threshold=0.9, iterations = 10, sample_list = NULL, parallel=FALSE, batch=1, save.result=TRUE, verbose = TRUE) {
##Need to make sure these two packages are loaded with BIGr (vcfR and dplyr,"foreach","doParallel"

  #Import VCF file
  if (verbose) {
    vcf <- vcfR::read.vcfR(as.character(vcf))
  } else {
    vcf <- vcfR::read.vcfR(as.character(vcf), verbose = FALSE)
  }
  # Check if the VCF file contains GT information
  info <- vcf@gt[1,"FORMAT"] #Getting the first row FORMAT
  if (is.na(info) || !grepl("GT", info)) {
    stop("The VCF file does not contain GT information. Please provide a VCF file with GT format.")
  }
  #Extract GT
  genomat <- extract.gt(vcf, element = "GT")
  rm(vcf)

  # Convert to numeric
  convert_to_dosage <- function(gt) {
    # Split the genotype string
    alleles <- strsplit(gt, "[|/]")
    # Sum the alleles, treating NA values appropriately
    sapply(alleles, function(x) {
      if (any(is.na(x))) {
        return(NA)
      } else {
        return(sum(as.numeric(x), na.rm = TRUE))
      }
    })
  }
  df <- apply(genomat, 2, convert_to_dosage)
  rm(genomat)

  # This  will subset it based on the user-supplied list
  if (!is.null(sample_list)) {
    df <- df[, colnames(df) %in% sample_list]
  }

  ############ 2. Perform bootstrap sampling ###########################

  bootstrap_batch_sample_regression <- function(df, batch=1, target_values, r2_threshold) {
    # Perform bootstrap sampling until threshold of diversity captured is met based on R2 value
    df_merged <- data.frame(matrix(ncol = 0, nrow = nrow(df)))
    rownames(df_merged) <- rownames(df)
    sampling_round <- 0
    diversity_captured <- FALSE

    while (!diversity_captured) {
      sampling_round <- sampling_round + 1
      sampled <- df[, sample(colnames(df), as.numeric(batch))]
      df_merged <- cbind(df_merged, sampled)
      af_df <- calculate_MAF(df_merged, ploidy)
      af_values <- af_df$AF
      lm_model <- lm(target_values ~ af_values)
      r2 <- summary(lm_model)$r.squared

      if (r2 >= r2_threshold) {
        diversity_captured <- TRUE
      }
    }

    return(as.numeric(sampling_round))
  }

  ############### 3. Calculate statistics ################################

  calculate_statistics <- function(sampling_round_list, batch) {
    # Convert sampling rounds to number of individuals
    sampling_round_list <- lapply(sampling_round_list, function(x) x * as.numeric(batch))
    mean_ind <- mean(unlist(sampling_round_list))
    stand_dev <- sd(unlist(sampling_round_list))
    CI <- qt(0.975, df = length(sampling_round_list) - 1) * (stand_dev / sqrt(length(sampling_round_list)))
    CI_lower <- mean_ind - CI
    CI_upper <- mean_ind + CI
    #Add results to dataframe
    results_df <- data.frame(
      Individuals = mean_ind,
      CI_Lower = CI_lower,
      CI_Upper = CI_upper,
      Iterations = length(sampling_round_list)
    )
    return(results_df)
  }

  target_AF_values <- calculate_MAF(df, ploidy)$AF
  sample_round_list <- list()

  #Perform iterations depending on user parallel selection
  if (!parallel) {
    for (i in 1:iterations) {
      sample_round_list[i] <- bootstrap_batch_sample_regression(df, batch, target_AF_values, r2_threshold)
    }
  } else {
    ###Parallel script
    # Detect the number of available cores and subtract 1
    #Need to make sure num_cores is 1 if that is all that is available..
    num_cores <- detectCores() - 1
    if (num_cores == 0) {
      num_cores = 1
    }

    # Set up parallel backend
    cl <- makeCluster(num_cores)
    registerDoParallel(cl)
    # Perform boostrap sampling over user input or default iterations
    sample_round_list <- foreach(i = 1:iterations, .combine = c) %dopar% {
      bootstrap_batch_sample_regression(df, batch, target_AF_values, r2_threshold)
    }
    # Stop the parallel backend
    stopCluster(cl)
  }

  final_df <- calculate_statistics(sample_round_list, batch)

  #Save results to a .txt file
  if (save.result){
    write.table(final_df, file= "capture_diversity_output.txt", row.names=FALSE)
  }

  if (verbose){
    cat("Number of individuals to sample =", final_df$Individuals, "\n95% Confidence Intervals =", final_df$CI_Lower, "-", final_df$CI_Upper, "\nIterations performed =", final_df$Iterations, "\n")
  }

  #Return the results dataframe
  return(final_df)
}


