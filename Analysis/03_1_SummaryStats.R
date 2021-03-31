# 03_1_SummaryStats.R

monthly_summary <- Calendar %>% left_join(Longitudinal_Prescribing,by=c("date"="prescribing_date")) %>%
  group_by(year,month,month_start,person_id,pre_covid) %>%
  summarise(n=n(),.groups="drop") %>%
  left_join(PersonDemographics,by="person_id") %>%
  group_by(year,month,month_start,ethnicity,CEV,age_band,imd_quintile,gender,pre_covid) %>%
  summarise(number_persons_prescribed = n(),.groups="drop") %>%
  mutate(pre_covid = factor(pre_covid,levels=c("Pre-Covid","Post-Covid"),ordered=T))


monthly_summary_new_repeat <- Calendar %>% left_join(Longitudinal_Prescribing,by=c("date"="prescribing_date")) %>%
  group_by(year,month,month_start,person_id,repeat_prescription,pre_covid) %>%
  summarise(n=n(),.groups="drop") %>%
  left_join(PersonDemographics,by="person_id") %>%
  group_by(year,month,month_start,ethnicity,CEV,age_band,imd_quintile,gender,repeat_prescription,pre_covid) %>%
  summarise(number_persons_prescribed = n(),.groups="drop") %>%
  mutate(pre_covid = factor(pre_covid,levels=c("Pre-Covid","Post-Covid"),ordered=T))
  
save(file="Data/03_1_SummaryStats.rda",list=c("monthly_summary","monthly_summary_new_repeat"))
