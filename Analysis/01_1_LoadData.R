# Load Data - the data for both areas is preprared into identical files, which we can load and process

# Conditionally load each file

if (file.exists('Data/Wirral/Wirral_Preload.rda')) {
  load('Data/Wirral/Wirral_Preload.rda')
  
  wirral = list(Combined_Pharmacy_Data=Combined_Pharmacy_Data,PersonDemographics=PersonDemographics)
  
  rm(Combined_Pharmacy_Data,PersonDemographics)  
}

if (file.exists('Data/Liverpool/Liverpool_Preload.rda')) {
  load('Data/Liverpool/Liverpool_Preload.rda')
  
  liverpool = list(Combined_Pharmacy_Data=Combined_Pharmacy_Data,PersonDemographics=PersonDemographics)
  
  rm(Combined_Pharmacy_Data,PersonDemographics)
}



# Check they both loaded and then build the joint dataset from those that did, if only one exists we proceed with just that one.

if (exists("wirral") & exists("liverpool")){
  Combined_Pharmacy_Data  <- bind_rows(wirral$Combined_Pharmacy_Data,liverpool$Combined_Pharmacy_Data)
  PersonDemographics      <- bind_rows(wirral$PersonDemographics,liverpool$PersonDemographics)
} else {
  if(exists("wirral")){
    Combined_Pharmacy_Data  <- wirral$Combined_Pharmacy_Data
    PersonDemographics      <-wirral$PersonDemographics
  } else {
    if (exists("liverpool")) {
      Combined_Pharmacy_Data  <- liverpool$Combined_Pharmacy_Data
      PersonDemographics      <- liverpool$PersonDemographics
    } else {
      stop("No Data to Load")
    }
  }
}

save(file='Data/01_1_LoadData.rda',list=ls())

suppressWarnings(rm(liverpool,wirral))
