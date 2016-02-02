; eASTROGAM_gpssource_test.pro - Description
; ---------------------------------------------------------------------------------
; Processing the BoGEMMS eASTROGAM simulation in order to test the input energy distribution:
; ---------------------------------------------------------------------------------
; Output:
; - Plot of the input particle energy spectrum
; ---------------------------------------------------------------------------------
; copyright            : (C) 2016 Valentina Fioretti
; email                : fioretti@iasfbo.inaf.it
; ----------------------------------------------
; Usage:
; eASTROGAM_gpssource_test
; ---------------------------------------------------------------------------------
; Notes:
; 


pro eASTROGAM_gpssource_test


; Variables initialization
N_in = 0UL            ;--> Number of emitted photons
part_type = ''       ; particle type
n_fits = 0           ;--> Number of FITS files produced by the simulation

astrogam_version = ''
bogemms_tag = ''
sim_type = 0
py_list = 0
ene_range = 0
ene_dis = ''
ene_type = 0.
ene_min = 0
ene_max = 0
ang_type = ''
theta_type = 0
phi_type = 0
source_g = 0
ene_min = 0
ene_max = 0
cal_flag = 0
passive_flag = 0
energy_thresh = 0

read, astrogam_version, PROMPT='% - Enter eASTROGAM release (e.g. V1.0):'
read, bogemms_tag, PROMPT='% - Enter BoGEMMS release (e.g. 201):'

if (astrogam_version EQ 'V1.0') then begin
  astrogam_tag = '01'
endif

sim_tag = 'eAST'+bogemms_tag+astrogam_tag+'0101'

read, sim_type, PROMPT='% - Enter simulation type [0 = Mono, 1 = Range, 2 = Chen, 3: Vela, 4: Crab, 4: G400]:'
read, py_list, PROMPT='% - Enter the Physics List [0 = QGSP_BERT_EMV, 100 = ARGO, 300 = FERMI, 400 = ASTROMEV]:'
read, N_in, PROMPT='% - Enter the number of emitted particles:'
read, part_type, PROMPT='% - Enter the particle type [ph = photons, mu = muons, g = geantino, p = proton, el = electron]:'
read, n_fits, PROMPT='% - Enter number of FITS files:'
read, ene_range, PROMPT='% - Enter energy distribution [0 = MONO, 1 = POW, 2 = EXP, 3 = LIN]:'


if (ene_range EQ 0) then begin
  ene_dis = 'MONO'
  read, ene_type, PROMPT='% - Enter energy [MeV]:'
  if (ene_type GE 1) then ene_type = strtrim(string(long(ene_type)),1)
  if (ene_type LT 1) then ene_type = STRMID(STRTRIM(STRING(ene_type),1),0,5)
  if (size(ene_min, /TYPE) NE 2) then begin
    nstring = strlen(ene_type)
    ene_type_notzero = ene_type
    flag = 1
    for ichar_reverse=0, nstring-1 do begin
      ichar = (nstring-1) - ichar_reverse
      if ((strmid(ene_type, ichar, 1) EQ '0') or (strmid(ene_type, ichar, 1) EQ '.')) then begin
        if (flag EQ 1) then ene_type_notzero = STRMID(ene_type_notzero, 0, ichar)
      endif else begin
        flag = 0
      endelse
    endfor
    ene_type = ene_type_notzero
  endif
