# Load Libraries
library(tabulizer)
library(tidyverse)
library(janitor)
library(DataExplorer)
library(NLP)


baseurl <- "https://www.cityofedwardsville.com/ArchiveCenter/ViewFile/Item/"
files <- c(141, 140, 139, 138, 137, 136, 135, 134, 132, 130)

for (urlEnd in c("141", "140", "139", "138", "137", "136", "135", "134", "132", "130")) { 

  # Start Extraction
  
  url <- paste(baseurl, urlEnd, sep = "")
  text <- extract_text(url)
  
  metadata <- extract_metadata(url)
  
  df <- str_split(text, "\r\n")
  
  df <- as.data.frame(df)
  colnames(df) <- as.character(unlist(df[1,]))
  df <- df[-1,]
  df <- as.data.frame(df)
  
  df$Date <- str_extract(df$df, regex("[0-9]{2}\\/[0-9]{2}\\/[0-9]{4}"))
  df$Date <- as.Date(df$Date, "%m/%d/%Y")
  df$Method <- str_extract(df$df, regex("BANK-DRAFT|CHECK"))
  df$Method <- as.factor(df$Method)
  df$CheckNum <- str_extract(df$df, regex("[0-9]{6}"))
  df$CheckNum <- as.numeric(df$CheckNum)
  
  start <- str_locate(df$df, regex("[0-9]{6}|BANK-DRAFT"))
  end <- str_locate(df$df, regex("\\$"))
  df$Vendor <- substr(df$df, start[,2]+2, end[,1]-2)
  df$Amount <- str_extract(df$df, regex("\\$[0-9]+\\,[0-9]+\\.[0-9]{2}|\\$[0-9]+\\.[0-9]{2}|
                                        \\$[0-9]+\\,[0-9]+\\,[0-9]+\\.[0-9]{2}"))
  df$Amount <- gsub("[^0-9.]","", df$Amount)
  df$Amount <- as.double(df$Amount)
  
  CheckReg <- df[-1]
  CheckReg <- CheckReg %>% remove_empty("rows")
  
  # Append to previous data
  
  RunningDF <- rbind(RunningDF, CheckReg)
}
