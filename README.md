# Bugs:
## Bug 1
In module azure_storage_account, there's a problem with deploying script "docker.sh" to blob if it already exists. I am whitelisting the SP's ip, but unable to figure out why it can't replace-upload if the blob/storage already exists. Solution is to remove the resource and then run the deployment.


## Bug 2
At deployment of diagnostic settings, there's a strange behavior where Terraform tries to deploy the diagnostic settings, but it already exists in Azure. Workaround is to go to Firewall resource and remove diagnostic settings, then re-run the deployment.
-----

