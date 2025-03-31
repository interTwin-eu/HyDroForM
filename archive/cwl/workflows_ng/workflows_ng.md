# Workflows Next Generation

Since our previous attempts fail a lot and are complicated to make
workflows, we decided to create a new way to make workflows. This separates each action into a separate file, and then you can combine them into a workflow. This is a lot easier to manage and create workflows. It will also hopefully allows us to be more precise when figuring out what went wrong.

**Note:** This is a work in progress, however, it will be the last restructuring and attempts to create these workflows before I quit and become a farmer.

## Structure

Each directory in the `workflows_ng` contains the required files for the workflow (`hydromt`,`wflow`,`surrogate`).

Each workflow directory is further divided into subdirectories containing each step of the workflow. Each step is a separate file that can be run independently.

Each step provides a sample `Dockerfile` used to build the image (as well as all the scripts required for the step) as well as the workflow CWL.
