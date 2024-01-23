#Getting current date 
$Today = Get-Date
#Printing Date on console
$Today
#Making a tracker variable to take care of backup jobs that ran in past 24hrs.
$Yesterday = $Today.AddDays(-1)
#Creating an object(Array) fr storing all outputs
$o = @()
#Initiating connection with the backup server
Connect-VBRServer -Server 192.168.10.111 
#Filtering all VBRJobs that have ran in last 24hrs. and have schedule enabled.
$TotalLiveJobs  = Get-VBRJob | Where-Object {$_.IsScheduleEnabled -eq $true -and $_.LatestRunLocal -ge $Yesterday}
#Further filtered jobs that have success result of last job.
$SuccessJobs = $TotalLiveJobs | Where-Object {$_.GetLastResult() -eq "Success"}
#Creating new temporary variable for appending my output in previouslt created object.
$temp = $TotalLiveJobs.Count
#Storing Total jobs in $o.
$o += "Total jobs: $temp"
#Storing Successful jobs in $o.
$temp = $SuccessJobs.Count
$o += "Success jobs $temp"
#Comaring if the total jobs and succcess jobs are equal if they are then I don't need to filter my Total jobs further.
if($SuccessJobs.Count -lt $TotalLiveJobs.Count){
#Now filtering jobs tht have failed result.
    $FailedJobs = $TotalLiveJobs | Where-Object {$_.GetLastResult() -eq "Failed"}
#If there are one or more failed jobs it will store the result in our $o.   
    If ($FailedJobs){   
        $temp = $FailedJobs.Count
        $o += "Failed jobs: $temp"
        foreach($FailedJob in $FailedJobs){$o += $FailedJob.Name
        }
    }
    $RunningJobs = $TotalLiveJobs | Where-Object {$_.IsRunning -eq $true}
#Using same filtering scheme for running jobs.
    If($RunningJobs){
        $temp = $RunningJobs.Count
        $o += "Running jobs: $temp"
        Foreach($RunningJob in $RunningJobs){
            $o += $RunningJob.Name
        }
    }
}      
#Declaring new Hash Table for filtering and storing Slow jobs in key: Value pair {Job-name: 20 Mbps}
$SlowJobs = @{}
Foreach ($Job in $SuccessJobs){
#Fething the last session of Job using Get-VBRTaskSession method.
    $SessionCounter = Get-VBRTaskSession -Session $Job.FindLastSession()
#Getting avg speed and dividing it by 1MB fto get result in MBps.
    $Counter = $SessionCounter.Progress.AvgSpeed/1MB
#Rounding off the speed counter.
    $Counter = [math]::Round($Counter, 0)
#Reading the size that was read by job.
    $size = $SessionCounter.Progress.ReadSize/1GB
#Filtering jobs by two factors:
#1. Avg speed < 100MBps
#2. Data read > 100GB
    if ($Counter -lt 100 -and $size -gt 100){
#Storing job name & speed in key value manner.
        $SlowJobs[$Job.Name] = "$Counter MB/s"
        }
    }
#Checking for counter of slow jobs.
if($SlowJobs.Count -gt 0){
#Storing slow job count in $o.
    $temp = $SlowJobs.Count
#Storing all slow jobs in $o.
    $o += "Total Slow Jobs(Less than 100 mbps):$temp"
    $o +=  $SlowJobs | Format-Table
    }
#If my slowjobs counter is empty.
else{$o += "No slow jobs found"}
#Disconnect the connection to backup server.
Disconnect-VBRServer 
$o