endif
if (ene_range EQ 1) then begin
  ene_dis = 'POW'
  read, ene_min, PROMPT='% - Enter miminum energy [MeV]:'
  read, ene_max, PROMPT='% - Enter maximum energy [MeV]:'

  ene_min_string = strtrim(string(ene_min),1)
  if (size(ene_min, /TYPE) NE 2) then begin
    nstring = strlen(ene_min_string)
    ene_min_string_notzero = ene_min_string
    flag = 1
    for ichar_reverse=0, nstring-1 do begin
      ichar = (nstring-1) - ichar_reverse
      if ((strmid(ene_min_string, ichar, 1) EQ '0') or (strmid(ene_min_string, ichar, 1) EQ '.')) then begin
        if (flag EQ 1) then ene_min_string_notzero = STRMID(ene_min_string_notzero, 0, ichar)
      endif else begin
        flag = 0
      endelse
    endfor
    ene_min_string = ene_min_string_notzero
  endif

  ene_max_string = strtrim(string(ene_max),1)
  if (size(ene_max, /TYPE) NE 2) then begin
    nstring = strlen(ene_max_string)
    ene_max_string_notzero = ene_max_string
    flag = 1
    for ichar_reverse=0, nstring-1 do begin
      ichar = (nstring-1) - ichar_reverse
      if ((strmid(ene_max_string, ichar, 1) EQ '0') or (strmid(ene_max_string, ichar, 1) EQ '.')) then begin
        if (flag EQ 1) then ene_max_string_notzero = STRMID(ene_max_string_notzero, 0, ichar)
      endif else begin
        flag = 0
      endelse
    endfor
    ene_max_string = ene_max_string_notzero
  endif

  ene_type = ene_min_string+'.'+ene_max_string
endif
if (ene_range EQ 2) then begin
  ene_dis = 'EXP'
  read, ene_min, PROMPT='% - Enter miminum energy [MeV]:'
  read, ene_max, PROMPT='% - Enter maximum energy [MeV]:'

  ene_min_string = strtrim(string(ene_min),1)
  if (size(ene_min_string, /TYPE) NE 2) then begin
    nstring = strlen(ene_min_string)
    ene_min_string_notzero = ene_min_string
    flag = 1
    for ichar_reverse=0, nstring-1 do begin
      ichar = (nstring-1) - ichar_reverse
      if ((strmid(ene_min_string, ichar, 1) EQ '0') or (strmid(ene_min_string, ichar, 1) EQ '.')) then begin
        if (flag EQ 1) then ene_min_string_notzero = STRMID(ene_min_string_notzero, 0, ichar)
      endif else begin
        flag = 0
      endelse
    endfor
    ene_min_string = ene_min_string_notzero
  endif

  ene_max_string = strtrim(string(ene_max),1)
  if (size(ene_max_string, /TYPE) NE 2) then begin
    nstring = strlen(ene_max_string)
    ene_max_string_notzero = ene_max_string
    flag = 1
    for ichar_reverse=0, nstring-1 do begin
      ichar = (nstring-1) - ichar_reverse
      if ((strmid(ene_max_string, ichar, 1) EQ '0') or (strmid(ene_max_string, ichar, 1) EQ '.')) then begin
        if (flag EQ 1) then ene_max_string_notzero = STRMID(ene_max_string_notzero, 0, ichar)
      endif else begin
        flag = 0
      endelse
    endfor
    ene_max_string = ene_max_string_notzero
  endif
  ene_type = ene_min_string+'.'+ene_max_string
endif
if (ene_range EQ 3) then begin
  ene_dis = 'LIN'
  read, ene_min, PROMPT='% - Enter miminum energy [MeV]:'
  read, ene_max, PROMPT='% - Enter maximum energy [MeV]:'
  
  ene_min_string = strtrim(string(ene_min),1)
  if (size(ene_min_string, /TYPE) NE 2) then begin
    nstring = strlen(ene_min_string)
    ene_min_string_notzero = ene_min_string
    flag = 1
    for ichar_reverse=0, nstring-1 do begin
      ichar = (nstring-1) - ichar_reverse
      if ((strmid(ene_min_string, ichar, 1) EQ '0') or (strmid(ene_min_string, ichar, 1) EQ '.')) then begin
        if (flag EQ 1) then ene_min_string_notzero = STRMID(ene_min_string_notzero, 0, ichar)
      endif else begin
        flag = 0
      endelse
    endfor
    ene_min_string = ene_min_string_notzero
  endif

  ene_max_string = strtrim(string(ene_max),1)
  if (size(ene_max_string, /TYPE) NE 2) then begin
    nstring = strlen(ene_max_string)
    ene_max_string_notzero = ene_max_string
    flag = 1
    for ichar_reverse=0, nstring-1 do begin
      ichar = (nstring-1) - ichar_reverse
      if ((strmid(ene_max_string, ichar, 1) EQ '0') or (strmid(ene_max_string, ichar, 1) EQ '.')) then begin
        if (flag EQ 1) then ene_max_string_notzero = STRMID(ene_max_string_notzero, 0, ichar)
      endif else begin
        flag = 0
      endelse
    endfor
    ene_max_string = ene_max_string_notzero
  endif
  ene_type = ene_min_string+'.'+ene_max_string
