﻿<#
.SYNOPSIS
    Gets the global list

.PARAMETER API
    Optional. API Handle (use only when not using session scope).

.PARAMETER List
    The type of global list to retrieve.
#>
function Get-CyGlobalList {
    Param (
        [parameter(Mandatory=$false)]
        [ValidateNotNullOrEmpty()]
        [CylanceAPIHandle]$API = $GlobalCyAPIHandle,
        [Parameter(Mandatory=$true)]
        [ValidateSet ("GlobalSafeList", "GlobalQuarantineList")]
        [String]$List
        )

    $APIListType = 0

    switch ($List) {
        "GlobalQuarantine" {
            $APIListType = 0
        }
        "GlobalSafeList" {
            $APIListType = 1
        }
    }

    Read-CyData -API $API -Uri "$($API.BaseUrl)/globallists/v2" -QueryParams @{ "listTypeId" = $APIListType }
}

<#
.SYNOPSIS
    Adds file hash to global list

.PARAMETER API
    Optional. API Handle (use only when not using session scope).

.PARAMETER List
    The global list type to add to

.PARAMETER SHA256
    The file hash to add

.PARAMETER Category
    The category of the file to add to the list

.PARAMETER Reason
    The reason for adding the file.
#>
function Add-CyHashToGlobalList {
    Param (
        [parameter(Mandatory=$false)]
        [ValidateNotNullOrEmpty()]
        [CylanceAPIHandle]$API = $GlobalCyAPIHandle,
        [Parameter(Mandatory=$true)]
        [ValidateSet ("GlobalSafeList", "GlobalQuarantineList")]
        [String]$List,
        [Parameter(
            Mandatory=$true, 
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true)]
        [String]$SHA256,
        [Parameter(Mandatory=$false)]
        [ValidateSet ("Admin Tool", "Commercial Software", "Drivers", "Internal Application", "Operating System", "Security Software", "None")]
        [String]$Category,
        [Parameter(Mandatory=$true)]
        [String]$Reason
    )

    Begin {
        $APIListType = "GlobalQuarantine";
        if ($List -eq "GlobalSafeList") { $APIListType = "GlobalSafe" }
    }

    Process {
        switch ($APIListType) {
            "GlobalQuarantine" {
                $updateMap = @{
                    "sha256" = $SHA256
                    "list_type" = $APIListType
                    "reason" = $Reason
                }
            }
            "GlobalSafe" {
                $updateMap = @{
                    "sha256" = $SHA256
                    "list_type" = $APIListType
                    "reason" = $Reason
                    "category" = $Category
                }
            }
        }

        $json = $updateMap | ConvertTo-Json
        # remain silent
        $null = Invoke-CyRestMethod -API $API -Method POST -Uri "$($API.BaseUrl)/globallists/v2" -ContentType "application/json; charset=utf-8" -Body $json
    }
}

<#
.SYNOPSIS
    Removes a hash from a global list

.PARAMETER API
    Optional. API Handle (use only when not using session scope).

.PARAMETER List
    The list type

.PARAMETER SHA256
    The file hash to remove.
#>
function Remove-CyHashFromGlobalList {
    Param (
        [parameter(Mandatory=$false)]
        [ValidateNotNullOrEmpty()]
        [CylanceAPIHandle]$API = $GlobalCyAPIHandle,
        [Parameter(Mandatory=$true)]
        [ValidateSet ("GlobalSafeList", "GlobalQuarantineList")]
        [String]$List,
        [Parameter(
            Mandatory=$true, 
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true)]
        [String]$SHA256
    )

    Begin {
        $APIListType = "GlobalQuarantine";
        if ($List -eq "GlobalSafeList") { $APIListType = "GlobalSafe" }
    }

    Process {
        $updateMap = @{
            "sha256" = $SHA256
            "list_type" = $APIListType
        }

        $json = $updateMap | ConvertTo-Json
        $null = Invoke-CyRestMethod -API $API -Method DELETE -Uri "$($API.BaseUrl)/globallists/v2" -ContentType "application/json; charset=utf-8" -Body $json
    }
}