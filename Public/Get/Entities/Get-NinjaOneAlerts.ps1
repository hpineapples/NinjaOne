using namespace System.Management.Automation

function Get-NinjaOneAlerts {
    <#
        .SYNOPSIS
            Gets alerts from the NinjaOne API.
        .DESCRIPTION
            Retrieves alerts from the NinjaOne v2 API.
        .FUNCTIONALITY
            Alerts
        .EXAMPLE
            PS> Get-NinjaOneAlerts
            
            Gets all alerts.
        .EXAMPLE
            PS> Get-NinjaOneAlerts -sourceType 'CONDITION_CUSTOM_FIELD'

            Gets all alerts with source type CONDITION_CUSTOM_FIELD.
        .EXAMPLE
            PS> Get-NinjaOneAlerts -deviceFilter 'status eq APPROVED'

            Gets alerts for all approved devices.
        .OUTPUTS    
            A powershell object containing the response.
    #>
    [CmdletBinding()]
    [OutputType([Object])]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', '', Justification = 'Uses dynamic parameter parsing.')]
    Param(
        # Filter by device ID.
        [Parameter(Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [Alias('id')]
        [Int]$deviceId,
        # Filter by source type.
        [Parameter(Position = 1)]
        [String]$sourceType,
        # Filter by device which triggered the alert.
        [Parameter(Position = 2)]
        [Alias('df')]
        [String]$deviceFilter,
        # Filter by language tag.
        [Parameter(Position = 3)]
        [Alias('lang')]
        [String]$languageTag,
        # Filter by timezone.
        [Parameter(Position = 4)]
        [Alias('tz')]
        [String]$timeZone
    )
    $CommandName = $MyInvocation.InvocationName
    $Parameters = (Get-Command -Name $CommandName).Parameters
    # Workaround to prevent the query string processor from adding an 'deviceid=' parameter by removing it from the set parameters.
    if ($deviceId) {
        $Parameters.Remove('deviceID') | Out-Null
    }
    try {
        $QSCollection = New-NinjaOneQuery -CommandName $CommandName -Parameters $Parameters
        if ($deviceId) {
            Write-Verbose 'Getting device from NinjaOne API.'
            $Device = Get-NinjaOneDevices -deviceID $deviceId
            if ($Device) {
                Write-Verbose "Retrieving alerts for $($Device.SystemName)."
                $Resource = "v2/device/$($deviceId)/alerts"
            }
        } else {
            Write-Verbose 'Retrieving all alerts.'
            $Resource = 'v2/alerts'
        }
        $RequestParams = @{
            Resource = $Resource
            QSCollection = $QSCollection
        }
        $AlertResults = New-NinjaOneGETRequest @RequestParams
        Return $AlertResults
    } catch {
        New-NinjaOneError -ErrorRecord $_
    }
}