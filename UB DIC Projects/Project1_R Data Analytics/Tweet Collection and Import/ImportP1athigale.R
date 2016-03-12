## PROJECT 1 : MODULE 1 ##
library(jsonlite)
## SCRIPT FOR IMPORTING JSON INTO R FROM FILE ##
datafromfile <- fromJSON(paste(readLines('F:/Projects/electionData21.json'), collapse=""))