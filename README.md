# Bugs:
## Bug 1
In module azure_storage_account, there's a problem with deploying script "docker.sh" to blob if it already exists. I am whitelisting the SP's ip, but unable to figure out why it can't replace-upload if the blob/storage already exists. Solution is to remove the resource and then run the deployment or "Enabled from all networks" in Storage account -> Networking. Terraform then changes this to "Enabled from selected virtual networks and IP addresses" at Deployment again.


## Bug 2
At deployment of diagnostic settings, there's a strange behavior where Terraform tries to deploy the diagnostic settings, but it already exists in Azure. Workaround is to go to Firewall resource and remove diagnostic settings, then re-run the deployment.
-----

Note: due to limitation of using Github's public runners, which is what I use as SP to deploy script to blob storage, it needs access since I run private endpoints for the blob that only allows VNets. Unable to whitelist public runner since it's using epherial (spelling?) IP and unknown vnet. From a green field deployment, that's why there's a need to set "default_action" in azurerm_storage_account_network_rules to "Allow" at deployment and then change it to "Deny".

However, a better solution is to run the pipeline as self-hosted runner. But this is against GitHub Actions recommended practice. It's commented out. To make it run as self-hosted, see this link (some github blabla) and whitelist ip_rules and add virtual_network_subnet_ids (subnet of self-hosted runner)