endif

read, ang_type, PROMPT='% - Enter the angular distribution [e.g. UNI, ISO]:'
read, theta_type, PROMPT='% - Enter theta:'
read, phi_type, PROMPT='% - Enter phi:'
read, source_g, PROMPT='% - Enter source geometry [0 = Point, 1 = Plane]:'

if (py_list EQ 0) then begin
   py_dir = 'QGSP_BERT_EMV'
   py_name = 'QGSP_BERT_EMV'
endif
if (py_list EQ 100) then begin
   py_dir = '100List'
   py_name = '100List'
endif
if (py_list EQ 300) then begin
   py_dir = '300List'
   py_name = '300List'
endif
if (py_list EQ 400) then begin
   py_dir = 'ASTROMEV'
   py_name = 'ASTROMEV'
endif

if (sim_type EQ 0) then begin
   sim_name = 'MONO'
endif
if (sim_type EQ 1) then begin
  sim_name = 'RANGE'
endif
if (sim_type EQ 2) then begin
   sim_name = 'CHEN'
endif
if (sim_type EQ 3) then begin
   sim_name = 'VELA'
endif
if (sim_type EQ 4) then begin
   sim_name = 'CRAB'
endif
if (sim_type EQ 5) then begin
   sim_name = 'G400'
endif

if (source_g EQ 0) then begin
 sdir = '/Point'
 sname = 'Point'
endif
if (source_g EQ 1) then begin
 sdir = '/Plane'
 sname = 'Plane'
endif

read, isStrip, PROMPT='% - Strip/Pixels activated?:'
read, repli, PROMPT='% - Strips/Pixels replicated?:'

read, cal_flag, PROMPT='% - Is Cal present? [0 = false, 1 = true]:'
read, ac_flag, PROMPT='% - Is AC present? [0 = false, 1 = true]:'

if ((cal_flag EQ 0) AND (ac_flag EQ 0))  then dir_cal = '/OnlyTracker'
if ((cal_flag EQ 1) AND (ac_flag EQ 0)) then dir_cal = '/onlyCAL'
if ((cal_flag EQ 0) AND (ac_flag EQ 1)) then dir_cal = '/onlyAC'
if ((cal_flag EQ 1) AND (ac_flag EQ 1)) then dir_cal = ''

read, passive_flag, PROMPT='% - Is Passive present? [0 = false, 1 = true]:'
if (passive_flag EQ 0) then dir_passive = ''
if (passive_flag EQ 1) then dir_passive = '/WithPassive'
read, energy_thresh, PROMPT='% - Enter energy threshold [keV]:'


if (astrogam_version EQ 'V1.0') then begin
    if (isStrip EQ 0) then stripDir = 'NoPixel/'
    if ((isStrip EQ 1) AND (repli EQ 0)) then stripDir = 'PixelNoRepli/'
    if ((isStrip EQ 1) AND (repli EQ 1)) then stripDir = 'PixelRepli/'
    
    if (isStrip EQ 0) then stripname = 'NOPIXEL'
    if ((isStrip EQ 1) AND (repli EQ 0)) then stripname = 'PIXEL'
    if ((isStrip EQ 1) AND (repli EQ 1)) then stripname = 'PIXEL.REPLI'
endif 

; setting specific agile version variables 
if (astrogam_version EQ 'V1.0') then begin
    ; --------> volume ID
    tracker_top_vol_start = 1090000
    tracker_bottom_vol_start = 1000000
    tracker_top_bot_diff = 90000
    
    cal_vol_start = 50000
    cal_vol_end = 64399

    ac_vol_start = 301
    ac_vol_end = 350
 
    panel_S = [301, 302, 303]
    panel_D = [311, 312, 313]
    panel_F = [321, 322, 323]
    panel_B = [331, 332, 333]
    panel_top = 340
        
    ; --------> design
    N_tray = 56l
    N_plane = N_tray*1
    N_strip = 3840l
    tray_side = 92.16 ;cm
    strip_side = Tray_side/N_strip

    
    ; --------> processing
    ; accoppiamento capacitivo
    ;acap = [0.035, 0.045, 0.095, 0.115, 0.38, 1., 0.38, 0.115, 0.095, 0.045, 0.035]  
    ; tracker energy threshold (0.25 MIP)
    E_th = float(energy_thresh)  ; keV 
    
    E_th_cal = 30. ; keV
  
    
