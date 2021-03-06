# #EW model experiments scenario 1

 
# #xlcFreeMemory()
# rm(list = ls())
options(java.parameters = "-Xmx4g")
# #lapply(paste('package:',names(sessionInfo()$otherPkgs),sep=""),detach,character.only=TRUE,unload=TRUE)
# (.packages())
# warnings()


# # Windows
# library(nlexperiment)
# nl_netlogo_path("C:/Program Files/NetLogo 6.0.2/app")  #to netlogo installation on windows
# nl_netlogo_path()
# setwd("C:/Users/shown/Documents/GitHub/EW-model")
# module_file_path="C:/Users/shown/Documents/GitHub/EW-model/EW model using numeric chooser.nlogo"

# AGAVE
library(nlexperiment)
nl_netlogo_path("/packages/7x/netlogo/6.0.2/app")  #to netlogo installation 
nl_netlogo_path()
setwd("/home/fzhang59/dev/EW-model")
module_file_path="/home/fzhang59/dev/EW-model/EW model using numeric chooser.nlogo"

#---use one scenario at one time--------------

experimentS1 <- nl_experiment(
  model_file = module_file_path,
  iterations = 120,
 
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
    chooseStrategy= 1
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


resultS1<-nl_run(experimentS1,parallel = T,print_progress = F)

resultS1_backup <- resultS1

resultS1_run<-nl_get_run_result(resultS1)
resultS1_step<-nl_get_step_result(resultS1)

dim(resultS1_run)
dim(resultS1_step)

write.csv(resultS1_run,"/home/fzhang59/dev/EW-model/Experiments/nlexperimentS1 run results.csv")
write.csv(resultS1_step,"/home/fzhang59/dev/EW-model/Experiments/nlexperimentS1 step results.csv")



