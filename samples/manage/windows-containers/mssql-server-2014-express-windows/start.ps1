# The script sets the sa password and start the SQL Service 
# Also it attaches additional database from the disk
# The format for attach_dbs

param(
[Parameter(Mandatory=$false)]
[string]$sa_password,

[Parameter(Mandatory=$false)]
[string]$attach_dbs
)

# start the service
Write-Verbose "Starting SQL Server"
start-service MSSQL`$SQLEXPRESS

if($sa_password -ne "_"){
	Write-Verbose "Changing SA login credentials"
    $sqlcmd = "ALTER LOGIN sa with password=" +"'" + $sa_password + "'" + ";ALTER LOGIN sa ENABLE;"
    Invoke-Sqlcmd -Query $sqlcmd -ServerInstance ".\SQLEXPRESS" 
}

$attach_dbs = $attach_dbs | ConvertFrom-Json

if ($null -ne $attach_dbs){
	Write-Verbose "Attaching database(s)"
	Foreach($db in $attach_dbs)
	{
		$files = @();
		Foreach($file in $db.dbFiles)
		{
			$files += "(FILENAME = 'N$($file)')";
		}
		
		$files = $files -join ","
		$sqlcmd = "sp_detach_db $($db.dbName);GO;CREATE DATABASE $($db.dbName) ON $($files) FOR ATTACH ;GO;"

		Write-Host Invoke-Sqlcmd -Query $($sqlcmd) -ServerInstance ".\SQLEXPRESS" 
		Invoke-Sqlcmd -Query $sqlcmd -ServerInstance ".\SQLEXPRESS"
	}
}

while ($true) { Start-Sleep -Seconds 3600 }