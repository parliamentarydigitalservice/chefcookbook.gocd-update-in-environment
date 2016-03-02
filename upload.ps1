Param(
  [string]$name ,
  [string]$version,
  [string]$environment,
  [string]$file
)

function Upload-Environment
{
    # ====== Get-Environment ====== #

    # Gets the environment either from Chef or from a file.
    #
    # If the -environment parameter is specified, we fetch that environment from Chef
    # Otherwise we fetch it from an already saved file.

    function Get-Environment
    {
        if ($environment -ne $null -and $environment -ne "") {
            & knife environment show $environment -F json
        }
        else {
            Get-Content $file
        }
    }


    # ====== Add-Version ====== #

    # Adds the package name and version to the environment.

    function Add-Version($env)
    {
        if ($env.cookbook_versions -eq $null) {
            $env | Add-Member -type NoteProperty `
                -name cookbook_versions `
                -value $(New-Object -type Object)
        }

        if ($env.cookbook_versions.$name -eq $null) {
            $env.cookbook_versions | Add-Member -type NoteProperty `
                -name $name `
                -value "= $version" `
                -force
        }
    }

    # ====== Save-Environment ====== #

    # Saves the environment back to either Chef or the file
    # If the -file parameter is specified, we save the environment to that file.
    # Otherwise we save it to Chef.

    function Save-Environment($env)
    {
        $newJson = $env | ConvertTo-Json -Compress
        echo $newJson

        function Save-EnvironmentToFile($target) {
            $Utf8NoBomEncoding = New-Object System.Text.UTF8Encoding($False)
            [System.IO.File]::WriteAllLines($target, $newJson ,$Utf8NoBomEncoding)
        }

        function Save-EnvironmentToChef($target) {
            & knife environment from file $target
        }

        if ($file -ne $null -and $file -ne "") {
            Save-EnvironmentToFile $file
        }
        else {
            $target = [System.IO.Path]::GetTempFileName()
            Save-EnvironmentToFile $target
            Save-EnvironmentToChef $target
            del $target
        }
    }


    $env = Get-Environment | out-string | ConvertFrom-Json
    Add-Version $env
    Save-Environment $env
}

Upload-Environment
#
#
# # delete temp file.
# $temp_file = "_update.json"
# if (Test-Path  ($temp_file))
# {
#     # del $temp_file
# }
#
# function Get-Environment
# {
#     & knife environment show $environment -F json
# }
#
#
# # read in the contents of the environment we are interested in as a .json file.
# $j =
#
# if($LASTEXITCODE -ne 0)
# {
#     throw "failed to get environment setting"
# }
#
# # read in the contents of the cookbook versions as an array.
# $ps = "[$j]" | ConvertFrom-Json
#
# # Check for $ps.cookbook_versions.$name and up date to $version
# # if we don't have the cookbook in the environment we need to add it.
# # if we do then we need to update it
#
# if ($ps.cookbook_versions -eq $null) {
#     $ps | Add-Member -type NoteProperty -name cookbook_versions -value $(New-Object -type Object)
# }
#
# $ps.cookbook_versions | Add-Member -type NoteProperty -name $name -value "= $version" -force
#
# # compress and encode the newly tweak json file ready for uploading to the Chef server.
# $newJson = $ps | ConvertTo-Json -Compress
# $newJson | Out-File update.json -Encoding UTF8
# $Utf8NoBomEncoding = New-Object System.Text.UTF8Encoding($False)
#
# # attempt to upload the new environment structure to the chef server.
# # [System.IO.File]::WriteAllLines($temp_file, $newJson ,$Utf8NoBomEncoding)
# # & knife environment from file ".\$temp_file"
# # if($LASTEXITCODE -ne 0)
# # {
# #     throw "failed to upload environment setting"
# # }
