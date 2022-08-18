NEED TO SET SOME VARIABLES FIRST 

$MYOUTBOUNDIP = (Invoke-WebRequest http://myexternalip.com/raw).Content -replace "`n"
$SQLPASSWORD = '<SOME PASSWORD>'

az deployment sub create --template-file "./main.bicep" --location "northeurope" --parameters sqlPassword=$SQLPASSWORD userIPAddress=$MYOUTBOUNDIP
