; eASTROGAM_kalmanLUT.pro - Description
; ---------------------------------------------------------------------------------
; Computing the eASTROGAM tracker strip position and the GPS set-up for the AG KALMAN
; ---------------------------------------------------------------------------------
; copyright            : (C) 2014 Valentina Fioretti
; email                : fioretti@iasfbo.inaf.it
; ----------------------------------------------
; Usage:
; eASTROGAM_kalmanLUT.pro
; ---------------------------------------------------------------------------------
; Notes:
; GPS theta, phi amd height set to 30, 225 and 150 cm
; Tracker geometry based on the AGILE V3.0 mass model


pro eASTROGAM_KalmanLUT

outdir = './conf/
print, 'Configuration files path: ', outdir

CheckOutDir = DIR_EXIST( outdir)
if (CheckOutDir EQ 0) then spawn,'mkdir -p ./conf'

theta_deg_point = 30.0d
phi_deg_point = 225.d
theta_point = theta_deg_point*(!PI/180.d)
phi_point = phi_deg_point*(!PI/180.d)

theta_deg_plane = 30.0d
phi_deg_plane = 0.d
theta_plane = theta_deg_plane*(!PI/180.d)
phi_plane = phi_deg_plane*(!PI/180.d)

; source height
h_s = 150.d  ;cm

; Global Geometry:
N_tray = 56l  
N_layer = 1l
N_strip = 3840l
pitch = 0.240   ;mm
Tray_side = 921.6  ;mm

; Tracker geometry [mm]
Si_t = 0.500
tracker_pitch = 10.
Al_t = tracker_pitch - Si_t

dist_tray = 0.   ;mm

print, '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%'
print, '%                eASTROGAM V1.0                    %
print, '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%'
print, '% - Number of trays:', N_tray 
print, '% - Number of strips:', N_strip
print, '% - Pitch [mm]:', pitch
print, '% - Tray side [mm]:', Tray_Side 
print, '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%'
print, '% Tracker thicknesses:'
print, '% - Silicon thickness [mm]:', Si_t
print, '% - Al honeycomb thickness [mm]:', Al_t
print, '% ----------------------------------------------'
print, '% - Plane pitch [mm]:', tracker_pitch
print, '% - Trays distance [mm]:', dist_tray
print, '% ----------------------------------------------'

Lower_module_t = 0.

z_start = 0.

Central_module_t = Al_t
Upper_module_t = Si_t

print, '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%'
print, '% Tracker heights:'
print, '% - Lower module height [mm]:', Lower_module_t
print, '% - Central module height [mm]:', Central_module_t
print, '% - Upper module height [mm]:', Upper_module_t
print, '% - Tray height [mm]:', Lower_module_t + Central_module_t + Upper_module_t


TRK_t = Lower_module_t + Central_module_t + Upper_module_t
for k=1l, N_tray -1 do begin
  TRK_t = TRK_t + Lower_module_t + Central_module_t + Upper_module_t + dist_tray
endfor

z_end = TRK_t + z_start

print, '% - Tracker height [mm]:', TRK_t
print, '% - Tracker Z start [mm]:', z_start
print, '% - Tracker Z end [mm]:', z_end

pos_x = -1.
pos_y = -1.

vol_id_x_bottom = -1l
tray_id_x_bottom = -1l
Si_id_x_bottom = -1l
Strip_id_x_bottom = -1l
pos_z_x_bottom = -1.

vol_id_x_top = -1l
tray_id_x_top = -1l
Si_id_x_top = -1l
Strip_id_x_top = -1l
pos_z_x_top = -1.


; Total number of strips

Total_vol_x = N_tray*N_strip
Total_vol_y = N_tray*N_strip

Glob_vol_id_x_top = lonarr(Total_vol_x) 
Glob_pos_x_top = dblarr(Total_vol_x) 
Glob_z_x_top = dblarr(Total_vol_x) 
Glob_moth_id_x_top = lonarr(Total_vol_x) 
Glob_Strip_id_x_top = lonarr(Total_vol_x) 
Glob_Si_id_x_top = lonarr(Total_vol_x) 
Glob_tray_id_x_top = lonarr(Total_vol_x) 
Glob_plane_id_x_top = lonarr(Total_vol_x) 
Glob_energy_dep_x_top = dblarr(Total_vol_x) 

Glob_vol_id_y_top = lonarr(Total_vol_y) 
Glob_pos_y_top = dblarr(Total_vol_y) 
Glob_z_y_top = dblarr(Total_vol_y) 
Glob_moth_id_y_top = lonarr(Total_vol_y) 
Glob_Strip_id_y_top = lonarr(Total_vol_y) 
Glob_Si_id_y_top = lonarr(Total_vol_y) 
Glob_tray_id_y_top = lonarr(Total_vol_y) 
Glob_plane_id_y_top = lonarr(Total_vol_y) 
Glob_energy_dep_y_top = dblarr(Total_vol_y) 

; all strips are readout

; ----> X layer

Tray_t = Lower_module_t + Central_module_t + Upper_module_t

