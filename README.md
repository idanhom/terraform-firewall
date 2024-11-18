# Azure Firewall with Terraform

This project deploys an Azure Firewall with customizable rules using Terraform. The configuration is designed to be reusable, easily modifiable, and follows best practices in file structure, naming conventions, and state management. 

## Features

- **Easily Modifiable Firewall Rules**: Simplified rule management with loops.
- **Reusable Variables**: Key settings are managed via variables for reusability and modularity.
- **Remote State Management**: Has remote state management with versioning.



Fix: 
Note: set subscription id in in features block using export ARM_SUBSCRIPTION_ID=00000000-xxxx-xxxx-xxxx-xxxxxxxxxxxx

also, script for creating state container...
-Kan vara att du med PowerShell skapar en RG + SA + Container. 
-Ibland måste man skapa många statefiler, skönt med ett script då!




todo

skapa modul för att skapa vm, se till så den fungerar, sedan återanvända modulen. innefatta också NSG, vnet, subnet.




sedan, peera vnet för alla (genom route table) så next hop från alla moduler går till (och genom) brandväggen.


route-tablea vnet att gå igenom brandväggen (next-hop för vm är brandväggen)


resource "azurerm_firewall_network_rule_collection" "name" {

}

resource "azurerm_firewall_application_rule_collection" "name" {

}


----


därefter:
log analytics workspace

resource "azurerm_log_analytics_saved_search" "name" {
  
}

https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/log_analytics_saved_search 


"hur gör jag för att hämta ut data från modul 1 till modul 2 för det går alltid att hämta ut saker"

------

när vi är helt nöjd med koden, använda github actions.


---

"Modules should be opinionated and designed to do one thing well. If a module's function or purpose is hard to explain, the module is probably too complex. When initially scoping your module, aim for small and simple to start." - https://developer.hashicorp.com/terraform/tutorials/modules/pattern-module-creation#scope-the-requirements-into-appropriate-modules

