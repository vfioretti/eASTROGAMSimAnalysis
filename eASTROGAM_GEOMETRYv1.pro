; eASTROGAM_GEOMETRYv1.pro - Description
; ---------------------------------------------------------------------------------
; Computing the eASTROGAM tracker strip position and the GPS set-up
; ---------------------------------------------------------------------------------
; copyright            : (C) 2015 Valentina Fioretti
; email                : fioretti@iasfbo.inaf.it
; ----------------------------------------------
; Usage:
; eASTROGAM_GEOMETRYv1
; ---------------------------------------------------------------------------------
; Notes:
; GPS theta, phi and height set to 30, 225 and 150 cm
; 
;


pro eASTROGAM_GEOMETRYv1

outdir = './conf/
print, 'Configuration files path: ', outdir

CheckOutDir = DIR_EXIST( outdir)
if (CheckOutDir EQ 0) then spawn,'mkdir -p ./conf'

theta_deg_point = 30.d0
phi_deg_point = 225.d
theta_point = theta_deg_point*(!PI/180.d)
phi_point = phi_deg_point*(!PI/180.d)

theta_deg_plane = 80.d0
phi_deg_plane = 0.d0
theta_plane = theta_deg_plane*(!PI/180.d)
phi_plane = phi_deg_plane*(!PI/180.d)

theta_deg_pol = 90.d0
phi_deg_pol = 20.d0
theta_pol = theta_deg_pol*(!PI/180.d)
phi_pol = phi_deg_pol*(!PI/180.d)

pol_vec = [sin(theta_pol)*cos(phi_pol), sin(theta_pol)*sin(phi_pol), cos(theta_pol)]


M = [[cos(theta_point)*cos(phi_point), cos(theta_point)*sin(phi_point), -sin(theta_point)], $
     [-sin(phi_point), cos(phi_point), 0.],$
     [sin(theta_point)*cos(phi_point), sin(theta_point)*sin(phi_point), cos(theta_point)]]

M_minus = invert(M)
pol_vec_new = MATRIX_MULTIPLY(M, pol_vec)

for j=0l, n_elements(pol_vec_new)-1 do begin
  pol_vec_new[j] =  round(pol_vec_new[j]*1000000.)/1000000.
endfor
x_vec_new = pol_vec_new[0]
y_vec_new = pol_vec_new[1]
z_vec_new = pol_vec_new[2]


if ((y_vec_new GE 0.) and (x_vec_new GE 0.)) then begin
  theta_pol_global = (180./!PI)*acos(z_vec_new/sqrt(x_vec_new^2. + y_vec_new^2. + z_vec_new^2.))
  phi_pol_global = (180./!PI)*asin(y_vec_new/sqrt(x_vec_new^2. + y_vec_new^2.))
endif
if ((y_vec_new GE 0.) and (x_vec_new LT 0.)) then begin
  theta_pol_global = (180./!PI)*acos(z_vec_new/sqrt(x_vec_new^2. + y_vec_new^2. + z_vec_new^2.))
  phi_pol_global = 180. - (180./!PI)*asin(y_vec_new/sqrt(x_vec_new^2. + y_vec_new^2.))
endif
if ((y_vec_new LT 0.) and (x_vec_new EQ 0.)) then begin
  theta_pol_global = (180./!PI)*acos(z_vec_new/sqrt(x_vec_new^2. + y_vec_new^2. + z_vec_new^2.))
  phi_pol_global = 360 + (180./!PI)*asin(y_vec_new/sqrt(x_vec_new^2. + y_vec_new^2.))
endif
if ((y_vec_new LT 0.) and (x_vec_new LT 0.)) then begin
  theta_pol_global = (180./!PI)*acos(z_vec_new/sqrt(x_vec_new^2. + y_vec_new^2. + z_vec_new^2.))
  phi_pol_global = 180. - (180./!PI)*asin(y_vec_new/sqrt(x_vec_new^2. + y_vec_new^2.))
endif
if ((y_vec_new LT 0.) and (x_vec_new GT 0.)) then begin
  theta_pol_global = (180./!PI)*acos(z_vec_new/sqrt(x_vec_new^2. + y_vec_new^2. + z_vec_new^2.))
  phi_pol_global = 360 + (180./!PI)*asin(y_vec_new/sqrt(x_vec_new^2. + y_vec_new^2.))
