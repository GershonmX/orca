using module "..\ORCA.psm1"

class ORCA120_spam : ORCACheck
{
    <#
    
        CONSTRUCTOR with Check Header Data
    
    #>

    ORCA120_spam()
    {
        $this.Control="120-spam"
        $this.Area="Zero Hour Autopurge"
        $this.Name="Zero Hour Autopurge Enabled for Spam"
        $this.PassText="Zero Hour Autopurge is Enabled"
        $this.FailRecommendation="Enable Zero Hour Autopurge"
        $this.Importance="Zero Hour Autopurge can assist removing false-negatives post detection from mailboxes. By default, it is enabled."
        $this.ExpandResults=$True
        $this.ItemName="Policy"
        $this.DataType="ZapEnabled Setting"
        $this.ChiValue=[ORCACHI]::VeryHigh
        $this.Links= @{
            "Security & Compliance Center - Anti-spam settings"="https://aka.ms/orca-antispam-action-antispam"
            "Zero-hour auto purge - protection against spam and malware"="https://aka.ms/orca-zha-docs-2"
            "Recommended settings for EOP and Microsoft Defender for Office 365 security"="https://aka.ms/orca-atpp-docs-6"
        }
    
    }

    <#
    
        RESULTS
    
    #>

    GetResults($Config)
    {
        #$CountOfPolicies = ($Config["HostedContentFilterPolicy"]).Count
        $CountOfPolicies = ($global:HostedContentPolicyStatus| Where-Object {$_.IsEnabled -eq $True}).Count
       
        ForEach($Policy in $Config["HostedContentFilterPolicy"]) 
        {
            $IsPolicyDisabled = !$Config["PolicyStates"][$Policy.Guid.ToString()].Applies
            $SpamZapEnabled = $($Policy.SpamZapEnabled)

            $IsBuiltIn = $false
            $policyname = $Config["PolicyStates"][$Policy.Guid.ToString()].Name

            # Check objects
            $ConfigObject = [ORCACheckConfig]::new()
            $ConfigObject.ConfigItem=$policyname
            $ConfigObject.ConfigData=$SpamZapEnabled
            $ConfigObject.ConfigReadonly=$Policy.IsPreset
            $ConfigObject.ConfigDisabled=$IsPolicyDisabled
            $ConfigObject.ConfigPolicyGuid=$Policy.Guid.ToString()

            if($SpamZapEnabled -eq $true) 
            {
                $ConfigObject.SetResult([ORCAConfigLevel]::Standard,"Pass")
            } 
            else
            {
                $ConfigObject.SetResult([ORCAConfigLevel]::Standard,"Fail")
            }

            # Add config to check
            $this.AddConfig($ConfigObject)

        }        

    }

}