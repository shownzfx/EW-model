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

#---use one scenario at one time S1-------------

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


resultS1<-nl_run(experimentS1,parallel = T,print_progress = F)

resultS1_backup <- resultS1

resultS1_run<-nl_get_run_result(resultS1)
resultS1_step<-nl_get_step_result(resultS1)

dim(resultS1_run)
dim(resultS1_step)

write.csv(resultS1_run,"/home/fzhang59/dev/EW-model/Experiments/nlexperimentS1 run results.csv")
write.csv(resultS1_step,"/home/fzhang59/dev/EW-model/Experiments/nlexperimentS1 step results.csv")



#-----------------S2--------------------------


#---use one scenario at one time--------------

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

resultS2<-nl_run(experimentS2,parallel = T,print_progress = F)

resultS2_backup <- resultS2

resultS2_run<-nl_get_run_result(resultS2)
resultS2_step<-nl_get_step_result(resultS2)

dim(resultS2_run)
dim(resultS2_step)

write.csv(resultS2_run,"/home/fzhang59/dev/EW-model/Experiments/nlexperimentS2 run results.csv")
write.csv(resultS2_step,"/home/fzhang59/dev/EW-model/Experiments/nlexperimentS2 step results.csv")


#-------------------S3----------------------------------------
experimentS3 <- nl_experiment(
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


resultS3<-nl_run(experimentS3,parallel = T,print_progress = F)

resultS3_backup <- resultS3

resultS3_run<-nl_get_run_result(resultS3)
resultS3_step<-nl_get_step_result(resultS3)

dim(resultS3_run)
dim(resultS3_step)

write.csv(resultS3_run,"/home/fzhang59/dev/EW-model/Experiments/nlexperimentS3 run results.csv")
write.csv(resultS3_step,"/home/fzhang59/dev/EW-model/Experiments/nlexperimentS3 step results.csv")

#------------------------------------S4------------------------------------------------------

experimentS4 <- nl_experiment(
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


resultS4<-nl_run(experimentS4,parallel = T,print_progress = F)

resultS4_backup <- resultS4

resultS4_run<-nl_get_run_result(resultS4)
resultS4_step<-nl_get_step_result(resultS4)

dim(resultS4_run)
dim(resultS4_step)

write.csv(resultS4_run,"/home/fzhang59/dev/EW-model/Experiments/nlexperimentS4 run results.csv")
write.csv(resultS4_step,"/home/fzhang59/dev/EW-model/Experiments/nlexperimentS4 step results.csv")

#------------------------------S5-----------------------------------------------------------------
experimentS5 <- nl_experiment(
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


resultS5<-nl_run(experimentS5,parallel = T,print_progress = F)

resultS5_backup <- resultS5

resultS5_run<-nl_get_run_result(resultS5)
resultS5_step<-nl_get_step_result(resultS5)

dim(resultS5_run)
dim(resultS5_step)

write.csv(resultS5_run,"/home/fzhang59/dev/EW-model/Experiment5/nlexperimentS5 run results.csv")
write.csv(resultS5_step,"/home/fzhang59/dev/EW-model/Experiment5/nlexperimentS5 step results.csv")


