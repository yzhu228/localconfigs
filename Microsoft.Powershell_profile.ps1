function List-Path {
    Param ($Pattern = '.*')
    (Get-ChildItem -Path env:PATH).Value -split ';' | Select-String -Pattern $Pattern
}

function Where-Is {
    Param (
        [parameter(Mandatory = $true, ValueFromPipeline = $true)]
        $Command,
        [Switch]
        [alias("a")]
        $ShowAll
    )
    
    foreach ($p in List-Path) {
        $fullpath = Join-Path $p $Command
        if (Test-Path -Path $fullpath) {
            Write-Output $fullpath
            if (!$ShowAll) { break }
        }
    }
}

function Prompt {
    [string]$current_path = (pwd | select -Property ProviderPath).ProviderPath
    [string]$new_prompt = $current_path
    if ($current_path.length -gt 32) {
        $new_prompt = "..$(pwd | Split-Path -Leaf)"
    }
    else {
        $new_prompt = "$current_path"
    }
    if ([string]::IsNullOrEmpty($env:AWS_PROMPT_ENV)) {
        $new_prompt = "$new_prompt"
    }
    else {
        $new_prompt = "$new_prompt(aws-$env:AWS_PROMPT_ENV)";
    }
    $new_prompt += & $GitPromptScriptBlock
    return $new_prompt;
}

function Set-AzureSubscription {
    Param (
        [parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [string]$SubscriptionId
    )

    $GuidObject = New-Object -TypeName System.Guid -ArgumentList $SubscriptionId
    $SubscriptionObject = Get-AzureRmSubscription | Where-Object { $_.Id -eq $GuidObject }
    if ($SubscriptionId -eq $null) {
        Write-Output ("The subscription {0} not found " -f $GuidObject)
        return
    }

    Set-AzureRmContext -SubscriptionObject $SubscriptionObject
    Get-AzureRmContext
}

function Set-Aws-Default-Profile {
    param (
        [string]$App,
        [string]$Env,
        [string]$Role
    )

    $Env:AWS_PROFILE = "$App-$Env-$Role";
    $Env:AWS_ENV = "$App-$Env-$Role";
    $Env:AWS_PROMPT_ENV = $Env:AWS_ENV;
    $Env:ENV_NAME = $Env;
}

function Set-AWS-INT-PowerUser {
    Set-Aws-Default-Profile 'jims' 'int' 'pu'
}

function Set-AWS-SAND-PowerUser {
    Set-Aws-Default-Profile 'jims' 'sand' 'pu'
}

function Set-AWS-INT-Readonly {
    Set-Aws-Default-Profile 'jims' 'int' 'ro'
}

function Set-AWS-SAND-Readonly {
    Set-Aws-Default-Profile 'jims' 'sand' 'ro'
}

function Set-Yzhu-QA-PowerUser {
    Set-Aws-Default-Profile 'yzhu' 'qa' 'pu'
}

function Clear-AWS-Env {
    Remove-Item -Path Env:AWS_PROFILE
    Remove-Item -Path Env:AWS_ENV
    Remove-Item -Path Env:AWS_PROMPT_ENV
}

Set-Alias -Name "path" -Value "List-Path"

#Set-Location -Path 'd:\workshop'

#$poshgit = Get-InstalledModule -Name @('posh-git')
#if ($poshgit.count -eq 0) {
#    Install-Module -Name posh-git
#}
Import-Module posh-git
$GitPromptSettings.DefaultPromptPath = ''