<#

ORCA-228 - Check ATP Anti-Phishing trusted senders  

#>

using module "..\ORCA.psm1"

class ORCA228 : ORCACheck
{
    <#
    
        CONSTRUCTOR with Check Header Data
    
    #>

    ORCA228()
    {
        $this.Control=228
        $this.Services=[ORCAService]::OATP
        $this.Area="Advanced Threat Protection Policies"
        $this.Name="Anti-phishing trusted senders"
        $this.PassText="No trusted senders in Anti-phishing policy"
        $this.FailRecommendation="Remove whitelisting on senders in Anti-phishing policy"
        $this.Importance="Adding senders as trusted in Anti-phishing policy will result in the action for protected domains, Protected users or mailbox intelligence protection will be not applied to messages coming from these senders. If a trusted sender needs to be added based on organizational requirements it should be reviewed regularly and updated as needed."
        $this.ExpandResults=$True
        $this.CheckType=[CheckType]::ObjectPropertyValue
        $this.ObjectType="Antiphishing Policy"
        $this.ItemName="Setting"
        $this.DataType="Current Value"
        $this.Links= @{
            "Security & Compliance Center - Anti-phishing"="https://aka.ms/orca-atpp-action-antiphishing"
            "Recommended settings for EOP and Office 365 ATP security"="https://aka.ms/orca-atpp-docs-7"
        }
    }

    <#
    
        RESULTS
    
    #>

    GetResults($Config)
    {

        $PolicyExists = $False
        #$CountOfPolicies = ($Config["AntiPhishPolicy"] | Where-Object {$_.Enabled -eq $True}).Count
        $CountOfPolicies = ($global:AntiSpamPolicyStatus| Where-Object {$_.IsEnabled -eq $True}).Count
        ForEach($Policy in ($Config["AntiPhishPolicy"] ))
        {
            $IsPolicyDisabled = !$Config["PolicyStates"][$Policy.Guid.ToString()].Applies

            $ExcludedSenders = $($Policy.ExcludedSenders)

            $policyname = $($Policy.Name)

            $PolicyExists = $True

            #  Determine if tips for user impersonation is on

            $ConfigObject = [ORCACheckConfig]::new()

            $ConfigObject.Object=$policyname
            $ConfigObject.ConfigItem="ExcludedSenders"
            $ConfigObject.ConfigDisabled = $IsPolicyDisabled

            <#
            
            Important! This setting can be changed on pre-set policies and is not read only. Do not apply read only tag to preset policies.
            
            #>

            If(($ExcludedSenders).count -eq 0)
            {
                $ConfigObject.ConfigData="No Sender Detected"    
                $ConfigObject.SetResult([ORCAConfigLevel]::Standard,"Pass")       
            }
            Else 
            {
                $ConfigObject.ConfigData=$ExcludedSenders
                $ConfigObject.SetResult([ORCAConfigLevel]::Standard,"Fail")                       
            }

            $this.AddConfig($ConfigObject)

        }

        If($PolicyExists -eq $False)
        {
            $ConfigObject = [ORCACheckConfig]::new()

            $ConfigObject.Object="No Policies"
            $ConfigObject.SetResult([ORCAConfigLevel]::Standard,"Fail")            

            $this.AddConfig($ConfigObject)      
        }        

    }

}