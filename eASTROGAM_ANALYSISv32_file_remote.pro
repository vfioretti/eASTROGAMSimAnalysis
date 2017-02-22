; eASTROGAM_ANALYSISv32_file_remote.pro - Description
; ---------------------------------------------------------------------------------
; Processing the THELSIM eASTROGAM simulation:
; - Tracker
; - AC
; - Calorimeter
; ---------------------------------------------------------------------------------
; Output:
; - all files are created in a self-descripted subdirectory of the current directory. If the directory is not present it is created by the IDL script.
; ---------> FITS files
; - G4.RAW.eASTROGAM<version>.<phys>List.<sim_type>.<strip>.<point>.<n_in>ph.<energy>MeV.<theta>.<phi>.<file>.fits
; - L0.5.eASTROGAM<version>.<phys>List.<sim_type>.<strip>.<point>.<n_in>ph.<energy>MeV.<theta>.<phi>.<file>.fits
; - G4.AC.eASTROGAM<version>.<phys>List.<sim_type>.<strip>.<point>.<n_in>ph.<energy>MeV.<theta>.<phi>.<file>.fits
; - G4.CAL.eASTROGAM<version>.<phys>List.<sim_type>.<strip>.<point>.<n_in>ph.<energy>MeV.<theta>.<phi>.<file>.fits
; ---------> ASCII files
; - to be used as input to AA kalman 
; ----------------------------------------------------------------------------------
; copyright            : (C) 2016 Valentina Fioretti
; email                : fioretti@iasfbo.inaf.it
; ----------------------------------------------
; Usage:
; eASTROGAM_ANALYSISv3_file
; ---------------------------------------------------------------------------------
; Notes:
; Each THELSIM FITS files individually processed


pro eASTROGAM_ANALYSISv32_file_remote, $
    astrogam_version, $     ; % - Enter eASTROGAM release (e.g. V1.0):
    bogemms_tag, $          ; % - Enter BoGEMMS release (e.g. 211):
    sim_type, $             ; % - Enter simulation type [0 = Mono, 1 = Range, 2 = Chen, 3: Vela, 4: Crab, 4: G400]:
    py_list, $              ; % - Enter the Physics List [0 = QGSP_BERT_EMV, 100 = ARGO, 300 = FERMI, 400 = ASTROMEV]:
    N_in, $                 ; % - Enter the number of emitted particles:
    part_type, $            ; % - Enter the particle type [ph = photons, mu = muons, g = geantino, p = proton, el = electron]:
    n_fits, $               ; % - Enter number of FITS files:
    ene_range, $            ; % - Enter energy distribution [0 = MONO, 1 = POW, 2 = EXP, 3 = LIN]:
    ene_min, $              ; % - Enter miminum energy [MeV]:
    ene_max, $              ; % - Enter maximum energy [MeV]:
    ang_type, $             ; % - Enter the angular distribution [e.g. UNI, ISO]:
    theta_type, $           ; % - Enter theta:
    phi_type, $             ; % - Enter phi:
    pol_type, $             ; % - Is the source polarized? [0 = false, 1 = true]: 
    pol_angle, $            ; % - Enter Polarization angle:
    source_g, $             ; % - Enter source geometry [0 = Point, 1 = Plane]:
    isStrip, $              ; % - Strip/Pixels activated?:
    repli, $                ; % - Strips/Pixels replicated?:
    cal_flag, $             ; % - Is Cal present? [0 = false, 1 = true]:
    ac_flag, $              ; % - Is AC present? [0 = false, 1 = true]:
    passive_flag, $         ; % - Is Passive present? [0 = false, 1 = true]:
    energy_thresh           ; % - Enter energy threshold [keV]:


if (astrogam_version EQ 'V1.0') then begin
  astrogam_tag = '01'
  sim_tag = 'eAST'+bogemms_tag+astrogam_tag+'0102'
endif
if (astrogam_version EQ 'V1.1') then begin
  astrogam_tag = '11'
  sim_tag = 'eAST'+bogemms_tag+astrogam_tag+'2021'
endif

if (ene_range EQ 0) then begin
  ene_dis = 'MONO'
  ene_type = ene_min
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

if (pol_type EQ 1) then begin
  pol_string = strtrim(string(pol_angle),1)+'POL.'
endif else begin
  pol_string = ''
endelse

if (source_g EQ 0) then begin
 sdir = '/Point'
 sname = 'Point'
endif
if (source_g EQ 1) then begin
 sdir = '/Plane'
 sname = 'Plane'
endif


if ((cal_flag EQ 0) AND (ac_flag EQ 0))  then dir_cal = '/OnlyTracker'
if ((cal_flag EQ 1) AND (ac_flag EQ 0)) then dir_cal = '/onlyCAL'
if ((cal_flag EQ 0) AND (ac_flag EQ 1)) then dir_cal = '/onlyAC'
if ((cal_flag EQ 1) AND (ac_flag EQ 1)) then dir_cal = ''

if (passive_flag EQ 0) then dir_passive = ''
if (passive_flag EQ 1) then dir_passive = '/WithPassive'

if ((astrogam_version EQ 'V1.0') or (astrogam_version EQ 'V1.1')) then begin
    if (isStrip EQ 0) then stripDir = 'NoPixel/'
    if ((isStrip EQ 1) AND (repli EQ 0)) then stripDir = 'PixelNoRepli/'
    if ((isStrip EQ 1) AND (repli EQ 1)) then stripDir = 'PixelRepli/'
    
    if (isStrip EQ 0) then stripname = 'NOPIXEL'
    if ((isStrip EQ 1) AND (repli EQ 0)) then stripname = 'PIXEL'
    if ((isStrip EQ 1) AND (repli EQ 1)) then stripname = 'PIXEL.REPLI'
endif 

; setting specific agile version variables
if ((astrogam_version EQ 'V1.0') or (astrogam_version EQ 'V1.1')) then begin
  ; --------> volume ID
  tracker_top_vol_start = 1090000
  tracker_bottom_vol_start = 1000000
  tracker_top_bot_diff = 90000

  if (astrogam_version EQ 'V1.0') then begin
    cal_vol_start = 50000
    cal_vol_end = 58463
  endif
  if (astrogam_version EQ 'V1.1') then begin
    cal_vol_start = 50000
    cal_vol_end = 83855
  endif

  
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

filepath = run_path + '/eASTROGAM'+astrogam_version+sdir+'/theta'+strtrim(string(theta_type),1)+'/'+stripDir+py_dir+dir_cal+dir_passive+'/'+ene_type+'MeV.'+sim_name+'.'+strtrim(string(theta_type),1)+'theta.'+pol_string+strtrim(string(N_in),1)+part_type
print, 'eASTROGAM simulation path: ', filepath

outdir = './eASTROGAM'+astrogam_version+sdir+'/theta'+strtrim(string(theta_type),1)+'/'+stripDir+py_dir+'/'+sim_name+'/'+ene_type+'MeV/'+strtrim(string(N_in),1)+part_type+dir_cal+dir_passive+'/'+strtrim(string(energy_thresh),1)+'keV'
print, 'eASTROGAM outdir path: ', outdir

CheckOutDir = DIR_EXIST( outdir)
if (CheckOutDir EQ 0) then spawn,'mkdir -p ./eASTROGAM'+astrogam_version+sdir+'/theta'+strtrim(string(theta_type),1)+'/'+stripDir+py_dir+'/'+sim_name+'/'+ene_type+'MeV/'+strtrim(string(N_in),1)+part_type+dir_cal+dir_passive+'/'+strtrim(string(energy_thresh),1)+'keV'


