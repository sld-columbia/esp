# Regression Testing

This PR introduces a regression testing suite for ESP. The main goals are:
1. Automate the process of testing a SoC design configuration on ESP.
2. Use GitHub Actions and Workflows to streamline the testing process. 

## Workflow overview
Given an ESP SoC design configuration, the automated process includes the following steps:

Generate the bitstream.
Upload the bitstream to the target FPGA.
Run a baremetal “Hello” program.
Generate a Linux image for the SoC design.
Boot Linux on the FPGA.
Verify the boot result.
SSH into the booted system.
Execute the `multifft` application.

The scripts developed in this work are under:
- `utils/scripts/actions-pipeline`
- `.github/workflows/regression-test-pro.yaml`
- `soft/common/apps/examples/multifft/multifft.c`

*For a more comprehensive report, consult the SLD team or Professor Carloni.

## Two Methods to Use This Testing Suite
1. Manual Script Execution
2. Rely on GitHub Runner

## Method 1. Manual Script Execution
### Detail steps for execution
1. Set up ESP environment (sysroot, submodules, etc.)
2. Grant permission to scripts in this testing suite
3. Specify the target ESP config to run the flow. Modify the config in `utils/scripts/actions-pipeline/esp_configs.json`. Specify FPGA name to connect, path of ESP config to test, path to save the result log, UART and SSH credentials.
4. Optional: Start a tmux session before running following steps. Some steps within the flow takes 1-3 hours.
5. Navigate to the scripts directory: `cd esp/utils/scripts/actions-pipeline`
6. Generate bitstream file for the testing target. It will generate bitstream for first ESP config that you specified in step 3. Execute `./helper/gen_bitstream.sh`
7. Generate Linux image file for the testing target. Execute `./helper/gen_linux.sh`
8. Run the main flow that uses the files generated from step 6 and 7. Execute `./run_workflow.sh`
9. The result output log file will be saved in the path specified in `esp_configs.json` 

This method is stable and reliable for testing ESP configurations.

## Method 2. GitHub Runner + Automated Workflow
### Design the workflow
The workflow is designed in a yaml file, located in `.github/workflows/regression-test-pro.yaml`. Now it is set as "triggered by push," which means that if the runner is running, when there's a push onto the specified branch, the actions listed in this workflow will be executed. Please modify as needed.

### Detail steps for execution
1. Design the workflow in the YAML file with specification. Previous workflows are in `.github/workflows/regression-test-pro.yaml`.
2. Follow the instruction from GitHub to setup a worker. To whom from SLD Columbia to work on developing this in the future, I set the worker on `server thecaptain.cs.columbia.edu`, consult SLD for accessing the server. 
- [Adding self-hosted runners to the repository](https://docs.github.com/en/actions/hosting-your-own-runners/managing-self-hosted-runners/adding-self-hosted-runners)
- [Configuring and starting the runner](https://docs.github.com/en/actions/hosting-your-own-runners/managing-self-hosted-runners/adding-self-hosted-runners)
3. Start the runner
4. Trigger the workflow: After the runner is active, make code changes and `git push` (or whatever specified in workflow) to execute the workflow automatically.

⚠️ Disclaimer: This method is currently unstable. Tools like minicom may interfere with the session running the workflow. It is recommended to use Method 1 until Method 2 is fully debugged.

## About
This testing suite was developed in Spring 2025 at Columbia University, under the guidance of:
* Joseph Zuckerman (jzuck@cs.columbia.edu)
* Professor Luca Carloni (luca@cs.columbia.edu)

For questions, suggestions, or support, contact:
Chia-Lin (Julie) Cheng – cc5210@columbia.edu, a report for this project can be provided for reference.