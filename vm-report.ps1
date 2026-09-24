$vmStatus = Get-AzVM `
    -ResourceGroupName 'RG-BH-PLATFORM-LAB' `
    -Name 'vm-bh-platform-01' `
    -Status

$powerStatus = $vmStatus.Statuses |
    Where-Object { $_.Code -like 'PowerState/*' }

$provisionStatus = $vmStatus.Statuses |
    Where-Object { $_.Code -like 'ProvisioningState/*' }

$vmReport = [pscustomobject]@{
    VM           = $vmStatus.Name
    Power        = $powerStatus.DisplayStatus
    PowerCode = $powerStatus.Code
    Provisioning = $provisionStatus.DisplayStatus
}

$vmReport | Export-Csv -Path .\vm-report.csv -NoTypeInformation
$vmReport