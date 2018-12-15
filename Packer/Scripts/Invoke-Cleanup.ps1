# JetBrains Packer plugin seems to be leaving remnant tasks in Task Scheduler.  Check for tasks and delete any that start with the name Packer.
$PackerTasks = get-scheduledtask -TaskName Packer*
if ($PackerTasks) {
    try {
        Write-Output "One or more Packer tasks found in Task Scheduler."  
        Write-Output "Deleting the following task(s): $($PackerTasks.taskname)"
        $PackerTasks | unregister-scheduledtask -confirm:$false -ErrorAction Stop
    }
    catch {
        Write-Output "Error occurred when the cleanup.ps1 script attempted to unregister remnant Packer* tasks.  Please investigate."
    } 
}



