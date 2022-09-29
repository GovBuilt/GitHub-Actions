# Composite GitHub Actions actions

These actions can be invoked from a step in any other repository's workflow. The're utilized by [our reusable workflows](Workflows.md).

In addition to the below short explanations, check out the inline documentation of the action you want to use, especially its parameters.

- `build-dotnet`: Builds all .NET solutions or projects in the given directory with optional static code analysis.
- `create-jira-issues-for-community-activities`: Creates Jira issues for community activities happening on GitHub, like issues, discussions, and pull requests being opened. Pull requests are only taken into account if they're not already related to a Jira issue (by starting their title with a Jira issue key).
- `enable-corepack`: Enables [Node corepack](https://nodejs.org/docs/latest-v16.x/api/corepack.html) so any package manager can be used seamlessly.
- `publish-nuget`: Publishes the content of the current directory as a NuGet package.
- `setup-azurite`: Sets up the [Azurite Azure Blob Storage Emulator](https://docs.microsoft.com/en-us/azure/storage/common/storage-use-azurite) via NPM.
- `setup-dotnet`: Sets up the .NET SDK.
- `setup-sql-server`: Sets up SQL Server with Lombiq-recommended defaults.
- `test-dotnet`: Runs .NET unit and UI tests (with the [Lombiq UI Testing Toolbox for Orchard Core](https://github.com/Lombiq/UI-Testing-Toolbox)), generates a test report, and uploads UI testing failure dumps to artifacts.
- `verify-dotnet-consolidation`: Verifies that the NuGet packages of a .NET solution are consolidated, i.e. the same version of a given package is used in all projects.
- `verify-submodule-pull-request`: Assuming that the current repository is a submodule in another repository, this action verifies that a pull request with a matching issue code has been opened there as well.
