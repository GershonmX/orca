<#

179

Checks to determine if SafeLinks is re-wring internal to internal emails. Does not however,
check to determine if there is a rule enforcing this.

#>

using module "..\ORCA.psm1"

class ORCA179 : ORCACheck
{
    <#
    
        CONSTRUCTOR with Check Header Data
    
    #>

    ORCA179()
    {
        $this.Control=179
        $this.Services=[ORCAService]::MDO
        $this.Area="Microsoft Defender for Office 365 Policies"
        $this.Name="Intra-organization Safe Links"
        $this.PassText="Safe Links is enabled intra-organization"
        $this.FailRecommendation="Enable Safe Links between internal users"
        $this.ExpandResults=$True
        $this.ChiValue=[ORCACHI]::High
        $this.Importance="Phishing attacks are not limited from external users. Commonly, when one user is compromised, that user can be used in a process of lateral movement between different accounts in your organization. Configuring Safe Links so that internal messages are also re-written can assist with lateral movement using phishing. The built-in policy is ignored in this check, as it only provides the minimum level of protection."
        $this.ItemName="SafeLinks Policy"
        $this.DataType="Enabled for Internal"
        $this.Links= @{
            "Security & Compliance Center - Safe links"="https://aka.ms/orca-atpp-action-safelinksv2"
            "Recommended settings for EOP and Microsoft Defender for Office 365"="https://aka.ms/orca-atpp-docs-7"
        }
    }

    <#
    
        RESULTS
    
    #>

    GetResults($Config)
    {

        $Enabled = $False
        $PolicyCount = 0
      
        ForEach($Policy in $Config["SafeLinksPolicy"]) 
        {
            if(!$Config["PolicyStates"][$Policy.Guid.ToString()].BuiltIn)
            {
                $IsPolicyDisabled = !$Config["PolicyStates"][$Policy.Guid.ToString()].Applies
                $EnableForInternalSenders = $($Policy.EnableForInternalSenders)

                $PolicyCount++

                # Check objects
                $ConfigObject = [ORCACheckConfig]::new()
                $ConfigObject.ConfigItem=$($Policy.Name)
                $ConfigObject.ConfigData=$EnableForInternalSenders
                $ConfigObject.ConfigReadonly = $Policy.IsPreset
                $ConfigObject.ConfigDisabled = $IsPolicyDisabled
                $ConfigObject.ConfigPolicyGuid=$Policy.Guid.ToString()

                # Determine if MDO link tracking is on for this safelinks policy
                If($EnableForInternalSenders -eq $true) 
                {
                    $Enabled = $True
                    $ConfigObject.SetResult([ORCAConfigLevel]::Standard,"Pass")
                } 
                Else 
                {
                    $ConfigObject.SetResult([ORCAConfigLevel]::Standard,"Fail")
                }

                $this.AddConfig($ConfigObject)
            }
        }

        If($PolicyCount -eq 0)
        {

            # No policy enabling
            $ConfigObject = [ORCACheckConfig]::new()
            $ConfigObject.ConfigItem="All"
            $ConfigObject.ConfigData="Enabled False"
            $ConfigObject.SetResult([ORCAConfigLevel]::Standard,"Fail")

            $this.AddConfig($ConfigObject)

        }    

    }

}