PRO SP_Read_FY_Sath,SStr_Fn_Read,VF_Lon,VF_Lat,VF_BT,VF_Time

  ;SStr_FN = 'E:\FY3\FY3B_MWRIA_GBAL_L1_20130917_0110_010KM_MS.HDF'
  SStr_FN = SStr_Fn_Read
  SStr_DataSet_Lon = 'Longitude' 
  SStr_DataSet_Lat = 'Latitude'
  SStr_DataSet_BT =  'EARTH_OBSERVE_BT_10_to_89GHz'
  SStr_DataSet_Time = 'Scan_Time_and_Period'
  
  SI_FID = H5F_OPEN(SStr_FN) 
  
  SI_DataSet_Lon = H5D_OPEN(SI_FID, SStr_DataSet_Lon)
  SI_DataSet_Lat = H5D_OPEN(SI_FID, SStr_DataSet_Lat)
  SI_DataSet_BT = H5D_OPEN(SI_FID, SStr_DataSet_BT)
  SI_DataSet_Time = H5D_OPEN(SI_FID, SStr_DataSet_Time)
  
  VF_Lon = H5D_READ(SI_DataSet_Lon) 
  VF_Lat = H5D_READ(SI_DataSet_Lat)
  VI_BT =  H5D_READ(SI_DataSet_BT)
   VI_Time = H5D_READ(SI_DataSet_Time)
  VF_Time=float(VI_Time)
   
  VF_BT = 0.01*float(VI_BT)+ 327.68
  VL_Inx_Invalid = where(VI_BT eq -999, SL_Count_Invalid)
  if SL_Count_Invalid gt 0 then VF_BT(VL_Inx_Invalid) = -999.0 
  
  H5F_CLOSE, SI_FID 
  
  
end