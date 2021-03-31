## -----------------------------
##
## Script Name  : Prebuild Wirral Data
##  
## Author       : Simon Chambers <simon.chambers@nhs.net>
##
## Date         : March 2021
##
## -----------------------------
##
## Description  :
##
##  This script pre-loads the Wirral data into agreed format for merging with Liverpool Data
##
##
## -----------------------------


require(openxlsx)
require(dplyr)

# These are the load files for demographics and the pharmacy data for wirral
Adep1         <- read.xlsx('Data/Wirral/CombinedAdepFile1.xlsx')
Adep2         <- read.xlsx('Data/Wirral/CombinedAdepFile2.xlsx')
Demographics  <- read.csv('../COVID_Vaccine_Model_Supplement/data.csv')
ShieldingList <- read.xlsx('../Health Foundation/Output1_ShieldQuery.xlsx') %>% rename(nhs_number=NHSNumber) %>% mutate(nhs_number = as.character(nhs_number))


# Tidy up variable names and convert excel DT values to actual dates, as well as remove spaces from NHS numbers
Combined_Pharmacy_Data <- bind_rows(Adep1,Adep2) %>% 
  mutate(source="Wirral") %>%
  mutate(Date.of.Issue = convertToDate(Date.of.Issue)) %>%
  rename(name_dose_qty = `Name,.Dosage.and.Quantity`,
         prescribing_org = Organisation.Code,
         dose = Dose,
         quantity = Quantity,
         course_status = `Medication.Course's.Course.Status.(Current,.Past.etc)`,
         prescribing_date = Date.of.Issue,
         postcode=Postcode,
         nhs_number = NHS.Number,
         age=Age,
         gender=Gender) %>%
  mutate(nhs_number = gsub("[[:space:]]","",nhs_number))

# Filter the person list to just individuals and count their total prescriptions, also add in shielding list flag and other demographics (ethnicity, deprivation, age) 
PersonDemographics <- Combined_Pharmacy_Data %>% group_by(nhs_number,age,gender) %>% summarise(total_prescriptions=n(),.groups="drop") %>%
  left_join(ShieldingList %>% select(nhs_number) %>% mutate(sl="Yes"),by="nhs_number") %>%
  left_join(Demographics %>% select(nhs_number,imd_quintile,lsoa11,ethnicity),by="nhs_number") %>%
  mutate(CEV = "No") %>% mutate(CEV = ifelse(!is.na(sl),"Yes",CEV)) %>% select(-sl) %>%
  mutate(ethnicity = ifelse(is.na(ethnicity),"Not Known/Stated",ethnicity)) %>%
  mutate(imd_quintile = factor(imd_quintile,levels=c(1,2,3,4,5),labels=c("Highest deprivation","Second highest","Middle","Second lowest","Lowest deprivation"),ordered=T)) %>%
  mutate(age_band = cut(age,breaks=c(0,20,30,40,50,60,70,80,1000),include.lowest = T,right=F,labels=c("0-19","20-29","30-39","40-49","50-59","60-69","70-79","80+"))) %>% select(-age) %>%
  mutate(person_id = paste0('W',formatC(row_number(),width=7,format="d",flag="0"))) 

write.csv(PersonDemographics %>% select(nhs_number,person_id),file="Wirral_ID_Lookup.csv")

# Remove the NHS number and replace with the generated person ID
Combined_Pharmacy_Data <- Combined_Pharmacy_Data %>% left_join(PersonDemographics %>% select(person_id,nhs_number),by="nhs_number") %>% select(-nhs_number,-postcode,-age,-gender)
PersonDemographics = PersonDemographics %>% select(-nhs_number)

save(file="Data/Wirral/Wirral_Preload.rda",list=c("PersonDemographics","Combined_Pharmacy_Data"))

#################################################################################
##
## Now build out population totals
##

demographics_summary <- Demographics %>% 
  left_join(ShieldingList %>% select(nhs_number) %>% mutate(sl="Yes"),by="nhs_number") %>%
  mutate(gender=ifelse(gender_code=="male","Male",ifelse(gender_code=="female","Female",ifelse(gender_code=="2","Female","Not specified")))) %>%
  mutate(CEV = "No") %>% mutate(CEV = ifelse(!is.na(sl),"Yes",CEV)) %>% select(-sl) %>%
  mutate(ethnicity = ifelse(is.na(ethnicity),"Not Known/Stated",ethnicity)) %>%
  mutate(imd_quintile = factor(imd_quintile,levels=c(1,2,3,4,5),labels=c("Highest deprivation","Second highest","Middle","Second lowest","Lowest deprivation"),ordered=T)) %>%
  mutate(age_band = factor(ageband10,levels=c("0-9","10-19","20-29","30-39","40-49","50-59","60-69","70-79","80-89","90+"),labels=c("0-19","0-19","20-29","30-39","40-49","50-59","60-69","70-79","80+","80+")),ordered=T) %>%
  group_by(imd_quintile,age_band,gender,CEV,ethnicity) %>%
  summarise(n=n(),.groups="drop")


save(file="Data/Wirral/population_summary.rda",list=c("demographics_summary"))

# Clean up
rm(Adep1,Adep2,Demographics,ShieldingList)



