; Sample NCL file
; This is a comment
f = addfile("data/fluxes_input.nc", "r")
o = addfile("data/fluxes_output.nc", "c")
t = f->t
v = f->v
printVarSummary(t)
printVarSummary(v)
tstar = t - conform(t, dim_avg_n(t, 3), (/0, 1, 2/))  ; zonal temperature anomaly
vstar = v - conform(v, dim_avg_n(v, 3), (/0, 1, 2/))  ; zonal meridional-wind anomaly
ehf = dim_avg_n(tstar * vstar, 3)  ; eddy heat flux
copy_VarCoords(t(:, :, :, 0), ehf)  ; add dimension coordinate data
ehf@long_name = "eddy heat flux"
ehf@units = "K*m/s"
printVarSummary(ehf)
o->ehf = ehf
