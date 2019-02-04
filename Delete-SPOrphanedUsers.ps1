#region Author-Info
########################################################################################################################## 
# Author: Zewwy (Aemilianus Kehler)
# Date:   Feb 1, 2019
# Script: Delete-SPOrphanedUsers
# This script allows to remove orpahned users from Site Collection UILs.
# 
# Required parameters: 
#  Just run it 
##########################################################################################################################
#endregion
#region Variables
##########################################################################################################################
#   Variables
##########################################################################################################################
#MyLogoArray
$MylogoArray = @(
    ("              This script is brought to you by:              "),
    ("      ___         ___         ___         ___                "),
    ("     /  /\       /  /\       /__/\       /__/\        ___    "),
    ("    /  /::|     /  /:/_     _\_ \:\     _\_ \:\      /__/|   "),
    ("   /  /:/:|    /  /:/ /\   /__/\ \:\   /__/\ \:\    |  |:|   "),
    ("  /  /:/|:|__ /  /:/ /:/_ _\_ \:\ \:\ _\_ \:\ \:\   |  |:|   "),
    (" /__/:/ |:| //__/:/ /:/ //__/\ \:\ \:/__/\ \:\ \:\__|__|:|   "),
    (" \__\/  |:|/:\  \:\/:/ /:\  \:\ \:\/:\  \:\ \:\/:/__/::::\   "),
    ("     |  |:/:/ \  \::/ /:/ \  \:\ \::/ \  \:\ \::/ \_\\~~\:\  "),
    ("     |  |::/   \  \:\/:/   \  \:\/:/   \  \:\/:/      \  \:\ "),
    ("     |  |:/     \  \::/     \  \::/     \  \::/        \__\/ "),
    ("     |__|/       \__\/       \__\/       \__\/               "),
    (" ")
)
#Script Definition
$ScriptName = "Delete-SPOrphanedUsers; cause some SharePoint orphans need to go."
$OrphanScript = @(
("   _________________________________________                "),
("  /                                         \               "),
(" | I hate all the orphans in the whole world |              "),
(" | !!!!!!!! Nachoooooooooooooooooooo!!!!     |              "),
("  \_________________________________________/               "),
("         \                                                  "),
("           ,,n;^^^^^..od&4@@@&@@bo.                         "),
("             4         ^            .%*@;,                  "),
("           m.           ^                ,@                 "),
("          @                                %(               "),
("         @                  .               ./              "),
("       d/           .       /            .    /,            "),
("      @$;            ;    , //                 *.&          "),
("     d@  `        /////  ////////.                &         "),
("     @.             ///////     .//;,              ;        "),
("     &         //////////////////////;       ,     &        "),
("     q         /.__   //////._    /////        ;   ;        "),
("      @       //.   ////////    ///////;          ;;        "),
("      x#      /////// //////////////////         .(1        "),
("      (       /////////////////////////// //    .* 1,       "),
("      ;      .'///////(////////////////// ///   1.   .      "),
("     :        ///////./////////////////// ///   Xl.. .)     "),
("      *       ////////___-//////////////////    # %@#*      "),
("      i ,  .  ///////////////////////////         1@l&&     "),
("       ;       //////////////////////////      * l*, l@     "),
("       (S      .////#___==//////////////         .,*11(     "),
("       a@,       /////////////////// /////         ^( s#    "),
("         @        /////////////////,//////          ,(ds@   "),
("         / a        ////////////' /////////@@            @  "),
("        @@@       ,  *///////' ./////////*/@            * & "),
("       @@@.         (        . ..///////@@ /*        .*a$*  "),
("   xXXXXX/           @/ /////////////(@@@ad@#/ *,       .   "),
("  XXXXX@@AA*         \@@@&.///////&@@@@'a@@@@@@@    //XXXx  "),
(" xXXX&@@#AA.AAAAAAA* .A`@@@@@@@@@@@@@'a@@@@@@@@    /#XXXXXX "),
(" XXXX@@@@AAAAAAAA@AAAAAb`~@@@@@@@@~asS@@@@@@@@@*/X(&XXXXXXXx"),
(" ")
)
#If domain vars are not altered, and do not exist, script still works fine
#Script Variables, Domain1 and Domain2 are the domains to be filtered.
$Domain1 = "Domain1"
$Domain2 = "Domain2"
#------------------------------------------------------------------------------------------------------------------------
#Static Variables
#------------------------------------------------------------------------------------------------------------------------
$pswheight = (get-host).UI.RawUI.MaxWindowSize.Height
$pswwidth = (get-host).UI.RawUI.MaxWindowSize.Width
#endregion

