PRO E_read_AMSR2

  SStr_Dir_In = 'C:\FY3\code\datasample'
  SStr_Dir_Out = 'C:\FY3\code\dataoutput'
  
  SStri_FN_Inquired = '*.hdf'
  AStri_FN_Found = file_search(SStr_Dir_In,SStri_FN_Inquired)
  SL_Num_FN = size(AStri_FN_Found,/n_elements)
  if AStri_FN_Found[0] ne '' then begin
    for SL_Inx_FN = 0,SL_Num_FN-1 do begin
      SStri_FN_Temp = AStri_FN_Found[SL_Inx_FN]      
      SStr_FN_Base = FILE_BASENAME(SStri_FN_Temp,'.hdf')
      
      S_read_AMSR2_swath,SStri_FN_Temp,Lon,Lat,VF_BT1,VF_BT2,VF_BT3,VF_BT4,VF_BT5,VF_BT6,VF_BT7,VF_BT8,VF_BT9,VF_BT10,VF_Time     
      VL_Dims = size(VF_Lon,/DIMENSIONS)
      SL_Row = VL_Dims[1]
      SL_Col = VL_Dims[0]/2         
      print, SL_Col,SL_Row
      ;SL_Co = STRCOMPRESS(string( VL_Dims[0]))
      ;SL_Ro = STRCOMPRESS(string( VL_Dims[1]))
      SL_Co = STRTRIM(string( VL_Dims[0]/2),2)
      SL_Ro = STRTRIM(string( VL_Dims[1]),2)
      SStr_FN_Out = SStr_Dir_Out + SStr_FN_Base + SL_Co +SL_Ro + '.bin' 
      OPENW,SI_LUN_W, SStr_FN_Out,/get_lun    
      for SI_Inx_Row = 0,SL_Row-1 do begin
       for SI_Inx_Col = 0,SL_Col-1 do begin
        WRITEU,SI_LUN_W,VF_Lon[2*SI_Inx_Col+1,SI_Inx_Row] , VF_Lat[2*SI_Inx_Col+1,SI_Inx_Row], $
                        VF_BT1[SI_Inx_Col,SI_Inx_Row] ,VF_BT2[SI_Inx_Col,SI_Inx_Row] , $
                        VF_BT3[SI_Inx_Col,SI_Inx_Row] ,VF_BT4[SI_Inx_Col,SI_Inx_Row] , $
                        VF_BT5[SI_Inx_Col,SI_Inx_Row] ,VF_BT6[SI_Inx_Col,SI_Inx_Row] , $
                        VF_BT7[SI_Inx_Col,SI_Inx_Row] ,VF_BT8[SI_Inx_Col,SI_Inx_Row] , $
                        VF_BT9[SI_Inx_Col,SI_Inx_Row] ,VF_BT10[SI_Inx_Col,SI_Inx_Row] ,  VF_Time[SI_Inx_Row]
         endfor 
      endfor
           
      ;for SI_Inx_Row1 = 0,SL_Row1-1 do begin
        ;for SI_Inx_Col1 = 0,SL_Col1-1 do begin
          ;WRITEU,SI_LUN_W,VF_Time[1,SI_Inx_Row1]
        ;endfor
      ;endfor
            
      free_Lun,SI_LUN_W
      
    endfor  
  
  endif else begin
    print,'There is no file in ' + SStr_Dir_In
  endelse
  

end