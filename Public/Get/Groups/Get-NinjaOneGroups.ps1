
function Get-NinjaOneGroups {
    <#
        .SYNOPSIS
            Gets groups from the NinjaOne API.
        .DESCRIPTION
            Retrieves groups from the NinjaOne v2 API.
        .FUNCTIONALITY
            Groups
        .EXAMPLE
            PS> Get-NinjaOneGroups
            
            Gets all groups.
        .OUTPUTS
            A powershell object containing the response.
    #>
    [CmdletBinding()]
    [OutputType([Object])]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', '', Justification = 'Uses dynamic parameter parsing.')]
    Param(
        # Group names should be returned in this language.
        [Parameter(Position = 0)]
        [Alias('lang')]
        [String]$languageTag
    )
    $CommandName = $MyInvocation.InvocationName
    $Parameters = (Get-Command -Name $CommandName).Parameters
    try {
        $QSCollection = New-NinjaOneQuery -CommandName $CommandName -Parameters $Parameters
        Write-Verbose 'Retrieving all groups.'
        $Resource = 'v2/groups'
        $RequestParams = @{
            Resource = $Resource
            QSCollection = $QSCollection
        }
        $GroupResults = New-NinjaOneGETRequest @RequestParams
        if ($GroupResults) {
            return $GroupResults
        } else {
            throw 'No groups found.'
        }
    } catch {
        New-NinjaOneError -ErrorRecord $_
    }
}