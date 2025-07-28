## Introduction

This is the basic project template for a Snowflake Native App project. It contains minimal code meant to help you set up your first application object in your account quickly.

### Project Structure
| File Name | Purpose |
| --------- | ------- |
| README.md | The current file you are looking at, meant to guide you through a Snowflake Native App project. |
| app/setup_script.sql | Contains SQL statements that are run when an account installs or upgrades a Snowflake Native App. |
| app/manifest.yml | Defines properties required by the application package. Find more details at the [Manifest Documentation.](https://docs.snowflake.com/en/developer-guide/native-apps/creating-manifest)
| app/README.md | Exposed to the account installing the Snowflake Native App with details on what it does and how to use it. |
| snowflake.yml | Used by the Snowflake CLI tool to discover your project's code and interact with your Snowflake account with all relevant prvileges and grants. |

