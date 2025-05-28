######################### IONIC BALANCE AND ALKALINITY QUALITY ASSESSMENT FUNCTION ############################
###############################################################################################################
# Function created for water chemical analysis quality assessment, based on ionic balance to detect potentially 
# inaccurate measurements. The function assigns two quality flags according to an ionic balance threshold 
# determined by a user-defined parameter ('high-quality' and 'low-quality') and a third flag ('no ionic balance 
# data') when required information is missing.

# List of function parameters:

# pH = pH
# ALK = Alkalinity in µeq/l
# Ca = Calcium in mg/l or µeq/l
# Cl = Chloride in mg/l or µeq/l
# K = Potasium in mg/l or µeq/l
# Mg = Magnesium in mg/l or µeq/l
# Na = Sodium in mg/l or µeq/l
# NH4 = Ammonium in mg/l or µeq/l
# NO3 = Nitrate in mg/l or µeq/l
# NO2 = Nitrite in mg/l or µeq/l
# SO4 =Sulfate in mg/l or µeq/l
# Cond = measured conductivity referenced to 20ºC
# IB_thres = Ionic balance threshold. Samples with an ionic balance less than or equal to this threshold (in absolute value) 
      # will be classified as 'high-quality'. Otherwise, they will be classified as 'low-quality'
# ALK.Dif_thres (optional) = Percentual difference between estimated and measured alkalinity threshold.
      # A threshold value to assess discrepancies between estimated and measured alkalinity. 
      # If provided, samples with a difference (ALK.Dif) greater than or equal to this threshold (in absolute value) 
      # will be reclassified from 'high-quality' to 'low-quality'.If not specified, this check is skipped.
# units_ueq = TRUE (default) or FALSE  
      # Major anions (Cl, SO4, NO3), major cations (Na, K, Ca, Mg), ammonium, and nitrite can be 
      # expressed either in µeq/L or mg/L, but all must be in the same unit.
      # "If 'units_ueq = TRUE' (default), all concentrations must be in µeq/L. If FALSE, they must be in mg/L."
      # Alkalinity and conductivity must be in µeq/l and µS/cm respectively

ionic_balance_control<-function(pH, ALK, Ca, Cl, K, Mg, Na, NH4, NO3, NO2, SO4, Cond, IB_thres, ALK.Dif_thres = NULL, units_ueq = TRUE){
  
  if (!units_ueq) {
  # Convert all the units to equivalents
  H = 10^6 * 10^-(pH)
  Ca = Ca * (1 / 40.079) * 2 * 1000
  Cl = Cl * (1 / 35.453) * 1000
  K = K * (1 / 39.0983) * 1000
  Mg = Mg * (1 / 24.305) * 2 * 1000
  Na = Na * (1 / 22.989769) * 1000
  NH4 = NH4 * (1 / 18) * 1000
  NO3 = NO3 * (1 / 62.0049) * 1000
  NO2 = NO2 * (1 / 46.0055) * 1000
  SO4 = SO4 * (1 / 96.06) * 2 * 1000
  } else {
  H=10^6 * 10^-(pH)  
  }
  
  # In order not to lose sites that do not have NO2 but do have NO3. 
  NO3NO2=rowSums(cbind(NO3, NO2), na.rm = TRUE)
  NO3NO2=if_else(is.na(NO2) & is.na(NO3),NA, NO3NO2)
  NO3NO2=if_else(is.na(NO3),NA, NO3NO2)
  
  # Cation and anion sums and the corresponding ionic balance
  C.sum=H+Ca+Mg+K+Na+NH4
  A.sum=ALK+Cl+NO3NO2+SO4
  I.Balance=100*(C.sum-A.sum)/(C.sum+A.sum)
  
  
 # Expected conductivity calculation. Ionic molal conductivity extracted from Haynes (2014)*
 # * Haynes, W. M., Ed. (2014). CRC Handbook of chemistry and physics. Boca Raton, Fl, CRC Press.
  
  # Dealing with nitrate-nitrite data availability
  NO3_cond=NO3*(71.42/1.11)
  NO2_cond=NO2*(71.8/1.11)
  NO3NO2_cond=rowSums(cbind(NO3_cond, NO2_cond), na.rm = TRUE)
  NO3NO2_cond=if_else(is.na(NO2) & is.na(NO3),NA, NO3NO2_cond)
  NO3NO2_cond=if_else(is.na(NO3),NA, NO3NO2_cond)
  #Ion-estimated conductivity
  cond.est=(H*(349.65/1.11)+NH4*(73.5/1.11) + Ca*(59.47/1.11) + Mg*(53/1.11) + Na*(50.08/1.11) + K*(73.48/1.11) + 
              ALK*(44.5/1.11) + SO4*(80/1.11) + NO3NO2_cond + Cl*(76.31/1.11))/1000
  
  # Correcting for ionic strength
  # Ionic strength
  ionic.strength=((H+NH4 + Ca*2 + Mg*2 + Na + K + ALK + SO4*2 + NO3NO2 + Cl)/1000/2000)
  # Ionic strength coefficient
  ionic.strength.coef=10^(-0.5*(ionic.strength^(1/2*(1+ionic.strength^1/2))-0.3*ionic.strength))
  # Estimated conductivity corrected
  cond.est.corr=(cond.est*(ionic.strength.coef^2))
  
  # Percentual difference between ion-estimated and measured conductivities 
  Cond.Dif=((Cond - cond.est.corr)/cond.est.corr)*100
  
  # Estimated alkalinity
  ALK.est=(Ca+Mg+K+Na+NH4-Cl-SO4-NO3NO2)
  
  # Percentual difference between estimated and measured alkalinity 
  ALK.Dif=(ALK-ALK.est)/ALK.est*100
  
  # Quality flag
  quality <- ifelse(is.na(I.Balance), "no ionic balance data",
                    ifelse(I.Balance >= -1 * IB_thres & I.Balance <= IB_thres, "high-quality", "low-quality"))
  if (!is.null(ALK.Dif_thres)) {
    quality <- ifelse(quality == "high-quality" & abs(ALK.Dif) >= ALK.Dif_thres, "low-quality", quality)
  }
  # Result as tibble/data.frame
  return(data.frame(
    quality = quality,
    I.Balance = I.Balance,
    ALK.Dif = ALK.Dif,
    Cond.Dif = Cond.Dif
  ))
  
  }

# Extra: way to join the result at the original table:
# table <- bind_cols(table, result_qc)
