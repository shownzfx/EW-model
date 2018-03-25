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
    intensityThreshold = seq(0,1,0.2),   
    orgBudget = seq(0,500,100),
    repairRatio=seq(0,1,0.2),
    extremeWeatherDamage=seq(0,20,5),
    adaptThreshold=seq(0,20,5),
    maxPrevention=seq(0,20,5)
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
results_backup <- results
write.csv(results1,"nlexperiment results.csv")




results1<-nl_get_result(results)
summary(results1)
head(results1)



aggregate(results1,by=list(results1$run_id),FUN=mean)

library(purrr)
library(dplyr)
library(ggplot2)

distinct(results1,intensityThreshold)




ggplot(results1,aes(x=factor(extremeWeatherDamage),y=mean_infra))  +
  geom_boxplot()  #sig. difference

ggplot(results1,aes(x=factor(maxPrevention),y=mean_infra))  +
  geom_boxplot() #sensitive to maxPrevention when maxPrevention is bigger than 5


ggplot(results1,aes(x=factor(intensityThreshold),y=mean_infra))  +
  geom_boxplot() #not too much difference unless intensity threshold is very high > 0.8



#examine effect of damage on mean_infra conditioned on prevention
ggplot(results1,aes(x=factor(extremeWeatherDamage),y=mean_infra))  +
  geom_boxplot()+
  facet_wrap(~factor(maxPrevention))  #interesting figure, how to deal with the so many variations

ggplot(results1,aes(x=factor(repairRatio),y=mean_infra))  +
  geom_boxplot()  #not sentitive to repairRatio; might because the maxBudget is only 500, very small


ggplot(results1,aes(x=factor(orgBudget),y=mean_infra))+
 geom_boxplot() +
  facet_wrap(~factor(intensityThreshold)) #still not sensitive to intensityThreshold unless at the

ggplot(results1,aes(x=factor(intensityThreshold),y=mean_infra))+
  geom_boxplot() #not very sentitive to threshold


ggplot(results1,aes(extreme_weather_frequency,mean_infra))+
  geom_point(aes(color=orgBudget)) +
  scale_color_gradient(low="red", high="green") 
# not very distinct pattern on budget, budget is low


ggplot(results1,aes(extreme_weather_frequency,mean_infra))+
  geom_point(aes(color=prevention)) + scale_color_gradient(low="red", high="green") 
#pattern on prevention becomes more clearer

ggplot(results1,aes(extreme_weather_frequency,mean_infra))+
  geom_point(aes(color=extremeWeatherDamage)) + 
  scale_color_gradient(low="red", high="green") 
#patter on damage also clear

#------------------adaptation------------

ggplot(results1,aes(x=factor(adaptThreshold),y=prevention))+
  geom_boxplot()#prevention is not sensitive to adaptThreshold when threshold is smaller than 15


ggplot(results1,aes(x=factor(adaptThreshold),y=mean_infra))+
  geom_boxplot() #adaptThreshold does not matter to infra quality, why?

ggplot(results1,aes(x=factor(adaptThreshold),y=mean_infra))+
  geom_boxplot()+
  facet_grid(~extremeWeatherDamage) #when accounting for extremeweatherDamage, it becomes sensitive



# 
# ggplot(results1,aes(extreme_weather_frequency,mean_infra))+
#   geom_point(aes(color=repairRatio, size =1/intensityThreshold)) +scale_color_gradient(low="green", high="red")
# 
# 


#experiment 2 with less 
experiment2 <- nl_experiment(
  model_file = "C:/Users/shown/Documents/GitHub/EW-model/EW draft 1.nlogo",
  iterations = 100,
  repetitions = 3,
  
  param_values = list(
    intensityThreshold = c(0,0.5,0.8,1),   
    orgBudget = seq(0,2000,1000),
    repairRatio=c(0.5,0.8,1),
    extremeWeatherDamage=c(0,5,10),
    adaptThreshold=seq(0,10,5),
    maxPrevention=seq(0,10,5),
    adaptCostPerUnit=c(1,2)
  ),
  
  step_measures = measures(
    mean_infra_perTick="mean [infraQuality] of serviceArea",
    mean_damage_perTick = "mean [currentDamage] of serviceArea",
    mean_preventionPerTick="mean [prevention] of serviceArea"
  )
  
  # run_measures=measures(
  #   mean_infra="mean [infraQuality] of serviceArea",
  #   org_repair_budget="[orgRepairBudget] of orgs",
  #   org_vulnerability = "mean [infraVulnerability] of serviceArea",
  #   repair_cost="sum [repairCost] of serviceArea",
  #   extreme_weather_frequency="extremeWeatherFreq",
  #   prevention="mean [prevention] of serviceArea", 
  #   damage="mean [currentDamage] of serviceArea"
  # ),
)

results2_lessCombinations<-nl_run(experiment2,print_progress = T,parallel = T)
