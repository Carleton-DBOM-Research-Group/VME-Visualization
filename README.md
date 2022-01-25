# VME-Visualization
** VME-Visulization virtual metered energy from AHU VAV system visualization tool

https://github.com/Carleton-DBOM-Research-Group/VME-Visualization

**Energy estimated from AHU VAV system:**
 
       1) Heat supplied by AHU heating coil
       
       2) Heat extracted by AHU cooling coil
       
       3) Heat gains from AHU supply fan
       
       4) Head added by zone-level radiant heaters
       
*VME-Visualization generates energy flow visualization from the AHU into VAV zones*

* User interaction panel includes options to select, filter, explore, and duplicate the visualization*

# Installation requirements 
  
  Verify that version 9.11 (R2021b) of the MATLAB Runtime is installed.
  
  Download and install the Windows version of the MATLAB Runtime for R2021b 
  from the following link on the MathWorks website:

    https://www.mathworks.com/products/compiler/mcr/index.html
    
# Input files format
  
  *files from VAV zones must be placed in a seperate folder*
  
  *file name format for VAV zones is "zone_XXXXXX.xlsx" where XXXXXX numeric values indicating the controller ID.*
  
  example: zone_431282.xlsx
    
  *file name format for the AHU serving the VAVs is "buildingname_ahu#.xlsx".*
      
  example: buildingX_ahu1.xlsx
  
  *time series data in each file must have identical start/stop dates*
  
  *hourly intervals and a full calendar year (8760 h) are recommended*
  
  **Zone data files contain time series data in the following format**
  
  column 1 - time strings (yyyy-mm-dd hh:mm)
  
  column 2 - indoor air temperature (degC)
  
  column 3 - vav airflow rate (L/s)
  
  column 4 - vav airflow setpoint (L/s)
  
  column 5 - vav damper position (%)  
  
  **ahu data file contains time series data in the following format**
  
  column 1 - time strings (yyyy-mm-dd hh:mm)
  
  column 2 - supply air temperature (degC)
  
  column 3 - return air temperature (degC)
  
  column 4 - outdoor air temperature (degC)
  
  column 5 - heating coil valve position (%)
  
  column 6 - cooling coil valve position (%)
  
  column 7 - outdoor air damper position (%)
  
  column 8 - fan state (%) 
  
  column 9 - supply air pressure (Pa)
