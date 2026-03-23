#Author: LOKONON Gbèna Ulrich Evrard
#E-mail: ulrichlokn@gmail.com
#Country: Benin
#City: Cotonou

library(readxl)
library(dplyr)
library(tidyr)
library(readr)

getwd()
# =============================
# Lecture
# =============================
df <- read_excel("ecovirBenin1.xlsx")

# =============================
# Colonnes de dates
# =============================
date_cols <- c("dob", "today_dat", "diseas_start_dat", 
               "chld_diseas_start_dat", "part_dob", "observ_dat")

# =============================
# 1. Nettoyage AVANT fusion
# =============================

df <- df %>%
  mutate(
    # ✅ Standardisation study_id
    study_id = as.character(study_id),
    study_id = trimws(study_id),
    study_id = toupper(study_id),
    study_id = na_if(study_id, ""),
    
    # ✅ Dates en caractère + trim
    across(all_of(date_cols), ~ trimws(as.character(.)))
  )

# =============================
# Conversion des dates Excel
# =============================
for(col in date_cols){
  
  is_num <- grepl("^[0-9]+$", df[[col]])
  
  df[[col]][is_num] <- format(
    as.Date(as.numeric(df[[col]][is_num]), origin = "1899-12-30"),
    "%d/%m/%Y"
  )
}

# =============================
# Nettoyage final
# =============================
df <- df %>%
  mutate(
    across(all_of(date_cols), ~ na_if(., "")),
    
    # ✅ Correction du site d'étude (BONNE VARIABLE)
    bn_study_site = case_when(
      bn_study_site %in% c("CTN", "Cotonou") ~ "Cotonou",
      bn_study_site %in% c("ODH", "Ouidah") ~ "Ouidah",
      bn_study_site %in% c("PMS", "Abomey-Calavi") ~ "Abomey-Calavi",
      TRUE ~ bn_study_site
    ),
    
    # ✅ Correction du sexe (indépendant)
    sex = case_when(
      sex %in% c("Féminin", "feminin", "F", "female") ~ "Female",
      sex %in% c("Masculin", "masculin", "M", "male") ~ "Male",
      TRUE ~ sex
    )
  )

# =============================
# Fonction first_valid
# =============================
first_valid <- function(x){
  x <- x[!is.na(x) & x != ""]
  if (length(x) == 0) return(NA)
  x[1]
}

# =============================
# 2. Fusion
# =============================
df_clean230326 <- df %>%
  group_by(study_id) %>%
  summarise(
    across(everything(), first_valid),
    .groups = "drop"
  )

# =============================
# 3. Vérification
# =============================
str(df_clean230326)

# =============================
# 4. Export
# =============================
#write.csv(df_clean230326, "df_clean230326.csv", row.names = FALSE)



#Controle qualité et tri intelligents des study_id


df_sorted <- df_clean230326

# 1. Décomposer study_id
df_check <- df_sorted %>%
  separate(
    study_id,
    into = c("country", "site", "service", "num"),
    sep = "/",
    remove = FALSE
  ) %>%
  mutate(num = as.numeric(num))

# 2. Détection des doublons
duplicates <- df_check %>%
  count(study_id) %>%
  filter(n > 1)
if(nrow(duplicates) > 0) print(duplicates)

# 3. Détection des trous
missing_ids <- df_check %>%
  group_by(site, service) %>%
  summarise(
    min_id = min(num, na.rm = TRUE),
    max_id = max(num, na.rm = TRUE),
    existing = list(num),
    .groups = "drop"
  ) %>%
  rowwise() %>%
  mutate(
    expected = list(seq(min_id, max_id)),
    missing = list(setdiff(expected, existing))
  ) %>%
  unnest(missing)
if(nrow(missing_ids) > 0) print(missing_ids)

# 4. Tri final
# Retirer uniquement les colonnes existantes
cols_to_remove <- intersect(c("country","num","existing","expected","missing"), colnames(df_check))
df_final <- df_check %>%
  arrange(site, service, num) %>%
  select(-all_of(cols_to_remove))

# 5. Export CSV final
write_csv(df_final, "df_final_sorted.csv")
print("✅ Base triée et exportée sous 'df_final_sorted.csv'")
