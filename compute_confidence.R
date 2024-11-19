#!/usr/bin/Rscript
# Title         : compute_confidence.R
# Description   : Compute confidence value for detected landslides polygons
# Date          : Jun 2024
# Version       : 0.6
# Licence       : GPL v3
# Authors       : Federico Filipponi
# Maintainer    : Federico Filipponi <federico.filipponi@gmail.com>
# ########################################################

# usage example
# compute_confidence.R -i /data/input_file.gpkg -o /data/output_file.gpkg -s /data/slope.tif

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
  optparse::make_option(c("-s", "--slope"), type="character", default=NULL, 
                        help="Input slope file path", metavar="character"),
  optparse::make_option(c("-d", "--dem"), type="character", default=NULL, 
                        help="Input dem file path", metavar="character"),
  optparse::make_option(c("-r", "--rdndvi"), type="character", default=NULL, 
                        help="Input RdNDVI file path", metavar="character"),
  optparse::make_option(c("-e", "--extra"), type="logical", default=FALSE, action="store_true",
                        help="Export extra fields in output vector file"),
  optparse::make_option(c("--verbose"), type="logical", default=FALSE, action="store_true",
                        help="Verbose mode")
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
if(is.null(opt$slope)){
  print_help(opt_parser)
  stop("At least one argument must be supplied (slope).n", call.=FALSE)
}
if(is.null(opt$dem)){
  print_help(opt_parser)
  stop("At least one argument must be supplied (dem).n", call.=FALSE)
}
if(is.null(opt$rdndvi)){
  print_help(opt_parser)
  stop("At least one argument must be supplied (rdndvi).n", call.=FALSE)
}

input_file <- normalizePath(path=opt$input, winslash = "/", mustWork = TRUE)
output_file <- normalizePath(path=opt$output, winslash = "/", mustWork = FALSE)
slope_file <- normalizePath(path=opt$slope, winslash = "/", mustWork = TRUE)
dem_file <- normalizePath(path=opt$dem, winslash = "/", mustWork = TRUE)
RdNDVI_file <- normalizePath(path=opt$rdndvi, winslash = "/", mustWork = TRUE)
extra_export <- opt$extra
verbose <- opt$verbose

# ### for debug
# input_file <- "/media/DATA/ISPRA/new7/CN-CRE/20230517_Alluvione_EMR/landslides/data/analysis/S2/PreEvent_NDVI.tif"
# output_file <- "/media/DATA/ISPRA/new7/CN-CRE/20230517_Alluvione_EMR/landslides/data/analysis/S2/PreEvent_NDVI_focal_w3_mask.tif"
# slope_file <- ""
# verbose <- TRUE

if(file.exists(output_file)){
  stop(paste("Output file already exists: ", "'", output_file, "'", sep=""))
}
dir.create(dirname(output_file), showWarnings = FALSE, recursive = TRUE)

# ############################
# load required libraries
invisible(tryCatch(find.package("sf"), error=function(e) install.packages("sf", dependencies=TRUE)))
invisible(tryCatch(find.package("terra"), error=function(e) install.packages("terra", dependencies=TRUE)))
suppressPackageStartupMessages(require(sf, quietly=TRUE))
suppressPackageStartupMessages(require(terra, quietly=TRUE))
terra::terraOptions(progress=0)

# ############################
# import spatial polygons
polys <- sf::st_read(input_file, stringsAsFactors=FALSE, quiet=TRUE)
# polys$PID <- as.integer(1:nrow(polys))
polys$AREA <- sf::st_area(polys)

# ############################
# statistics on TINITALY slope
r <- terra::rast(slope_file)
names(r)[1] <- "Slope"
qut <- terra::extract(r, polys, weights=FALSE, exact=FALSE, cells=FALSE, ID=FALSE, fun=mean, na.rm=TRUE)
polys$Slope_mean <- as.double(qut[,1])

