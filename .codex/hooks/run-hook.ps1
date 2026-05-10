param(
  [Parameter(Mandatory = $true, Position = 0)]
  [string]$HookName
)

$ErrorActionPreference = "Stop"

$HookDir = Split-Path -Parent $MyInvocation.MyCommand.Path

function Invoke-HookScript {
  param(
    [Parameter(Mandatory = $true)]
    [string]$ScriptName
  )

  $ScriptPath = Join-Path $HookDir $ScriptName

  $Python = Get-Command python -ErrorAction SilentlyContinue
  if ($Python) {
    & $Python.Source $ScriptPath
    exit $LASTEXITCODE
  }

  $Python3 = Get-Command python3 -ErrorAction SilentlyContinue
  if ($Python3) {
    & $Python3.Source $ScriptPath
    exit $LASTEXITCODE
  }

  $PythonLauncher = Get-Command py -ErrorAction SilentlyContinue
  if ($PythonLauncher) {
    & $PythonLauncher.Source -3 $ScriptPath
    exit $LASTEXITCODE
  }

  Write-Error "Python 3 was not found on PATH."
  exit 127
}

switch ($HookName) {
  "session_start" {
    Invoke-HookScript "session_start.py"
  }
  "user_prompt_submit" {
    Invoke-HookScript "user_prompt_submit.py"
  }
  "wiki_stop" {
    Invoke-HookScript "wiki_stop.py"
  }
  default {
    Write-Error "unknown hook: $HookName"
    exit 2
  }
}