endif

theta_pol_global = theta_pol_global*(!PI/180.d)
phi_pol_global = phi_pol_global*(!PI/180.d)


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
Glob_pair_flag_x_top = dblarr(Total_vol_x)

Glob_vol_id_y_top = lonarr(Total_vol_y) 
Glob_pos_y_top = dblarr(Total_vol_y) 
Glob_z_y_top = dblarr(Total_vol_y) 
Glob_moth_id_y_top = lonarr(Total_vol_y) 
Glob_Strip_id_y_top = lonarr(Total_vol_y) 
Glob_Si_id_y_top = lonarr(Total_vol_y) 
Glob_tray_id_y_top = lonarr(Total_vol_y) 
Glob_plane_id_y_top = lonarr(Total_vol_y) 
Glob_energy_dep_y_top = dblarr(Total_vol_y) 
Glob_pair_flag_y_top = dblarr(Total_vol_x)

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
        Glob_pair_flag_x_top[(t)*N_strip + s] = 0

        Strip_pos_x_top = -(Tray_side/2.0) + (pitch/2.) + (pitch*s)
        Glob_pos_x_top[(t)*N_strip + s] = Strip_pos_x_top/10.  ;cm
        Glob_z_x_top[(t)*N_strip + s] = pos_z_x_top/10.

        Glob_moth_id_y_top[(t)*N_strip + s] = (copyM + 90000l)
        Glob_tray_id_y_top[(t)*N_strip + s] = t+1
        Glob_plane_id_y_top[(t)*N_strip + s] = N_tray - t
        Glob_Si_id_y_top[(t)*N_strip + s] = 1
        Glob_Strip_id_y_top[(t)*N_strip + s] = s
        Glob_energy_dep_y_top[(t)*N_strip + s] = 0.
        Glob_vol_id_y_top[(t)*N_strip + s] = s
        Glob_pair_flag_y_top[(t)*N_strip + s] = 0

        Strip_pos_y_top = -(Tray_side/2.0) + (pitch/2.) + (pitch*s)
        Glob_pos_y_top[(t)*N_strip + s] = Strip_pos_y_top/10.  ;cm
        Glob_z_y_top[(t)*N_strip + s] = pos_z_y_top/10.
      endfor
 endfor
 

CREATE_STRUCT, eASTROGAMv1GridXTop, 'GrideASTROGAMv1XTop', ['VOLUME_ID', 'MOTHER_ID', 'TRAY_ID', 'PLANE_ID','TRK_FLAG', 'STRIP_ID', 'XPOS', 'ZPOS','E_DEP','PAIR_FLAG'], 'J,J,I,I,I,J,F20.5,F20.5,F20.5,I', DIMEN = N_ELEMENTS(Glob_vol_id_x_top)
eASTROGAMv1GridXTop.VOLUME_ID = Glob_vol_id_x_Top
eASTROGAMv1GridXTop.MOTHER_ID = Glob_moth_id_x_Top
eASTROGAMv1GridXTop.TRAY_ID = Glob_tray_id_x_Top
eASTROGAMv1GridXTop.PLANE_ID = Glob_plane_id_x_Top
eASTROGAMv1GridXTop.TRK_FLAG = Glob_Si_id_x_Top
eASTROGAMv1GridXTop.STRIP_ID = Glob_Strip_id_x_Top
eASTROGAMv1GridXTop.XPOS = Glob_pos_x_Top
eASTROGAMv1GridXTop.ZPOS = Glob_z_x_Top
eASTROGAMv1GridXTop.E_DEP = Glob_energy_dep_x_Top
eASTROGAMv1GridXTop.PAIR_FLAG = Glob_pair_flag_x_Top

HDR_XGRID_Top = ['Creator          = Valentina Fioretti', $
                 'eASTROGAM release    = V1.0']

MWRFITS, eASTROGAMv1GridXTop, './conf/ARCH.XSTRIP.TOP.eASTROGAMV1.0.TRACKER.FITS', HDR_XGRID_Top, /CREATE

