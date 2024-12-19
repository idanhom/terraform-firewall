
resource "azurerm_firewall_network_rule_collection" "name" 


resource "azurerm_firewall_application_rule_collection" "name" 



# Azure Firewall with Terraform

This project deploys an Azure Firewall with customizable rules using Terraform. The configuration is designed to be reusable, easily modifiable, and follows best practices in file structure, naming conventions, and state management. 


https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/log_analytics_saved_search 




Fix: 
Note: set subscription id in in features block using export ARM_SUBSCRIPTION_ID=00000000-xxxx-xxxx-xxxx-xxxxxxxxxxxx

also, script for creating state container...
-Kan vara att du med PowerShell skapar en RG + SA + Container. 
-Ibland måste man skapa många statefiler, skönt med ett script då!



"hur gör jag för att hämta ut data från modul 1 till modul 2 för det går alltid att hämta ut saker"


//bygga keyvault och secret för att lösenordet för min vm inte ska skrivas ut i klartext. behöver miniscritp för att slumpa lösenord. "kallar på lösenordet som variabel men denna skrivs aldrig ut. notera: keyvault får inte tas bort. purge_protection_enabled = false"

------

när vi är helt nöjd med koden, använda github actions.


---

"Modules should be opinionated and designed to do one thing well. If a module's function or purpose is hard to explain, the module is probably too complex. When initially scoping your module, aim for small and simple to start." - https://developer.hashicorp.com/terraform/tutorials/modules/pattern-module-creation#scope-the-requirements-into-appropriate-modules

