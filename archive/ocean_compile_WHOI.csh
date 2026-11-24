# Build the Ocean library

set srcList = ( mom5/ocean_core mom5/ocean_diag mom5/ocean_wave mom5/ocean_blobs mom5/ocean_param/neutral mom5/ocean_param/sources mom5/ocean_param/lateral mom5/ocean_param/vertical mom5/ocean_param/gotm-4.0/include mom5/ocean_param/gotm-4.0/turbulence mom5/ocean_param/gotm-4.0/util mom5/ocean_tracers )

set lib_name = "lib_ocean"

if( $type == ACCESS-OM || $type == ACCESS-CM || $type == ACCESS-OM-BGC || $type == ACCESS-ESM) then
    set srcList = ( $srcList mom5/ocean_access )
    if( $type ==  ACCESS-OM-BGC || $type == ACCESS-ESM) then
        set srcList = ( $srcList mom5/ocean_csiro_bgc )
    endif
    mkdir -p $executable:h:h/$type/$lib_name
    cd $executable:h:h/$type/$lib_name
else
    set srcList = ( $srcList mom5/ocean_bgc \
                        ocean_shared/generic_tracers/FMS_coupler_util.F90 \
                        ocean_shared/generic_tracers/FMS_ocmip2_co2calc.F90 \
                        ocean_shared/generic_tracers/generic_abiotic.F90 \
                        ocean_shared/generic_tracers/generic_age.F90 \
                        ocean_shared/generic_tracers/generic_argon.F90 \
                        ocean_shared/generic_tracers/generic_BLING.F90 \
                        ocean_shared/generic_tracers/generic_blres.F90 \
                        ocean_shared/generic_tracers/generic_CFC.F90 \
                        ocean_shared/generic_tracers/generic_ERGOM.F90 \
                        ocean_shared/generic_tracers/generic_miniBLING.F90 \
                        ocean_shared/generic_tracers/generic_SF6.F90 \
                        ocean_shared/generic_tracers/generic_TOPAZ.F90 \
                        ocean_shared/generic_tracers/generic_tracer.F90 \
                        ocean_shared/generic_tracers/generic_tracer_utils.F90)
    mkdir -p $executable:h:h/$lib_name
    cd $executable:h:h/$lib_name

    if( $COBALT == v1) then
        set srcList = ( $srcList ocean_shared/generic_tracers/generic_COBALT1.F90 )
    else
        set srcList = ( $srcList ocean_shared/generic_tracers/generic_COBALT2.F90 )
    endif 

endif

$mkmf_lib -p $lib_name.a -c "$cppDefs" -o "$includes" -I$code_dir/ocean_shared/mocsy $srcList $lib_include_dirs
make

if( $status ) then
    echo "Make failed to create $lib_name.a"
    exit 1
endif