for ifile=0, n_fits-1 do begin
  print, 'Reading the THELSIM file.....', ifile+1

  ; Tracker
  event_id = -1l
  vol_id = -1l
  moth_id = -1l
  energy_dep = -1.

  ent_x = -1.
  ent_y = -1.
  ent_z = -1.
  exit_x = -1.
  exit_y = -1.
  exit_z = -1.

  theta_ent = -1.
  phi_ent = -1.

  theta_exit = -1.
  phi_exit = -1.

  part_id = -1l
  child_id = -1l
  proc_id = -1l
  
  gtime_ent = -1.

  ; Calorimeter
  event_id_cal = -1l
  vol_id_cal = -1l
  moth_id_cal = -1l
  energy_dep_cal = -1.

  ent_x_cal = -1.
  ent_y_cal = -1.
  ent_z_cal = -1.
  exit_x_cal = -1.
  exit_y_cal = -1.
  exit_z_cal = -1.

  theta_ent_cal = -1.
  phi_ent_cal = -1.

  theta_exit_cal = -1.
  phi_exit_cal = -1.

  part_id_cal = -1l
  child_id_cal = -1l
  proc_id_cal = -1l
  
  gtime_ent_cal = -1.

  ; AC
  event_id_ac = -1l
  vol_id_ac = -1l
  moth_id_ac = -1l
  energy_dep_ac = -1.

  ent_x_ac = -1.
  ent_y_ac = -1.
  ent_z_ac = -1.
  exit_x_ac = -1.
  exit_y_ac = -1.
  exit_z_ac = -1.

  theta_ent_ac = -1.
  phi_ent_ac = -1.

  theta_exit_ac = -1.
  phi_exit_ac = -1.

  part_id_ac = -1l
  child_id_ac = -1l
  proc_id_ac = -1l
  
  gtime_ent_ac = -1.

  filename = filepath+'/xyz.'+strtrim(string(ifile), 1)+'.fits.gz'
  struct = mrdfits(filename,$
    1, $
    structyp = 'astrogam', $
    /unsigned)

  for k=0l, n_elements(struct)-1l do begin

    ; Reading the tracker (events with E > 0)
    if ((struct(k).VOLUME_ID GE tracker_bottom_vol_start) or (struct(k).MOTHER_ID GE tracker_bottom_vol_start)) then begin
      ;if (struct(k).MOTHER_ID GE tracker_bottom_vol_start) then begin
      if (part_type EQ 'g') then begin
        struct(k).E_DEP = 100.
        event_id = [event_id, struct(k).EVT_ID]
        vol_id = [vol_id, struct(k).VOLUME_ID]
        moth_id = [moth_id, struct(k).MOTHER_ID]
        energy_dep = [energy_dep, struct(k).E_DEP]

        ent_x = [ent_x, struct(k).X_ENT]
        ent_y = [ent_y, struct(k).Y_ENT]
        ent_z = [ent_z, struct(k).Z_ENT]
        exit_x = [exit_x, struct(k).X_EXIT]
        exit_y = [exit_y, struct(k).Y_EXIT]
        exit_z = [exit_z, struct(k).Z_EXIT]

        theta_ent = [theta_ent, (180./!PI)*acos(-(struct(k).MDZ_ENT))]
        phi_ent = [phi_ent, (180./!PI)*atan((struct(k).MDY_ENT)/(struct(k).MDX_ENT))]

        theta_exit = [theta_exit, (180./!PI)*acos(-(struct(k).MDZ_EXIT))]
        phi_exit = [phi_exit, (180./!PI)*atan((struct(k).MDY_EXIT)/(struct(k).MDX_EXIT))]

        part_id = [part_id, struct(k).PARTICLE_ID]
        child_id = [child_id, struct(k).PARENT_TRK_ID]
        proc_id = [proc_id, struct(k).PROCESS_ID]

        gtime_ent = [gtime_ent, struct(k).GTIME_ENT]

      endif else begin
        if (struct(k).E_DEP GT 0.d) then begin

          event_id = [event_id, struct(k).EVT_ID]
          vol_id = [vol_id, struct(k).VOLUME_ID]
          moth_id = [moth_id, struct(k).MOTHER_ID]
          energy_dep = [energy_dep, struct(k).E_DEP]

          ent_x = [ent_x, struct(k).X_ENT]
          ent_y = [ent_y, struct(k).Y_ENT]
          ent_z = [ent_z, struct(k).Z_ENT]
          exit_x = [exit_x, struct(k).X_EXIT]
          exit_y = [exit_y, struct(k).Y_EXIT]
          exit_z = [exit_z, struct(k).Z_EXIT]

          theta_ent = [theta_ent, (180./!PI)*acos(-(struct(k).MDZ_ENT))]
          phi_ent = [phi_ent, (180./!PI)*atan((struct(k).MDY_ENT)/(struct(k).MDX_ENT))]

          theta_exit = [theta_exit, (180./!PI)*acos(-(struct(k).MDZ_EXIT))]
          phi_exit = [phi_exit, (180./!PI)*atan((struct(k).MDY_EXIT)/(struct(k).MDX_EXIT))]

          part_id = [part_id, struct(k).PARTICLE_ID]
          child_id = [child_id, struct(k).PARENT_TRK_ID]
          proc_id = [proc_id, struct(k).PROCESS_ID]

          gtime_ent = [gtime_ent, struct(k).GTIME_ENT]

        endif
      endelse
    endif
    ; Reading the calorimeter
    if (cal_flag EQ 1) then begin
      if ((struct(k).VOLUME_ID GE cal_vol_start) AND (struct(k).VOLUME_ID LE cal_vol_end)) then begin
        if (part_type EQ 'g') then begin
          event_id_cal = [event_id_cal, struct(k).EVT_ID]
          vol_id_cal = [vol_id_cal, struct(k).VOLUME_ID]
          moth_id_cal = [moth_id_cal, struct(k).MOTHER_ID]
          energy_dep_cal = [energy_dep_cal, struct(k).E_DEP]

          ent_x_cal = [ent_x_cal, struct(k).X_ENT]
          ent_y_cal = [ent_y_cal, struct(k).Y_ENT]
          ent_z_cal = [ent_z_cal, struct(k).Z_ENT]
          exit_x_cal = [exit_x_cal, struct(k).X_EXIT]
          exit_y_cal = [exit_y_cal, struct(k).Y_EXIT]
          exit_z_cal = [exit_z_cal, struct(k).Z_EXIT]

          theta_ent_cal = [theta_ent_cal, (180./!PI)*acos(-(struct(k).MDZ_ENT))]
          phi_ent_cal = [phi_ent_cal, (180./!PI)*atan((struct(k).MDY_ENT)/(struct(k).MDX_ENT))]

          theta_exit_cal = [theta_exit_cal, (180./!PI)*acos(-(struct(k).MDZ_EXIT))]
          phi_exit_cal = [phi_exit_cal, (180./!PI)*atan((struct(k).MDY_EXIT)/(struct(k).MDX_EXIT))]

          part_id_cal = [part_id_cal, struct(k).PARTICLE_ID]
          child_id_cal = [child_id_cal, struct(k).PARENT_TRK_ID]
          proc_id_cal = [proc_id_cal, struct(k).PROCESS_ID]
          
          gtime_ent_cal = [gtime_ent_cal, struct(k).GTIME_ENT]

        endif else begin
          if (struct(k).E_DEP GT 0.d) then begin
            event_id_cal = [event_id_cal, struct(k).EVT_ID]
            vol_id_cal = [vol_id_cal, struct(k).VOLUME_ID]
            moth_id_cal = [moth_id_cal, struct(k).MOTHER_ID]
            energy_dep_cal = [energy_dep_cal, struct(k).E_DEP]

            ent_x_cal = [ent_x_cal, struct(k).X_ENT]
            ent_y_cal = [ent_y_cal, struct(k).Y_ENT]
            ent_z_cal = [ent_z_cal, struct(k).Z_ENT]
            exit_x_cal = [exit_x_cal, struct(k).X_EXIT]
            exit_y_cal = [exit_y_cal, struct(k).Y_EXIT]
            exit_z_cal = [exit_z_cal, struct(k).Z_EXIT]

            theta_ent_cal = [theta_ent_cal, (180./!PI)*acos(-(struct(k).MDZ_ENT))]
            phi_ent_cal = [phi_ent_cal, (180./!PI)*atan((struct(k).MDY_ENT)/(struct(k).MDX_ENT))]

            theta_exit_cal = [theta_exit_cal, (180./!PI)*acos(-(struct(k).MDZ_EXIT))]
            phi_exit_cal = [phi_exit_cal, (180./!PI)*atan((struct(k).MDY_EXIT)/(struct(k).MDX_EXIT))]

            part_id_cal = [part_id_cal, struct(k).PARTICLE_ID]
            child_id_cal = [child_id_cal, struct(k).PARENT_TRK_ID]
            proc_id_cal = [proc_id_cal, struct(k).PROCESS_ID]

            gtime_ent_cal = [gtime_ent_cal, struct(k).GTIME_ENT]

          endif
        endelse
      endif
    endif
    if ((struct(k).VOLUME_ID GE ac_vol_start) AND (struct(k).VOLUME_ID LE ac_vol_end)) then begin
      if (part_type EQ 'g') then begin
        event_id_ac = [event_id_ac, struct(k).EVT_ID]
        vol_id_ac = [vol_id_ac, struct(k).VOLUME_ID]
        if (isStrip EQ 1) then moth_id_ac = [moth_id_ac, struct(k).MOTHER_ID] else moth_id_ac = [moth_id_ac, 0]
        energy_dep_ac = [energy_dep_ac, struct(k).E_DEP]

        ent_x_ac = [ent_x_ac, struct(k).X_ENT]
        ent_y_ac = [ent_y_ac, struct(k).Y_ENT]
        ent_z_ac = [ent_z_ac, struct(k).Z_ENT]
        exit_x_ac = [exit_x_ac, struct(k).X_EXIT]
        exit_y_ac = [exit_y_ac, struct(k).Y_EXIT]
        exit_z_ac = [exit_z_ac, struct(k).Z_EXIT]

        theta_ent_ac = [theta_ent_ac, (180./!PI)*acos(-(struct(k).MDZ_ENT))]
        phi_ent_ac = [phi_ent_ac, (180./!PI)*atan((struct(k).MDY_ENT)/(struct(k).MDX_ENT))]

        theta_exit_ac = [theta_exit_ac, (180./!PI)*acos(-(struct(k).MDZ_EXIT))]
        phi_exit_ac = [phi_exit_ac, (180./!PI)*atan((struct(k).MDY_EXIT)/(struct(k).MDX_EXIT))]

        part_id_ac = [part_id_ac, struct(k).PARTICLE_ID]
        child_id_ac = [child_id_ac, struct(k).PARENT_TRK_ID]
        proc_id_ac = [proc_id_ac, struct(k).PROCESS_ID]

        gtime_ent_ac = [gtime_ent_ac, struct(k).GTIME_ENT]

      endif else begin
        if (struct(k).E_DEP GT 0.d) then begin
          event_id_ac = [event_id_ac, struct(k).EVT_ID]
          vol_id_ac = [vol_id_ac, struct(k).VOLUME_ID]
          if (isStrip EQ 1) then moth_id_ac = [moth_id_ac, struct(k).MOTHER_ID] else moth_id_ac = [moth_id_ac, 0]
          energy_dep_ac = [energy_dep_ac, struct(k).E_DEP]

          ent_x_ac = [ent_x_ac, struct(k).X_ENT]
          ent_y_ac = [ent_y_ac, struct(k).Y_ENT]
          ent_z_ac = [ent_z_ac, struct(k).Z_ENT]
          exit_x_ac = [exit_x_ac, struct(k).X_EXIT]
          exit_y_ac = [exit_y_ac, struct(k).Y_EXIT]
          exit_z_ac = [exit_z_ac, struct(k).Z_EXIT]

          theta_ent_ac = [theta_ent_ac, (180./!PI)*acos(-(struct(k).MDZ_ENT))]
          phi_ent_ac = [phi_ent_ac, (180./!PI)*atan((struct(k).MDY_ENT)/(struct(k).MDX_ENT))]

          theta_exit_ac = [theta_exit_ac, (180./!PI)*acos(-(struct(k).MDZ_EXIT))]
          phi_exit_ac = [phi_exit_ac, (180./!PI)*atan((struct(k).MDY_EXIT)/(struct(k).MDX_EXIT))]

          part_id_ac = [part_id_ac, struct(k).PARTICLE_ID]
          child_id_ac = [child_id_ac, struct(k).PARENT_TRK_ID]
          proc_id_ac = [proc_id_ac, struct(k).PROCESS_ID]
          
          gtime_ent_ac = [gtime_ent_ac, struct(k).GTIME_ENT]

        endif
      endelse
    endif

  endfor

  ; Tracker (removing fake starting value)
  event_id = event_id[1:*]
  vol_id = vol_id[1:*]
  moth_id = moth_id[1:*]
  energy_dep = energy_dep[1:*]

  ent_x = (ent_x[1:*])/10.
  ent_y = (ent_y[1:*])/10.
  ent_z = (ent_z[1:*])/10.
  exit_x = (exit_x[1:*])/10.
  exit_y = (exit_y[1:*])/10.
  exit_z = (exit_z[1:*])/10.


  x_pos = dblarr(n_elements(ent_x))
  y_pos = dblarr(n_elements(ent_x))
  z_pos = dblarr(n_elements(ent_x))

  for j=0l, n_elements(ent_x)-1 do begin
    x_pos(j) = ent_x(j) + ((exit_x(j) - ent_x(j))/2.)
    y_pos(j) = ent_y(j) + ((exit_y(j) - ent_y(j))/2.)
    z_pos(j) = ent_z(j) + ((exit_z(j) - ent_z(j))/2.)
  endfor

  theta_ent = theta_ent[1:*]
  phi_ent = phi_ent[1:*]

  theta_exit = theta_exit[1:*]
  phi_exit = phi_exit[1:*]

  part_id = part_id[1:*]
  child_id = child_id[1:*]
  proc_id = proc_id[1:*]

  gtime_ent = gtime_ent[1:*]

  ; Calorimeter (removing fake starting value)
  if (cal_flag EQ 1) then begin
    event_id_cal = event_id_cal[1:*]
    vol_id_cal = vol_id_cal[1:*]
    moth_id_cal = moth_id_cal[1:*]
    energy_dep_cal = energy_dep_cal[1:*]

    ent_x_cal = (ent_x_cal[1:*])/10.
    ent_y_cal = (ent_y_cal[1:*])/10.
    ent_z_cal = (ent_z_cal[1:*])/10.
    exit_x_cal = (exit_x_cal[1:*])/10.
    exit_y_cal = (exit_y_cal[1:*])/10.
    exit_z_cal = (exit_z_cal[1:*])/10.

    theta_ent_cal = theta_ent_cal[1:*]
    phi_ent_cal = phi_ent_cal[1:*]

    theta_exit_cal = theta_exit_cal[1:*]
    phi_exit_cal = phi_exit_cal[1:*]

    part_id_cal = part_id_cal[1:*]
    child_id_cal = child_id_cal[1:*]
    proc_id_cal = proc_id_cal[1:*]

    gtime_ent_cal = gtime_ent_cal[1:*]
    
  endif

  ; AC (removing fake starting value)
  if (ac_flag EQ 1) then begin
    event_id_ac = event_id_ac[1:*]
    vol_id_ac = vol_id_ac[1:*]
    moth_id_ac = moth_id_ac[1:*]
    energy_dep_ac = energy_dep_ac[1:*]

    ent_x_ac = (ent_x_ac[1:*])/10.
    ent_y_ac = (ent_y_ac[1:*])/10.
    ent_z_ac = (ent_z_ac[1:*])/10.
    exit_x_ac = (exit_x_ac[1:*])/10.
    exit_y_ac = (exit_y_ac[1:*])/10.
    exit_z_ac = (exit_z_ac[1:*])/10.

    theta_ent_ac = theta_ent_ac[1:*]
    phi_ent_ac = phi_ent_ac[1:*]

    theta_exit_ac = theta_exit_ac[1:*]
    phi_exit_ac = phi_exit_ac[1:*]

    part_id_ac = part_id_ac[1:*]
    child_ac = child_id_ac[1:*]
    proc_ac = proc_id_ac[1:*]
    
    gtime_ent_ac = gtime_ent_ac[1:*]

  endif

  ; %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  ;                             Processing the tracker
  ; %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


  if ((astrogam_version EQ 'V1.0') or (astrogam_version EQ 'V1.1')) then begin
    ; From Tracker volume ID to strip and tray ID
    Strip_id_x = intarr(n_elements(vol_id))
    Strip_id_y = intarr(n_elements(vol_id))
    tray_id = intarr(n_elements(vol_id))

    ; Si_id = Si layer flag description:
    ; - 0 = X
    ; - 1 = Y

    ; Conversion from tray ID (starting from bottom) to plane ID (starting from the top)
    plane_id = intarr(n_elements(tray_id))

    for j=0l, n_elements(vol_id)-1 do begin
      if (isStrip EQ 1) then begin  ;--------> PIXEL = 1
        if (repli EQ 1) then begin ;--------> REPLI = 1

          ;Strip_id_x(j) = vol_id(j) mod N_strip
          ;Strip_id_y(j) = vol_id(j)/N_strip
          ;tray_id(j) = moth_id(j)/tracker_bottom_vol_start
          ;invert_tray_id = (N_tray - tray_id(j))+1
          ;plane_id(j) = invert_tray_id

          ;vol_id(j) = Strip_id_y(j)
          ;moth_id(j) = moth_id(j) + Strip_id_x(j)

          Strip_id_y(j) = vol_id(j)
          tray_id(j) = moth_id(j)/tracker_bottom_vol_start
          invert_tray_id = (N_tray - tray_id(j))+1
          vol_id_temp = moth_id(j) - (tracker_bottom_vol_start*tray_id(j) + tracker_top_bot_diff) ; removing 1000000xn_tray + 90000
          Strip_id_x(j) = vol_id_temp
          plane_id(j) = invert_tray_id
        endif
      endif else begin

        Strip_id_y(j) = 0
        tray_id(j) = vol_id(j)/tracker_bottom_vol_start
        invert_tray_id = (N_tray - tray_id(j))+1
        Strip_id_x(j) = 0
        plane_id(j) = invert_tray_id

      endelse
    endfor
  endif

  print, '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%'
  print, '                             Tracker   '
  print, '           Saving the Tracker raw hits (fits and .dat)      '
  print, '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%'



  if ((astrogam_version EQ 'V1.0') or (astrogam_version EQ 'V1.1')) then begin

    CREATE_STRUCT, rawData, 'rawData', ['EVT_ID', 'VOL_ID', 'MOTH_ID', 'TRAY_ID', 'PLANE_ID', 'STRIP_ID_X', 'STRIP_ID_Y', 'E_DEP', 'X_ENT', 'Y_ENT', 'Z_ENT', 'X_EXIT', 'Y_EXIT', 'Z_EXIT', 'PART_ID', 'CHILD_ID', 'PROC_ID'], $
      'I,I,J,I,I,I,I,F20.5,F20.5,F20.5,F20.5,F20.5,F20.5,F20.5,I,I,I', DIMEN = n_elements(event_id)
    rawData.EVT_ID = event_id
    rawData.VOL_ID = vol_id
    rawData.MOTH_ID = moth_id
    rawData.TRAY_ID = tray_id
    rawData.PLANE_ID = plane_id
    rawData.STRIP_ID_X = Strip_id_x
    rawData.STRIP_ID_Y = Strip_id_y
    rawData.E_DEP = energy_dep
    rawData.X_ENT = ent_x
    rawData.Y_ENT = ent_y
    rawData.Z_ENT = ent_z
    rawData.X_EXIT = exit_x
    rawData.Y_EXIT = exit_y
    rawData.Z_EXIT = exit_z
    rawData.PART_ID = part_id
    rawData.CHILD_ID = child_id
    rawData.PROC_ID = proc_id


    hdr_rawData = ['COMMENT  eASTROGAM '+astrogam_version+' Geant4 simulation', $
      'N_in     = '+strtrim(string(N_in),1), $
      'Energy     = '+ene_type, $
      'Theta     = '+strtrim(string(theta_type),1), $
      'Phi     = '+strtrim(string(phi_type),1), $
      'Position unit = cm', $
      'Energy unit = keV']

    MWRFITS, rawData, outdir+'/G4.RAW.eASTROGAM'+astrogam_version+'.'+py_name+'.'+sim_name+'.'+stripname+'.'+sname+'.'+strmid(strtrim(string(N_in),1),0,10)+part_type+'.'+ene_type+'MeV.'+strmid(strtrim(string(theta_type),1),0,10)+'.'+strmid(strtrim(string(phi_type),1),0,10)+'.'+pol_string+strtrim(string(ifile),1)+'.fits', hdr_rawData, /create

    if (isStrip EQ 0) then begin

      openw,lun,outdir+'/AA_FAKE_eASTROGAM'+astrogam_version+'_'+py_name+'_'+sim_name+'_'+stripname+'_'+sname+'_'+strmid(strtrim(string(N_in),1),0,10)+part_type+'_'+ene_type+'MeV_'+strmid(strtrim(string(theta_type),1),0,10)+'_'+strmid(strtrim(string(phi_type),1),0,10)+'.'+pol_string+strtrim(string(ifile),1)+'.dat',/get_lun
      ; ASCII Columns:
      ; - c1 = event ID
      ; - c2 = theta input
      ; - c3 = phi input
      ; - c4 = energy input
      ; - c5 = plane ID
      ; - c6 = Pos Z
      ; - c7 = X/Y flag (X = 0, Y = 1)
      ; - c8 = Cluster position (reference system center at the Silicon layer center)
      ; - c9 = energy deposition (keV)
      ; - c10 = number of strips composing the cluster
      ; - c11 = child id
      ; - c12 = proc id

      j=0l
      while (1) do begin
        where_event_eq = where(event_id EQ event_id(j))
        plane_id_temp = plane_id(where_event_eq)
        Cluster_x_temp  = x_pos(where_event_eq)
        Cluster_y_temp  = y_pos(where_event_eq)
        Cluster_z_temp  = z_pos(where_event_eq)
        e_dep_x_temp  = (energy_dep(where_event_eq))/2.
        e_dep_y_temp  = (energy_dep(where_event_eq))/2.
        child_temp = child_id(where_event_eq)
        proc_temp = proc_id(where_event_eq)

        ; ------------------------------------
        ; X VIEW
        for r=0l, n_elements(Cluster_x_temp)-1 do begin
          if (e_dep_x_temp(r) GT E_th) then begin
            printf, lun, event_id(j), theta_type, phi_type, ene_type, plane_id_temp(r), Cluster_z_temp(r), 0, Cluster_x_temp(r), e_dep_x_temp(r), 1, child_temp(r), proc_temp(r), format='(I5,I5,I5,I5,I5,F10.5,I5,F10.5,F10.5,I5,I5,I5)'
          endif
        endfor

        ; Y VIEW
        for r=0l, n_elements(Cluster_y_temp)-1 do begin
          if (e_dep_y_temp(r) GT E_th) then begin
            printf, lun, event_id(j), theta_type, phi_type, ene_type, plane_id_temp(r), Cluster_z_temp(r), 1, Cluster_y_temp(r), e_dep_y_temp(r), 1, child_temp(r), proc_temp(r), format='(I5,I5,I5,I5,I5,F10.5,I5,F10.5,F10.5,I5,I5,I5)'
          endif
        endfor

        ; ------------------------------------


        N_event_eq = n_elements(where_event_eq)
        if where_event_eq(N_event_eq-1) LT (n_elements(event_id)-1) then begin
          j = where_event_eq(N_event_eq-1)+1
        endif else break
      endwhile

      Free_lun, lun

    endif

    print, '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%'
    print, '                             Tracker   '
    print, '  Creation of LUT data table with summed energy for each volume       '
    print, '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%'

    ; Loading the LUT
    if (isStrip) then begin
      filename_x_top = './conf/ARCH.XSTRIP.TOP.eASTROGAM'+astrogam_version+'.TRACKER.FITS'
      filename_y_top = './conf/ARCH.YSTRIP.TOP.eASTROGAM'+astrogam_version+'.TRACKER.FITS'

      struct_x_top = mrdfits(filename_x_top,$
        1, $
        structyp = 'astrogam_xtop', $
        /unsigned)

      struct_y_top = mrdfits(filename_y_top,$
        1, $
        structyp = 'astrogam_ytop', $
        /unsigned)

      Arch_vol_id_x_top = struct_x_top.VOLUME_ID
      Arch_moth_id_x_top = struct_x_top.MOTHER_ID
      Arch_Strip_id_x_top = struct_x_top.STRIP_ID
      Arch_Si_id_x_top = struct_x_top.TRK_FLAG
      Arch_tray_id_x_top = struct_x_top.TRAY_ID
      Arch_plane_id_x_top = struct_x_top.PLANE_ID
      Arch_xpos_x_top = struct_x_top.XPOS
      Arch_zpos_x_top = struct_x_top.ZPOS
      Arch_energy_dep_x_top = struct_x_top.E_DEP
      Arch_pair_flag_x_top = struct_x_top.PAIR_FLAG

      Arch_vol_id_y_top = struct_y_top.VOLUME_ID
      Arch_moth_id_y_top = struct_y_top.MOTHER_ID
      Arch_Strip_id_y_top = struct_y_top.STRIP_ID
      Arch_Si_id_y_top = struct_y_top.TRK_FLAG
      Arch_tray_id_y_top = struct_y_top.TRAY_ID
      Arch_plane_id_y_top = struct_y_top.PLANE_ID
      Arch_ypos_y_top = struct_y_top.YPOS
      Arch_zpos_y_top = struct_y_top.ZPOS
      Arch_energy_dep_y_top = struct_y_top.E_DEP
      Arch_pair_flag_y_top = struct_y_top.PAIR_FLAG


      N_trig = 0l

      event_id_tot = -1l
      vol_id_tot = -1l
      moth_id_tot = -1l
      Strip_id_x_tot = -1l
      Strip_id_y_tot = -1l
      tray_id_tot = -1l
      plane_id_tot = -1l
      energy_dep_tot = -1.
      pair_flag_tot = -1l
      gtime_tot = -1.


      j=0l
      while (1) do begin
        where_event_eq = where(event_id EQ event_id(j))

        vol_id_temp = vol_id(where_event_eq)
        moth_id_temp = moth_id(where_event_eq)
        Strip_id_x_temp = Strip_id_x(where_event_eq)
        Strip_id_y_temp = Strip_id_y(where_event_eq)
        tray_id_temp = tray_id(where_event_eq)
        plane_id_temp = plane_id(where_event_eq)
        energy_dep_temp = energy_dep(where_event_eq)
        child_id_temp = child_id(where_event_eq)
        proc_id_temp = proc_id(where_event_eq)
        gtime_temp = gtime_ent(where_event_eq)

        r = 0l
        gtime_ref = 10.^9.
        while(1) do begin
          where_vol_eq = where(((vol_id_temp EQ vol_id_temp(r)) and (moth_id_temp EQ moth_id_temp(r))), complement = where_other_vol)
          ; summing the energy 
          e_dep_temp = total(energy_dep_temp(where_vol_eq))
          event_id_tot = [event_id_tot, event_id(j)]
          vol_id_tot = [vol_id_tot, vol_id_temp(r)]
          moth_id_tot = [moth_id_tot, moth_id_temp(r)]
          Strip_id_x_tot = [Strip_id_x_tot, Strip_id_x_temp(r)]
          Strip_id_y_tot = [Strip_id_y_tot, Strip_id_y_temp(r)]
          tray_id_tot = [tray_id_tot, tray_id_temp(r)]
          plane_id_tot = [plane_id_tot, plane_id_temp(r)]
          energy_dep_tot = [energy_dep_tot, e_dep_temp]

          ; Searching for Pair/Compton events
          ; if one of hits in the same volume is a pair the summed event is flagged as 1
          ; if one of hits in the same volume is a compton the summed event is flagged as 2
          all_child = child_id_temp(where_vol_eq)
          all_proc = proc_id_temp(where_vol_eq)
          all_gtime = gtime_temp(where_vol_eq)
          
          where_pair = where((all_child EQ 1) and (all_proc EQ 7))
          if (where_pair(0) NE -1) then begin
            if (all_gtime[where_pair] LT gtime_ref) then begin
               pair_flag_tot = [pair_flag_tot, 1]
               gtime_ref = all_gtime[where_pair]
            endif else begin
               pair_flag_tot = [pair_flag_tot, 0]
            endelse
          endif else begin
            pair_flag_tot = [pair_flag_tot, 0]
          endelse
          where_compton = where((all_child EQ 1) and (all_proc EQ 3))
          if (where_compton(0) NE -1) then begin
            if (all_gtime[where_compton] LT gtime_ref) then begin
               pair_flag_tot = [pair_flag_tot, 2]
               gtime_ref = all_gtime[where_compton]
            endif else begin
               pair_flag_tot = [pair_flag_tot, 0]
            endelse
          endif else begin
            pair_flag_tot = [pair_flag_tot, 0]
          endelse

          if (where_other_vol(0) NE -1) then begin
            vol_id_temp = vol_id_temp(where_other_vol)
            moth_id_temp = moth_id_temp(where_other_vol)
            Strip_id_x_temp = Strip_id_x_temp(where_other_vol)
            Strip_id_y_temp = Strip_id_y_temp(where_other_vol)
            tray_id_temp = tray_id_temp(where_other_vol)
            plane_id_temp = plane_id_temp(where_other_vol)
            energy_dep_temp = energy_dep_temp(where_other_vol)
            child_id_temp = child_id_temp(where_other_vol)
            proc_id_temp = proc_id_temp(where_other_vol)
            gtime_temp = gtime_temp(where_other_vol)
          endif else break
        endwhile

        N_event_eq = n_elements(where_event_eq)
        if where_event_eq(N_event_eq-1) LT (n_elements(event_id)-1) then begin
          j = where_event_eq(N_event_eq-1)+1
        endif else break
      endwhile


      if (n_elements(event_id_tot) GT 1) then begin
        event_id_tot = event_id_tot[1:*]
        vol_id_tot = vol_id_tot[1:*]
        moth_id_tot = moth_id_tot[1:*]
        Strip_id_x_tot = Strip_id_x_tot[1:*]
        Strip_id_y_tot = Strip_id_y_tot[1:*]
        tray_id_tot = tray_id_tot[1:*]
        plane_id_tot = plane_id_tot[1:*]
        energy_dep_tot = energy_dep_tot[1:*]
        pair_flag_tot = pair_flag_tot[1:*]
      endif

      event_id_tot_temp = lonarr(2*n_elements(event_id_tot))
      vol_id_tot_temp = lonarr(2*n_elements(event_id_tot))
      moth_id_tot_temp = lonarr(2*n_elements(event_id_tot))
      Strip_id_tot_temp = lonarr(2*n_elements(event_id_tot))
      Si_id_tot_temp = lonarr(2*n_elements(event_id_tot))
      tray_id_tot_temp = lonarr(2*n_elements(event_id_tot))
      plane_id_tot_temp = lonarr(2*n_elements(event_id_tot))
      energy_dep_tot_temp = dblarr(2*n_elements(event_id_tot))
      pair_flag_tot_temp = dblarr(2*n_elements(event_id_tot))

      for jev = 0l, n_elements(event_id_tot) - 1 do begin
        ev_index = jev*2
        event_id_tot_temp[ev_index] = event_id_tot[jev]
        event_id_tot_temp[ev_index+1] = event_id_tot[jev]
        vol_id_tot_temp[ev_index] = Strip_id_x_tot[jev]
        vol_id_tot_temp[ev_index+1] = Strip_id_y_tot[jev]
        moth_id_tot_temp[ev_index] = moth_id_tot[jev] - Strip_id_x_tot[jev]
        moth_id_tot_temp[ev_index+1] = moth_id_tot[jev] - Strip_id_x_tot[jev]
        Strip_id_tot_temp[ev_index] = Strip_id_x_tot[jev]
        Strip_id_tot_temp[ev_index+1] = Strip_id_y_tot[jev]
        Si_id_tot_temp[ev_index] = 0
        Si_id_tot_temp[ev_index+1] = 1
        tray_id_tot_temp[ev_index] = tray_id_tot[jev]
        tray_id_tot_temp[ev_index+1] = tray_id_tot[jev]
        plane_id_tot_temp[ev_index] = plane_id_tot[jev]
        plane_id_tot_temp[ev_index+1] = plane_id_tot[jev]
        energy_dep_tot_temp[ev_index] = energy_dep_tot[jev]/2.
        energy_dep_tot_temp[ev_index+1] = energy_dep_tot[jev]/2.
        pair_flag_tot_temp[ev_index] = pair_flag_tot[jev]
        pair_flag_tot_temp[ev_index+1] = pair_flag_tot[jev]

      endfor


      event_id_tot = -1l
      vol_id_tot = -1l
      moth_id_tot = -1l
      Strip_id_tot = -1l
      Si_id_tot = -1l
      tray_id_tot = -1l
      plane_id_tot = -1l
      energy_dep_tot = -1.
      pair_flag_tot = -1l

      ;
      ; Summing the energy along the strip
      ;

      j=0l
      while (1) do begin
        where_event_eq = where(event_id_tot_temp EQ event_id_tot_temp(j))

        vol_id_temp = vol_id_tot_temp(where_event_eq)
        moth_id_temp = moth_id_tot_temp(where_event_eq)
        Strip_id_temp = Strip_id_tot_temp(where_event_eq)
        Si_id_temp = Si_id_tot_temp(where_event_eq)
        tray_id_temp = tray_id_tot_temp(where_event_eq)
        plane_id_temp = plane_id_tot_temp(where_event_eq)
        energy_dep_temp = energy_dep_tot_temp(where_event_eq)
        pair_flag_temp = pair_flag_tot_temp(where_event_eq)

        r = 0l
        while(1) do begin

          where_vol_eq = where(((vol_id_temp EQ vol_id_temp(r)) and (moth_id_temp EQ moth_id_temp(r)) and (Si_id_temp EQ 0)), complement = where_other_vol)
          if (where_vol_eq(0) NE -1) then begin
            e_dep_temp = total(energy_dep_temp(where_vol_eq))
            event_id_tot = [event_id_tot, event_id_tot_temp(j)]
            vol_id_tot = [vol_id_tot, vol_id_temp(r)]
            moth_id_tot = [moth_id_tot, moth_id_temp(r)]
            Strip_id_tot = [Strip_id_tot, Strip_id_temp(r)]
            Si_id_tot = [Si_id_tot, 0]
            tray_id_tot = [tray_id_tot, tray_id_temp(r)]
            plane_id_tot = [plane_id_tot, plane_id_temp(r)]
            energy_dep_tot = [energy_dep_tot, e_dep_temp]
            pair_flag_tot = [pair_flag_tot, pair_flag_temp(r)]

            if (where_other_vol(0) NE -1) then begin
              vol_id_temp = vol_id_temp(where_other_vol)
              moth_id_temp = moth_id_temp(where_other_vol)
              Strip_id_temp = Strip_id_temp(where_other_vol)
              Si_id_temp = Si_id_temp(where_other_vol)
              tray_id_temp = tray_id_temp(where_other_vol)
              plane_id_temp = plane_id_temp(where_other_vol)
              energy_dep_temp = energy_dep_temp(where_other_vol)
              pair_flag_temp = pair_flag_temp(where_other_vol)
            endif else break
          endif

          where_vol_eq = where(((vol_id_temp EQ vol_id_temp(r)) and (moth_id_temp EQ moth_id_temp(r)) and (Si_id_temp EQ 1)), complement = where_other_vol)
          if (where_vol_eq(0) NE -1) then begin
            e_dep_temp = total(energy_dep_temp(where_vol_eq))
            event_id_tot = [event_id_tot, event_id_tot_temp(j)]
            vol_id_tot = [vol_id_tot, vol_id_temp(r)]
            moth_id_tot = [moth_id_tot, moth_id_temp(r)]
            Strip_id_tot = [Strip_id_tot, Strip_id_temp(r)]
            Si_id_tot = [Si_id_tot, 1]
            tray_id_tot = [tray_id_tot, tray_id_temp(r)]
            plane_id_tot = [plane_id_tot, plane_id_temp(r)]
            energy_dep_tot = [energy_dep_tot, e_dep_temp]
            pair_flag_tot = [pair_flag_tot, pair_flag_temp(r)]

            if (where_other_vol(0) NE -1) then begin
              vol_id_temp = vol_id_temp(where_other_vol)
              moth_id_temp = moth_id_temp(where_other_vol)
              Strip_id_temp = Strip_id_temp(where_other_vol)
              Si_id_temp = Si_id_temp(where_other_vol)
              tray_id_temp = tray_id_temp(where_other_vol)
              plane_id_temp = plane_id_temp(where_other_vol)
              energy_dep_temp = energy_dep_temp(where_other_vol)
              pair_flag_temp = pair_flag_temp(where_other_vol)
            endif else break
          endif
        endwhile

        N_event_eq = n_elements(where_event_eq)
        if where_event_eq(N_event_eq-1) LT (n_elements(event_id_tot_temp)-1) then begin
          j = where_event_eq(N_event_eq-1)+1
        endif else break
      endwhile

      if (n_elements(event_id_tot) GT 1) then begin
        event_id_tot = event_id_tot[1:*]
        vol_id_tot = vol_id_tot[1:*]
        moth_id_tot = moth_id_tot[1:*]
        Strip_id_tot = Strip_id_tot[1:*]
        Si_id_tot = Si_id_tot[1:*]
        tray_id_tot = tray_id_tot[1:*]
        plane_id_tot = plane_id_tot[1:*]
        energy_dep_tot = energy_dep_tot[1:*]
        pair_flag_tot = pair_flag_tot[1:*]
      endif
    endif

    ; apply the energy thresold

    where_eth = where(energy_dep_tot GT E_th)
    event_id_tot = event_id_tot[where_eth]
    vol_id_tot = vol_id_tot[where_eth]
    moth_id_tot = moth_id_tot[where_eth]
    Strip_id_tot = Strip_id_tot[where_eth]
    Si_id_tot = Si_id_tot[where_eth]
    tray_id_tot = tray_id_tot[where_eth]
    plane_id_tot = plane_id_tot[where_eth]
    energy_dep_tot = energy_dep_tot[where_eth]
    pair_flag_tot = pair_flag_tot[where_eth]

    N_trig = n_elements(uniq(event_id_tot))
    event_array = event_id_tot(uniq(event_id_tot))

  endif


  if ((astrogam_version EQ 'V1.0') or (astrogam_version EQ 'V1.1')) then begin

    if (isStrip) then begin
      ; Total number of strips
      Total_vol_x_top = (N_tray)*N_strip
      Total_vol_y_top = (N_tray)*N_strip

      print, 'Number of tracker triggered events:', N_trig

      Glob_event_id_x_top = lonarr(Total_vol_x_top, N_trig)
      Glob_vol_id_x_top = lonarr(Total_vol_x_top, N_trig)
      Glob_moth_id_x_top = lonarr(Total_vol_x_top, N_trig)
      Glob_Strip_id_x_top = lonarr(Total_vol_x_top, N_trig)
      Glob_Si_id_x_top = lonarr(Total_vol_x_top, N_trig)
      Glob_tray_id_x_top = lonarr(Total_vol_x_top, N_trig)
      Glob_plane_id_x_top = lonarr(Total_vol_x_top, N_trig)
      Glob_xpos_x_top = dblarr(Total_vol_x_top, N_trig)
      Glob_zpos_x_top = dblarr(Total_vol_x_top, N_trig)
      Glob_energy_dep_x_top = dblarr(Total_vol_x_top, N_trig)
      Glob_pair_flag_x_top = dblarr(Total_vol_x_top, N_trig)

      Glob_event_id_y_top = lonarr(Total_vol_y_top, N_trig)
      Glob_vol_id_y_top = lonarr(Total_vol_y_top, N_trig)
      Glob_moth_id_y_top = lonarr(Total_vol_y_top, N_trig)
      Glob_Strip_id_y_top = lonarr(Total_vol_y_top, N_trig)
      Glob_Si_id_y_top = lonarr(Total_vol_y_top, N_trig)
      Glob_tray_id_y_top = lonarr(Total_vol_y_top, N_trig)
      Glob_plane_id_y_top = lonarr(Total_vol_y_top, N_trig)
      Glob_ypos_y_top = dblarr(Total_vol_y_top, N_trig)
      Glob_zpos_y_top = dblarr(Total_vol_y_top, N_trig)
      Glob_energy_dep_y_top = dblarr(Total_vol_y_top, N_trig)
      Glob_pair_flag_y_top = dblarr(Total_vol_x_top, N_trig)


      for i=0, N_trig-1 do begin

        Glob_vol_id_x_top[*,i] = Arch_vol_id_x_top
        Glob_moth_id_x_top[*,i] = Arch_moth_id_x_top
        Glob_Strip_id_x_top[*,i] = Arch_Strip_id_x_top
        Glob_Si_id_x_top[*,i] = Arch_Si_id_x_top
        Glob_tray_id_x_top[*,i] = Arch_tray_id_x_top
        Glob_plane_id_x_top[*,i] = Arch_plane_id_x_top
        Glob_xpos_x_top[*,i] = Arch_xpos_x_top
        Glob_zpos_x_top[*,i] = Arch_zpos_x_top
        Glob_energy_dep_x_top[*,i] = Arch_energy_dep_x_top
        Glob_pair_flag_x_top[*,i] = Arch_pair_flag_x_top

        Glob_vol_id_y_top[*,i] = Arch_vol_id_y_top
        Glob_moth_id_y_top[*,i] = Arch_moth_id_y_top
        Glob_Strip_id_y_top[*,i] = Arch_Strip_id_y_top
        Glob_Si_id_y_top[*,i] = Arch_Si_id_y_top
        Glob_tray_id_y_top[*,i] = Arch_tray_id_y_top
        Glob_plane_id_y_top[*,i] = Arch_plane_id_y_top
        Glob_ypos_y_top[*,i] = Arch_ypos_y_top
        Glob_zpos_y_top[*,i] = Arch_zpos_y_top
        Glob_energy_dep_y_top[*,i] = Arch_energy_dep_y_top
        Glob_pair_flag_y_top[*,i] = Arch_pair_flag_y_top

      endfor


      j=0l
      N_ev =0l
      while (1) do begin
        where_event_eq = where(event_id_tot EQ event_id_tot(j))

        event_id_temp = event_id_tot(where_event_eq)
        vol_id_temp = vol_id_tot(where_event_eq)
        moth_id_temp = moth_id_tot(where_event_eq)
        Strip_id_temp = Strip_id_tot(where_event_eq)
        Si_id_temp = Si_id_tot(where_event_eq)
        tray_id_temp = tray_id_tot(where_event_eq)
        plane_id_temp = plane_id_tot(where_event_eq)
        energy_dep_temp = energy_dep_tot(where_event_eq)
        pair_flag_temp = pair_flag_tot(where_event_eq)

        vol_sort_arr = sort(vol_id_temp)

        vol_id_temp = vol_id_temp[vol_sort_arr]
        moth_id_temp = moth_id_temp[vol_sort_arr]
        Strip_id_temp = Strip_id_temp[vol_sort_arr]
        Si_id_temp = Si_id_temp[vol_sort_arr]
        tray_id_temp = tray_id_temp[vol_sort_arr]
        plane_id_temp = plane_id_temp[vol_sort_arr]
        energy_dep_temp = energy_dep_temp[vol_sort_arr]
        pair_flag_temp = pair_flag_temp[vol_sort_arr]

        ;print, 'vol_id_temp', vol_id_temp
        ;print, 'moth_id_temp', moth_id_temp
        for z=0l, Total_vol_x_top -1 do begin
          where_hit_x_top = where((Si_id_temp EQ 0) and (vol_id_temp EQ Glob_vol_id_x_top(z, N_ev)) and (moth_id_temp EQ Glob_moth_id_x_top(z, N_ev)))
          if (where_hit_x_top(0) NE -1) then begin
            Glob_energy_dep_x_top(z, N_ev) = energy_dep_temp(where_hit_x_top)
            Glob_pair_flag_x_top(z, N_ev) = pair_flag_temp(where_hit_x_top)
          endif
          where_hit_y_top = where((Si_id_temp EQ 1) and (vol_id_temp EQ Glob_vol_id_y_top(z, N_ev)) and (moth_id_temp EQ Glob_moth_id_y_top(z, N_ev)))
          if (where_hit_y_top(0) NE -1) then begin
            Glob_energy_dep_y_top(z, N_ev) = energy_dep_temp(where_hit_y_top)
            Glob_pair_flag_y_top(z, N_ev) = pair_flag_temp(where_hit_y_top)
          endif
        endfor

        N_event_eq = n_elements(where_event_eq)
        if where_event_eq(N_event_eq-1) LT (n_elements(event_id_tot)-1) then begin
          j = where_event_eq(N_event_eq-1)+1
          N_ev = N_ev + 1
        endif else break
      endwhile


      print, 'N_ev: ', N_ev



      print, '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%'
      print, '                      Tracker   '
      print, '              Build the LEVEL 0 output            '
      print, '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%'


      Glob_event_id_test = -1l
      Glob_vol_id_test = -1l
      Glob_moth_id_test = -1l
      Glob_Strip_id_test = -1l
      Glob_Si_id_test = -1l
      Glob_tray_id_test = -1l
      Glob_plane_id_test = -1l
      Glob_pos_test = -1.
      Glob_zpos_test = -1.
      Glob_energy_dep_test = -1.
      Glob_pair_flag_test = -1.


      for j=0l, N_trig -1 do begin

        where_test_x = where(Glob_energy_dep_x_top[*,j] GT 0.)

        if (where_test_x(0) NE -1) then begin
          Glob_vol_id_x_test_temp = Glob_vol_id_x_top[where_test_x,j]
          Glob_moth_id_x_test_temp = Glob_moth_id_x_top[where_test_x,j]
          Glob_Strip_id_x_test_temp = Glob_Strip_id_x_top[where_test_x,j]
          Glob_Si_id_x_test_temp = Glob_Si_id_x_top[where_test_x,j]
          Glob_tray_id_x_test_temp = Glob_tray_id_x_top[where_test_x,j]
          Glob_plane_id_x_test_temp = Glob_plane_id_x_top[where_test_x,j]
          Glob_xpos_x_test_temp = Glob_xpos_x_top[where_test_x,j]
          Glob_zpos_x_test_temp = Glob_zpos_x_top[where_test_x,j]
          Glob_energy_dep_x_test_temp = Glob_energy_dep_x_top[where_test_x,j]
          Glob_pair_flag_x_test_temp = Glob_pair_flag_x_top[where_test_x,j]
        endif


        where_test_y = where(Glob_energy_dep_y_top[*,j] GT 0.)

        if (where_test_y(0) NE -1) then begin
          Glob_vol_id_y_test_temp = Glob_vol_id_y_top[where_test_y,j]
          Glob_moth_id_y_test_temp = Glob_moth_id_y_top[where_test_y,j]
          Glob_Strip_id_y_test_temp = Glob_Strip_id_y_top[where_test_y,j]
          Glob_Si_id_y_test_temp = Glob_Si_id_y_top[where_test_y,j]
          Glob_tray_id_y_test_temp = Glob_tray_id_y_top[where_test_y,j]
          Glob_plane_id_y_test_temp = Glob_plane_id_y_top[where_test_y,j]
          Glob_ypos_y_test_temp = Glob_ypos_y_top[where_test_y,j]
          Glob_zpos_y_test_temp = Glob_zpos_y_top[where_test_y,j]
          Glob_energy_dep_y_test_temp = Glob_energy_dep_y_top[where_test_y,j]
          Glob_pair_flag_y_test_temp = Glob_pair_flag_y_top[where_test_y,j]
        endif

        if ((where_test_y(0) NE -1) AND (where_test_x(0) NE -1)) then begin
          Glob_vol_id_test_temp = [Glob_vol_id_y_test_temp, Glob_vol_id_x_test_temp]
          Glob_moth_id_test_temp = [Glob_moth_id_y_test_temp, Glob_moth_id_x_test_temp]
          Glob_Strip_id_test_temp = [Glob_Strip_id_y_test_temp, Glob_Strip_id_x_test_temp]
          Glob_Si_id_test_temp = [Glob_Si_id_y_test_temp, Glob_Si_id_x_test_temp]
          Glob_tray_id_test_temp = [Glob_tray_id_y_test_temp, Glob_tray_id_x_test_temp]
          Glob_plane_id_test_temp = [Glob_plane_id_y_test_temp, Glob_plane_id_x_test_temp]
          Glob_pos_test_temp = [Glob_ypos_y_test_temp, Glob_xpos_x_test_temp]
          Glob_zpos_test_temp = [Glob_zpos_y_test_temp, Glob_zpos_x_test_temp]
          Glob_energy_dep_test_temp = [Glob_energy_dep_y_test_temp, Glob_energy_dep_x_test_temp]
          Glob_pair_flag_test_temp = [Glob_pair_flag_y_test_temp, Glob_pair_flag_x_test_temp]
        endif else begin
          if ((where_test_y(0) NE -1) AND (where_test_x(0) EQ -1)) then begin
            Glob_vol_id_test_temp = Glob_vol_id_y_test_temp
            Glob_moth_id_test_temp = Glob_moth_id_y_test_temp
            Glob_Strip_id_test_temp = Glob_Strip_id_y_test_temp
            Glob_Si_id_test_temp = Glob_Si_id_y_test_temp
            Glob_tray_id_test_temp = Glob_tray_id_y_test_temp
            Glob_plane_id_test_temp = Glob_plane_id_y_test_temp
            Glob_pos_test_temp = Glob_ypos_y_test_temp
            Glob_zpos_test_temp = Glob_zpos_y_test_temp
            Glob_energy_dep_test_temp = Glob_energy_dep_y_test_temp
            Glob_pair_flag_test_temp = Glob_pair_flag_y_test_temp
          endif else begin
            if ((where_test_y(0) EQ -1) AND (where_test_x(0) NE -1)) then begin
              Glob_vol_id_test_temp = Glob_vol_id_x_test_temp
              Glob_moth_id_test_temp = Glob_moth_id_x_test_temp
              Glob_Strip_id_test_temp = Glob_Strip_id_x_test_temp
              Glob_Si_id_test_temp = Glob_Si_id_x_test_temp
              Glob_tray_id_test_temp = Glob_tray_id_x_test_temp
              Glob_plane_id_test_temp = Glob_plane_id_x_test_temp
              Glob_pos_test_temp = Glob_xpos_x_test_temp
              Glob_zpos_test_temp = Glob_zpos_x_test_temp
              Glob_energy_dep_test_temp = Glob_energy_dep_x_test_temp
              Glob_pair_flag_test_temp = Glob_pair_flag_x_test_temp
            endif
          endelse
        endelse

        tray_sort_arr = sort(Glob_tray_id_test_temp)

        Glob_vol_id_test_temp = Glob_vol_id_test_temp[reverse(tray_sort_arr)]
        Glob_moth_id_test_temp = Glob_moth_id_test_temp[reverse(tray_sort_arr)]
        Glob_Strip_id_test_temp = Glob_Strip_id_test_temp[reverse(tray_sort_arr)]
        Glob_Si_id_test_temp = Glob_Si_id_test_temp[reverse(tray_sort_arr)]
        Glob_tray_id_test_temp = Glob_tray_id_test_temp[reverse(tray_sort_arr)]
        Glob_plane_id_test_temp = Glob_plane_id_test_temp[reverse(tray_sort_arr)]
        Glob_pos_test_temp = Glob_pos_test_temp[reverse(tray_sort_arr)]
        Glob_zpos_test_temp = Glob_zpos_test_temp[reverse(tray_sort_arr)]
        Glob_energy_dep_test_temp = Glob_energy_dep_test_temp[reverse(tray_sort_arr)]
        Glob_pair_flag_test_temp = Glob_pair_flag_test_temp[reverse(tray_sort_arr)]

        vol_id_intray = -1l
        moth_id_intray = -1l
        Strip_id_intray = -1l
        Si_id_intray = -1l
        tray_id_intray = -1l
        plane_id_intray = -1l
        pos_intray = -1.
        zpos_intray = -1.
        energy_dep_intray = -1.
        pair_flag_intray = -1.

        intray = 0l
        while(1) do begin
          where_tray_eq = where(Glob_tray_id_test_temp EQ Glob_tray_id_test_temp(intray), complement = where_other_tray)

          vol_id_extract = Glob_vol_id_test_temp[where_tray_eq]
          moth_id_extract = Glob_moth_id_test_temp[where_tray_eq]
          Strip_id_extract = Glob_Strip_id_test_temp[where_tray_eq]
          Si_id_extract = Glob_Si_id_test_temp[where_tray_eq]
          tray_id_extract = Glob_tray_id_test_temp[where_tray_eq]
          plane_id_extract = Glob_plane_id_test_temp[where_tray_eq]
          pos_extract = Glob_pos_test_temp[where_tray_eq]
          zpos_extract = Glob_zpos_test_temp[where_tray_eq]
          energy_dep_extract = Glob_energy_dep_test_temp[where_tray_eq]
          pair_flag_extract = Glob_pair_flag_test_temp[where_tray_eq]

          where_Y = where(Si_id_extract EQ 1)
          if (where_Y(0) NE -1) then begin
            vol_id_intray = [vol_id_intray, vol_id_extract[where_Y]]
            moth_id_intray = [moth_id_intray, moth_id_extract[where_Y]]
            Strip_id_intray = [Strip_id_intray, Strip_id_extract[where_Y]]
            Si_id_intray = [Si_id_intray, Si_id_extract[where_Y]]
            tray_id_intray = [tray_id_intray, tray_id_extract[where_Y]]
            plane_id_intray = [plane_id_intray, plane_id_extract[where_Y]]
            pos_intray = [pos_intray, pos_extract[where_Y]]
            zpos_intray = [zpos_intray, zpos_extract[where_Y]]
            energy_dep_intray = [energy_dep_intray, energy_dep_extract[where_Y]]
            pair_flag_intray = [pair_flag_intray, pair_flag_extract[where_Y]]
          endif
          where_X = where(Si_id_extract EQ 0)
          if (where_X(0) NE -1) then begin
            vol_id_intray = [vol_id_intray, vol_id_extract[where_X]]
            moth_id_intray = [moth_id_intray, moth_id_extract[where_X]]
            Strip_id_intray = [Strip_id_intray, Strip_id_extract[where_X]]
            Si_id_intray = [Si_id_intray, Si_id_extract[where_X]]
            tray_id_intray = [tray_id_intray, tray_id_extract[where_X]]
            plane_id_intray = [plane_id_intray, plane_id_extract[where_X]]
            pos_intray = [pos_intray, pos_extract[where_X]]
            zpos_intray = [zpos_intray, zpos_extract[where_X]]
            energy_dep_intray = [energy_dep_intray, energy_dep_extract[where_X]]
            pair_flag_intray = [pair_flag_intray, pair_flag_extract[where_X]]
          endif
          N_tray_eq = n_elements(where_tray_eq)
          if where_tray_eq(N_tray_eq-1) LT (n_elements(Glob_tray_id_test_temp)-1) then begin
            intray = where_tray_eq(N_tray_eq-1)+1
          endif else break
        endwhile


        vol_id_temp = vol_id_intray[1:*]
        moth_id_temp = moth_id_intray[1:*]
        Strip_id_temp = Strip_id_intray[1:*]
        Si_id_temp = Si_id_intray[1:*]
        tray_id_temp = tray_id_intray[1:*]
        plane_id_temp = plane_id_intray[1:*]
        pos_temp = pos_intray[1:*]
        zpos_temp = zpos_intray[1:*]
        energy_dep_temp = energy_dep_intray[1:*]
        pair_flag_temp = pair_flag_intray[1:*]

        event_id_temp = lonarr(n_elements(vol_id_temp))
        for k=0l, n_elements(vol_id_temp)-1 do begin
          event_id_temp(k) = event_array(j)
        endfor

        Glob_event_id_test = [Glob_event_id_test, event_id_temp]
        Glob_vol_id_test = [Glob_vol_id_test, vol_id_temp]
        Glob_moth_id_test= [Glob_moth_id_test, moth_id_temp]
        Glob_Strip_id_test = [Glob_Strip_id_test, Strip_id_temp]
        Glob_Si_id_test = [Glob_Si_id_test, Si_id_temp]
        Glob_tray_id_test = [Glob_tray_id_test, tray_id_temp]
        Glob_plane_id_test = [Glob_plane_id_test, plane_id_temp]
        Glob_pos_test = [Glob_pos_test, pos_temp]
        Glob_zpos_test = [Glob_zpos_test, zpos_temp]
        Glob_energy_dep_test = [Glob_energy_dep_test, energy_dep_temp]
        Glob_pair_flag_test = [Glob_pair_flag_test, pair_flag_temp]

      endfor

      Glob_event_id_test = Glob_event_id_test[1:*]
      Glob_vol_id_test =  Glob_vol_id_test[1:*]
      Glob_moth_id_test =  Glob_moth_id_test[1:*]
      Glob_Strip_id_test =  Glob_Strip_id_test[1:*]
      Glob_Si_id_test =  Glob_Si_id_test[1:*]
      Glob_tray_id_test =  Glob_tray_id_test[1:*]
      Glob_plane_id_test =  Glob_plane_id_test[1:*]
      Glob_pos_test = Glob_pos_test[1:*]
      Glob_zpos_test = Glob_zpos_test[1:*]
      Glob_energy_dep_test = Glob_energy_dep_test[1:*]
      Glob_pair_flag_test = Glob_pair_flag_test[1:*]


      ; Level 0 = energy summed
      ; Level 0 = the events are sorted in tray, and Y before X within the same tray
      ; energy threshold applied

      CREATE_STRUCT, L0TRACKERGLOBAL, 'GLOBALTRACKERL0', ['EVT_ID', 'VOLUME_ID', 'MOTHER_ID', 'TRAY_ID', 'PLANE_ID','TRK_FLAG', 'STRIP_ID', 'POS', 'ZPOS','E_DEP', 'PAIR_FLAG'], 'I,J,J,I,I,I,J,F20.5,F20.5,F20.5,I', DIMEN = N_ELEMENTS(Glob_event_id_test)
      L0TRACKERGLOBAL.EVT_ID = Glob_event_id_test
      L0TRACKERGLOBAL.VOLUME_ID = Glob_vol_id_test
      L0TRACKERGLOBAL.MOTHER_ID = Glob_moth_id_test
      L0TRACKERGLOBAL.TRAY_ID = Glob_tray_id_test
      L0TRACKERGLOBAL.PLANE_ID = Glob_plane_id_test
      L0TRACKERGLOBAL.TRK_FLAG = Glob_Si_id_test
      L0TRACKERGLOBAL.STRIP_ID = Glob_Strip_id_test
      L0TRACKERGLOBAL.POS = Glob_pos_test
      L0TRACKERGLOBAL.ZPOS = Glob_zpos_test
      L0TRACKERGLOBAL.E_DEP = Glob_energy_dep_test
      L0TRACKERGLOBAL.PAIR_FLAG = Glob_pair_flag_test

      HDR_L0GLOBAL = ['Creator          = Valentina Fioretti', $
        'THELSIM release  = eASTROGAM '+astrogam_version, $
        'N_IN             = '+STRTRIM(STRING(N_IN),1)+'   /Number of simulated particles', $
        'N_TRIG           = '+STRTRIM(STRING(N_TRIG),1)+'   /Number of triggering events', $
        'ENERGY           = '+ene_type+'   /Simulated input energy', $
        'THETA            = '+STRTRIM(STRING(THETA_TYPE),1)+'   /Simulated input theta angle', $
        'PHI              = '+STRTRIM(STRING(PHI_TYPE),1)+'   /Simulated input phi angle', $
        'ENERGY UNIT      = KEV']


      MWRFITS, L0TRACKERGLOBAL, outdir+'/L0.eASTROGAM'+astrogam_version+'.'+py_name+'.'+sim_name+'.'+stripname+'.'+sname+'.'+STRMID(STRTRIM(STRING(N_IN),1),0,10)+part_type+'.'+ene_type+'MeV.'+STRMID(STRTRIM(STRING(THETA_TYPE),1),0,10)+'.'+STRMID(STRTRIM(STRING(PHI_TYPE),1),0,10)+'.'+pol_string+strtrim(string(ifile),1)+'.fits', HDR_L0GLOBAL, /CREATE



      print, '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%'
      print, '         ASCII data format for AA input - strip'
      print, '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%'


      openw,lun,outdir+'/'+sim_tag+'_STRIP_'+strmid(strtrim(string(N_in),1),0,10)+part_type+'_'+sname+'_'+ene_dis+'_'+ang_type+'_'+ene_type+'MeV_'+strmid(strtrim(string(theta_type),1),0,10)+'_'+strmid(strtrim(string(phi_type),1),0,10)+'.'+pol_string+strtrim(string(ifile),1)+'.dat',/get_lun
      ; ASCII Columns:
      ; - c1 = event ID
      ; - c2 = theta input
      ; - c3 = phi input
      ; - c4 = energy input
      ; - c5 = plane ID
      ; - c6 = Pos Z
      ; - c7 = X/Y flag (X = 0, Y = 1)
      ; - c8 = Strip ID
      ; - c9 = strip position (reference system center at the Silicon layer center)
      ; - c10 = energy deposition (keV)
      ; - c11 = pair flag (1 = pair, 0 = not pair)

      event_start = -1
      j=0l
      while (1) do begin
        where_event_eq = where(Glob_event_id_test EQ Glob_event_id_test(j))
        Glob_Si_id_test_temp = Glob_Si_id_test(where_event_eq)
        Glob_tray_id_test_temp  = Glob_tray_id_test(where_event_eq)
        Glob_plane_id_test_temp  = Glob_plane_id_test(where_event_eq)
        Glob_Strip_id_test_temp = Glob_Strip_id_test(where_event_eq)
        Glob_pos_test_temp = Glob_pos_test(where_event_eq)
        Glob_zpos_test_temp = Glob_zpos_test(where_event_eq)
        Glob_energy_dep_test_temp = Glob_energy_dep_test(where_event_eq)
        Glob_pair_flag_test_temp = Glob_pair_flag_test(where_event_eq)

        ; ------------------------------------
        ; X VIEW
        where_x = where(Glob_Si_id_test_temp EQ 0)
        if (where_x(0) NE -1) then begin
          for r=0l, n_elements(where_x)-1 do begin
            printf, lun, Glob_event_id_test(j), theta_type, phi_type, ene_type, Glob_plane_id_test_temp(where_x(r)), Glob_zpos_test_temp(where_x(r)), 0, Glob_Strip_id_test_temp(where_x(r)), Glob_pos_test_temp(where_x(r)), Glob_energy_dep_test_temp(where_x(r)), Glob_pair_flag_test_temp(where_x(r)), format='(I5,I5,I5,I7,I5,F10.5,I5,I5,F10.5,F10.5,I5)'
          endfor
        endif

        ; Y VIEW
        where_y = where(Glob_Si_id_test_temp EQ 1)
        if (where_y(0) NE -1) then begin
          for r=0l, n_elements(where_y)-1 do begin
            printf, lun, Glob_event_id_test(j), theta_type, phi_type, ene_type, Glob_plane_id_test_temp(where_y(r)), Glob_zpos_test_temp(where_y(r)), 1, Glob_Strip_id_test_temp(where_y(r)), Glob_pos_test_temp(where_y(r)), Glob_energy_dep_test_temp(where_y(r)), Glob_pair_flag_test_temp(where_y(r)), format='(I5,I5,I5,I7,I5,F10.5,I5,I5,F10.5,F10.5,I5)'
          endfor
        endif
        ; ------------------------------------

        N_event_eq = n_elements(where_event_eq)
        if where_event_eq(N_event_eq-1) LT (n_elements(Glob_event_id_test)-1) then begin
          j = where_event_eq(N_event_eq-1)+1
        endif else break
      endwhile

      Free_lun, lun


      print, '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%'
      print, '                      Tracker   '
      print, '       L0.5 - cluster baricenter '
      print, '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%'


      Glob_event_id_x_top_cluster = -1l
      Glob_Si_id_x_top_cluster = -1l
      Glob_tray_id_x_top_cluster = -1l
      Glob_plane_id_x_top_cluster = -1l
      Glob_xpos_x_top_cluster = -1.
      Glob_zpos_x_top_cluster = -1.
      Glob_energy_dep_x_top_cluster = -1.
      Glob_Strip_number_x_top_cluster = -1l
      Glob_pair_flag_x_top_cluster = -1l

      Glob_event_id_y_top_cluster = -1l
      Glob_Si_id_y_top_cluster = -1l
      Glob_tray_id_y_top_cluster = -1l
      Glob_plane_id_y_top_cluster = -1l
      Glob_ypos_y_top_cluster = -1.
      Glob_zpos_y_top_cluster = -1.
      Glob_energy_dep_y_top_cluster = -1.
      Glob_Strip_number_y_top_cluster = -1l
      Glob_pair_flag_y_top_cluster = -1l


      print, 'N_trig: ', N_trig

      for k=0l, N_trig-1 do begin

        N_start = 0l
        j=0l
        while (1) do begin

          ; sorting the planes
          sort_ascending_plane_x = sort(Glob_plane_id_x_top(*, k))
          Glob_vol_id_x_top_tray = Glob_vol_id_x_top[sort_ascending_plane_x, k]
          Glob_moth_id_x_top_tray = Glob_moth_id_x_top[sort_ascending_plane_x, k]
          Glob_Strip_id_x_top_tray = Glob_Strip_id_x_top[sort_ascending_plane_x, k]
          Glob_Si_id_x_top_tray = Glob_Si_id_x_top[sort_ascending_plane_x, k]
          Glob_tray_id_x_top_tray = Glob_tray_id_x_top[sort_ascending_plane_x, k]
          Glob_plane_id_x_top_tray = Glob_plane_id_x_top[sort_ascending_plane_x, k]
          Glob_xpos_x_top_tray = Glob_xpos_x_top[sort_ascending_plane_x, k]
          Glob_zpos_x_top_tray = Glob_zpos_x_top[sort_ascending_plane_x, k]
          Glob_energy_dep_x_top_tray = Glob_energy_dep_x_top[sort_ascending_plane_x, k]
          Glob_pair_flag_x_top_tray = Glob_pair_flag_x_top[sort_ascending_plane_x, k]

          where_tray_eq_x_top = where(Glob_tray_id_x_top_tray EQ Glob_tray_id_x_top_tray(j))

          Glob_vol_id_x_top_tray = Glob_vol_id_x_top_tray[where_tray_eq_x_top]
          Glob_moth_id_x_top_tray = Glob_moth_id_x_top_tray[where_tray_eq_x_top]
          Glob_Strip_id_x_top_tray = Glob_Strip_id_x_top_tray[where_tray_eq_x_top]
          Glob_Si_id_x_top_tray = Glob_Si_id_x_top_tray[where_tray_eq_x_top]
          Glob_tray_id_x_top_tray = Glob_tray_id_x_top_tray[where_tray_eq_x_top]
          Glob_plane_id_x_top_tray = Glob_plane_id_x_top_tray[where_tray_eq_x_top]
          Glob_xpos_x_top_tray = Glob_xpos_x_top_tray[where_tray_eq_x_top]
          Glob_zpos_x_top_tray = Glob_zpos_x_top_tray[where_tray_eq_x_top]
          Glob_energy_dep_x_top_tray = Glob_energy_dep_x_top_tray[where_tray_eq_x_top]
          Glob_pair_flag_x_top_tray = Glob_pair_flag_x_top_tray[where_tray_eq_x_top]

          where_layer_x_top = where((Glob_Si_id_x_top_tray EQ 0) and (Glob_energy_dep_x_top_tray GT 0.))
          ;print, k
          ;print, where_layer_x_top
          if (where_layer_x_top(0) NE -1) then begin
            Glob_vol_id_x_top_tray = Glob_vol_id_x_top_tray[where_layer_x_top]
            Glob_moth_id_x_top_tray = Glob_moth_id_x_top_tray[where_layer_x_top]
            Glob_Strip_id_x_top_tray = Glob_Strip_id_x_top_tray[where_layer_x_top]
            Glob_Si_id_x_top_tray = Glob_Si_id_x_top_tray[where_layer_x_top]
            Glob_tray_id_x_top_tray = Glob_tray_id_x_top_tray[where_layer_x_top]
            Glob_plane_id_x_top_tray = Glob_plane_id_x_top_tray[where_layer_x_top]
            Glob_xpos_x_top_tray = Glob_xpos_x_top_tray[where_layer_x_top]
            Glob_zpos_x_top_tray = Glob_zpos_x_top_tray[where_layer_x_top]
            Glob_energy_dep_x_top_tray = Glob_energy_dep_x_top_tray[where_layer_x_top]
            Glob_pair_flag_x_top_tray = Glob_pair_flag_x_top_tray[where_layer_x_top]


            ;print, 'k:', k
            ;print, 'n of same strip: ', n_elements(Glob_Strip_id_x_top_tray)
            sort_strip_ascending = sort(Glob_Strip_id_x_top_tray)
            Glob_vol_id_x_top_tray = Glob_vol_id_x_top_tray[sort_strip_ascending]
            Glob_moth_id_x_top_tray = Glob_moth_id_x_top_tray[sort_strip_ascending]
            Glob_Strip_id_x_top_tray = Glob_Strip_id_x_top_tray[sort_strip_ascending]
            Glob_Si_id_x_top_tray = Glob_Si_id_x_top_tray[sort_strip_ascending]
            Glob_tray_id_x_top_tray = Glob_tray_id_x_top_tray[sort_strip_ascending]
            Glob_plane_id_x_top_tray = Glob_plane_id_x_top_tray[sort_strip_ascending]
            Glob_xpos_x_top_tray = Glob_xpos_x_top_tray[sort_strip_ascending]
            Glob_zpos_x_top_tray = Glob_zpos_x_top_tray[sort_strip_ascending]
            Glob_energy_dep_x_top_tray = Glob_energy_dep_x_top_tray[sort_strip_ascending]
            Glob_pair_flag_x_top_tray = Glob_pair_flag_x_top_tray[sort_strip_ascending]

            e_cluster_temp = Glob_energy_dep_x_top_tray(0)
            wx_cluster_temp = Glob_xpos_x_top_tray(0)*Glob_energy_dep_x_top_tray(0)
            nstrip_temp = 1

            if (n_elements(Glob_Strip_id_x_top_tray) EQ 1) then begin
              Glob_event_id_x_top_cluster = [Glob_event_id_x_top_cluster, k]
              Glob_Si_id_x_top_cluster = [Glob_Si_id_x_top_cluster, Glob_Si_id_x_top_tray]
              Glob_tray_id_x_top_cluster = [Glob_tray_id_x_top_cluster, Glob_tray_id_x_top_tray]
              Glob_plane_id_x_top_cluster = [Glob_plane_id_x_top_cluster, Glob_plane_id_x_top_tray]
              Glob_zpos_x_top_cluster = [Glob_zpos_x_top_cluster, Glob_zpos_x_top_tray]
              Glob_energy_dep_x_top_cluster = [Glob_energy_dep_x_top_cluster, total(e_cluster_temp)]
              Glob_xpos_x_top_cluster = [Glob_xpos_x_top_cluster, total(wx_cluster_temp)/total(e_cluster_temp)]
              Glob_Strip_number_x_top_cluster = [Glob_Strip_number_x_top_cluster , nstrip_temp]
              Glob_pair_flag_x_top_cluster = [Glob_pair_flag_x_top_cluster, Glob_pair_flag_x_top_tray]
            endif else begin
              ;print, 'plane: ', Glob_plane_id_x_top_tray(0)
              ;print, 'pos: ', Glob_xpos_x_top_tray
              ;print, 'energy: ',  Glob_energy_dep_x_top_tray

              for jc=0l, n_elements(Glob_Strip_id_x_top_tray) -2 do begin
                if (Glob_Strip_id_x_top_tray(jc+1) EQ (Glob_Strip_id_x_top_tray(jc)+1)) then begin
                  e_cluster_temp = [e_cluster_temp, Glob_energy_dep_x_top_tray(jc+1)]
                  wx_cluster_temp = [wx_cluster_temp, Glob_xpos_x_top_tray(jc + 1)*Glob_energy_dep_x_top_tray(jc+1)]
                  nstrip_temp = nstrip_temp+1

                  ;print, Glob_xpos_x_top_tray(jc)
                  if (jc EQ (n_elements(Glob_Strip_id_x_top_tray)-2)) then begin
                    Glob_event_id_x_top_cluster = [Glob_event_id_x_top_cluster, k]
                    Glob_Si_id_x_top_cluster = [Glob_Si_id_x_top_cluster, Glob_Si_id_x_top_tray(jc)]
                    Glob_tray_id_x_top_cluster = [Glob_tray_id_x_top_cluster, Glob_tray_id_x_top_tray(jc)]
                    Glob_plane_id_x_top_cluster = [Glob_plane_id_x_top_cluster, Glob_plane_id_x_top_tray(jc)]
                    Glob_zpos_x_top_cluster = [Glob_zpos_x_top_cluster, Glob_zpos_x_top_tray(jc)]
                    Glob_energy_dep_x_top_cluster = [Glob_energy_dep_x_top_cluster, total(e_cluster_temp)]
                    Glob_xpos_x_top_cluster = [Glob_xpos_x_top_cluster, total(wx_cluster_temp)/total(e_cluster_temp)]
                    Glob_Strip_number_x_top_cluster = [Glob_Strip_number_x_top_cluster , nstrip_temp]
                    Glob_pair_flag_x_top_cluster = [Glob_pair_flag_x_top_cluster, Glob_pair_flag_x_top_tray(jc)]
                  endif
                endif else begin
                  Glob_event_id_x_top_cluster = [Glob_event_id_x_top_cluster, k]
                  Glob_Si_id_x_top_cluster = [Glob_Si_id_x_top_cluster, Glob_Si_id_x_top_tray(jc)]
                  Glob_tray_id_x_top_cluster = [Glob_tray_id_x_top_cluster, Glob_tray_id_x_top_tray(jc)]
                  Glob_plane_id_x_top_cluster = [Glob_plane_id_x_top_cluster, Glob_plane_id_x_top_tray(jc)]
                  Glob_zpos_x_top_cluster = [Glob_zpos_x_top_cluster, Glob_zpos_x_top_tray(jc)]
                  Glob_energy_dep_x_top_cluster = [Glob_energy_dep_x_top_cluster, total(e_cluster_temp)]
                  Glob_xpos_x_top_cluster = [Glob_xpos_x_top_cluster, total(wx_cluster_temp)/total(e_cluster_temp)]
                  Glob_Strip_number_x_top_cluster = [Glob_Strip_number_x_top_cluster , nstrip_temp]
                  Glob_pair_flag_x_top_cluster = [Glob_pair_flag_x_top_cluster, Glob_pair_flag_x_top_tray(jc)]

                  e_cluster_temp = Glob_energy_dep_x_top_tray(jc+1)
                  wx_cluster_temp = Glob_xpos_x_top_tray(jc+1)*Glob_energy_dep_x_top_tray(jc+1)
                  nstrip_temp = 1

                  if (jc EQ (n_elements(Glob_Strip_id_x_top_tray)-2)) then begin
                    Glob_event_id_x_top_cluster = [Glob_event_id_x_top_cluster, k]
                    Glob_Si_id_x_top_cluster = [Glob_Si_id_x_top_cluster, Glob_Si_id_x_top_tray(jc+1)]
                    Glob_tray_id_x_top_cluster = [Glob_tray_id_x_top_cluster, Glob_tray_id_x_top_tray(jc+1)]
                    Glob_plane_id_x_top_cluster = [Glob_plane_id_x_top_cluster, Glob_plane_id_x_top_tray(jc+1)]
                    Glob_zpos_x_top_cluster = [Glob_zpos_x_top_cluster, Glob_zpos_x_top_tray(jc+1)]
                    Glob_energy_dep_x_top_cluster = [Glob_energy_dep_x_top_cluster, Glob_energy_dep_x_top_tray(jc+1)]
                    Glob_xpos_x_top_cluster = [Glob_xpos_x_top_cluster, Glob_xpos_x_top_tray(jc +1)]
                    Glob_Strip_number_x_top_cluster = [Glob_Strip_number_x_top_cluster , nstrip_temp]
                    Glob_pair_flag_x_top_cluster = [Glob_pair_flag_x_top_cluster, Glob_pair_flag_x_top_tray(jc+1)]
                  endif
                endelse
              endfor
              ;print, 'Glob_xpos_x_top_cluster: ', Glob_xpos_x_top_cluster
              ;print, 'Glob_energy_dep_x_top_cluster: ', Glob_energy_dep_x_top_cluster
            endelse
          endif

          N_tray_eq_x = n_elements(where_tray_eq_x_top)
          if where_tray_eq_x_top(N_tray_eq_x-1) LT (n_elements(Glob_tray_id_x_top(*,k))-1) then begin
            j = where_tray_eq_x_top(N_tray_eq_x-1)+1
          endif else break
        endwhile

      endfor

      Glob_event_id_x_top_cluster = Glob_event_id_x_top_cluster[1:*]
      Glob_Si_id_x_top_cluster = Glob_Si_id_x_top_cluster[1:*]
      Glob_tray_id_x_top_cluster = Glob_tray_id_x_top_cluster[1:*]
      Glob_plane_id_x_top_cluster = Glob_plane_id_x_top_cluster[1:*]
      Glob_xpos_x_top_cluster = Glob_xpos_x_top_cluster[1:*]
      Glob_zpos_x_top_cluster = Glob_zpos_x_top_cluster[1:*]
      Glob_energy_dep_x_top_cluster = Glob_energy_dep_x_top_cluster[1:*]
      Glob_Strip_number_x_top_cluster = Glob_Strip_number_x_top_cluster[1:*]
      Glob_pair_flag_x_top_cluster = Glob_pair_flag_x_top_cluster[1:*]


      for k=0l, N_trig-1 do begin

        N_start = 0l
        j=0l
        while (1) do begin

          ; sorting the planes
          sort_ascending_plane_y = sort(Glob_plane_id_y_top(*, k))
          Glob_vol_id_y_top_tray = Glob_vol_id_y_top[sort_ascending_plane_y, k]
          Glob_moth_id_y_top_tray = Glob_moth_id_y_top[sort_ascending_plane_y, k]
          Glob_Strip_id_y_top_tray = Glob_Strip_id_y_top[sort_ascending_plane_y, k]
          Glob_Si_id_y_top_tray = Glob_Si_id_y_top[sort_ascending_plane_y, k]
          Glob_tray_id_y_top_tray = Glob_tray_id_y_top[sort_ascending_plane_y, k]
          Glob_plane_id_y_top_tray = Glob_plane_id_y_top[sort_ascending_plane_y, k]
          Glob_ypos_y_top_tray = Glob_ypos_y_top[sort_ascending_plane_y, k]
          Glob_zpos_y_top_tray = Glob_zpos_y_top[sort_ascending_plane_y, k]
          Glob_energy_dep_y_top_tray = Glob_energy_dep_y_top[sort_ascending_plane_y, k]
          Glob_pair_flag_y_top_tray = Glob_pair_flag_y_top[sort_ascending_plane_y, k]

          where_tray_eq_y_top = where(Glob_tray_id_y_top_tray EQ Glob_tray_id_y_top_tray(j))

          Glob_vol_id_y_top_tray = Glob_vol_id_y_top_tray[where_tray_eq_y_top]
          Glob_moth_id_y_top_tray = Glob_moth_id_y_top_tray[where_tray_eq_y_top]
          Glob_Strip_id_y_top_tray = Glob_Strip_id_y_top_tray[where_tray_eq_y_top]
          Glob_Si_id_y_top_tray = Glob_Si_id_y_top_tray[where_tray_eq_y_top]
          Glob_tray_id_y_top_tray = Glob_tray_id_y_top_tray[where_tray_eq_y_top]
          Glob_plane_id_y_top_tray = Glob_plane_id_y_top_tray[where_tray_eq_y_top]
          Glob_ypos_y_top_tray = Glob_ypos_y_top_tray[where_tray_eq_y_top]
          Glob_zpos_y_top_tray = Glob_zpos_y_top_tray[where_tray_eq_y_top]
          Glob_energy_dep_y_top_tray = Glob_energy_dep_y_top_tray[where_tray_eq_y_top]
          Glob_pair_flag_y_top_tray = Glob_pair_flag_y_top_tray[where_tray_eq_y_top]

          where_layer_y_top = where((Glob_Si_id_y_top_tray EQ 1) and (Glob_energy_dep_y_top_tray GT 0.))
          ;print, k
          ;print, where_layer_y_top
          if (where_layer_y_top(0) NE -1) then begin
            Glob_vol_id_y_top_tray = Glob_vol_id_y_top_tray[where_layer_y_top]
            Glob_moth_id_y_top_tray = Glob_moth_id_y_top_tray[where_layer_y_top]
            Glob_Strip_id_y_top_tray = Glob_Strip_id_y_top_tray[where_layer_y_top]
            Glob_Si_id_y_top_tray = Glob_Si_id_y_top_tray[where_layer_y_top]
            Glob_tray_id_y_top_tray = Glob_tray_id_y_top_tray[where_layer_y_top]
            Glob_plane_id_y_top_tray = Glob_plane_id_y_top_tray[where_layer_y_top]
            Glob_ypos_y_top_tray = Glob_ypos_y_top_tray[where_layer_y_top]
            Glob_zpos_y_top_tray = Glob_zpos_y_top_tray[where_layer_y_top]
            Glob_energy_dep_y_top_tray = Glob_energy_dep_y_top_tray[where_layer_y_top]
            Glob_pair_flag_y_top_tray = Glob_pair_flag_y_top_tray[where_layer_y_top]

            sort_strip_ascending = sort(Glob_Strip_id_y_top_tray)
            Glob_vol_id_y_top_tray = Glob_vol_id_y_top_tray[sort_strip_ascending]
            Glob_moth_id_y_top_tray = Glob_moth_id_y_top_tray[sort_strip_ascending]
            Glob_Strip_id_y_top_tray = Glob_Strip_id_y_top_tray[sort_strip_ascending]
            Glob_Si_id_y_top_tray = Glob_Si_id_y_top_tray[sort_strip_ascending]
            Glob_tray_id_y_top_tray = Glob_tray_id_y_top_tray[sort_strip_ascending]
            Glob_plane_id_y_top_tray = Glob_plane_id_y_top_tray[sort_strip_ascending]
            Glob_ypos_y_top_tray = Glob_ypos_y_top_tray[sort_strip_ascending]
            Glob_zpos_y_top_tray = Glob_zpos_y_top_tray[sort_strip_ascending]
            Glob_energy_dep_y_top_tray = Glob_energy_dep_y_top_tray[sort_strip_ascending]
            Glob_pair_flag_y_top_tray = Glob_pair_flag_y_top_tray[sort_strip_ascending]

            e_cluster_temp = Glob_energy_dep_y_top_tray(0)
            wx_cluster_temp = Glob_ypos_y_top_tray(0)*Glob_energy_dep_y_top_tray(0)
            nstrip_temp = 1
            ;print, 'k:', k
            ;print, 'n of same strip: ', n_elements(Glob_Strip_id_y_top_tray)

            if (n_elements(Glob_Strip_id_y_top_tray) EQ 1) then begin
              Glob_event_id_y_top_cluster = [Glob_event_id_y_top_cluster, k]
              Glob_Si_id_y_top_cluster = [Glob_Si_id_y_top_cluster, Glob_Si_id_y_top_tray]
              Glob_tray_id_y_top_cluster = [Glob_tray_id_y_top_cluster, Glob_tray_id_y_top_tray]
              Glob_plane_id_y_top_cluster = [Glob_plane_id_y_top_cluster, Glob_plane_id_y_top_tray]
              Glob_zpos_y_top_cluster = [Glob_zpos_y_top_cluster, Glob_zpos_y_top_tray]
              Glob_energy_dep_y_top_cluster = [Glob_energy_dep_y_top_cluster, total(e_cluster_temp)]
              Glob_ypos_y_top_cluster = [Glob_ypos_y_top_cluster, total(wx_cluster_temp)/total(e_cluster_temp)]
              Glob_Strip_number_y_top_cluster = [Glob_Strip_number_y_top_cluster , nstrip_temp]
              Glob_pair_flag_y_top_cluster = [Glob_pair_flag_y_top_cluster, Glob_pair_flag_y_top_tray]
            endif else begin
              ;print, 'plane: ', Glob_plane_id_y_top_tray(0)
              ;print, 'pos: ', Glob_ypos_y_top_tray
              ;print, 'energy: ',  Glob_energy_dep_y_top_tray
              for jc=0l, n_elements(Glob_Strip_id_y_top_tray) -2 do begin
                if (Glob_Strip_id_y_top_tray(jc+1) EQ (Glob_Strip_id_y_top_tray(jc)+1)) then begin
                  e_cluster_temp = [e_cluster_temp, Glob_energy_dep_y_top_tray(jc+1)]
                  wx_cluster_temp = [wx_cluster_temp, Glob_ypos_y_top_tray(jc + 1)*Glob_energy_dep_y_top_tray(jc+1)]
                  nstrip_temp = nstrip_temp+1
                  if (jc EQ (n_elements(Glob_Strip_id_y_top_tray)-2)) then begin
                    Glob_event_id_y_top_cluster = [Glob_event_id_y_top_cluster, k]
                    Glob_Si_id_y_top_cluster = [Glob_Si_id_y_top_cluster, Glob_Si_id_y_top_tray(jc)]
                    Glob_tray_id_y_top_cluster = [Glob_tray_id_y_top_cluster, Glob_tray_id_y_top_tray(jc)]
                    Glob_plane_id_y_top_cluster = [Glob_plane_id_y_top_cluster, Glob_plane_id_y_top_tray(jc)]
                    Glob_zpos_y_top_cluster = [Glob_zpos_y_top_cluster, Glob_zpos_y_top_tray(jc)]
                    Glob_energy_dep_y_top_cluster = [Glob_energy_dep_y_top_cluster, total(e_cluster_temp)]
                    Glob_ypos_y_top_cluster = [Glob_ypos_y_top_cluster, total(wx_cluster_temp)/total(e_cluster_temp)]
                    Glob_Strip_number_y_top_cluster = [Glob_Strip_number_y_top_cluster , nstrip_temp]
                    Glob_pair_flag_y_top_cluster = [Glob_pair_flag_y_top_cluster, Glob_pair_flag_y_top_tray(jc)]
                  endif
                endif else begin
                  Glob_event_id_y_top_cluster = [Glob_event_id_y_top_cluster, k]
                  Glob_Si_id_y_top_cluster = [Glob_Si_id_y_top_cluster, Glob_Si_id_y_top_tray(jc)]
                  Glob_tray_id_y_top_cluster = [Glob_tray_id_y_top_cluster, Glob_tray_id_y_top_tray(jc)]
                  Glob_plane_id_y_top_cluster = [Glob_plane_id_y_top_cluster, Glob_plane_id_y_top_tray(jc)]
                  Glob_zpos_y_top_cluster = [Glob_zpos_y_top_cluster, Glob_zpos_y_top_tray(jc)]
                  Glob_energy_dep_y_top_cluster = [Glob_energy_dep_y_top_cluster, total(e_cluster_temp)]
                  Glob_ypos_y_top_cluster = [Glob_ypos_y_top_cluster, total(wx_cluster_temp)/total(e_cluster_temp)]
                  Glob_Strip_number_y_top_cluster = [Glob_Strip_number_y_top_cluster , nstrip_temp]
                  Glob_pair_flag_y_top_cluster = [Glob_pair_flag_y_top_cluster, Glob_pair_flag_y_top_tray(jc)]

                  e_cluster_temp = Glob_energy_dep_y_top_tray(jc+1)
                  wx_cluster_temp = Glob_ypos_y_top_tray(jc+1)*Glob_energy_dep_y_top_tray(jc+1)
                  nstrip_temp = 1

                  if (jc EQ (n_elements(Glob_Strip_id_y_top_tray)-2)) then begin
                    Glob_event_id_y_top_cluster = [Glob_event_id_y_top_cluster, k]
                    Glob_Si_id_y_top_cluster = [Glob_Si_id_y_top_cluster, Glob_Si_id_y_top_tray(jc+1)]
                    Glob_tray_id_y_top_cluster = [Glob_tray_id_y_top_cluster, Glob_tray_id_y_top_tray(jc+1)]
                    Glob_plane_id_y_top_cluster = [Glob_plane_id_y_top_cluster, Glob_plane_id_y_top_tray(jc+1)]
                    Glob_zpos_y_top_cluster = [Glob_zpos_y_top_cluster, Glob_zpos_y_top_tray(jc+1)]
                    Glob_energy_dep_y_top_cluster = [Glob_energy_dep_y_top_cluster, Glob_energy_dep_y_top_tray(jc+1)]
                    Glob_ypos_y_top_cluster = [Glob_ypos_y_top_cluster, Glob_ypos_y_top_tray(jc +1)]
                    Glob_Strip_number_y_top_cluster = [Glob_Strip_number_y_top_cluster , nstrip_temp]
                    Glob_pair_flag_y_top_cluster = [Glob_pair_flag_y_top_cluster, Glob_pair_flag_y_top_tray(jc+1)]
                  endif
                endelse
              endfor
              ;print, 'Glob_ypos_y_top_cluster: ', Glob_ypos_y_top_cluster
              ;print, 'Glob_energy_dep_y_top_cluster: ', Glob_energy_dep_y_top_cluster
            endelse
          endif

          N_tray_eq_y = n_elements(where_tray_eq_y_top)
          if where_tray_eq_y_top(N_tray_eq_y-1) LT (n_elements(Glob_tray_id_y_top(*,k))-1) then begin
            j = where_tray_eq_y_top(N_tray_eq_y-1)+1
          endif else break
        endwhile

      endfor

      Glob_event_id_y_top_cluster = Glob_event_id_y_top_cluster[1:*]
      Glob_Si_id_y_top_cluster = Glob_Si_id_y_top_cluster[1:*]
      Glob_tray_id_y_top_cluster = Glob_tray_id_y_top_cluster[1:*]
      Glob_plane_id_y_top_cluster = Glob_plane_id_y_top_cluster[1:*]
      Glob_ypos_y_top_cluster = Glob_ypos_y_top_cluster[1:*]
      Glob_zpos_y_top_cluster = Glob_zpos_y_top_cluster[1:*]
      Glob_energy_dep_y_top_cluster = Glob_energy_dep_y_top_cluster[1:*]
      Glob_Strip_number_y_top_cluster = Glob_Strip_number_y_top_cluster[1:*]
      Glob_pair_flag_y_top_cluster = Glob_pair_flag_y_top_cluster[1:*]



      print, '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%'
      print, '                      Tracker   '
      print, '             L0 - X-Y layers merging '
      print, '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%'


      Glob_event_id_cluster = -1l
      Glob_Si_id_cluster = -1l
      Glob_tray_id_cluster = -1l
      Glob_plane_id_cluster = -1l
      Glob_pos_cluster = -1.
      Glob_zpos_cluster = -1.
      Glob_energy_dep_cluster = -1.
      Glob_Strip_number_cluster = -1l
      Glob_pair_flag_cluster = -1l


      for j=0l, N_trig -1 do begin

        where_cluster_x_top = where(Glob_event_id_x_top_cluster EQ j)
        if (where_cluster_x_top(0) NE -1) then begin

          Glob_Strip_number_cluster_temp = Glob_Strip_number_x_top_cluster[where_cluster_x_top]
          Glob_Si_id_cluster_temp = Glob_Si_id_x_top_cluster[where_cluster_x_top]
          Glob_tray_id_cluster_temp = Glob_tray_id_x_top_cluster[where_cluster_x_top]
          Glob_plane_id_cluster_temp = Glob_plane_id_x_top_cluster[where_cluster_x_top]
          Glob_pos_cluster_temp = Glob_xpos_x_top_cluster[where_cluster_x_top]
          Glob_zpos_cluster_temp = Glob_zpos_x_top_cluster[where_cluster_x_top]
          Glob_energy_dep_cluster_temp = Glob_energy_dep_x_top_cluster[where_cluster_x_top]
          Glob_pair_flag_cluster_temp = Glob_pair_flag_x_top_cluster[where_cluster_x_top]


          where_cluster_y_top = where(Glob_event_id_y_top_cluster EQ j)
          if (where_cluster_y_top(0) NE -1) then begin

            Glob_Strip_number_cluster_temp = [Glob_Strip_number_cluster_temp, Glob_Strip_number_y_top_cluster[where_cluster_y_top]]
            Glob_Si_id_cluster_temp = [Glob_Si_id_cluster_temp, Glob_Si_id_y_top_cluster[where_cluster_y_top]]
            Glob_tray_id_cluster_temp = [Glob_tray_id_cluster_temp, Glob_tray_id_y_top_cluster[where_cluster_y_top]]
            Glob_plane_id_cluster_temp = [Glob_plane_id_cluster_temp, Glob_plane_id_y_top_cluster[where_cluster_y_top]]
            Glob_pos_cluster_temp = [Glob_pos_cluster_temp, Glob_ypos_y_top_cluster[where_cluster_y_top]]
            Glob_zpos_cluster_temp = [Glob_zpos_cluster_temp, Glob_zpos_y_top_cluster[where_cluster_y_top]]
            Glob_energy_dep_cluster_temp = [Glob_energy_dep_cluster_temp, Glob_energy_dep_y_top_cluster[where_cluster_y_top]]
            Glob_pair_flag_cluster_temp = [Glob_pair_flag_cluster_temp, Glob_pair_flag_y_top_cluster[where_cluster_y_top]]
          endif

        endif else begin
          where_cluster_y_top = where(Glob_event_id_y_top_cluster EQ j)
          if (where_cluster_y_top(0) NE -1) then begin
            Glob_Strip_number_cluster_temp = Glob_Strip_number_y_top_cluster[where_cluster_y_top]
            Glob_Si_id_cluster_temp = Glob_Si_id_y_top_cluster[where_cluster_y_top]
            Glob_tray_id_cluster_temp = Glob_tray_id_y_top_cluster[where_cluster_y_top]
            Glob_plane_id_cluster_temp = Glob_plane_id_y_top_cluster[where_cluster_y_top]
            Glob_pos_cluster_temp = Glob_ypos_y_top_cluster[where_cluster_y_top]
            Glob_zpos_cluster_temp = Glob_zpos_y_top_cluster[where_cluster_y_top]
            Glob_energy_dep_cluster_temp = Glob_energy_dep_y_top_cluster[where_cluster_y_top]
            Glob_pair_flag_cluster_temp = Glob_pair_flag_y_top_cluster[where_cluster_y_top]
          endif
        endelse

        tray_sort_arr = sort(Glob_tray_id_cluster_temp)

        Glob_Si_id_cluster_temp = Glob_Si_id_cluster_temp[reverse(tray_sort_arr)]
        Glob_tray_id_cluster_temp = Glob_tray_id_cluster_temp[reverse(tray_sort_arr)]
        Glob_plane_id_cluster_temp = Glob_plane_id_cluster_temp[reverse(tray_sort_arr)]
        Glob_pos_cluster_temp = Glob_pos_cluster_temp[reverse(tray_sort_arr)]
        Glob_zpos_cluster_temp = Glob_zpos_cluster_temp[reverse(tray_sort_arr)]
        Glob_energy_dep_cluster_temp = Glob_energy_dep_cluster_temp[reverse(tray_sort_arr)]
        Glob_Strip_number_cluster_temp = Glob_Strip_number_cluster_temp[reverse(tray_sort_arr)]
        Glob_pair_flag_cluster_temp = Glob_pair_flag_cluster_temp[reverse(tray_sort_arr)]


        Si_id_intray = -1l
        tray_id_intray = -1l
        plane_id_intray = -1l
        pos_intray = -1.
        zpos_intray = -1.
        energy_dep_intray = -1.
        strip_number_intray = -1l
        pair_flag_intray = -1l

        intray = 0l
        while(1) do begin
          where_tray_eq = where(Glob_tray_id_cluster_temp EQ Glob_tray_id_cluster_temp(intray), complement = where_other_tray)

          Si_id_extract = Glob_Si_id_cluster_temp[where_tray_eq]
          tray_id_extract = Glob_tray_id_cluster_temp[where_tray_eq]
          plane_id_extract = Glob_plane_id_cluster_temp[where_tray_eq]
          pos_extract = Glob_pos_cluster_temp[where_tray_eq]
          zpos_extract = Glob_zpos_cluster_temp[where_tray_eq]
          energy_dep_extract = Glob_energy_dep_cluster_temp[where_tray_eq]
          strip_number_extract = Glob_Strip_number_cluster_temp[where_tray_eq]
          pair_flag_extract = Glob_pair_flag_cluster_temp[where_tray_eq]

          where_Xtop = where(Si_id_extract EQ 0)
          if (where_Xtop(0) NE -1) then begin
            Si_id_intray = [Si_id_intray, Si_id_extract[where_Xtop]]
            tray_id_intray = [tray_id_intray, tray_id_extract[where_Xtop]]
            plane_id_intray = [plane_id_intray, plane_id_extract[where_Xtop]]
            pos_intray = [pos_intray, pos_extract[where_Xtop]]
            zpos_intray = [zpos_intray, zpos_extract[where_Xtop]]
            energy_dep_intray = [energy_dep_intray, energy_dep_extract[where_Xtop]]
            strip_number_intray = [strip_number_intray, strip_number_extract[where_Xtop]]
            pair_flag_intray = [pair_flag_intray, pair_flag_extract[where_Xtop]]
          endif
          where_Ytop = where(Si_id_extract EQ 1)
          if (where_Ytop(0) NE -1) then begin
            Si_id_intray = [Si_id_intray, Si_id_extract[where_Ytop]]
            tray_id_intray = [tray_id_intray, tray_id_extract[where_Ytop]]
            plane_id_intray = [plane_id_intray, plane_id_extract[where_Ytop]]
            pos_intray = [pos_intray, pos_extract[where_Ytop]]
            zpos_intray = [zpos_intray, zpos_extract[where_Ytop]]
            energy_dep_intray = [energy_dep_intray, energy_dep_extract[where_Ytop]]
            strip_number_intray = [strip_number_intray, strip_number_extract[where_Ytop]]
            pair_flag_intray = [pair_flag_intray, pair_flag_extract[where_Ytop]]
          endif

          N_tray_eq = n_elements(where_tray_eq)
          if where_tray_eq(N_tray_eq-1) LT (n_elements(Glob_tray_id_cluster_temp)-1) then begin
            intray = where_tray_eq(N_tray_eq-1)+1
          endif else break
        endwhile

        Si_id_temp = Si_id_intray[1:*]
        tray_id_temp = tray_id_intray[1:*]
        plane_id_temp = plane_id_intray[1:*]
        pos_temp = pos_intray[1:*]
        zpos_temp = zpos_intray[1:*]
        energy_dep_temp = energy_dep_intray[1:*]
        strip_number_temp = strip_number_intray[1:*]
        pair_flag_temp = pair_flag_intray[1:*]

        event_id_temp = lonarr(n_elements(Si_id_temp))
        for k=0l, n_elements(Si_id_temp)-1 do begin
          event_id_temp(k) = event_array(j)
        endfor

        Glob_event_id_cluster = [Glob_event_id_cluster, event_id_temp]
        Glob_Si_id_cluster = [Glob_Si_id_cluster, Si_id_temp]
        Glob_tray_id_cluster = [Glob_tray_id_cluster, tray_id_temp]
        Glob_plane_id_cluster = [Glob_plane_id_cluster, plane_id_temp]
        Glob_pos_cluster = [Glob_pos_cluster, pos_temp]
        Glob_zpos_cluster = [Glob_zpos_cluster, zpos_temp]
        Glob_energy_dep_cluster = [Glob_energy_dep_cluster, energy_dep_temp]
        Glob_Strip_number_cluster = [Glob_Strip_number_cluster, strip_number_temp]
        Glob_pair_flag_cluster = [Glob_pair_flag_cluster, pair_flag_temp]

      endfor

      Glob_event_id_cluster = Glob_event_id_cluster[1:*]
      Glob_Si_id_cluster =  Glob_Si_id_cluster[1:*]
      Glob_tray_id_cluster =  Glob_tray_id_cluster[1:*]
      Glob_plane_id_cluster =  Glob_plane_id_cluster[1:*]
      Glob_pos_cluster = Glob_pos_cluster[1:*]
      Glob_zpos_cluster = Glob_zpos_cluster[1:*]
      Glob_energy_dep_cluster = Glob_energy_dep_cluster[1:*]
      Glob_Strip_number_cluster = Glob_Strip_number_cluster[1:*]
      Glob_pair_flag_cluster = Glob_pair_flag_cluster[1:*]


      ; Level 0.5 = energy summed, MIP threshold applied, strip position used

      CREATE_STRUCT, L05TRACKER, 'TRACKERL05', ['EVT_ID', 'TRAY_ID','PLANE_ID','TRK_FLAG','POS', 'ZPOS','E_DEP','PAIR_FLAG'], 'J,I,I,I,F20.5,F20.5,F20.5,I', DIMEN = N_ELEMENTS(Glob_event_id_cluster)
      L05TRACKER.EVT_ID = Glob_event_id_cluster
      L05TRACKER.TRAY_ID = Glob_tray_id_cluster
      L05TRACKER.PLANE_ID = Glob_plane_id_cluster
      L05TRACKER.TRK_FLAG = Glob_Si_id_cluster
      L05TRACKER.POS = Glob_pos_cluster
      L05TRACKER.ZPOS = Glob_zpos_cluster
      L05TRACKER.E_DEP = Glob_energy_dep_cluster
      L05TRACKER.PAIR_FLAG = Glob_pair_flag_cluster

      HDR_L05GLOBAL = ['Creator          = Valentina Fioretti', $
        'THELSIM release  = eASTROGAM '+astrogam_version, $
        'N_IN             = '+STRTRIM(STRING(N_IN),1)+'   /Number of simulated particles', $
        'N_TRIG           = '+STRTRIM(STRING(N_TRIG),1)+'   /Number of triggering events', $
        'ENERGY           = '+ene_type+'   /Simulated input energy', $
        'THETA            = '+STRTRIM(STRING(THETA_TYPE),1)+'   /Simulated input theta angle', $
        'PHI              = '+STRTRIM(STRING(PHI_TYPE),1)+'   /Simulated input phi angle', $
        'ENERGY UNIT      = KEV']


      MWRFITS, L05TRACKER, outdir+'/L0.5.eASTROGAM'+astrogam_version+'.'+py_name+'.'+sim_name+'.'+stripname+'.'+sname+'.'+STRMID(STRTRIM(STRING(N_IN),1),0,10)+part_type+'.'+ene_type+'MeV.'+STRMID(STRTRIM(STRING(THETA_TYPE),1),0,10)+'.'+STRMID(STRTRIM(STRING(PHI_TYPE),1),0,10)+'.'+pol_string+strtrim(string(ifile),1)+'.fits', HDR_L05GLOBAL, /CREATE



      print, '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%'
      print, '         ASCII data format for AA input - cluster'
      print, '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%'


      openw,lun,outdir+'/'+sim_tag+'_CLUSTER_'+strmid(strtrim(string(N_in),1),0,10)+part_type+'_'+sname+'_'+ene_dis+'_'+ang_type+'_'+ene_type+'MeV_'+strmid(strtrim(string(theta_type),1),0,10)+'_'+strmid(strtrim(string(phi_type),1),0,10)+'.'+pol_string+strtrim(string(ifile),1)+'.dat',/get_lun
      ; ASCII Columns:
      ; - c1 = event ID
      ; - c2 = theta input
      ; - c3 = phi input
      ; - c4 = energy input
      ; - c5 = plane ID
      ; - c6 = Pos Z
      ; - c7 = X/Y flag (X = 0, Y = 1)
      ; - c8 = Cluster position (reference system center at the Silicon layer center)
      ; - c9 = energy deposition (keV)
      ; - c10 = number of strips composing the cluster
      ; - c11 = pair flag (1 = pair, 0 = not pair, 2 = compton)


      event_start = -1
      totalstrips_before = 0l
      j=0l
      while (1) do begin
        where_event_eq = where(Glob_event_id_cluster EQ Glob_event_id_cluster(j))
        Glob_Si_id_cluster_temp = Glob_Si_id_cluster(where_event_eq)
        Glob_tray_id_cluster_temp  = Glob_tray_id_cluster(where_event_eq)
        Glob_plane_id_cluster_temp  = Glob_plane_id_cluster(where_event_eq)
        Glob_energy_dep_cluster_temp = Glob_energy_dep_cluster(where_event_eq)
        Glob_pos_cluster_temp = Glob_pos_cluster(where_event_eq)
        Glob_zpos_cluster_temp = Glob_zpos_cluster(where_event_eq)
        Glob_pair_flag_cluster_temp = Glob_pair_flag_cluster(where_event_eq)

        Glob_Strip_number_cluster_temp = Glob_Strip_number_cluster(where_event_eq)

        ; ------------------------------------
        ; X VIEW
        where_x = where(Glob_Si_id_cluster_temp EQ 0)
        if (where_x(0) NE -1) then begin
          for r=0l, n_elements(where_x)-1 do begin
            printf, lun, Glob_event_id_cluster(j), theta_type, phi_type, ene_type, Glob_plane_id_cluster_temp(where_x(r)), Glob_zpos_cluster_temp(where_x(r)), 0, Glob_pos_cluster_temp(where_x(r)), Glob_energy_dep_cluster_temp(where_x(r)), Glob_Strip_number_cluster_temp(where_x(r)), Glob_pair_flag_cluster_temp(where_x(r)), format='(I5,I5,I5,I7,I5,F10.5,I5,F10.5,F10.5,I5,I5)'
          endfor
        endif

        ; Y VIEW
        where_y = where(Glob_Si_id_cluster_temp EQ 1)
        if (where_y(0) NE -1) then begin
          for r=0l, n_elements(where_y)-1 do begin
            printf, lun, Glob_event_id_cluster(j), theta_type, phi_type, ene_type, Glob_plane_id_cluster_temp(where_y(r)), Glob_zpos_cluster_temp(where_y(r)), 1, Glob_pos_cluster_temp(where_y(r)), Glob_energy_dep_cluster_temp(where_y(r)), Glob_Strip_number_cluster_temp(where_y(r)), Glob_pair_flag_cluster_temp(where_y(r)), format='(I5,I5,I5,I7,I5,F10.5,I5,F10.5,F10.5,I5,I5)'
          endfor
        endif
        ; ------------------------------------

        N_event_eq = n_elements(where_event_eq)
        if where_event_eq(N_event_eq-1) LT (n_elements(Glob_event_id_cluster)-1) then begin
          j = where_event_eq(N_event_eq-1)+1
        endif else break
      endwhile

      Free_lun, lun

      print, '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%'
      print, '      ASCII data format for AA input - cluster - only pairs'
      print, '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%'


      openw,lun,outdir+'/'+sim_tag+'_CLUSTER_PAIR_'+strmid(strtrim(string(N_in),1),0,10)+part_type+'_'+sname+'_'+ene_dis+'_'+ang_type+'_'+ene_type+'MeV_'+strmid(strtrim(string(theta_type),1),0,10)+'_'+strmid(strtrim(string(phi_type),1),0,10)+'.'+pol_string+strtrim(string(ifile),1)+'.dat',/get_lun
      ; ASCII Columns:
      ; - c1 = event ID
      ; - c2 = theta input
      ; - c3 = phi input
      ; - c4 = energy input
      ; - c5 = plane ID
      ; - c6 = Pos Z
      ; - c7 = X/Y flag (X = 0, Y = 1)
      ; - c8 = Cluster position (reference system center at the Silicon layer center)
      ; - c9 = energy deposition (keV)
      ; - c10 = number of strips composing the cluster
      ; - c11 = pair flag (1 = pair)


      event_start = -1
      totalstrips_before = 0l
      j=0l
      while (1) do begin
        where_event_eq = where(Glob_event_id_cluster EQ Glob_event_id_cluster(j))
        Glob_Si_id_cluster_temp = Glob_Si_id_cluster(where_event_eq)
        Glob_tray_id_cluster_temp  = Glob_tray_id_cluster(where_event_eq)
        Glob_plane_id_cluster_temp  = Glob_plane_id_cluster(where_event_eq)
        Glob_energy_dep_cluster_temp = Glob_energy_dep_cluster(where_event_eq)
        Glob_pos_cluster_temp = Glob_pos_cluster(where_event_eq)
        Glob_zpos_cluster_temp = Glob_zpos_cluster(where_event_eq)
        Glob_pair_flag_cluster_temp = Glob_pair_flag_cluster(where_event_eq)

        Glob_Strip_number_cluster_temp = Glob_Strip_number_cluster(where_event_eq)

        ; ------------------------------------
        ; X VIEW
        where_x = where(Glob_Si_id_cluster_temp EQ 0)
        if (where_x(0) NE -1) then begin
          for r=0l, n_elements(where_x)-1 do begin
            if (Glob_pair_flag_cluster_temp(where_x(r)) EQ 1) then printf, lun, Glob_event_id_cluster(j), theta_type, phi_type, ene_type, Glob_plane_id_cluster_temp(where_x(r)), Glob_zpos_cluster_temp(where_x(r)), 0, Glob_pos_cluster_temp(where_x(r)), Glob_energy_dep_cluster_temp(where_x(r)), Glob_Strip_number_cluster_temp(where_x(r)), Glob_pair_flag_cluster_temp(where_x(r)), format='(I5,I5,I5,I7,I5,F10.5,I5,F10.5,F10.5,I5,I5)'
          endfor
        endif

        ; Y VIEW
        where_y = where(Glob_Si_id_cluster_temp EQ 1)
        if (where_y(0) NE -1) then begin
          for r=0l, n_elements(where_y)-1 do begin
            if (Glob_pair_flag_cluster_temp(where_y(r)) EQ 1) then printf, lun, Glob_event_id_cluster(j), theta_type, phi_type, ene_type, Glob_plane_id_cluster_temp(where_y(r)), Glob_zpos_cluster_temp(where_y(r)), 1, Glob_pos_cluster_temp(where_y(r)), Glob_energy_dep_cluster_temp(where_y(r)), Glob_Strip_number_cluster_temp(where_y(r)), Glob_pair_flag_cluster_temp(where_y(r)), format='(I5,I5,I5,I7,I5,F10.5,I5,F10.5,F10.5,I5,I5)'
          endfor
        endif
        ; ------------------------------------

        N_event_eq = n_elements(where_event_eq)
        if where_event_eq(N_event_eq-1) LT (n_elements(Glob_event_id_cluster)-1) then begin
          j = where_event_eq(N_event_eq-1)+1
        endif else break
      endwhile

      Free_lun, lun

      print, '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%'
      print, '      ASCII data format for AA input - cluster - only compton'
      print, '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%'
      
      
      openw,lun,outdir+'/'+sim_tag+'_CLUSTER_COMPTON_'+strmid(strtrim(string(N_in),1),0,10)+part_type+'_'+sname+'_'+ene_dis+'_'+ang_type+'_'+ene_type+'MeV_'+strmid(strtrim(string(theta_type),1),0,10)+'_'+strmid(strtrim(string(phi_type),1),0,10)+'.'+pol_string+strtrim(string(ifile),1)+'.dat',/get_lun
      ; ASCII Columns:
      ; - c1 = event ID
      ; - c2 = theta input
      ; - c3 = phi input
      ; - c4 = energy input
      ; - c5 = plane ID
      ; - c6 = Pos Z
      ; - c7 = X/Y flag (X = 0, Y = 1)
      ; - c8 = Cluster position (reference system center at the Silicon layer center)
      ; - c9 = energy deposition (keV)
      ; - c10 = number of strips composing the cluster
      ; - c11 = pair flag (2 = compton)
      
      
      event_start = -1
      totalstrips_before = 0l
      j=0l
      while (1) do begin
        where_event_eq = where(Glob_event_id_cluster EQ Glob_event_id_cluster(j))
        Glob_Si_id_cluster_temp = Glob_Si_id_cluster(where_event_eq)
        Glob_tray_id_cluster_temp  = Glob_tray_id_cluster(where_event_eq)
        Glob_plane_id_cluster_temp  = Glob_plane_id_cluster(where_event_eq)
        Glob_energy_dep_cluster_temp = Glob_energy_dep_cluster(where_event_eq)
        Glob_pos_cluster_temp = Glob_pos_cluster(where_event_eq)
        Glob_zpos_cluster_temp = Glob_zpos_cluster(where_event_eq)
        Glob_pair_flag_cluster_temp = Glob_pair_flag_cluster(where_event_eq)
        
        Glob_Strip_number_cluster_temp = Glob_Strip_number_cluster(where_event_eq)
        
        ; ------------------------------------
        ; X VIEW
        where_x = where(Glob_Si_id_cluster_temp EQ 0)
        if (where_x(0) NE -1) then begin
          for r=0l, n_elements(where_x)-1 do begin
            if (Glob_pair_flag_cluster_temp(where_x(r)) EQ 2) then printf, lun, Glob_event_id_cluster(j), theta_type, phi_type, ene_type, Glob_plane_id_cluster_temp(where_x(r)), Glob_zpos_cluster_temp(where_x(r)), 0, Glob_pos_cluster_temp(where_x(r)), Glob_energy_dep_cluster_temp(where_x(r)), Glob_Strip_number_cluster_temp(where_x(r)), Glob_pair_flag_cluster_temp(where_x(r)), format='(I5,I5,I5,I7,I5,F10.5,I5,F10.5,F10.5,I5,I5)'
          endfor
        endif
        
        ; Y VIEW
        where_y = where(Glob_Si_id_cluster_temp EQ 1)
        if (where_y(0) NE -1) then begin
          for r=0l, n_elements(where_y)-1 do begin
            if (Glob_pair_flag_cluster_temp(where_y(r)) EQ 2) then printf, lun, Glob_event_id_cluster(j), theta_type, phi_type, ene_type, Glob_plane_id_cluster_temp(where_y(r)), Glob_zpos_cluster_temp(where_y(r)), 1, Glob_pos_cluster_temp(where_y(r)), Glob_energy_dep_cluster_temp(where_y(r)), Glob_Strip_number_cluster_temp(where_y(r)), Glob_pair_flag_cluster_temp(where_y(r)), format='(I5,I5,I5,I7,I5,F10.5,I5,F10.5,F10.5,I5,I5)'
          endfor
        endif
        ; ------------------------------------
        
        N_event_eq = n_elements(where_event_eq)
        if where_event_eq(N_event_eq-1) LT (n_elements(Glob_event_id_cluster)-1) then begin
          j = where_event_eq(N_event_eq-1)+1
        endif else break
      endwhile
      
      Free_lun, lun

    endif ; endif end of is Strip
  endif

  if (cal_flag EQ 1) then begin

    ; %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    ;                             Processing the calorimeter
    ; %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    print, '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%'
    print, '          Calorimeter Bar Energy attenuation                '
    print, '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%'

    bar_ene = energy_dep_cal

    print, '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%'
    print, '                   Calorimeter                '
    print, '              Applying the minimum cut                '
    print, '                Summing the energy                '
    print, '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%'

    N_trig_cal = 0l

    event_id_tot_cal = -1l
    vol_id_tot_cal = -1l
    moth_id_tot_cal = -1l
    bar_id_tot = -1l
    bar_ene_tot = -1.

    j=0l
    while (1) do begin
      where_event_eq = where(event_id_cal EQ event_id_cal(j))

      N_trig_cal = N_trig_cal + 1

      vol_id_temp_cal = vol_id_cal(where_event_eq)
      moth_id_temp_cal = moth_id_cal(where_event_eq)
      bar_ene_temp = bar_ene(where_event_eq)

      r = 0l
      while(1) do begin
        where_vol_eq = where(vol_id_temp_cal EQ vol_id_temp_cal(r), complement = where_other_vol)
        bar_ene_tot_temp = total(bar_ene_temp(where_vol_eq))
        if (bar_ene_tot_temp GT E_th_cal) then begin
          event_id_tot_cal = [event_id_tot_cal, event_id_cal(j)]
          vol_id_tot_cal = [vol_id_tot_cal, vol_id_temp_cal(r)]
          bar_id_tot = [bar_id_tot, vol_id_temp_cal(r) - cal_vol_start]
          moth_id_tot_cal = [moth_id_tot_cal, moth_id_temp_cal(r)]
          bar_ene_tot = [bar_ene_tot, total(bar_ene_temp(where_vol_eq))]
        endif
        if (where_other_vol(0) NE -1) then begin
          vol_id_temp_cal = vol_id_temp_cal(where_other_vol)
          moth_id_temp_cal = moth_id_temp_cal(where_other_vol)
          bar_ene_temp = bar_ene_temp(where_other_vol)
        endif else break
      endwhile

      N_event_eq = n_elements(where_event_eq)
      if where_event_eq(N_event_eq-1) LT (n_elements(event_id_cal)-1) then begin
        j = where_event_eq(N_event_eq-1)+1
      endif else break
    endwhile


    if (n_elements(event_id_tot_cal) GT 1) then begin
      event_id_tot_cal = event_id_tot_cal[1:*]
      vol_id_tot_cal = vol_id_tot_cal[1:*]
      bar_id_tot = bar_id_tot[1:*]
      moth_id_tot_cal = moth_id_tot_cal[1:*]
      bar_ene_tot = bar_ene_tot[1:*]
    endif


    CREATE_STRUCT, calInput, 'input_cal_astrogam', ['EVT_ID', 'BAR_ID', 'BAR_ENERGY'], $
      'I,I,F20.15', DIMEN = n_elements(event_id_tot_cal)
    calInput.EVT_ID = event_id_tot_cal
    calInput.BAR_ID = bar_id_tot
    calInput.BAR_ENERGY = bar_ene_tot


    hdr_calInput = ['COMMENT  eASTROGAM V'+astrogam_version+' Geant4 simulation', $
      'N_in     = '+strtrim(string(N_in),1), $
      'Energy     = '+ene_type, $
      'Theta     = '+strtrim(string(theta_type),1), $
      'Phi     = '+strtrim(string(phi_type),1), $
      'Energy unit = GeV']

    MWRFITS, calInput, outdir+'/G4.CAL.eASTROGAM'+astrogam_version+'.'+py_name+'.'+sim_name+'.'+stripname+'.'+sname+'.'+strmid(strtrim(string(N_in),1),0,10)+part_type+'.'+ene_type+'MeV.'+strmid(strtrim(string(theta_type),1),0,10)+'.'+strmid(strtrim(string(phi_type),1),0,10)+'.'+pol_string+strtrim(string(ifile),1)+'.fits', hdr_calInput, /create

    event_id_tot_cal_sum = -1l
    bar_ene_tot_sum = -1.

    j=0l
    while (1) do begin
      where_event_eq = where(event_id_tot_cal EQ event_id_tot_cal(j))

      event_id_tot_cal_sum = [event_id_tot_cal_sum, event_id_tot_cal(j)]
      bar_ene_tot_sum = [bar_ene_tot_sum, total(bar_ene_tot(where_event_eq))]

      N_event_eq = n_elements(where_event_eq)
      if where_event_eq(N_event_eq-1) LT (n_elements(event_id_tot_cal)-1) then begin
        j = where_event_eq(N_event_eq-1)+1
      endif else break
    endwhile

    event_id_tot_cal_sum = event_id_tot_cal_sum[1:*]
    bar_ene_tot_sum = bar_ene_tot_sum[1:*]

    CREATE_STRUCT, calInputSum, 'input_cal_sum', ['EVT_ID','BAR_ENERGY'], $
      'I,F20.15', DIMEN = n_elements(event_id_tot_cal_sum)
    calInputSum.EVT_ID = event_id_tot_cal_sum
    calInputSum.BAR_ENERGY = bar_ene_tot_sum


    hdr_calInputSum = ['COMMENT  eASTROGAM V'+astrogam_version+' Geant4 simulation', $
      'N_in     = '+strtrim(string(N_in),1), $
      'Energy     = '+ene_type, $
      'Theta     = '+strtrim(string(theta_type),1), $
      'Phi     = '+strtrim(string(phi_type),1), $
      'Energy unit = GeV']

    MWRFITS, calInput, outdir+'/SUM.CAL.eASTROGAM'+astrogam_version+'.'+py_name+'.'+sim_name+'.'+stripname+'.'+sname+'.'+strmid(strtrim(string(N_in),1),0,10)+part_type+'.'+ene_type+'MeV.'+strmid(strtrim(string(theta_type),1),0,10)+'.'+strmid(strtrim(string(phi_type),1),0,10)+'.'+pol_string+strtrim(string(ifile),1)+'.fits', hdr_calInputSum, /create

  endif


  if (ac_flag EQ 1) then begin


    print, '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%'
    print, '                          AC'
    print, '                  Summing the energy                '
    print, '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%'

    N_trig_ac = 0l

    event_id_tot_ac = -1l
    vol_id_tot_ac = -1l
    moth_id_tot_ac = -1l
    energy_dep_tot_ac = -1.

    j=0l
    while (1) do begin
      where_event_eq = where(event_id_ac EQ event_id_ac(j))

      N_trig_ac = N_trig_ac + 1

      vol_id_temp_ac = vol_id_ac(where_event_eq)
      moth_id_temp_ac = moth_id_ac(where_event_eq)
      energy_dep_temp_ac = energy_dep_ac(where_event_eq)

      r = 0l
      while(1) do begin
        where_vol_eq = where(vol_id_temp_ac EQ vol_id_temp_ac(r), complement = where_other_vol)
        event_id_tot_ac = [event_id_tot_ac, event_id_ac(j)]
        vol_id_tot_ac = [vol_id_tot_ac, vol_id_temp_ac(r)]
        moth_id_tot_ac = [moth_id_tot_ac, moth_id_temp_ac(r)]
        energy_dep_tot_ac = [energy_dep_tot_ac, total(energy_dep_temp_ac(where_vol_eq))]
        if (where_other_vol(0) NE -1) then begin
          vol_id_temp_ac = vol_id_temp_ac(where_other_vol)
          moth_id_temp_ac = moth_id_temp_ac(where_other_vol)
          energy_dep_temp_ac = energy_dep_temp_ac(where_other_vol)
        endif else break
      endwhile

      N_event_eq = n_elements(where_event_eq)
      if where_event_eq(N_event_eq-1) LT (n_elements(event_id_ac)-1) then begin
        j = where_event_eq(N_event_eq-1)+1
      endif else break
    endwhile


    if (n_elements(event_id_tot_ac) GT 1) then begin
      event_id_tot_ac = event_id_tot_ac[1:*]
      vol_id_tot_ac = vol_id_tot_ac[1:*]
      moth_id_tot_ac = moth_id_tot_ac[1:*]
      energy_dep_tot_ac = energy_dep_tot_ac[1:*]
    endif

    ; AC panel IDs

    AC_panel = strarr(n_elements(vol_id_tot_ac))
    AC_subpanel = intarr(n_elements(vol_id_tot_ac))


    for j=0l, n_elements(vol_id_tot_ac)-1 do begin
      if ((vol_id_tot_ac(j) GE panel_S[0]) AND (vol_id_tot_ac(j) LE panel_S[2])) then begin
        AC_panel(j) = 'S'
        if (vol_id_tot_ac(j) EQ panel_S[0]) then AC_subpanel(j) = 3
        if (vol_id_tot_ac(j) EQ panel_S[1]) then AC_subpanel(j) = 2
        if (vol_id_tot_ac(j) EQ panel_S[2]) then AC_subpanel(j) = 1
      endif
      if ((vol_id_tot_ac(j) GE panel_D[0]) AND (vol_id_tot_ac(j) LE panel_D[2])) then begin
        AC_panel(j) = 'D'
        if (vol_id_tot_ac(j) EQ panel_D[0]) then AC_subpanel(j) = 3
        if (vol_id_tot_ac(j) EQ panel_D[1]) then AC_subpanel(j) = 2
        if (vol_id_tot_ac(j) EQ panel_D[2]) then AC_subpanel(j) = 1
      endif
      if ((vol_id_tot_ac(j) GE panel_F[0]) AND (vol_id_tot_ac(j) LE panel_F[2])) then begin
        AC_panel(j) = 'F'
        if (vol_id_tot_ac(j) EQ panel_F[0]) then AC_subpanel(j) = 1
        if (vol_id_tot_ac(j) EQ panel_F[1]) then AC_subpanel(j) = 2
        if (vol_id_tot_ac(j) EQ panel_F[2]) then AC_subpanel(j) = 3
      endif
      if ((vol_id_tot_ac(j) GE panel_B[0]) AND (vol_id_tot_ac(j) LE panel_B[2])) then begin
        AC_panel(j) = 'B'
        if (vol_id_tot_ac(j) EQ panel_B[0]) then AC_subpanel(j) = 1
        if (vol_id_tot_ac(j) EQ panel_B[1]) then AC_subpanel(j) = 2
        if (vol_id_tot_ac(j) EQ panel_B[2]) then AC_subpanel(j) = 3
      endif
      if (vol_id_tot_ac(j) EQ panel_top) then begin
        AC_panel(j) = 'T'
        AC_subpanel(j) = 0
      endif
    endfor

    CREATE_STRUCT, acInput, 'input_ac_dhsim', ['EVT_ID', 'AC_PANEL', 'AC_SUBPANEL', 'E_DEP'], $
      'I,A,I,F20.15', DIMEN = n_elements(event_id_tot_ac)
    acInput.EVT_ID = event_id_tot_ac
    acInput.AC_PANEL = AC_panel
    acInput.AC_SUBPANEL = AC_subpanel
    acInput.E_DEP = energy_dep_tot_ac


    hdr_acInput = ['COMMENT  eASTROGAM '+astrogam_version+' Geant4 simulation', $
      'N_in     = '+strtrim(string(N_in),1), $
      'Energy     = '+ene_type, $
      'Theta     = '+strtrim(string(theta_type),1), $
      'Phi     = '+strtrim(string(phi_type),1), $
      'Energy unit = GeV']

    MWRFITS, acInput, outdir+'/G4.AC.eASTROGAM'+astrogam_version+'.'+py_name+'.'+sim_name+'.'+stripname+'.'+sname+'.'+strmid(strtrim(string(N_in),1),0,10)+part_type+'.'+ene_type+'MeV.'+strmid(strtrim(string(theta_type),1),0,10)+'.'+strmid(strtrim(string(phi_type),1),0,10)+'.'+pol_string+strtrim(string(ifile),1)+'.fits', hdr_acInput, /create
    

  endif
endfor
end