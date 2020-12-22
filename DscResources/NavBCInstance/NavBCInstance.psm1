function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param (

        [parameter(Mandatory = $true)]
        [System.String]
        $ServerInstance,

        [parameter(Mandatory = $true)]
        [System.String]
        $ManagementServicesPort,

        [parameter(Mandatory = $true)]
        [System.String]
        $ClientServicesPort,

        [parameter(Mandatory = $true)]
        [ValidateSet("User","LocalService","NetworkService","LocalSystem")]
        [System.String]
        $ServiceAccount,

        [parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        $ServiceAccountCredential,

        [parameter(Mandatory = $true)]
        [System.String]
        $SOAPServicesPort,

        [parameter(Mandatory = $true)]
        [System.String]
        $ODataServicesPort,

        [parameter(Mandatory = $true)]
        [ValidateSet("Windows", "Username", "NavUserPassword","AccessControlService")]
        [System.String]
        $ClientServicesCredentialType,

        [parameter(Mandatory = $true)]
        [System.String]
        $DeveloperServicesPort,

        [parameter(Mandatory = $true)]
        [System.String]
        $ServicesCertificateThumbprint,

        [ValidateSet("Present","Absent")]
        [System.String]
        $Ensure
        
    )
    Import-module "C:\Program Files\Microsoft Dynamics 365 Business Central\*\Service\NavAdminTool.ps1"

    write-host "Checking to see if the BC module has been loaded!"

    $loaded = Get-Module | where-object {$_.name -match "NavAdminTool"}

    if ($loaded) {
        write-host "Nav BC module has been loaded"
    }
    else {
        Write-Error "NavBC module loaded $loaded"
        return $Error
        exit 1
    }

    $NewInstance = Get-NAVServerInstance $ServerInstance

    if ($NewInstance -and ($NewInstance.state -eq "Stopped")) {
        $Ensure = 'Present'
    }
    else {
        $Ensure = 'Absent'
    }

    $returnValue = @{
        ServerInstance     = $NewInstance.ServerInstance
        Ensure          = $Ensure
        Params          = $Params
    }

    $returnValue
}

