#EW model experiments

library(nlexperiment)
nl_netlogo_path("C:/Program Files/NetLogo 6.0.2/app")  #to netlogo installation on windows
nl_netlogo_path()
setwd("C:/Users/shown/Documents/GitHub/EW-model")

experiment <- nl_experiment(
  model_file = "C:/Users/shown/Documents/GitHub/EW-model/EW draft 1.nlogo",
  iterations = 100,
  repetitions = 3,
  
  param_values = list(
    intensityThreshold = seq(0,0.2,1),
    orgBudget = seq(0,500,100),
    repairRatio=seq(0,1,0.2),
    extremeWeatherDamage=seq(1,20,5),
    adaptThreshold=seq(1,20,5),
    maxPrevention=seq(0,100,20)
  ),
  # mapping = c(
  #   intensity_threshold="intensity-threshold",
  #   org_budget="org-budget"
  # ),
  # step_measures = measures(
  #  mean_damage = "mean [currentDamage] of serviceArea",
  #  mean_preventionPerTick="mean [prevention] of serviceArea"
  # ),
  
  run_measures=measures(
   mean_infra="mean [infraQuality] of serviceArea",
   org_repair_budget="[orgRepairBudget] of orgs",
   org_vulnerability = "mean [infraVulnerability] of serviceArea",
   repair_cost="sum [repairCost] of serviceArea",
   extreme_weather_frequency="extremeWeatherFreq",
   prevention="mean [prevention] of serviceArea", 
   damage="mean [currentDamage] of serviceArea"
  ),
)

results<-nl_run(experiment,parallel = T,print_progress = T)
write.csv(results1,"nlexperiment results.csv")


results1<-nl_get_result(results)
summary(results1)
head(results1)

library(purrr)
map(results1,table)
results1 %>% select_("intensityThreshold:maxPrevention")


library(dplyr)
library(ggplot2)

distinct(results1,intensityThreshold)


ggplot(results1,aes(x=factor(intensity_threshold),y=mean_infra))+
 geom_violin() +
  stat_summary(fun.y=mean, geom = "point")

ggplot(results1,aes(x=factor(org_budget),y=mean_infra))+
  geom_violin()+
  stat_summary(fun.y=median,geom="point")


ggplot(results1,aes(x=factor(repairRatio),y=mean_infra))+
  geom_violin()+
  stat_summary(fun.y = median,geom = "point")


ggplot(results1,aes(x=factor(prevention),y=damage))+
  geom_violin()+
  stat_summary(fun.y = median,geom = "point")

ggplot(results1,aes(x=prevention,y=damage))+
  geom_line() #why does the line look so thick? 


ggplot(results1,aes(extreme_weather_frequency,mean_infra))+
  geom_point(aes(color=prevention)) +scale_color_gradient(low="green", high="red")


ggplot(results1,aes(extreme_weather_frequency,mean_infra))+
  geom_point(aes(color=repairRatio, size =1/intensity_threshold)) +scale_color_gradient(low="green", high="red")





