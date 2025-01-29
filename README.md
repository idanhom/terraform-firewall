# Bugs:
## Bug 1
In module azure_storage_account, there's a problem with deploying script "docker.sh" to blob. I believe the reason is that it's being done from GitHub Actions, and although I'm extracting the IP of the runner on the pipeline, GitHub Actions are ephemeral, so I believe the IP is being changed ones the job arrives at job "Terraform Plan".

That's why I recommend having "default_action" in azurerm_storage_account_network_rules during initial deployment and then do "Deny" afterwards. Alternative solution is to create a private runner and allow this specific IP and subnet.


## Bug 2
At deployment of diagnostic settings, there's a strange behavior where Terraform tries to deploy the diagnostic settings, but it already exists in Azure. Workaround is to go to Firewall resource and remove diagnostic settings, then re-run the script.
-----

