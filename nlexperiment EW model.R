#EW model experiments

library(nlexperiment)
nl_netlogo_path("C:/Program Files/NetLogo 6.0.2/app")  #to netlogo installation on windows
nl_netlogo_path()

experiment <- nl_experiment(
  model_file = "C:/Users/shown/Documents/GitHub/EW-model/EW draft 1.nlogo",
  iterations = 100,
  repetitions = 3,
  
  param_values = list(
    intensity_threshold = seq(0.6,1,0.1),
    org_budget = seq(0, 20000, 5000),
    repairRatio=seq(0,1,0.1)
  ),
  mapping = c(
    intensity_threshold="intensity-threshold",
    org_budget="org-budget"
  ),
  step_measures = measures(
   mean_damage = "mean [current-damage] of serviceArea"
  ),
  
  run_measures=measures(
   mean_infra="mean [infra-quality] of serviceArea",
   # org_vulnerability = "mean [infra-vul] of serviceArea",
   repair_cost="sum [repairCost] of serviceArea",
   ewfreq="ewfreq"
  ),
 
)

results<-nl_run(experiment,parallel = T,print_progress = T)
write.csv(results1,"nlexperiment results.csv")


results1<-nl_get_result(results)
summary(results1)
View(results1)


library(psych)
library(ggplot2)

ggplot(results1,aes(x=factor(intensity_threshold),y=mean_infra))+
 geom_boxplot()

ggplot(results1,aes(x=factor(org_budget),y=mean_infra))+
  geom_boxplot()


ggplot(results1,aes(x=factor(repairRatio),y=mean_infra))+
  geom_boxplot()



ggplot(results1,aes(x=ewfreq,y=mean_infra))+
  geom_line()


#Ignore the content below. 
results2<-nl_get_result(results,type="step")  #look at damage for each tick
summary(results2)


# ggplot(results2,aes(x=factor(buffer),y=mean_damage))+
#   geom_boxplot()



ggplot(results2,aes(x=step_id, y=mean_damage,color=factor(org_budget)))+
  geom_line()+
  facet_grid(~org_budget)


# ggplot(results1,aes(x=factor(intensity_threshold),y=org_vulnerability))+
#   geom_boxplot()
# ggplot(results1,aes(x=factor(org_budget),y=org_vulnerability))+
#   geom_boxplot()
# ggplot(results1,aes(x=factor(buffer),y=org_vulnerability))+
#   geom_boxplot()