endif 

run_path = GETENV('BGRUNS')

filepath = run_path + '/eASTROGAM'+astrogam_version+sdir+'/theta'+strtrim(string(theta_type),1)+'/'+stripDir+py_dir+dir_cal+dir_passive+'/'+ene_type+'MeV.'+sim_name+'.'+strtrim(string(theta_type),1)+'theta.'+strtrim(string(N_in),1)+part_type
print, 'eASTROGAM simulation path: ', filepath

ene_in = -1.
for ifile=0, n_fits-1 do begin
    print, 'Reading the BoGEMMS file.....', ifile+1

    filename = filepath+'/inout.'+strtrim(string(ifile), 1)+'.fits.gz'
    struct = mrdfits(filename,$ 
                     1, $
                     structyp = 'eastrogam inout', $
                     /unsigned)

    for k=0l, n_elements(struct)-1l do begin 
      if (k EQ 0) then begin
          ene_in = [ene_in, struct(k).EVT_KE]
      endif else begin
        if ((struct(k).VOLUME_ID EQ 0) AND (struct(k).DIRECTION EQ 1) AND (struct(k-1).EVT_ID NE struct(k).EVT_ID)) then begin
          ene_in = [ene_in, struct(k).EVT_KE]
        endif
      endelse
    endfor
    
    
endfor
 
ene_in = ene_in[1:*]
ene_in = ene_in/1000.  ; from keV to MeV

if (sim_type EQ 1) then begin
 Emin_sim = 100.
 Emax_sim = 141.
 deltaE_sim = Emax_sim - Emin_sim
endif
if ((sim_type EQ 2) OR (sim_type EQ 3)) then begin
 Emin_sim = ene_min
 Emax_sim = ene_max
 deltaE_sim = Emax_sim - Emin_sim
endif


if not keyword_set(nopsp) then begin
  CGPS_Open, /encapsulated, FILENAME='eASTROGAM_gps_test_'+sim_name+'.eps', $
  FONT=0, CHARSIZE=1., nomatch=1, xsize=9., yoffset=9.6, ysize=7 
  bits_per_pixel=8
endif
RED   = [0, .5, 1, 0, 0, 1, 1, 0]
GREEN = [0, .5, 0, 1, 0, 1, 0, 1]
BLUE  = [0, 1., 0, 0, 1, 0, 1, 1]
TVLCT, 255 * RED, 255 * GREEN, 255 * BLUE

xt = 'Energy [MeV]' 
yt = 'phot. MeV!A-1!N' 
xr = [Emin_sim - 10, Emax_sim + 10]
yr = [100, 5000]

plot, /ylog,/xlog,[1], xtitle=xt, ytitle=yt, xrange=xr, yrange=yr, xstyle=1, ystyle=1,xmargin=[10,3], $
    xcharsize=1, ycharsize=1,charsize = 1, charthick=1.5,$
    title= 'AGILESim - '+ene_type+' MeV - '+sim_name, /nodata
    
;-------> Ploting!
bin_histo_log = 0.01
log_E_in = alog10(ene_in)
plothist, log_E_in,log_Earr_in, N_in_sim, bin=bin_histo_log, /noplot

log_Earr_in_plot = [log_Earr_in(0)-bin_histo_log/2., log_Earr_in, log_Earr_in[n_elements(log_Earr_in)-1] + bin_histo_log/2.]
log_Earr_in = [log_Earr_in(0)-bin_histo_log/2., log_Earr_in + bin_histo_log/2.]
Earr_in = 10.^(log_Earr_in)
Earr_in_plot = 10.^(log_Earr_in_plot)
bin_histo = dblarr(n_elements(Earr_in)-1)
for i=0l, n_elements(bin_histo) -1 do begin
  bin_histo(i) = Earr_in(i+1) - Earr_in(i)
