
Param(
  [string]$name ,
  [string]$version,
  [string]$environment
)

# delete temp file.
$temp_file = "_update.json"
if (Test-Path  (temp_file))
{
    del $temp_file
}

# read in the contents of the environment we are interested in as a .json file.
$j =  & knife environment show $environment -F json

if($LASTEXITCODE -ne 0)
{
    throw "failed to get environment setting"
}

# read in the contents of the cookbook versions as an array.
$ps = "[$j]" | ConvertFrom-Json

# if we don't have the cookbook in the environment we need to add it.


# if we already have the cookbook we simply need to update the version.


# compress and encode the newly tweak json file ready for uploading to the Chef server.
$ps.cookbook_versions | Add-Member -type NoteProperty -name $name -value "= $version" -force
$newJson = $ps | ConvertTo-Json -Compress
$newJson | Out-File update.json -Encoding UTF8
$Utf8NoBomEncoding = New-Object System.Text.UTF8Encoding($False)

# attempt to upload the new environment structure to the chef server.
[System.IO.File]::WriteAllLines($temp_file, $newJson ,$Utf8NoBomEncoding)
& knife environment from file ".\$temp_file"
if($LASTEXITCODE -ne 0)
{
    throw "failed to upload environment setting"
}
