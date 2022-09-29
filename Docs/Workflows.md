# Reusable GitHub Actions workflows

These workflows can be invoked from a step from any other repository's workflow. The utilize [our composite actions](Actions.md).

In addition to the below short explanations and samples, check out the inline documentation of the workflow you want to use, especially its parameters. These examples don't necessarily utilize all parameters.

To add the workflows to a project create a folder in the root of the repository that will call them, e.g. _.github/workflows/build.yml_ and/or _.github/workflows/publish.yml_. Things to keep in mind:

- If you have multiple projects in the repository or if the project you want to build is in a subfolder, then add a solution to the root of the repository that references all projects you want to build.
- References to projects (`<ProjectReference>` elements) not in the repository won't work, these need to be changed to package references (`<PackageReference>` elements). Make the conditional based on `$(NuGetBuild)`. See the [Helpful Extensions project file](https://github.com/Lombiq/Helpful-Extensions/blob/dev/Lombiq.HelpfulExtensions.csproj) for an example. References to projects in the repository will work and those projects, if configured with the proper metadata, will be published together, with dependencies retained among the packages too.
- Projects building client-side assets with [Gulp Extensions](https://github.com/Lombiq/Gulp-Extensions) won't work during such builds. Until [we fix this](https://github.com/Lombiq/Open-Source-Orchard-Core-Extensions/issues/48), you have to commit the _wwwroot_ folder to the repository and add the same conditional to the Gulp and NPM Import elements too ([example](https://github.com/Lombiq/Orchard-Data-Tables/blob/58458b5d6381c71c094cb8d960e12b15a59f62d7/Lombiq.DataTables/Lombiq.DataTables.csproj#L33-L35)).

## Build and Test Orchard Core solution workflow

Meant to be used with [Orchard Core](https://orchardcore.net/) solutions; this workflow checks out the code, installs dependencies, builds the solution, runs unit and UI tests (with [Lombiq UI Testing Toolbox for Orchard Core](https://github.com/Lombiq/UI-Testing-Toolbox)), and publishes artifacts as well as a test report.

For an example of this, see below and the workflow of [Lombiq's Open-Source Orchard Core Extensions](https://github.com/Lombiq/Open-Source-Orchard-Core-Extensions).

```yaml
name: Build and Test

# Runs for PRs opened for any branch, and pushes to the dev branch.
on:
  pull_request:
  push:
    branches:
      - dev

jobs:
  call-build-and-test-workflow:
    name: Build and Test
    uses: Lombiq/GitHub-Actions/.github/workflows/build-and-test-orchard-core.yml@dev
    with:
      timeout-minutes: 60
```

## Build .NET solution workflow

Builds a .NET solution (or project) with static code analysis. You can use it along the lines of the following:

```yaml
name: Build

# Runs for PRs opened for any branch, and pushes to the dev branch.
on:
  pull_request:
  push:
    branches:
      - dev

jobs:
  call-build-workflow:
    name: Build
    uses: Lombiq/GitHub-Actions/.github/workflows/build-dotnet.yml@dev
    with:
      machine-types: "[\"ubuntu-latest\", \"windows-latest\"]"
      timeout-minutes: 10
```

## NuGet publish workflow

Builds the project with the .NET SDK and publishes it as a NuGet package to the configured NuGet feed. Example _publish.yml_:

```yaml
name: Publish to NuGet

on:
  push:
    tags:
      - v*

jobs:
  call-publish-workflow:
    uses: Lombiq/GitHub-Actions/.github/workflows/publish-nuget.yml@dev
    secrets:
      apikey: ${{ secrets.DEFAULT_NUGET_PUBLISH_API_KEY }}
```

The _publish.yml_ workflow is triggered on a tag pushed to any branch with the prefix `v` and should contain a [valid version number](https://docs.microsoft.com/en-us/nuget/concepts/package-versioning#version-basics), e.g. `v1.0.1`, which will be extracted and used to version the NuGet packages produced.

There is no configuration required for automated Orchard Core extension manifest versioning, all of the `Manifest.cs` files are looked up, and the existing `Version` properties are updated automatically inside the `Module` or `Theme` definition with the version pushed. Note that the `Version` property should be present and leave the version number on the default value (0.0.1). This is because we don't actually need to keep manifest version changes in the code.

It takes one non-optional secret parameter, `apikey`, the organization API key for pushing to NuGet, and two optional parameters, `source` and `verbosity`. E.g.:

```yaml
jobs:
  call-publish-workflow:
    uses: Lombiq/GitHub-Actions/.github/workflows/publish-nuget.yml@dev
    with:
      source: https://nuget.cloudsmith.io/lombiq/open-source-orchard-core-extensions/v3/index.json
      verbosity: detailed
    secrets:
      apikey: ${{ secrets.CLOUDSMITH_NUGET_PUBLISH_API_KEY }}
```

When `source` is not provided, it assumes a default value of pushing to the [Lombiq NuGet feed](https://www.nuget.org/profiles/Lombiq).

Valid values for `verbosity` are those defined by [MSBuild](https://docs.microsoft.com/en-us/visualstudio/msbuild/msbuild-command-line-reference?view=vs-2022#:~:text=you%20can%20specify%20the%20following%20verbosity%20levels). The default value is `minimal`.

## Submodule verify workflow

Verifies if the submodule contains a JIRA style issue code (e.g. PROJ-123) and if a pull request exists for the parent module. Example _publish.yml_:

```yaml
name: Verify OSOCE Pull Request

on:
  pull_request:

jobs:
  call-verify-workflow:
    uses: Lombiq/GitHub-Actions/.github/workflows/verify-submodule-pull-request.yml@dev
    with:
      repo: Lombiq/Open-Source-Orchard-Core-Extensions
```

If this is for a submodule of [Lombiq's Open-Source Orchard Core Extensions](https://github.com/Lombiq/Open-Source-Orchard-Core-Extensions/), the `repo` input can be omitted, because the above is its default value. Otherwise, use your parent repository's address in the `{owner}/{repo_name}` format.

Refer to [Github Actions reusable workflows](https://docs.github.com/en/actions/learn-github-actions/reusing-workflows#overview) for more information.

## Deploy to Azure App Service

This workflow builds and publishes a .NET web project and then deploys the app to [Azure App Service](https://azure.microsoft.com/en-us/services/app-service/). The workflow also supports [Ready to Run compilation](https://learn.microsoft.com/en-us/dotnet/core/deploying/ready-to-run). Example _deploy-to-azure-app-service.yml_:

```yaml
name: Deploy to Azure App Service

on:
  workflow_dispatch:

jobs:
  call-deploy-workflow:
    name: Deploy to Azure App Service
    uses: Lombiq/GitHub-Actions/.github/workflows/deploy-to-azure-app-service.yml@dev
    with:
      timeout-minutes: 60
      app-name: AppName
      resource-group-name: ResourceGroupName
      slot-name: Staging
      url: https://www.myapp.com
      runtime: win-x86
      self-contained: true
      ready-to-run: true
    secrets:
      AZURE_APP_SERVICE_DEPLOYMENT_SERVICE_PRINCIPAL: ${{ secrets.AZURE_APP_SERVICE_DEPLOYMENT_SERVICE_PRINCIPAL }}
      AZURE_APP_SERVICE_PUBLISH_PROFILE: ${{ secrets.AZURE_APP_SERVICE_PUBLISH_PROFILE }}
```

## Jira issue creation for community activities workflow

Creates Jira issues for community activities happening on GitHub, like issues, discussions, and pull requests being opened. Pull requests are only taken into account if they're not already related to a Jira issue (by starting their title with a Jira issue key).

Set up secrets for the `JIRA_*` parameters as explained [here](https://github.com/marketplace/actions/jira-login#enviroment-variables). You may use secret names without the `DEFAULT_*` prefix, but that's our recommendation for organization-level secrets, so you have defaults but can override them on a per-repository basis.

The secrets with the `*_JIRA_ISSUE_DESCRIPTION` suffix should contain templates for the Jira issues to be created, using the internal markup format of Jira (not Markdown). Example for one for `ISSUE_JIRA_ISSUE_DESCRIPTION`:

```text
h1. Summary
See the linked GitHub issue, including all the comments.

h1. Checklist
* Assign yourself to the referenced GitHub issue.
* [Issue completion checklist|https://example.com/checklist]
```

All three templates are optional and if not provided, defaults will be used.

```yaml
name: Create Jira issues for community activities

on:
  discussion:
    types: created
  issues:
    types: opened
  pull_request:
    types: opened

jobs:
  call-publish-workflow:
    uses: Lombiq/GitHub-Actions/.github/workflows/create-jira-issues-for-community-activities.yml@dev
    secrets:
      JIRA_BASE_URL: ${{ secrets.DEFAULT_JIRA_BASE_URL }}
      JIRA_USER_EMAIL: ${{ secrets.DEFAULT_JIRA_USER_EMAIL }}
      JIRA_API_TOKEN: ${{ secrets.DEFAULT_JIRA_API_TOKEN }}
      JIRA_PROJECT_KEY: ${{ secrets.DEFAULT_JIRA_PROJECT_KEY }}
      DISCUSSION_JIRA_ISSUE_DESCRIPTION: ${{ secrets.DEFAULT_DISCUSSION_JIRA_ISSUE_DESCRIPTION }}
      ISSUE_JIRA_ISSUE_DESCRIPTION: ${{ secrets.DEFAULT_ISSUE_JIRA_ISSUE_DESCRIPTION }}
      PULL_REQUEST_JIRA_ISSUE_DESCRIPTION: ${{ secrets.DEFAULT_PULL_REQUEST_JIRA_ISSUE_DESCRIPTION }}
    with:
      issue-component: Lombiq.MyProject

```