#region Functions
##########################################################################################################################
#   Functions
##########################################################################################################################

#function takes in a name to alert confirmation of an action
function confirm()
{
  param(
  [Parameter(Position=0,Mandatory=$true)]
  [string]$name,
  [Parameter(Position=1,Mandatory=$false,ParameterSetName="color")]
  [string]$C
  )
    Centeralize "$name" "$C" -NoNewLine;$answer = Read-Host;Write-Host " "
    Switch($answer)
    {
        yes{$result=0}
        ye{$result=0}
        y{$result=0}
        no{$result=1}
        n{$result=1}
        default{confirm $name $C}
    }
    Switch ($result)
        {
              0 { Return $true }
              1 { Return $false }
        }
}

#Function to Centeralize Write-Host Output, Just take string variable parameter and pads it
function Centeralize()
{
  param(
  [Parameter(Position=0,Mandatory=$true)]
  [string]$S,
  [Parameter(Position=1,Mandatory=$false,ParameterSetName="color")]
  [string]$C,
  [Parameter(Mandatory=$false)]
  [switch]$NoNewLine = $false
  )
    $sLength = $S.Length
    $padamt =  "{0:N0}" -f (($pswwidth-$sLength)/2)
    $PadNum = $padamt/1 + $sLength #the divide by one is a quick dirty trick to covert string to int
    $CS = $S.PadLeft($PadNum," ").PadRight($PadNum," ") #Pad that shit
    if (!$NoNewLine)
    {
        if ($C) #if variable for color exists run below
        {    
            Write-Host $CS -ForegroundColor $C #write that shit to host with color
        }
        else #need this to prevent output twice if color is provided
        {
            $CS #write that shit without color
        }
    }
    else
    {
        if ($C) #if variable for color exists run below
        {    
            Write-Host $CS -ForegroundColor $C -NoNewLine #write that shit to host with color
        }
        else #need this to prevent output twice if color is provided
        {
            Write-Host $CS -NoNewLine #write that shit without color
        }
    }
}

function CheckForestGroupObject()
{
    Param(
             [Parameter(Position=0,Mandatory=$true)] [string]$ADObjectString,
             [Parameter(Position=1,Mandatory=$true)] $Forest
         )
        foreach ($Domain in $Forest.Domains)
        {
              $context = new-object System.DirectoryServices.ActiveDirectory.DirectoryContext("Domain", $Domain.Name)
              $domain = [System.DirectoryServices.ActiveDirectory.Domain]::GetDomain($context)          
              $root = $domain.GetDirectoryEntry()
              $search = [System.DirectoryServices.DirectorySearcher]$root
              $search.Filter = "(&(objectCategory=Group)(samAccountName=$ADObjectString))"
              $result = $search.FindOne()            
              if ($result)
              {
                return $true
              }
        }
        return $false
}
#Function to check Object against Forest
function CheckForestObject()
{
    Param(
             [Parameter(Position=0,Mandatory=$true)] [string]$ADObjectString,
             [Parameter(Position=1,Mandatory=$true)] $Forest
         )
        foreach ($Domain in $Forest.Domains)
        {
              $context = new-object System.DirectoryServices.ActiveDirectory.DirectoryContext("Domain", $Domain.Name)
              $domain = [System.DirectoryServices.ActiveDirectory.Domain]::GetDomain($context)          
              $root = $domain.GetDirectoryEntry()
              $search = [System.DirectoryServices.DirectorySearcher]$root
              $search.Filter = "(&(objectCategory=User)(samAccountName=$ADObjectString))"
              $result = $search.FindOne()            
              if ($result)
              {
                return $true
              }
        }
        return $false
}
#Function to Check if an User exists in AD
function CheckUserExistsInAD($ADObject)
{
    CheckForestObject $ADObject $Script:forest
}

Function ManuallyDeleteSPUsers($OUsers,$SSite)
{
    foreach($OrpUser in $OUsers)
    {
        if(confirm "Delete SharePoint User: $($OrpUser)? ")
        {
            $SSite.SiteUsers.Remove($OrpUser)
            Centeralize "Removed the Orphaned user $($OrpUser) from $($SSite.URL) `n" "Red"
        }
        else
        {
            Centeralize "The Orphaned user $($OrpUser) remains in $($SSite.URL) `n" "Yellow"
        }
    }
}

