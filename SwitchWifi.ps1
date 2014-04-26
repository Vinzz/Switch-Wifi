# In case of execution policy error, launch this command in an elevated powershell
# Set-ExecutionPolicy -ExecutionPolicy Unrestricted

# Elevation des privileges
function Test-Admin {
  $currentUser = New-Object Security.Principal.WindowsPrincipal $([Security.Principal.WindowsIdentity]::GetCurrent())
  $currentUser.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
}

Try
{
	if ((Test-Admin) -eq $false)  
	{
		Start-Process powershell.exe -Verb RunAs -ArgumentList ('-noprofile -noexit -file "{0}" -elevated' -f ($myinvocation.MyCommand.Definition))
		exit
	}
	
	"1/6 - Accès à la livebox"

	#IE automation
	$ie = new-object -com "InternetExplorer.Application"
	$ie.navigate("http://livebox")
	$ie.visible = $false

	Start-Sleep -s 3

	$doc = $ie.document

	#Fill password
	$tb1 = $doc.getElementByID("authpasswd")
	$tb1.value = 'Put-your-password-here'

	$links=@($doc.getElementsByTagName("a"))

	#Click on login
	$button = $links | where {$_.Title -eq 'Accéder'}
	$button.click()
	
	"2/6 - Login console administration"
	
	Start-Sleep -s 3

	#Click on configuration
	$doc.getElementByID("rubric2").click()

	"3/6 - Accès configuration"
	
	Start-Sleep -s 2

	#Click on wifi
	"4/6 - Paramètres Wifi"
	
	$doc.getElementByID("link6").click()

	Start-Sleep -s 2

	$a = new-object -comobject wscript.shell

	"5/6 - Check Wifi"
	
	#Wifi checkbox exist test
	if($doc.getElementById("wifistatus"))
	{
	    if($doc.getElementById("wifistatus").Checked -eq "True")
	    {
	        "6/6 - Coupure Wifi"
		    $b = $a.popup("Coupure Wifi",2,”Wifi Switch”,64)
	    }
	    else
	    {
            "6/6 - Mise en route Wifi"
		    $b = $a.popup("Mise en route Wifi",2,”Wifi Switch”,64)
	    }

	#Click on wifi checkbox
	    $doc.getElementById("wifistatus").click()

	#Click on save button
	    $doc.getElementById("linkbutt2").click()

	    Start-Sleep -s 1
	    $ie.Quit()
	    $ie = ""
	}
	else
	{
	#Error handling
	    $b = $a.popup("Quelque chose s'est mal passé...",0,”Wifi Switch”,16)
	    $ie.visible = $true
	}
}
Catch
{
    $ErrorMessage = $_.Exception.Message
    
    $a = new-object -comobject wscript.shell
    $b = $a.popup($ErrorMessage,0,”Wifi Switch”,16)
    
    Break
}

"...Fin du script"
Exit 