CREATE_STRUCT, eASTROGAMv1GridYTop, 'GrideASTROGAMv1YTop', ['VOLUME_ID', 'MOTHER_ID', 'TRAY_ID', 'PLANE_ID','TRK_FLAG', 'STRIP_ID', 'YPOS', 'ZPOS','E_DEP','PAIR_FLAG'], 'J,J,I,I,I,J,F20.5,F20.5,F20.5,I', DIMEN = N_ELEMENTS(Glob_vol_id_y_top)
eASTROGAMv1GridYTop.VOLUME_ID = Glob_vol_id_y_Top
eASTROGAMv1GridYTop.MOTHER_ID = Glob_moth_id_y_Top
eASTROGAMv1GridYTop.TRAY_ID = Glob_tray_id_y_Top
eASTROGAMv1GridYTop.PLANE_ID = Glob_plane_id_y_Top
eASTROGAMv1GridYTop.TRK_FLAG = Glob_Si_id_y_Top
eASTROGAMv1GridYTop.STRIP_ID = Glob_Strip_id_y_Top
eASTROGAMv1GridYTop.YPOS = Glob_pos_y_Top
eASTROGAMv1GridYTop.ZPOS = Glob_z_y_Top
eASTROGAMv1GridYTop.E_DEP = Glob_energy_dep_y_Top
eASTROGAMv1GridYTop.PAIR_FLAG = Glob_pair_flag_y_Top

HDR_YGRID_Top = ['Creator          = Valentina Fioretti', $
                 'ASTROGAM release    = V3.0']

MWRFITS, eASTROGAMv1GridYTop, './conf/ARCH.YSTRIP.TOP.eASTROGAMV1.0.TRACKER.FITS', HDR_YGRID_Top, /CREATE

print, '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%'
print, '% Output FITS files with X and Y strip positions'
print, '% - ARCH.XSTRIP.TOP.ASTROGAMV3.0.TRACKER.FITS'
print, '% - ARCH.YSTRIP.TOP.ASTROGAMV3.0.TRACKER.FITS'

print, '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%'
print, '% GPS Set-up for the point source position:'
print, '% - theta [deg.]:', theta_deg_point
print, '% - phi [deg.]:', phi_deg_point
print, '% - source height [cm]:', h_s
print, '% ----------------------------------------------'

; tracker height
h_t = z_end/10. ; cm

; source height respect to tracker
h_r = h_s - h_t

; source distance from (0,0)
radius = h_r*tan(theta_point)
x_s = ((cos(phi_point))*radius)
y_s = ((sin(phi_point))*radius)


P_x = -sin(theta_point)*cos(phi_point)
P_y = -sin(theta_point)*sin(phi_point)
P_z = -cos(theta_point)

print, '% Point source position:'
print, '% - X [cm]:', x_s
print, '% - Y [cm]:', y_s
print, '% - Z [cm]:', h_s
print, '% Point Source direction:'
print, '% - P_x:', P_x
print, '% - P_y:', P_y
print, '% - P_z:', P_z
print, '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%'


; Plane center distance from (0,0)
radius_plane = h_r*tan(theta_plane)

; Plane center
c_x_plane = ((cos(phi_plane))*radius_plane)
c_y_plane = ((sin(phi_plane))*radius_plane)
halfx_plane = Tray_side/20.
halfy_plane = Tray_side/20.

; Plane Momenta

P_x = -sin(theta_plane)*cos(phi_plane)
P_y = -sin(theta_plane)*sin(phi_plane)
P_z = -cos(theta_plane)

print, '% Plane (square) center position:'
print, '% - X [cm]:', c_x_plane
print, '% - Y [cm]:', c_y_plane
print, '% - Z [cm]:', h_s
print, '% Plane (square) side position:'
print, '% - Half X [cm]:', halfx_plane
print, '% - Half Y [cm]:', halfy_plane
print, '% Plane Source direction:'
print, '% - P_x:', P_x
print, '% - P_y:', P_y
print, '% - P_z:', P_z
print, '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%'

; Polarimetry Momenta

P_x_pol = sin(theta_pol_global)*cos(phi_pol_global)
P_y_pol = sin(theta_pol_global)*sin(phi_pol_global)
P_z_pol = cos(theta_pol_global)

print, '% Polarimetry Momenta:'
print, '% - P_x:', P_x_pol
print, '% - P_y:', P_y_pol
print, '% - P_z:', P_z_pol
print, '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%'

end
