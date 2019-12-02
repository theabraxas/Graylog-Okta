function Main {
#    Try {
#        Sleep -Seconds 1
#        New-Item "C:\Logs\Okta\AuditLog.json" -force
#    }
#    Catch { 
#        Continue
#    }
############################################################
#                Variables and Functions                   #
############################################################
	function Get-EndDate{
	    $EndDate = (Get-date).AddMinutes(-1)
	    return Get-Date $EndDate -Format "yyyy-MM-dd'T'HH:mm:ss'Z'"
	}
	function Get-FirstStartDate{
	    $StartDate = (Get-Date).AddMinutes(-60)
	    return Get-Date $StartDate -Format "yyyy-MM-dd'T'HH:mm:ss'Z'"
	}
    
	$StartDatePath = "C:\Logs\Okta\starttime.txt"
	$StartFileExists = Test-Path $StartDatePath
  $AuditFile = "C:\Logs\Okta\AuditLog.json"

	If ($StartFileExists) {
	    $StartDate = Get-Content $StartDatePath
	}
	Else {
	    $StartDate = Get-FirstStartDate
	    $StartDate | Out-File "C:\Logs\Okta\starttime.txt"
	}
  
	$EndDate = Get-EndDate
  $TenantName = "" #This is the part of ____.okta.com you use to access your tenant
	$URI= "https://$TenantName.okta.com/api/v1/logs?since=$StartDate&until=$EndDate&limit=1000"

	############################################################
	#                   Connection Prereqs                     #
	############################################################

	$Token = ""  #Enter your token here, get this from the Okta API admin page
	$headers = @{}
	$Headers = @{"Authorization" = "SSWS $token"; "Accept" = "application/json"; "Content-Type" = "application/json"}
	[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

    While ($true) {
        $Result = Invoke-WebRequest -Headers $headers -Method GET -URI $uri
        $link = $Result.headers['link'] -split ","
        $next = $link[1] -split ";"
        $next = $next[0] -replace "<",""
        $next = $next -replace ">",""
        $Result.headers['link']
        If (-not ($next)) { 
            $EndDate | Out-File $StartDatePath
            break
        }
        $uri = $next
        $jsonData = ConvertFrom-Json $([String]::new($Result.Content))
        Foreach ($Log in $jsonData) {
            $Log | ConvertTo-Json -Compress | Out-File -FilePath $AuditFile -Append -Encoding ascii
        }
        Sleep -Milliseconds 600
    }
    Sleep -Seconds 120
    Remove-Item "C:\Logs\Okta\AuditLog.json" -Force
}

While ($true) {
    Main
    Sleep -Seconds 120
}
