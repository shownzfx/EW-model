#results analysis Scenario 2 rememberCumDamage


library(nlexperiment)
library(DT)
library(dplyr)
library(ggplot2)
library(tidyr)

library(nlexperiment)
nl_netlogo_path("C:/Program Files/NetLogo 6.0.2/app")  #to netlogo installation on windows
nl_netlogo_path()
setwd("C:/Users/shown/Documents/GitHub/EW-model")
module_file_path="C:/Users/shown/Documents/GitHub/EW-model/EW model using numeric chooser.nlogo"



#---experiment params-------------------
experimentS2 <- nl_experiment(
  model_file = module_file_path,
  iterations = 10,
  
  
  param_values = nl_param_oat(
    n=25,
    intensityThreshold = c(0,0.5,1),
    orgBudget = c(0,4000,2000),
    repairRatio=c(0,1,0.5),
    extremeWeatherDamage=c(0,20,10),
    adaptThreshold=c(0,10,5),
    maxPrevention=c(0,20,10),
    cumDamageRatioThreshold=c(0,100,50),
    damageRatioThreshold=c(0,0.3,0.15),
    interval=c(0,48,24),
    numMonths = c(0,48,24),
    riskPerceptionThreshold=c(0,150,75),
    chooseStrategy= 2
  ),
  
  # mapping = c(
  #   intensity_threshold="intensity-threshold",
  #   org_budget="org-budget"
  # ),
  
  run_measures=measures(
    mean_infra="mean [infraQuality] of serviceArea",
    org_repair_budget="[orgRepairBudget] of orgs",
    org_vulnerability = "[orgVulnerability] of orgs",
    repair_cost="sum [repairCost] of serviceArea",
    extreme_weather_frequency="extremeWeatherFreq",
    prevention="mean [prevention] of serviceArea", 
    damage="mean [damagePerTick] of serviceArea",
    NumAdapt="sum [adaptTime] of orgs"
  ),
  
  step_measures=measures(
    step_infraQuality="mean [infraQuality] of serviceArea",
    step_orgVul= "[orgVulnerability] of orgs",
    whetherAdapt="[whetherAdapt] of orgs",
    step_prevention="mean [prevention] of serviceArea", 
    step_repair_cost="sum [repairCost] of serviceArea",
    step_meanDamage= "mean [damagePerTick] of serviceArea" 
    
  ),
  repetitions = 100
  #random_seed = 1:100
)

#-------------load data-------------------------------------------

runS2<-read.csv(("~/GitHub/EW-model/Experiments/nlexperimentS2 run results.csv"))
stepS2<-read.csv(("~/GitHub/EW-model/Experiments/nlexperimentS2 step results.csv"))



nl_show_params(experimentS2)

dplyr::count(runS2,param_set_id)

run_long<-gather_(runS2,key="parameter",value="value",c("intensityThreshold","orgBudget",
                      "repairRatio","extremeWeatherDamage","adaptThreshold",   "maxPrevention",
                       "damageRatioThreshold","interval", "numMonths","riskPerceptionThreshold","chooseStrategy"))

step_long<-gather_(stepS2,key="parameter",value="value",c("intensityThreshold","orgBudget",
                      "repairRatio","extremeWeatherDamage","adaptThreshold",   "maxPrevention",
                       "damageRatioThreshold","interval", "numMonths","riskPerceptionThreshold","chooseStrategy"))




ggplot(run_Long,aes(x=value,y=mean_infra))+
  geom_point(alpha=0.3)+
  stat_smooth(method = "lm", color = "red") +
  facet_wrap(~ parameter, scales = "free_x") + 
  theme_bw()


ggplot(run_long,aes(x=value,y=org_vulnerability))+
  geom_point(alpha=0.3)+
  stat_smooth(method = "lm", color = "red") +
  facet_wrap(~ parameter, scales = "free_x") + 
  theme_bw()

ggplot(step_long,aes(x=value,y=step_infraQuality))+
  geom_point(alpha=0.3)+
  stat_smooth(method = "lm", color = "red") +
  facet_wrap(~ parameter, scales = "free_x") + 
  theme_bw()

ggplot(step_long,aes(x=value,y=step_orgVul))+
  geom_point(alpha=0.3)+
  stat_smooth(method = "lm", color = "red") +
  facet_wrap(~ parameter, scales = "free_x") + 
  theme_bw()