# ##################################
# statistics on slope
r <- terra::rast(slope_file)
names(r)[1] <- "Slope"
qut <- terra::extract(r, polys, weights=FALSE, exact=FALSE, cells=FALSE, ID=FALSE, fun=mean, na.rm=TRUE)
polys$Slope_mean <- as.double(qut[,1])
if(extra_export){
  qut <- terra::extract(r, polys, weights=FALSE, exact=FALSE, cells=FALSE, ID=FALSE, fun=sd, na.rm=TRUE)
  polys$Slope_std <- as.double(qut[,1])
  qut <- terra::extract(r, polys, weights=FALSE, exact=FALSE, cells=FALSE, ID=FALSE, fun=min, na.rm=TRUE)
  polys$Slope_min <- as.double(qut[,1])
  qut <- terra::extract(r, polys, weights=FALSE, exact=FALSE, cells=FALSE, ID=FALSE, fun=max, na.rm=TRUE)
  polys$Slope_max <- as.double(qut[,1])
  qut <- terra::extract(r, polys, weights=FALSE, exact=FALSE, cells=FALSE, ID=FALSE, fun=median, na.rm=TRUE)
  polys$Slope_median <- as.double(qut[,1])
}

suppressWarnings(rm(list=c("r","qut")))
invisible(gc())

# ############################
# statistics on elevation
r <- terra::rast(dem_file)
names(r)[1] <- "Elevation"
qut <- terra::extract(r, polys, weights=FALSE, exact=FALSE, cells=FALSE, ID=FALSE, fun=min, na.rm=TRUE)
polys$Elevation_min <- as.double(qut[,1])
qut <- terra::extract(r, polys, weights=FALSE, exact=FALSE, cells=FALSE, ID=FALSE, fun=max, na.rm=TRUE)
polys$Elevation_max <- as.double(qut[,1])
polys$Elevation_range <- as.double(polys$Elevation_max - polys$Elevation_min)
if(extra_export){
  qut <- terra::extract(r, polys, weights=FALSE, exact=FALSE, cells=FALSE, ID=FALSE, fun=mean, na.rm=TRUE)
  polys$Elevation_mean <- as.double(qut[,1])
  qut <- terra::extract(r, polys, weights=FALSE, exact=FALSE, cells=FALSE, ID=FALSE, fun=sd, na.rm=TRUE)
  polys$Elevation_std <- as.double(qut[,1])
}

# compute Area Weighted Elevation Range
polys$AWER <- as.double(polys$Elevation_range / sqrt(polys$AREA))
if(!extra_export){
  polys <- polys[,which(!(names(polys) %in% c("Elevation_max","Elevation_min","Elevation_range")))]
}

suppressWarnings(rm(list=c("r","qut")))
invisible(gc())

# ##################################
# statistics on RdNDVI
r <- terra::rast(RdNDVI_file)
names(r)[1] <- "RdNDVI"
qut <- terra::extract(r, polys, weights=FALSE, exact=FALSE, cells=FALSE, ID=FALSE, fun=mean, na.rm=TRUE)
polys$RdNDVI <- as.double(qut[,1])
polys$N_RdNDVI <- as.double(tanh(sqrt(((polys$RdNDVI - min(polys$RdNDVI))/(max(polys$RdNDVI) - min(polys$RdNDVI)))))*3)
polys$N_RdNDVI[which(polys$N_RdNDVI > 1)] <- 1
if(!extra_export){
  polys <- polys[,which(!(names(polys) %in% c("RdNDVI")))]
}

suppressWarnings(rm(list=c("r","qut")))
invisible(gc())

# ############################
# compute CONFIDENCE

# set weights
W_AREA <- 1.0
W_SLOPE <- 1.0
W_AWER <- 1.0
W_RdNDVI <- 1.0

polys$CONFIDENCE <- as.double(((W_AREA * (1.0950-(0.095 + 0.9032 * exp(-exp(-1.4058 * (log( as.double(polys$AREA )) - log(6947.7772))))))) + (W_SLOPE * (0.9979470 / (1 + exp(-0.7859512*(polys$Slope_mean - 10.9374365))))) + (W_AWER * as.double(tanh(sqrt(0.1 + polys$AWER)))) + (W_RdNDVI * polys$N_RdNDVI)) / sum(W_AREA, W_SLOPE, W_AWER, W_RdNDVI))

# ############################
# export result to GeoPackage file
sf::st_write(polys, format="GPKG", dsn = output_file, layer=sf::st_layers(input_file)$name,  quiet=TRUE)

# ############################
# clean workspace and exit
suppressWarnings(rm(list=ls()))
invisible(gc())
q("no")

