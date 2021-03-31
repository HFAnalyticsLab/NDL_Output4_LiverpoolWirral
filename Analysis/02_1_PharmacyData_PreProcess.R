# build the data pipeline for pharmacy data


# Take the prescription data and give each prescription an ID and
# order the prescriptions such that each person's have a sequence id that is in order of prescription date

if(!file.exists('Data/02_1_preprocess.rda')) {
  Combined_Pharmacy_Data <- Combined_Pharmacy_Data %>%
    mutate(prescription_id = row_number()) %>%
    group_by(person_id) %>%
    arrange(prescribing_date) %>%
    mutate(person_sequence = row_number()) %>%
    ungroup
  
  Longitudinal_Prescribing = Combined_Pharmacy_Data %>% 
    group_by(person_id,prescribing_date) %>% 
    summarise(num_prescriptions = n(),prescription_group = min(prescription_id),.groups="drop") %>%
    group_by(person_id) %>%
    arrange(prescribing_date) %>%
    mutate(prescription_seq =  row_number()) %>%
    ungroup
    
  
  save(file="Data/02_1_preprocess.rda",list=c("Longitudinal_Prescribing","Combined_Pharmacy_Data"))
} else {
  load("Data/02_1_preprocess.rda")
}

# Add in the previous prescription date
Longitudinal_Prescribing <- Longitudinal_Prescribing %>%
  left_join(Longitudinal_Prescribing %>% 
              select(person_id,prescription_seq,prescribing_date) %>% 
              mutate(prescription_seq = prescription_seq + 1) %>% 
              rename(last_prescription_date = prescribing_date)
            ,by=c("person_id","prescription_seq")) 

# Perform some rudimentary checks to see if it's a repeat prescription or not.
Longitudinal_Prescribing <- Longitudinal_Prescribing %>%
  mutate(repeat_prescription = ifelse(is.na(last_prescription_date),"New","Repeat")) %>%
  mutate(days_since_last_prescription = prescribing_date - last_prescription_date) %>%
  mutate(repeat_prescription = ifelse(is.na(days_since_last_prescription),"New",ifelse(days_since_last_prescription > 90,"New",repeat_prescription))) 

Calendar = data.frame(date=seq(min(Longitudinal_Prescribing$prescribing_date),to=max(Longitudinal_Prescribing$prescribing_date),by=1)) %>%
  mutate(year=year(date),month=month(date),day=day(date)) %>%
  mutate(pre_covid = ifelse(date > "2020-03-31","Post-Covid","Pre-Covid")) %>%
  mutate(month_display = format(date,"%m/%Y")) %>%
  mutate(month_start = as.Date(paste0(format(date,"%Y-%m"),"-01"))) %>%
  mutate(date_id = row_number())
