using module "..\ORCA.psm1"

class ORCA118_1 : ORCACheck
{
    <#
    
        CONSTRUCTOR with Check Header Data
    
    #>

    ORCA118_1()
    {
        $this.Control="ORCA-118-1"
        $this.Area="Anti-Spam Policies"
        $this.Name="Domain Allowlisting"
        $this.PassText="Domains are not being allow listed in an unsafe manner"
        $this.FailRecommendation="Remove allow listing on domains"
        $this.Importance="Emails coming from allow listed domains bypass several layers of protection within Exchange Online Protection. If domains are allow listed, they are open to being spoofed from malicious actors."
        $this.ExpandResults=$True
        $this.ItemName="Anti-Spam Policy"
        $this.DataType="Allowlisted Domain"
        $this.ChiValue=[ORCACHI]::High
        $this.Links= @{
            "Security & Compliance Center - Anti-spam settings"="https://aka.ms/orca-antispam-action-antispam"
            "Use Anti-Spam Policy Sender/Domain Allow lists"="https://aka.ms/orca-antispam-docs-4"
        }
    
    }

    <#
    
        RESULTS
    
    #>

    GetResults($Config)
    {
        #$CountOfPolicies = ($Config["HostedContentFilterPolicy"] ).Count
        $CountOfPolicies = ($global:HostedContentPolicyStatus| Where-Object {$_.IsEnabled -eq $True}).Count
       
        ForEach($Policy in $Config["HostedContentFilterPolicy"]) {
            $IsPolicyDisabled = !$Config["PolicyStates"][$Policy.Guid.ToString()].Applies

            $IsBuiltIn = $false
            $policyname = $Config["PolicyStates"][$Policy.Guid.ToString()].Name
            $AllowedSenderDomains = $($Policy.AllowedSenderDomains)


            <#
            
            Important! Do not apply read-only here for preset/default policies a this can be modified
            
            #>
    
            # Fail if AllowedSenderDomains is not null
    
            If(($AllowedSenderDomains).Count -gt 0) 
            {
                ForEach($Domain in $AllowedSenderDomains) 
                {
                    # Check objects
                    $ConfigObject = [ORCACheckConfig]::new()
                    $ConfigObject.ConfigItem=$policyname
                    $ConfigObject.ConfigData=$($Domain.Domain)
                    $ConfigObject.ConfigDisabled=$IsPolicyDisabled
                    $ConfigObject.ConfigPolicyGuid=$Policy.Guid.ToString()

                    $ConfigObject.SetResult([ORCAConfigLevel]::Standard,"Fail")

                    $this.AddConfig($ConfigObject)  
                }
            } 
            else 
            {
                # Check objects
                $ConfigObject = [ORCACheckConfig]::new()
                $ConfigObject.ConfigItem=$policyname
                $ConfigObject.ConfigDisabled=$IsPolicyDisabled
                $ConfigObject.ConfigPolicyGuid=$Policy.Guid.ToString()
                
                $ConfigObject.ConfigData="No domain available"
                $ConfigObject.SetResult([ORCAConfigLevel]::Standard,"Pass")

                $this.AddConfig($ConfigObject)  
            }
        }        
    }

}