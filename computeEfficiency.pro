; computeEfficiency
; specific tool to check the attenuation efficiency without compton


pro computeEfficiency

N_in = 100000.

filenamefits_raw = '/scratch/astrogam/eASTROGAM/eASTROGAMSimAnalysis/eASTROGAMV1.1/Point/theta30/PixelRepli/ASTROMEV/MONO/10MeV/100000ph/OnlyTracker/15keV/G4.RAW.eASTROGAMV1.1.ASTROMEV.MONO.PIXEL.REPLI.Point.100000ph.10MeV.30.225.all.fits'
struct_raw_conv = mrdfits(filenamefits_raw,$
  1, $
  structyp = 'raw_conv', $
  /unsigned)

rawData_event_id = struct_raw_conv.EVT_ID
rawData_tray_id = struct_raw_conv.TRAY_ID
rawData_plane_id = struct_raw_conv.PLANE_ID
rawData_Strip_id_x = struct_raw_conv.STRIP_ID_X
rawData_Strip_id_y = struct_raw_conv.STRIP_ID_Y
rawData_energy_dep = struct_raw_conv.E_DEP

n_events = 1
for jrow=0l, n_elements(rawData_event_id)-2 do begin
  if (rawData_event_id[jrow+1] NE rawData_event_id[jrow]) then begin
    n_events = n_events + 1
  endif
endfor

err_n_events = sqrt(n_events)
sim_eff = double(n_events)/N_in
err_sim_eff = double(err_n_events)/N_in
mu_tot = 0.02462
mu_compton = 0.01536
rho_si = 2.33
t = (0.05*56.)/cos((!PI/180.)*30.)

real_eff = 1. - exp(-(mu_tot-mu_compton)*rho_si*t)

print, 'Simulated efficiency [%]: ', sim_eff*100., ' +/- ', err_sim_eff*100.
print, 'Real efficiency [%]: ', real_eff*100.

end