Function AutoDeleteSPUsers($OUsers,$SSite)
{
    foreach($OrpUser in $OUsers)
    {
        $SSite.SiteUsers.Remove($OrpUser)
        Centeralize "Removed the Orphaned user $($OrpUser) from $($SSite.URL)"
    }
}

function AskHowToDelete($Question)
{
    Centeralize "$Question" "Red" -NoNewLine;$answer = Read-Host;Write-Host " "
    Switch($answer)
    {
        Auto{$result=0}
        a{$result=0}
        Manual{$result=1}
        m{$result=1}
        default{confirm $Question}
    }
    Switch ($result)
        {
              0 { Return $true }
              1 { Return $false }
        }
}
#endregion

#region Run

    #region DisplayLogo
    #Start actual script by posting and asking user for responses
    foreach($L in $MylogoArray){Centeralize $L "green"}
    Centeralize $ScriptName "White"
    foreach($L in $OrphanScript){Centeralize $L "white"}
    #endregion
    #region AskForWebAppURL
    function AskForWebAppURL()
    {
        #Notify User to enter the Site Collection URL then check if it exits.
        Centeralize "Please enter a SharePoint Web App URL`n"
        Write-host "SharePoint Web Application URL: " -ForegroundColor Magenta -NoNewline
        $Script:WebAppURL = Read-Host
        Write-Host " "
        if(!$WebAppURL){AskForWebAppURL}
        if(Get-SPWebApplication $WebAppURL -ErrorAction SilentlyContinue)
        {
            Centeralize "Web App Exists: $WebAppURL`n" "Green"
        }
        else
        {
            Centeralize "No WebApp Returned.`n" "Yellow";AskForWebAppURL;
        }
    }
    AskForWebAppURL
    #endregion
    #region AskSearchForestDomainAndDefineForestObject
    #Notify User to enter Forest Domain to Search. Then define the Forest Object Once

        Centeralize "If you know the users exist in the local forest leave this undefined.`n" "Yellow"
        Centeralize "Otherwise if the users exist in a trusted forest, enter that Forest name.`n" "Yellow"
        Centeralize "Pretty much, enter the domain in which this script will query to see if accounts exist.`n" "Yellow"
        function AskForForest()
        {
            if(confirm "Do you have a forest trust? " "Blue")
            {
                Write-host "Forest (Default: Forest in which this server resides): " -ForegroundColor Magenta -NoNewline
                $ForestToSearch = Read-Host
                Write-Host " "
                if($ForestToSearch)
                {
                    Try{
                    $ForestContext = new-object System.DirectoryServices.ActiveDirectory.DirectoryContext("Forest", $ForestToSearch)
                    $Script:forest = [System.DirectoryServices.ActiveDirectory.Forest]::GetForest($ForestContext)
                    }
                    catch
                    {AskForForest}
                }
                else
                {
                    $Script:forest = [System.DirectoryServices.ActiveDirectory.Forest]::GetCurrentForest()
                }
             }
             else
             {
                $Script:forest = [System.DirectoryServices.ActiveDirectory.Forest]::GetCurrentForest()
             }
        }
        AskForForest

    #endregion
    #region AskIfFilters
    Centeralize "Normally if you are running a single domain you will not want to apply a filter.`n" "Yellow" 
    if(confirm "Apply Filters? " "blue")
    {
        #region AskFirstFilteredDomain
        Centeralize "Please enter a Domain to Filter. These users will not appear in the log.`n"
        #Notify User to enter Domain to Filter.
        Write-host "Domain (Default Domain1): " -ForegroundColor Magenta -NoNewline
        $Domain1 = Read-Host
        if(!$Domain1){$Domain1 = "Domain1"}
        if($Domain1.Contains(".")){Centeralize "`nYou have entered a FQDN domain name, Stripping First part`n" "Cyan"; $Domain1 = $Domain1.ToLower().Split(".")[0];Centeralize $Domain1 "White"}
        Write-Host " "
        #endregion
        #region AskSecondFilteredDomain
        #Notify User to enter Second Domain to Filter.
        Write-host "Domain (Default Domain2): " -ForegroundColor Magenta -NoNewline
        $Domain2 = Read-Host
        if(!$Domain2){$Domain2 = "Domain2"}
        if($Domain2.Contains(".")){Centeralize "`nYou have entered a FQDN domain name, Stripping First part`n" "Cyan"; $Domain2 = $Domain2.ToLower().Split(".")[0];Centeralize $Domain2 "White"}
        Write-Host " "
        #endregion
    }
    #endregion

    #region Go
    Centeralize "Verifying SharePoint Web App, Please Wait...`n" "White"
    if ($WebApp=Get-SPWebApplication $WebAppURL -EA SilentlyContinue)
    {   
        #Iterate through all Site Collections
        foreach($site in $WebApp.Sites) 
        {     
            $OrphanedUsers = @()
            Centeralize "Going through $Site`n" "Cyan"
            try{$site.AllWebs | Out-null
                $SPSiteMainWeb = $site.AllWebs[0] | Where {$_.HasUniqueRoleAssignments -eq $True}                  
                Centeralize "Grabbing users from SharePoint Web: $SPSiteMainWeb`n" "Cyan"
                Centeralize "Verifying if User exists in forest: $Forest`n" "Cyan"   
                #Iterate through the users collection
                $SPOrphans = @()
                foreach($User in $SPSiteMainWeb.SiteUsers)
                {
                    #Write-Host "Hi my name is: " + $User.LoginName + " with a count of " + $SPSiteMainWeb.SiteUsers.Count
                    #Exclude Built-in User Accounts , Security Groups & an external domain "corporate"
                    if(($User.LoginName.ToLower() -ne "nt authority\authenticated users") -and
                    ($User.LoginName.ToLower() -ne "sharepoint\system") -and
                    ($User.LoginName.ToLower() -ne "nt authority\local service")  -and
                    #($user.IsDomainGroup -eq $false ) -and
                    ((($User.LoginName.ToLower().Split("\"))[0]).Contains("$Domain1") -ne $true) -and
                    ((($User.LoginName.ToLower().Split("\"))[0]).Contains("$Domain2") -ne $true))
                    {
                        if($User.IsDomainGroup)
                        {
                            #----- I haven't implemented custom object code base for the groups yet --------
                            #$FullGroupName = $User.LoginName.split("\")  #Domain\UserName
                            #$GroupName = $FullGroupName[1]    #GroupName
                            #if(!$GroupName){Write "Group name is apparently null.. skipping AD check"}
                            #elseif((CheckForestGroupObject $GroupName $Script:forest) -eq $false)
                            #{
                            #    LogWrite "$($User.Name)($($User.LoginName)) GROUP from $($_.URL) doesn't Exists in AD Forest ($Script:forest)!"       
                            #    #Make a note of the Orphaned user
                            #    $OrphanedUsers+=$User.LoginName
                            #}                       
                        }#Close If
                        else
                        {
                            $UserName = $User.LoginName.split("\")  #Domain\UserName
                            $AccountName = $UserName[1]    #UserName
                            if(!$AccountName){Write "User Account name is apparently null.. skipping AD check"}
                            elseif((CheckUserExistsInAD $AccountName) -eq $false)
                            {      
                                 
                                 $SPOrphan = New-Object -TypeName psobject
                                 # Add property to hold Orphaned Users Name
                                 $SPOrphan | Add-Member -MemberType NoteProperty -Name UserName $User.Name
                                 # Add property to hold Orphaned Users Login Name
                                 $SPOrphan | Add-Member -MemberType NoteProperty -Name UserLoginName $User.LoginName
                                 $SPOrphans = $SPOrphans + $SPOrphan
                            }
                        }#Close Else
                    }#Close First If                
                }#End ForEach User
                #region AskHowtoDisplayList
                # Remove the Orphaned Users from the site
                $OrphCount = "SP Web " + $SPSiteMainWeb.URL + " contained this many orphaned accounts: "
                Centeralize "$OrphCount" "Yellow" -NoNewLine
                Write-Host $SPOrphans.Count -ForegroundColor Red               
                Write-Host " "
                foreach($or in $SPOrphans)
                {
                    #$or.UserLoginName
                    $OrphanedUsers += $or.UserLoginName
                }
                #Write-Host $OrphanedUsers
                if(confirm "Delete Users from $($SPSiteMainWeb)? ")
                {
                    if(AskHowToDelete "How would like to delete? (A)uto or (M)anual? ")
                    {
                        AutoDeleteSPUsers $OrphanedUsers $SPSiteMainWeb
                    }
                    else #Auto Dele
                    {
                        ManuallyDeleteSPUsers $OrphanedUsers $SPSiteMainWeb
                    }
                    #write-host "please"
                }
                #endregion HowtoDisplayList
            #}#Close AllWeb ForEach-Object            
        }catch{Centeralize "Sorry it appears you lack site permissions, Check yo privliges!`n" "red"} 
        }#Close Site ForEach
        Centeralize "Script has completed.`n" "Green"
    }
    #endregion Go

#endregion Run