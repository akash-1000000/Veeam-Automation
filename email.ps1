#Storing password for support@v-connect.in $pass variable.
$pass = Get-StoredCredential -Target 'v-connect.in'
#Changinf the security protocol to Tls12
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
#Send-MailMessage with attachment
Send-MailMessage -UseSsl -Credential $pass -From 'support@v-connect.in' -To 'akash.uniyal@v-connect.in' -Subject '192.168.10.111' -Body 'Result' -SmtpServer 'smtp.office365.com' -Attachments 'C:\Users\Administrator\Desktop\Veeam-automation\result.txt' 