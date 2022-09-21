# Since Hyper-V is not enabled deliberately (https://github.com/actions/runner-images/pull/2525) and can't be enabled
# without a reboot, which is not possible on GitHub Actions runners, we can't use New-VHD and Mount-VHD. Thus, resorting
# to diskpart. For the same reason, we can't mount ext4 drives from WSL2. The only option for a non-Windows filesystem
# is thus Btrfs with WinBtrfs. See: https://github.com/Lombiq/GitHub-Actions/issues/32.

$vhdxPath = Join-Path $Env:GITHUB_WORKSPACE Workspace.vhdx

# Diskpart uses an interactive mode. We thus use /s to feed a script to it.
# You get 14 GB of storage space on GitHub-hosted runners, so erring on the safe side with 13 GB max size, see:
# https://docs.github.com/en/actions/using-github-hosted-runners/about-github-hosted-runners#supported-runners-and-hardware-resources
@"
create vdisk file='$vhdxPath' maximum=13312 type=expandable
select vdisk file='$vhdxPath'
attach vdisk
list disk
"@ > DiskpartCommands.txt

$output = & diskpart /s DiskpartCommands.txt

Write-Output $output

# For some reason, Split() won't work with the "DiskPart successfully attached the virtual disk file." string, just new
# lines.
$listDiskOutput = $output.Split([Environment]::NewLine)

$lineIndex = 0
foreach ($line in $listDiskOutput)
{
    if ($line.Contains("DiskPart successfully attached the virtual disk file."))
    {
        break
    }

    $lineIndex++
}

# The first 4 lines are empty and the command's output header.
$numberOfDisks = $listDiskOutput.Length - $lineIndex - 4
$diskIndex = $numberOfDisks - 1

# mkbtrfs needs a drive letter to format, but we can't mount the drive until it's formatted, and diskpart can't format
# with btrfs... So, formatting with NTFS first.
@"
select vdisk file='$vhdxPath'
clean
create partition primary
format fs=ntfs
assign letter=Q
"@ > DiskpartCommands.txt

diskpart /s DiskpartCommands.txt

# This will change the drive letter to the next available one.
Write-Output "Starting Btrfs formatting."
mkbtrfs Q: BtrfsDrive
Write-Output "Finished Btrfs formatting."

# For some reason, the drive is not immediately available once the above finishes.
$i = 0;
while ($i -lt 10 -and (Get-Volume | Where-Object {$_.FileSystemLabel -eq "BtrfsDrive"}).Length -eq 0)
{
    Start-Sleep -Seconds 1
}


$driveLetter = (Get-Volume -FileSystemLabel "BtrfsDrive").DriveLetter
New-Item -Path Workspace -ItemType SymbolicLink -Value "$($driveLetter):\\"
