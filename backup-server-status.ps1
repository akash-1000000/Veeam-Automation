$Today = Get-Date

$Today

$Yesterday = $Today.AddDays(-1)


Connect-VBRServer -Server "ServerIP"
 
#Fetching all Live jobs that has run in time span of last 24 hours and have next run enabled.
$TotalLiveJobs  = Get-VBRJob | Where-Object {$_.IsScheduleEnabled -eq $true -and $_.LatestRunLocal -ge $Yesterday}

#Filtering Successful jobs
$SuccessJobs = $TotalLiveJobs | Where-Object {$_.GetLastResult() -eq "Success"}

#Filtering Failed jobs
$FailedJobs = $TotalLiveJobs | Where-Object {$_.GetLastResult() -eq "Failed"}

#Filtering Running jobs
$RunningJobs = $TotalLiveJobs | Where-Object {$_.IsRunning -eq $true}


Write-Host "Total success jobs "$SuccessJobs.count"/"$TotalLiveJobs.count""

If ($FailedJobs){
    foreach($FailedJob in $FailedJobs){$FailedJob.Name}}

If ($RunningJobs) {
    Foreach($RunningJob in $RunningJobs){
        Write-Host "Running Jobs:"
        $RunningJob.Name
        }}


Write-Host "Slow Jobs(Less than 100 mbps):"

#Declaring new Hash Table for filtering and storing Slow jobs in key: Value pair {Job-name: 100 Mbps}
$SlowJobs = @{}
Foreach ($Job in $SuccessJobs){
    #Getting Getting lastsession of all success jobs
    $SessionCounter = Get-VBRTaskSession -Session $Job.FindLastSession()
    #Getting avg speed in MB/sec.
    $Counter = $SessionCounter.Progress.AvgSpeed/1MB
    $Counter = [math]::Round($Counter, 0)
    #Getting size of the data read in GB.
    $size = $SessionCounter.Progress.ReadSize/1GB
    
    if ($Counter -lt 100 -and $size -gt 100){
        $SlowJobs[$Job.Name] = "$Counter MB/s"
        }
    }


$SlowJobs.Count

$SlowJobs | Format-Table

Disconnect-VBRServer 