for t=0l, N_tray-1 do begin
      
      LowerModulePos_z = t*(dist_tray + Tray_t) + (Lower_module_t/2.)

      UpperModulePos_z = t*(dist_tray + Tray_t) + Lower_module_t + Central_module_t + (Upper_module_t/2.)      
      pos_z_x_top = UpperModulePos_z -(Upper_module_t/2.) + Si_t/2.
      pos_z_y_top = UpperModulePos_z -(Upper_module_t/2.) + Si_t/2.

      
      ;print, pos_z_x
      copyM = 1000000l + 1000000l*t
      for s=0l, N_strip-1 do begin

        Glob_moth_id_x_top[(t)*N_strip + s] = (copyM + 90000l)
        Glob_tray_id_x_top[(t)*N_strip + s] = t+1
        Glob_plane_id_x_top[(t)*N_strip + s] = N_tray - t
        Glob_Si_id_x_top[(t)*N_strip + s] = 0
        Glob_Strip_id_x_top[(t)*N_strip + s] = s
        Glob_energy_dep_x_top[(t)*N_strip + s] = 0.
        Glob_vol_id_x_top[(t)*N_strip + s] = s

        Strip_pos_x_top = (pitch/2.) + (pitch*s)
        Glob_pos_x_top[(t)*N_strip + s] = Strip_pos_x_top/10.  ;cm
        Glob_z_x_top[(t)*N_strip + s] = pos_z_x_top/10.

        Glob_moth_id_y_top[(t)*N_strip + s] = (copyM + 90000l)
        Glob_tray_id_y_top[(t)*N_strip + s] = t+1
        Glob_plane_id_y_top[(t)*N_strip + s] = N_tray - t
        Glob_Si_id_y_top[(t)*N_strip + s] = 1
        Glob_Strip_id_y_top[(t)*N_strip + s] = s
        Glob_energy_dep_y_top[(t)*N_strip + s] = 0.
        Glob_vol_id_y_top[(t)*N_strip + s] =  s

        Strip_pos_y_top = (pitch/2.) + (pitch*s)
        Glob_pos_y_top[(t)*N_strip + s] = Strip_pos_y_top/10.  ;cm
        Glob_z_y_top[(t)*N_strip + s] = pos_z_y_top/10.
      endfor
 endfor
 

CREATE_STRUCT, KALMANXTop, 'KALMANXTop', ['VOLUME_ID', 'MOTHER_ID', 'TRAY_ID', 'PLANE_ID','TRK_FLAG', 'STRIP_ID', 'XPOS', 'ZPOS','E_DEP'], 'J,J,I,I,I,J,F20.5,F20.5,F20.5', DIMEN = N_ELEMENTS(Glob_vol_id_x_top)
KALMANXTop.VOLUME_ID = Glob_vol_id_x_Top
KALMANXTop.MOTHER_ID = Glob_moth_id_x_Top
KALMANXTop.TRAY_ID = Glob_tray_id_x_Top
KALMANXTop.PLANE_ID = Glob_plane_id_x_Top
KALMANXTop.TRK_FLAG = Glob_Si_id_x_Top
KALMANXTop.STRIP_ID = Glob_Strip_id_x_Top
KALMANXTop.XPOS = Glob_pos_x_Top
KALMANXTop.ZPOS = Glob_z_x_Top
KALMANXTop.E_DEP = Glob_energy_dep_x_Top

HDR_XGRID_Top = ['Creator          = Valentina Fioretti', $
                 'AeSTROGAM release    = V1.0']

MWRFITS, KALMANXTop, './conf/KALMAN.XTOP.eASTROGAMV1.0.TRACKER.FITS', HDR_XGRID_Top, /CREATE

CREATE_STRUCT, KALMANYTop, 'KALMANYTop', ['VOLUME_ID', 'MOTHER_ID', 'TRAY_ID', 'PLANE_ID','TRK_FLAG', 'STRIP_ID', 'YPOS', 'ZPOS','E_DEP'], 'J,J,I,I,I,J,F20.5,F20.5,F20.5', DIMEN = N_ELEMENTS(Glob_vol_id_y_top)
KALMANYTop.VOLUME_ID = Glob_vol_id_y_Top
KALMANYTop.MOTHER_ID = Glob_moth_id_y_Top
KALMANYTop.TRAY_ID = Glob_tray_id_y_Top
KALMANYTop.PLANE_ID = Glob_plane_id_y_Top
KALMANYTop.TRK_FLAG = Glob_Si_id_y_Top
KALMANYTop.STRIP_ID = Glob_Strip_id_y_Top
KALMANYTop.YPOS = Glob_pos_y_Top
KALMANYTop.ZPOS = Glob_z_y_Top
KALMANYTop.E_DEP = Glob_energy_dep_y_Top

HDR_YGRID_Top = ['Creator          = Valentina Fioretti', $
                 'eASTROGAM release    = V1.0']

MWRFITS, KALMANYTop, './conf/KALMAN.YTOP.eASTROGAMV1.0.TRACKER.FITS', HDR_YGRID_Top, /CREATE


end
