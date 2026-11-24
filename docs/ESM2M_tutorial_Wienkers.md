# ESM2M Tutorial & Brief Overall Documentation
_Aaron Wienkers, 2024_

## 0. CSCS Setup
1. Configure `~/.ssh/config` file (one time):
	```
	Host cscs
	  HostName ela.cscs.ch
	  User YOUR_USERNAME
	  ForwardAgent yes
	```
2. Set-up MFA for SSH keys: [CSCS MFA](https://user.cscs.ch/access/auth/mfa/)
3. SSH into Login Node with `ssh cscs`
4. SSH then into Eiger with `ssh eiger`
## 1. Updated Version of ESM2M Source Code
1. [GitHub Repository](https://github.com/wienkers/ESM2M_UniBe) 
2. Need to set SSH key for remote host into GitHub before able to `git clone`
3. Make your own branch (don't commit/push onto `master` branch):
	1. `git branch NAME`
	2. `git checkout NAME`
	3. `git status` — Should show "Currently on branch NAME"
4. Other Useful GitHub Commands:
	1. `git pull` — Updates from remote (GitHub)
 	2. `git rebase master` — Merge in updates from branch 'master' into your current branch 
	3. `git commit` etc...
	4. `git push origin NAME` — Pushes local changes to GitHub
## 2. Compiling (_for Eiger_)
- Set-up CSCS Profile (one time) into `~/.profile`:
	```
	if [ $(hostname -s | cut -c1-5) = eiger ]; then
		module load cray
		module switch PrgEnv-cray PrgEnv-intel
		module unload cray-libsci
		module load cray-hdf5-parallel
		module load cray-netcdf-hdf5parallel
	fi
	```
- NB: `mkmf.template.Eiger_prod` is machine dependent file (on Eiger you don't need to worry about this)
- Compile Script:
	- `./ESM2M_compile.csh Eiger_prod clean`
	- This compiles in reference to the 'Eiger_prod' production configuration, and 'cleans' the build directory first
	- The resulting executable is then `ESM2M_prod.x`
## 3. Running
NOTE: _Only_ run in the `$SCRATCH` directory
cf. `$PROJECT/EXAMPLE_PI` directory
- Components:
	- `input.nml`   — Specifies all model parameters/options
	- `data_table` — Specifies the files to read for inputs
	- `diag_table` — Specifies diagnostics to output
	- `field_tale` — Specifies any additional tracers/fields to evolve
	- `./INPUT/`     — Holds all the input/forcing/restart files
	- `batch_prod` — SLURM Production Job Submission Script
	- `batch_post` — SLURM Post-processing/transfer Job Script
		- NB. `input.nml` and `batch_*` scripts are machine-specific — changing the configuration / number of CPUs requires some thought...
		- These model definition files uniquely define also the type of experiment (e.g. PI, historical, etc.)  cf. [[Climate Change Run Configurations]]
- Restart File:
	- `tar -xvf RESTART_FILE.tar -C ./INPUT`
	- NB.: If immediately continuing from a successfully completed run, then these files are already copied into `./INPUT` at the end of the production run batch script.
## 4. Transferring
Options to send the `./OUTPUT/...` directory to e.g. ClimateStor
1. `scp` or `rsync` 
2. Use [Globus](https://www.globus.org) GUI 
3. Setup [Globus CLI](https://sites.google.com/a/case.edu/hpcc/data-transfer/transferring-files/globus-cli)
## 5. Processing
1. Some helpful tools in `./tools/` directory
