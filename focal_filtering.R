#!/usr/bin/Rscript
# Title         : focal_filtering.R
# Description   : Apply focal filtering with specific parameters
# Date          : Sep 2023
# Version       : 0.2
# Licence       : GPL v3
# Authors       : Federico Filipponi
# Maintainer    : Federico Filipponi <federico.filipponi@gmail.com>
# ########################################################

# usage example
# focal_filtering.R -i /data/input_file.tif -o /data/output_file.tif

# load required libraries
invisible(tryCatch(find.package("optparse"), error=function(e) install.packages("optparse", dependencies=TRUE)))
suppressPackageStartupMessages(require(optparse, quietly=TRUE))

# ########################################################
# get variables
# ########################################################

option_list <- list(
  optparse::make_option(c("-i", "--input"), type="character", default=NULL, 
                        help="Input file path", metavar="character"),
  optparse::make_option(c("-o", "--output"), type="character", default=NULL, 
                        help="Output file path", metavar="character"),
  optparse::make_option(c("-k", "--kernel"), type="integer", default=3, 
                        help="Kernel size (in pixels)", metavar="character")
)

opt_parser <- OptionParser(option_list=option_list)
opt <- parse_args(opt_parser)

# check if options are supplied
if(is.null(opt$input)){
  print_help(opt_parser)
  stop("At least one argument must be supplied (input).n", call.=FALSE)
}
if(is.null(opt$output)){
  print_help(opt_parser)
  stop("At least one argument must be supplied (output).n", call.=FALSE)
}

input_file <- normalizePath(path=opt$input, winslash = "/", mustWork = TRUE)
output_file <- normalizePath(path=opt$output, winslash = "/", mustWork = FALSE)
k <- as.integer(opt$kernel)
if((k %% 2) == 0){
    stop("Kernel value must be odd.")
}

if(file.exists(output_file)){
  stop(paste("Output file already exists: ", "'", output_file, "'", sep=""))
}
dir.create(dirname(output_file), showWarnings = FALSE, recursive = TRUE)

# ### for debug
# input_file <- "/media/DATA/ISPRA/new7/CN-CRE/20230517_Alluvione_EMR/landslides/data/analysis/S2/PreEvent_NDVI.tif"
# output_file <- "/media/DATA/ISPRA/new7/CN-CRE/20230517_Alluvione_EMR/landslides/data/analysis/S2/PreEvent_NDVI_focal_w3_mask.tif"
# k <- 3

invisible(tryCatch(find.package("terra"), error=function(e) install.packages("terra", dependencies=TRUE)))
suppressPackageStartupMessages(require(terra, quietly=TRUE))
terra::terraOptions(progress=0)

# set NDVI threshold
nt <- 0.3

# set fractionalvalue of mask pixels
kp <- 0.3

n <- terra::rast(input_file)

# generate mask
m <- terra::rast(n, vals=0)
m[n < nt & n > 0] <- 1

# run focal filter
f <- terra::focal(m, w=k, fun="mean", expand=TRUE, fillvalue=0)
# generate mask from focal result
m <- terra::rast(n, vals=0)
m[f >= kp] <- 1

# export result
writeRaster(m, output_file)

# clean workspace and exit
suppressWarnings(rm(list=ls()))
invisible(gc())
q("no")