endfor
rate_in = dblarr(n_elements(N_in_sim))
for i=0l, n_elements(rate_in)-1 do begin
  rate_in(i) = N_in_sim(i)/(bin_histo(i))
endfor

;oplot, [Earr_in,Earr_in[n_elements(Earr_in)-1]+bin_histo(n_elements(bin_histo)-1)/2.], $
;       [rate_in[0],rate_in,rate_in[n_elements(rate_in)-1]], psym = 10, thick = 5, color =4
oplot, Earr_in_plot, $
       [rate_in[0],rate_in,rate_in[n_elements(rate_in)-1]], psym = 10, thick = 5, color =4
       
err_rate_in = dblarr(n_elements(N_in_sim))
for i=0l, n_elements(N_in_sim)-1 do begin        
  err_rate_in(i) = (sqrt(N_in_sim(i)))/(bin_histo(i))
endfor
oploterror, Earr_in_plot[1:n_elements(Earr_in_plot)-2], rate_in, err_rate_in, $
       psym = 3, thick = 2, /nohat, errcolor = 4       

oplot, [Earr_in_plot[0], Earr_in_plot[0]], [yr[0], rate_in[0]],thick = 5, color=4
oplot, [Earr_in_plot[n_elements(Earr_in_plot)-1], Earr_in_plot[n_elements(Earr_in_plot)-1]], $
[yr[0], rate_in[n_elements(rate_in)-1]],thick = 5, color=4

if (sim_type EQ 1) then begin
  N_in_model = dblarr(n_elements(N_in_sim))
  rate_in_model = dblarr(n_elements(N_in_sim))
  for i=0l, n_elements(N_in_sim)-1 do begin
    N_in_model[i] = N_in*(bin_histo(i)/deltaE_sim)
    rate_in_model[i] = N_in_model[i]/(bin_histo(i))
  endfor
endif
if (sim_type EQ 2) then begin
  ph_index = 1.66
  N_in_model = dblarr(n_elements(N_in_sim))
  rate_in_model = dblarr(n_elements(N_in_sim))
  intE_tot = ((Emax_sim^(1 - ph_index))/(1 - ph_index)) - ((Emin_sim^(1 - ph_index))/(1 - ph_index))
  norm = N_in/intE_tot
  for i=0l, n_elements(N_in_sim)-1 do begin
    E_start = Earr_in[i]
    E_end = Earr_in[i+1]
    intE_delta = ((E_end^(1 - ph_index))/(1 - ph_index)) - ((E_start^(1 - ph_index))/(1 - ph_index))
    prop = intE_delta/intE_tot
    N_in_model[i] = N_in*prop
    rate_in_model[i] = N_in_model[i]/(bin_histo(i))
  endfor
endif
if (sim_type EQ 3) then begin
  ph_index = 2.1
  N_in_model = dblarr(n_elements(N_in_sim))
  rate_in_model = dblarr(n_elements(N_in_sim))
  intE_tot = ((Emax_sim^(1 - ph_index))/(1 - ph_index)) - ((Emin_sim^(1 - ph_index))/(1 - ph_index))
  norm = N_in/intE_tot
  for i=0l, n_elements(N_in_sim)-1 do begin
    E_start = Earr_in[i]
    E_end = Earr_in[i+1]
    intE_delta = ((E_end^(1 - ph_index))/(1 - ph_index)) - ((E_start^(1 - ph_index))/(1 - ph_index))
    prop = intE_delta/intE_tot
    N_in_model[i] = N_in*prop
    rate_in_model[i] = N_in_model[i]/(bin_histo(i))
  endfor
endif
oplot, Earr_in[1:*], rate_in_model, thick = 3, linestyle=2

lines = [0, 2]
al_legend,['eASTROGAMSim', 'Model'], $
spacing=1.4, thick=2,/top, textcolor=[4,0], linestyle = lines, /right,box=0, outline_color=0, charsize=1., charthick=2.


print, Earr_in, N_in_sim

CGPS_Close, /PNG
end