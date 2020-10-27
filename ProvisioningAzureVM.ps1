

#=======================================
# Define your all parameters here
#=======================================
$TestStorageAccName = "tststorageacc1010124"
$ResGrp = "TestResourceGroup"
$Subnet = New-AzureRmVirtualNetworkSubnetConfig -Name "TestSubnet" -AddressPrefix 10.0.0.0/24
$DCLocation = "Australia East"
#Since i am in New Zealand so closest Microsoft Datacenter for us is "Australia East"
$VMCredentials = Get-Credential -Message "Name/Password of the local Admin"
$BlobPath = "vhds/TestVMOsDisk.vhd"
$VMName = "TestVM"
$DiskName = "TestVMOsDisk" 

#=======================================
# Creating Resource Group
#=======================================
New-AzureRmResourceGroup -Name $ResGrp -Location $DCLocation

#=======================================
# Creating Storage Account to host Disks
#=======================================
$myStorageAccount = New-AzureRmStorageAccount -ResourceGroupName $ResGrp -Name $TestStorageAccName -SkuName "Standard_LRS" -Kind "Storage" -Location $DCLocation

#=======================================
# Creating Virtual Network
#=======================================
$TestVnet = New-AzureRmVirtualNetwork -Name "TestVnet" -ResourceGroupName $ResGrp -Location $DCLocation -AddressPrefix 10.0.0.0/16 -Subnet $Subnet

#=======================================
# Creating IP & NetworkCard
#=======================================
$TestPublicIP = New-AzureRmPublicIpAddress -Name "TestPublicIP" -ResourceGroupName $ResGrp -Location $DCLocation -AllocationMethod Dynamic
$TestNIC = New-AzureRmNetworkInterface -Name "TestNIC" -ResourceGroupName $ResGrp -Location $DCLocation -SubnetId $TestVnet.Subnets[0].Id -PublicIpAddressId $TestPublicIP.Id

#=======================================
# Placing VM Configuration & Provisioning
#=======================================
$TestVM = New-AzureRmVMConfig -VMName $VMName -VMSize "Standard_DS1_v2"
$TestVM = Set-AzureRmVMOperatingSystem -VM $TestVM -Windows -ComputerName $VMName -Credential $VMCredentials -ProvisionVMAgent -EnableAutoUpdate
$TestVM = Set-AzureRmVMSourceImage -VM $TestVM -PublisherName "MicrosoftWindowsServer" -Offer "WindowsServer" -Skus "2012-R2-Datacenter" -Version "latest"
$TestVM = Add-AzureRmVMNetworkInterface -VM $TestVM -Id $TestNIC.Id
$TestVM = Set-AzureRmVMOSDisk -VM $TestVM -Name $DiskName -StorageAccountType PremiumLRS -DiskSizeInGB 128 -CreateOption FromImage -Caching ReadWrite
New-AzureRmVM -ResourceGroupName $ResGrp -Location $DCLocation -VM $TestVM
