<#

123 - Check MDO Phishing Enable Unusual Characters Safety Tips 

#>

using module "..\ORCA.psm1"

class ORCA123 : ORCACheck
{
    <#
    
        CONSTRUCTOR with Check Header Data
    
    #>

    ORCA123()
    {
        $this.Control=123
        $this.Services=[ORCAService]::MDO
        $this.Area="Microsoft Defender for Office 365 Policies"
        $this.Name="Unusual Characters Safety Tips"
        $this.PassText="Unusual Characters Safety Tips is enabled"
        $this.FailRecommendation="Enable Unusual Characters Safety Tips so that users can receive visible indication on incoming messages."
        $this.Importance="Microsoft Defender for Office 365 can show a warning tip to recipients where the sender name or email address contains character sets that aren't usually used together."
        $this.ExpandResults=$True
        $this.CheckType=[CheckType]::ObjectPropertyValue
        $this.ObjectType="Antiphishing Policy"
        $this.ItemName="Setting"
        $this.DataType="Current Value"
        $this.ChiValue=[ORCACHI]::Low
        $this.Links= @{
            "Security & Compliance Center - Anti-phishing"="https://aka.ms/orca-atpp-action-antiphishing"
            "Recommended settings for EOP and Microsoft Defender for Office 365 security"="https://aka.ms/orca-atpp-docs-7"
        }
    }

    <#
    
        RESULTS
    
    #>

    GetResults($Config)
    {

        ForEach($Policy in ($Config["AntiPhishPolicy"] | Where-Object {$_.Enabled -eq $True}))
        {
            $IsPolicyDisabled = !$Config["PolicyStates"][$Policy.Guid.ToString()].Applies
            $EnableUnusualCharactersSafetyTips = $($Policy.EnableUnusualCharactersSafetyTips)

            $policyname = $Config["PolicyStates"][$Policy.Guid.ToString()].Name
            
            #  Determine if tips for user impersonation is on

            $ConfigObject = [ORCACheckConfig]::new()

            $ConfigObject.Object=$policyname
            $ConfigObject.ConfigItem="EnableUnusualCharactersSafetyTips"
            $ConfigObject.ConfigData=$EnableUnusualCharactersSafetyTips
            $ConfigObject.ConfigReadonly=$Policy.IsPreset
            $ConfigObject.ConfigDisabled=$IsPolicyDisabled
            $ConfigObject.ConfigPolicyGuid=$Policy.Guid.ToString()

            If($EnableUnusualCharactersSafetyTips -eq $false)
            {
                $ConfigObject.SetResult([ORCAConfigLevel]::Standard,"Fail")       
            }
            Else 
            {
                $ConfigObject.SetResult([ORCAConfigLevel]::Standard,"Pass")                  
            }

            $this.AddConfig($ConfigObject)

        }

        If($Config["AnyPolicyState"][[PolicyType]::Antiphish] -eq $False)
        {
            $ConfigObject = [ORCACheckConfig]::new()
            $ConfigObject.Object="No Enabled Policies"
            $ConfigObject.ConfigItem="EnableUnusualCharactersSafetyTips"
            $ConfigObject.ConfigData=""
            $ConfigObject.SetResult([ORCAConfigLevel]::Standard,"Fail")
            $this.AddConfig($ConfigObject)
        }             

    }

}