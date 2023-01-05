# Install and load packages ==============================================================
ls <- c("readxl","xlsx","data.table","dplyr","reshape2","tidyverse")
new.packages <- ls[!(ls %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages)

library(readxl)
library(xlsx)
library(data.table)
library(dplyr)
library(reshape2)
library(tidyverse)


# Load metadata and units thesauri =======================================================
metadata <- read_excel("ejemplos/metadatos_ejemplo.xlsx")
units <- read_excel("ejemplos/unidades_ejemplo.xlsx")


# Data integration =======================================================================
#remove references from units.xlsx
units_df <- units[-1,]

#list with file path and names
datasets <- list.files("ejemplos/raw_datasets", pattern = ".csv$", full.names = TRUE)
#names of all datasets
dataset_names <- gsub("ejemplos/raw_datasets/|.csv", "", datasets)

#empty dataframe used for row binding
ext_df <- data.frame() 

for (i in 1:length(datasets)){
  
  #subsets
  loop_thesaurus <- metadata %>% select(category, classes, names, verbatim = dataset_names[i]) %>% drop_na()
  numeric_names <- loop_thesaurus %>% filter(classes == "numeric")
  character_names <- loop_thesaurus %>% filter(classes == "character")
  
  #read classes from dataset
  numeric_df <- fread(input = datasets[i], 
                      select = numeric_names$verbatim, 
                      col.names = numeric_names$names,
                      colClasses = "numeric",
                      encoding = "UTF-8",
                      dec = ".")
  character_df <- fread(input = datasets[i], 
                        select = character_names$verbatim,
                        col.names = character_names$names,
                        colClasses = "character",
                        encoding = "UTF-8")
  
  #bind for full dataset with standardized names
  dataset <- cbind(numeric_df, character_df)
  
  #melt data_full to long table
  taxon_occ_meas <- loop_thesaurus %>% filter(category != "trait")
  traits <- loop_thesaurus %>% filter(category == "trait")
  data_melt <- melt(data = dataset, id.vars = taxon_occ_meas$names, 
                    measure.vars = traits$names, value.name = "traitValue", 
                    variable.name = "traitName", variable.factor = FALSE) %>% drop_na(traitValue)
  
  #add unit column
  loop_unit <- units_df %>% select(traitName = names, traitUnit = dataset_names[i]) %>% drop_na() #relate unit to traitName
  data_melt <- full_join(data_melt, loop_unit, by = "traitName") #add unit column by merging
  
  ## ·························································
  ## Esta parte de unidades no se si es necesaria, en caso que no, 
  ## puede ser eliminada directamente
  ## ·························································
  #standardize measurement units
  data_melt$traitValue <- ifelse(data_melt$traitUnit == "m", data_melt$traitValue*100, data_melt$traitValue)
  data_melt$traitValue <- ifelse(data_melt$traitUnit == "mm", data_melt$traitValue/10, data_melt$traitValue)
  data_melt$traitUnit <- ifelse(data_melt$traitUnit == "m" | data_melt$traitUnit == "mm", "cm", data_melt$traitUnit)
  
  #add original traitname column
  verba_name <- select(traits, traitName = names, verbatimTraitName = verbatim)  #df to relate traitname to verbatim traitname
  data_melt <- full_join(data_melt, verba_name, by = "traitName") #add verbatim traitname column by merging
  
  #add archive name
  archive_names <- list.files("ejemplos/raw_datasets", pattern = ".csv$", full.names = F)
  data_melt$original_archive <- archive_names[i]
  
  #output df
  ext_df <- bind_rows(ext_df, data_melt)
  
}

# Output table =====================================
fwrite(ext_df, "output/output.csv", row.names = FALSE)
write.xlsx(ext_df, file = "output/output.xlsx")



