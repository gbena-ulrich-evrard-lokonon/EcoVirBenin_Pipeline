# Study Data Cleaning and Sorting Pipeline - EcoVirBenin

## Author
*LOKONON Gbèna Ulrich Evrard*  
*Country:* Benin  
*City:* Cotonou  

## Description
This *R* pipeline performs cleaning, standardization, and organization of a biomedical study dataset, specifically handling study_id identifiers, dates, sex, and study site. It also detects duplicates and gaps in the sequence of identifiers before generating a final analysis-ready dataset.

### Features
- Standardization of study_id (uppercase and removal of extra spaces)
- Conversion of Excel date columns (numeric or text) into day/month/year format
- Correction of sex and bn_study_site values
- Row-wise merging by study_id keeping the first non-missing value
- Quality control: detection of duplicates and missing IDs
- Final sorting of identifiers by site, service, and number
- Export of the final file df_final_sorted.csv

## Input File
- ecovirBenin1.xlsx: raw dataset with key columns:
  - study_id
  - dob, today_dat, diseas_start_dat, chld_diseas_start_dat, part_dob, observ_dat
  - sex
  - bn_study_site

## Output File
- df_final_sorted.csv: cleaned and sorted final dataset.

## Usage
```r
# Install required packages if not already installed
install.packages(c("readxl","dplyr","tidyr","readr"))

# Run the pipeline
source("pipeline_clean_sort.R")
