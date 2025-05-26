# Ionic Balance and Alkalinity Quality Assessment Function

## Description 

This repository contains a function created for water chemical analysis quality assessment, based on ionic balance to detect potentially inaccurate measurements.

The function assigns two quality flags according to a ionic balance threshold determined by a user-defined parameter ('high-quality' and 'low-quality') 
and a third flag ('no ionic balance data'), when required information is missing.

## Arguments

pH = pH  
ALK = Alkalinity in µeq/l  
Ca = Calcium in mg/l or µeq/l  
Cl = Chloride in mg/l or µeq/l  
K = Potasium in mg/l or µeq/l  
Mg = Magnessium in mg/l or µeq/l  
Na = Sodium in mg/l or µeq/l  
NH4 = Ammonium in mg/l or µeq/l  
NO3 = Nitrate in mg/l or µeq/l  
NO2 = Nitrite in mg/l or µeq/l  
SO4 = Sulfate in mg/l or µeq/l  
Cond = measured conductivity in µS/cm (at 20ºC)  
IB_thres = Ionic balance threshold. Samples with a ionic balance less than or equal to this threshold (in absolute value) will be classified as 'high-quality', otherwise, they will be classified as 'low-quality'
ALK.Dif_thres (optional) = Percentual difference between estimated and measured alkalinity threshold. If provided, samples with a difference (ALK.Dif) greater than or equal to this threshold (in absolute value) will be reclassified from 'high-quality' to 'low-quality'.If not specified, this check is skipped.
units_ueq = TRUE (default, µeq/l) or FALSE (mg/l)    

## Units

Major anions (Cl, SO4, NO3), major cations (Na, K, Ca, Mg) ammonium and nitrites can be expressed either in µeq/L or in mg/L, but all must be in the same unit.
"If 'units_ueq = TRUE' (default), all concentrations must be in µeq/L. If FALSE, they must be in mg/L."
Alkalinity and conductivity must be in µeq/l and µS/cm, respectively

## Result

The function returns a dataframe containing:
* Quality flag (quality)
* Ionic balance (I.Balance)
* Percentual difference between estimated and measured alkalinity (ALK.Dif)
* Percentual difference between ion-estimated and measured conductivities (Cond.Dif)
  
## Example

```sh

table<-data.frame(pH = c(7.2, 6.8), 
                  ALK = c(80, 63), 
                  Ca = c(50, 45), 
                  Cl = c(8, 15), 
                  K = c(2.1, 2.5), 
                  Mg = c(10, 18), 
                  Na = c(15, 24), 
                  NH4 = c(0.5, 0.4), 
                  NO3 = c(1.2, 1.1), 
                  NO2 = c(0.01, 0.02), 
                  SO4 = c(12, 8), 
                  Cond = c(22, 55)) 

result_qc <- ionic_balance_control(
  pH = table$pH,
  ALK = table$ALK,
  Ca = table$Ca,
  Cl = table$Cl,
  K = table$K,
  Mg = table$Mg,
  Na = table$Na,
  NH4 = table$NH4,
  NO3 = table$NO3,
  NO2 = table$NO2,
  SO4 = table$SO4,
  Cond = table$Cond,
  IB_thres = 5,
  ALK.Dif_thres = 100,
  units_ueq = TRUE)
  
table <- bind_cols(table, result_qc)

 ```
  
  