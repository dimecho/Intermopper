Add-Type -AssemblyName System.IO.Compression.FileSystem

$maps="C:\ProgramData\InterMapper\InterMapper Settings\Maps\6.2\Enabled\"
$change = $false

Get-ChildItem $PSScriptRoot -Filter *.zip | Sort LastWriteTime | Select -Last 1 |
Foreach-Object {

    Write-Host $_.FullName

	$RawFiles = [IO.Compression.ZipFile]::OpenRead($_.FullName).Entries            
	foreach($RawFile in $RawFiles) {
		
        $l = Get-Childitem -File "$($maps)$($RawFile.FullName)" | Select-Object -ExpandProperty Length
        
        #TODO Checksum
        #$sum = Get-FileHash "$($maps)$($RawFile.FullName)" -Algorithm MD5 | Select-Object -ExpandProperty Hash

        if($RawFile.Length -ne $l)
        {
            Write-Host "Something Changed!"

            Write-Host $RawFile.FullName
			Write-Host "$($RawFile.Length) != $($l)"

            $change = $true
            #return
        }
    }
}

if($change -eq $true)
{
    Compress-Archive -Path "$($maps)*" -CompressionLevel Optimal -DestinationPath "$($PSScriptRoot)\$(get-date -f yyyy-MM-dd-hh-mm).zip"
}

Get-ChildItem $($PSScriptRoot) -Include *.zip -Recurse -File | Where CreationTime -lt  (Get-Date).AddDays(-90)  | Remove-Item -Force