function Set-TargetResource
{
    param (

        [CmdletBinding()]
        [parameter(Mandatory = $true)]
        [System.String]
        $ServerInstance,

        [parameter(Mandatory = $true)]
        [System.String]
        $ManagementServicesPort,

        [parameter(Mandatory = $true)]
        [System.String]
        $ClientServicesPort,

        [parameter(Mandatory = $true)]
        [ValidateSet("User","LocalService","NetworkService","LocalSystem")]
        [System.String]
        $ServiceAccount,

        [parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        $ServiceAccountCredential,

        [parameter(Mandatory = $true)]
        [System.String]
        $SOAPServicesPort,

        [parameter(Mandatory = $true)]
        [System.String]
        $ODataServicesPort,

        [parameter(Mandatory = $true)]
        [ValidateSet("Windows", "Username", "NavUserPassword","AccessControlService")]
        [System.String]
        $ClientServicesCredentialType,

        [parameter(Mandatory = $true)]
        [System.String]
        $DeveloperServicesPort,

        [parameter(Mandatory = $true)]
        [System.String]
        $ServicesCertificateThumbprint,

        [ValidateSet("Present","Absent")]
        [System.String]
        $Ensure
        
    )

    $ErrorActionPreference = 'Stop'
    $ReturnObject = [PSCustomObject]@{
    'ErrorMessage' = $null
    'ServerInstance' = $ServerInstance
    }

    Import-module "C:\Program Files\Microsoft Dynamics 365 Business Central\*\Service\NavAdminTool.ps1"

    try {
        write-host "Checking to see if the BC module has been loaded!"

        $loaded = Get-Module | where-object {$_.name -match "NavAdminTool"}

        if ($loaded) {
            write-host "Nav BC module has been loaded"
        }
        else {
            Write-Error "NavBC module loaded $loaded"
            return $Error
            exit 1
        }

        Write-Host "Validating Ports specified are unique - $ClientServicesPort - $DeveloperServicesPort - $ManagementServicesPort - $ODataServicesPort - $SOAPServicesPort"

        $AllPorts = @($ManagementServicesPort, $ClientServicesPort, $SOAPServicesPort, $ODataServicesPort, $DeveloperServicesPort)

        $UniquePorts = $AllPorts | select -Unique

        $Compare = Compare-Object -ReferenceObject $UniquePorts -DifferenceObject $AllPorts

        if ($Compare) {
            Write-Warning "It seems that there are some duplicate ports specified, all ports need to be unique in order to continue"
            exit 1
        }
        else {
            Write-Host "All Ports are unique" 
        }

    
        Write-Host "Check to see if Server Instance Already Exists"
        $InstanceExists = Get-NAVServerInstance -ServerInstance $ServerInstance

        if ($InstanceExists) {
            Write-Warning "Instance already exists! Please check Instance name and existing Instance and try again"
            exit 1
        }
        else {
            if ($Ensure -eq 'Present'){
                Write-Host "Creating new Service Instance - $ServerInstance"
                New-NAVServerInstance -ServerInstance $ServerInstance -ManagementServicesPort $ManagementServicesPort -ClientServicesPort $ClientServicesPort -SOAPServicesPort $SOAPServicesPort -ODataServicesPort $ODataServicesPort -DeveloperServicesPort $DeveloperServicesPort -ServiceAccount $ServiceAccount -ServiceAccountCredential $ServiceAccountCredential -ServicesCertificateThumbprint $ServicesCertificateThumbprint            
                
                $NewInstance = Get-NAVServerInstance $ServerInstance

                if ($NewInstance -and ($NewInstance.state -eq "Stopped")) {
                    Write-Host "New Instance has been created and is in a Stopped state"
                }
                else {
                    Write-Error "Instance did not create, please validate settings and try again. Alternatively further investigation will be required from Engineering"
            }

            }
            elseif ($Ensure -eq 'Absent') {
                Remove-NAVServerInstance $ServerInstance -VERBOSE
            }
        }
    
    }
    catch
    {
        $ReturnObject.ErrorMessage = "Failed to Create new Server Instance - $($_.Exception.Message) - $($_.InvocationInfo.PositionMessage)"
        throw $ReturnObject
    }
}

function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param (

        [parameter(Mandatory = $true)]
        [System.String]
        $ServerInstance,

        [parameter(Mandatory = $true)]
        [System.String]
        $ManagementServicesPort,

        [parameter(Mandatory = $true)]
        [System.String]
        $ClientServicesPort,

        [parameter(Mandatory = $true)]
        [ValidateSet("User","LocalService","NetworkService","LocalSystem")]
        [System.String]
        $ServiceAccount,

        [parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        $ServiceAccountCredential,

        [parameter(Mandatory = $true)]
        [System.String]
        $SOAPServicesPort,

        [parameter(Mandatory = $true)]
        [System.String]
        $ODataServicesPort,

        [parameter(Mandatory = $true)]
        [ValidateSet("Windows", "Username", "NavUserPassword","AccessControlService")]
        [System.String]
        $ClientServicesCredentialType,

        [parameter(Mandatory = $true)]
        [System.String]
        $DeveloperServicesPort,

        [parameter(Mandatory = $true)]
        [System.String]
        $ServicesCertificateThumbprint,

        [ValidateSet("Present","Absent")]
        [System.String]
        $Ensure
        
    ) 

    $result = [System.Boolean]

    Import-module "C:\Program Files\Microsoft Dynamics 365 Business Central\*\Service\NavAdminTool.ps1"

    write-host "Checking to see if the BC module has been loaded!"

        $loaded = Get-Module | where-object {$_.name -match "NavAdminTool"}

        if ($loaded) {
            write-host "Nav BC module has been loaded"
        }
        else {
            Write-Error "NavBC module loaded $loaded"
            return $Error
            exit 1
        }
    
    Write-Verbose "Testing to see if the Server Instance [$ServerInstance] is present"

    $InstanceExists = Get-NAVServerInstance -ServerInstance $ServerInstance

    if (($InstanceExists) -and ($Ensure -eq 'Present'))
    {
        Write-Verbose -Message "NavBC Server Instance - $ServerInstance is already present"
        $result = $true
    }
    elseif (($InstanceExists) -and ($Ensure -eq 'Absent')) 
    {
        Write-Verbose -Message "NavBC Server Instance - $ServerInstance is present but should be removed"
        $result = $false
    }
    elseif ((-not($InstanceExists) -and ($Ensure -eq 'Present'))) 
    {
        Write-Verbose -Message "NavBC Server Instance - $ServerInstance is not present but should be configured"
        $result = $false
    }
    else 
    {
        Write-Verbose -Message "NavBC Server Instance - $ServerInstance is already removed"
        $result = $true
    }

    $result

}

Export-ModuleMember -Function *-TargetResource
