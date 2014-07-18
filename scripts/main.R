###############################################################################
#
#				SEQUENCE GENERATION
#
##############################################################################
#
# This code generate multiple sequences that can be possibly used designing
# a new reporter
#
# Created by Lana Kammerer; Jia Wu; Hyojun Lee, Beatriz Penalver Bernabe
# Originated 08/2013
# Last modified 11/25/2013
##############################################################################

#edit with your settings!
source("C:/Users/Beatriz/Dropbox/NU/Codes/SEQUENCE_GENERATION/SequenceGenerator.R")
setwd("C:/Users/Beatriz/Dropbox/NU/Codes/SEQUENCE_GENERATION")

#Maximum length of the sequence you would like to generate your TF reporters
max_sequence_length = 40

#Total number of sequences that you would like to create
max_number_of_sequences = 1000

#name of database of PWMs
fname<-"matrix.dat"

#Name of the specific PWM from TRANSFAC that you would like to employ. NOTE: you
#should go through the matrix.dat file and determine which one if the best PWM based
#on the origin of the data (Chip, SELEX,..)
name_PWM="GATA1_04"

#########################################################################################
#Update whether stringr is present and installs it otherwise
pkgTest <- function(x)
  {
    if (!require(x,character.only = TRUE))
    {
      install.packages(x,dep=TRUE)
        if(!require(x,character.only = TRUE)) stop("Package not found")
    }
  }
#Parse TRANSFAC file
fnamep<-parseTRANSFACdatabase(data=fname)
f<-readLines(con=fnamep)

#will automatically install stringr package
pkgTest('stringr')

#command to generate sequences
sequence_meta = generateSequencesFromDatabase(name_PWM, f, max_sequence_length, max_number_of_sequences)

sequence_list = sequence_meta[1]
PWM = sequence_meta[2]
width = sequence_meta[3]

