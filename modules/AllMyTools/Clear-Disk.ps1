#+-------------------------------------------------------------------+  
#| = : = : = : = : = : = : = : = : = : = : = : = : = : = : = : = : = |  
#|{>/-------------------------------------------------------------\<}|           
#|: | Author:  Aman Dhally                                                   
#| :| Email:   amandhally@gmail.com
#| :| Web:	www.amandhally.net/blog
#| :| blog: http://newdelhipowershellusergroup.blogspot.com/
#| :|
#|: | Purpose: 													   
#| :|       Clean lapopt using removing un-wantede files 
#|: |           						                         
#|: |                                Date: 23-02-2012             
#| :| 					/^(o.o)^\    Version: 2       
#|{>\-------------------------------------------------------------/<}|
#| = : = : = : = : = : = : = : = : = : = : = : = : = : = : = : = : = |
#+-------------------------------------------------------------------+


#### Variables ####

function Clear-Disk {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $False)]
        $Custom,
        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        $Wizard = $false
    )

    if ($Wizard -eq $true) {
        switch (Read-Host "Add custom folders ? (1)Lenovo") {
            "1" {
                    $Custom = "Lenovo"
                }
            default {}
        }
    }
    
    $objShell = New-Object -ComObject Shell.Application
    
    $temp = (get-ChildItem "env:\TEMP").Value
    $FoldersList = @($temp, "c:\Windows\Temp\*")

    foreach ($Folder in $FoldersList) {
        write-Host "Removing Junk files in $Folder." -ForegroundColor Magenta 
        Remove-Item -Recurse  "$Folder\*" -Force -Verbose
    }

    if ($Custom -match "Lenovo") {
        $Lenovo = "C:\Program Files\Lenovo\System Update\session\*"
        $swtools = "c:\SWTOOLS\*"
        write-Host "Lenovo folders."
        Remove-Item -Recurse  -Path $Lenovo -Exclude system, temp, updates.ser, "*.xml"   -Verbose -Force
        write-Host "Emptying $swtools folder."
        Remove-Item -Recurse $swtools   -Verbose -Force -WhatIf
    }

    write-Host "Emptying Recycle Bin." -ForegroundColor Cyan
    $objFolder = $objShell.Namespace(0xA)
    $objFolder.items() | % { remove-item $_.path -Recurse -Confirm:$false }
	
    write-Host "Finally now , Running Windows disk Clean up Tool" -ForegroundColor Cyan
    cleanmgr /sagerun:1 | out-Null
	
    write-Host "I finished the cleanup task,Bye Bye " -ForegroundColor Yellow

}