#!/bin/csh -f

######################################################################
######################################################################

# A. Wienkers -- 
# To Compile Coupled ESM2M:   >>  ./ESM2M_compile.csh CSCS_prod
# 
# To Debug:		      >>  ./ESM2M_compile.csh CSCS_debug
#
# To Make Clean Build:	      >>  ./ESM2M_compile.csh CSCS_prod clean


######################################################################
######################################################################




set platform      = $1        # This corresponds to the mkmf templates in $root/bin dir.
			      # e.g. CSCS_x

if( $1 == '' ) then
    echo "Error: Need to supply a platform ID, such as CSCS_prod or CSCS_debug"
    exit 1
endif



set root          = $cwd                            # The directory you created when you checkout

if( $2 == 'clean' ) then
    echo "This will delete the entire $1 build directory and make a clean compile."
    set answer = ""
    while ( "$answer" != "y" && "$answer" != "n" )
        echo -n "Are you sure you want to continue? (y/n): "
        set answer = $<
    end
    if ( "$answer" == "n" ) then
        echo "Aborting..."
        exit 1
    endif
    if ( "$answer" == "y" ) then
        rm -rf $root/build/$platform
    endif
endif

cd $root/exp


set type	  = ESM2M
set COBALT    = v2   # v1 or v2
set code_dir      = $root/src                         # source code directory
set executable    = $root/build/$platform/ESM2M/fms_ESM2M.x      # executable created after compilation
set mppnccombine  = $root/bin/mppnccombine  # path to executable mppnccombine
set mkmfTemplate  = $root/bin/mkmf.template.$platform # path to template for your platform
set mkmf          = $root/bin/mkmf                    # path to executable mkmf
set cppDefs  = ( " -Duse_netCDF -Duse_netCDF4 -Duse_libMPI -DUSE_OCEAN_BGC -DENABLE_ODA -DSPMD -DLAND_BND_TRACERS" )



# Compile mppnccombine
if ( ! -f $mppnccombine ) then
    cc -O -o $mppnccombine -I/usr/local/include -L/usr/local/lib $code_dir/postprocessing/mppnccombine/mppnccombine.c -lm -lnetcdf
endif

set mkmf_lib = "$mkmf -f -m Makefile -a $code_dir -t $mkmfTemplate"
set lib_include_dirs = "$root/include $code_dir/shared/include $code_dir/shared/mpp/include"

# Build version
source ./version_compile.csh

# Build FMS
source ./FMS_compile.csh

set includes = "-I$code_dir/shared/include -I$executable:h:h/lib_FMS -I$executable:h:h/lib_ocean -I$executable:h:h/lib_version/"

# Build each ESM2M component Model

cd $root/exp
source ./ocean_compile.csh
if ( $status ) exit $status

cd $root/exp
source ./ice_compile.csh
if ( $status ) exit $status

cd $root/exp
source ./atmos_phys_compile.csh
if ( $status ) exit $status

cd $root/exp
source ./atmos_fv_compile.csh
if ( $status ) exit $status

cd $root/exp
source ./land_lad2_compile.csh
if ( $status ) exit $status

# Build the executable
set mkmf_exec = "$mkmf -f -m Makefile -a $code_dir -t $mkmfTemplate -p $executable:t"
mkdir -p $executable:h
cd $executable:h
    
set srcList = ( coupler )
set includes = "$includes -I$executable:h:h/lib_ice -I$executable:h:h/lib_atmos_fv -I$executable:h:h/lib_atmos_phys -I$executable:h:h/lib_land_lad2"
set libs = "$executable:h:h/lib_ocean/lib_ocean.a $executable:h:h/lib_ice/lib_ice.a $executable:h:h/lib_atmos_fv/lib_atmos_fv.a $executable:h:h/lib_atmos_phys/lib_atmos_phys.a $executable:h:h/lib_land_lad2/lib_land_lad2.a"

# Always include FMS and version
set libs = "$libs $executable:h:h/lib_version/lib_version.a $executable:h:h/lib_FMS/lib_FMS.a"

$mkmf_exec -o "$includes" -c "$cppDefs" -l "$libs"  $srcList
make -j8
if( $status ) then
    echo "Make failed to create the executable"
    exit 1
endif

# Clean up at the end and copy the executable to root directory
cd ../
set mod = `echo $platform | sed 's/.*_//'`
if( $COBALT == v1) then
    set mod = "$mod.COBALTv1"
endif

cp $executable $root/ESM2M_$mod.x

exit
