# The script sets the sa password and start the SQl Service 

param(
[Parameter(Mandatory=$false)]
[string]$sa_password
)

# start the service
start-service MSSQL`$SQLEXPRESS


if($sa_password -ne "_"){
    $sqlcmd = "ALTER LOGIN sa with password=" +"'" + $sa_password + "'" + ";ALTER LOGIN sa ENABLE;"
    Invoke-Sqlcmd -Query $sqlcmd -ServerInstance ".\SQLEXPRESS" 
}

while ($true) { Start-Sleep -Seconds 3600 }