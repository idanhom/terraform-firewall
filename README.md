# Azure Firewall with Terraform

This project deploys an Azure Firewall with customizable rules using Terraform. The configuration is designed to be reusable, easily modifiable, and follows best practices in file structure, naming conventions, and state management. 

## Features

- **Easily Modifiable Firewall Rules**: Simplified rule management with loops.
- **Reusable Variables**: Key settings are managed via variables for reusability and modularity.
- **Remote State Management**: Uses a Key Vault for remote state management with versioning.



Fix: 
Note: set subscription id in in features block using export ARM_SUBSCRIPTION_ID=00000000-xxxx-xxxx-xxxx-xxxxxxxxxxxx

also, script for creating state container...
-Kan vara att du med PowerShell skapar en RG + SA + Container. 
-Ibland måste man skapa många statefiler, skönt med ett script då!