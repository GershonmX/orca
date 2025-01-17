<#

221 - Check MDO Phishing Mailbox Intelligence is enabled 

#>

using module "..\ORCA.psm1"

class ORCA221 : ORCACheck
{
    <#
    
        CONSTRUCTOR with Check Header Data
    
    #>

    ORCA221()
    {
        $this.Control=221
        $this.Services=[ORCAService]::MDO
        $this.Area="Microsoft Defender for Office 365 Policies"
        $this.Name="Mailbox Intelligence Enabled"
        $this.PassText="Mailbox intelligence is enabled in anti-phishing policies"
        $this.FailRecommendation="Enable mailbox intelligence in anti-phishing policies"
        $this.Importance="Mailbox Intelligence checks can provide your users with intelligence on suspicious incoming emails that appear to be from users that they normally communicate with based on their graph."
        $this.ExpandResults=$True
        $this.CheckType=[CheckType]::ObjectPropertyValue
        $this.ObjectType="Antiphishing Policy"
        $this.ItemName="Setting"
        $this.DataType="Current Value"
        $this.ChiValue=[ORCACHI]::Low
        $this.Links= @{
            "Security & Compliance Center - Anti-phishing"="https://aka.ms/orca-atpp-action-antiphishing"
            "Recommended settings for EOP and Microsoft Defender for Office 365"="https://aka.ms/orca-atpp-docs-7"
        }
    }

    <#
    
        RESULTS
    
    #>

    GetResults($Config)
    {
        
        <#
        
        This check does not need a default fail if no policies exist, as there is always a default AP policy.
        
        #>
      
        ForEach($Policy in ($Config["AntiPhishPolicy"] | Where-Object {$_.Enabled -eq $True}))
        {
                  
            $IsPolicyDisabled = !$Config["PolicyStates"][$Policy.Guid.ToString()].Applies

            $EnableMailboxIntelligence = $($Policy.EnableMailboxIntelligence)

            $policyname = $Config["PolicyStates"][$Policy.Guid.ToString()].Name

            # Check objects
            $ConfigObject = [ORCACheckConfig]::new()
            $ConfigObject.Object=$policyname
            $ConfigObject.ConfigItem="EnableMailboxIntelligence"
            $ConfigObject.ConfigData=$EnableMailboxIntelligence
            $ConfigObject.ConfigDisabled = $IsPolicyDisabled
            $ConfigObject.ConfigReadonly = $Policy.IsPreset
            $ConfigObject.ConfigPolicyGuid=$Policy.Guid.ToString()

            # Determine Mailbox Intelligence is ON

            If($EnableMailboxIntelligence -eq $false)
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
            $ConfigObject.ConfigItem="EnableMailboxIntelligence"
            $ConfigObject.ConfigData=""
            $ConfigObject.SetResult([ORCAConfigLevel]::Standard,"Fail")
            $this.AddConfig($ConfigObject)
        }     
  

    }

}