# ESM2M–COBALTv2 with mixotrophic nanoflagellates

Model source code used for the simulations in manuscript under title "Mixotrophy sustains ocean productivity and attenuates carbon export decline under climate warming" (Flanjak et al., submitted).

- Original configuration: GFDL ESM2M with the COBALTv2 ocean biogeochemistry, in the University of Bern configuration
  (A. Wienkers; setup guide in `docs/ESM2M_tutorial_Wienkers.md`).

- Mixotroph implementation: `src/ocean_shared/generic_tracers/generic_COBALT2.F90`, with tracer registration in
  `generic_tracer.F90` and MOM5 coupling in `src/mom5/ocean_bgc/ocean_generic_tracer.F90`.
  Namelist parameters `mixo_eta`, `mixo_nu` in `&generic_COBALT_nml`.


Licenses:
The GFDL FMS infrastructure (`src/shared/`) is distributed under the GNU LGPL v3 (`src/shared/LICENSE.md`);
other components keep the licenses in their own folders. 
