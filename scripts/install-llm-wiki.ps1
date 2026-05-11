param(
  [Parameter(Position = 0)]
  [string]$Target = (Get-Location).Path
)

$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$SourceRoot = (Resolve-Path (Join-Path $ScriptDir "..")).Path
$TargetRoot = (Resolve-Path $Target).Path

$directories = @(
  ".codex/hooks",
  "scripts",
  "wiki",
  "raw"
)

foreach ($directory in $directories) {
  New-Item -ItemType Directory -Force -Path (Join-Path $TargetRoot $directory) | Out-Null
}

function Copy-WikiFile {
  param(
    [Parameter(Mandatory = $true)]
    [string]$Source,
    [Parameter(Mandatory = $true)]
    [string]$Destination
  )

  if (Test-Path $Destination) {
    $relative = Resolve-Path -Relative $Destination
    Write-Host "skip existing: $relative"
    return
  }

  Copy-Item -Path $Source -Destination $Destination
  $relative = Resolve-Path -Relative $Destination
  Write-Host "created: $relative"
}

function New-WindowsHooksJson {
  param(
    [Parameter(Mandatory = $true)]
    [string]$Destination
  )

  if (Test-Path $Destination) {
    $relative = Resolve-Path -Relative $Destination
    Write-Host "skip existing: $relative"
    return
  }

  $hooks = @'
{
  "hooks": {
    "SessionStart": [
      {
        "matcher": "startup|resume",
        "hooks": [
          {
            "type": "command",
            "command": "powershell.exe -NoProfile -ExecutionPolicy Bypass -File .codex/hooks/run-hook.ps1 session_start",
            "timeout": 10,
            "statusMessage": "Loading wiki context"
          }
        ]
      }
    ],
    "UserPromptSubmit": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "powershell.exe -NoProfile -ExecutionPolicy Bypass -File .codex/hooks/run-hook.ps1 user_prompt_submit",
            "timeout": 10,
            "statusMessage": "Recording prompt"
          }
        ]
      }
    ],
    "Stop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "powershell.exe -NoProfile -ExecutionPolicy Bypass -File .codex/hooks/run-hook.ps1 wiki_stop",
            "timeout": 10,
            "statusMessage": "Checking wiki writeback"
          }
        ]
      }
    ]
  }
}
'@

  Set-Content -Path $Destination -Value $hooks -Encoding UTF8
  $relative = Resolve-Path -Relative $Destination
  Write-Host "created: $relative"
}

Copy-WikiFile (Join-Path $SourceRoot ".codex/config.toml") (Join-Path $TargetRoot ".codex/config.toml")
New-WindowsHooksJson (Join-Path $TargetRoot ".codex/hooks.json")
Copy-WikiFile (Join-Path $SourceRoot ".codex/hooks/run-hook.sh") (Join-Path $TargetRoot ".codex/hooks/run-hook.sh")
Copy-WikiFile (Join-Path $SourceRoot ".codex/hooks/run-hook.ps1") (Join-Path $TargetRoot ".codex/hooks/run-hook.ps1")
Copy-WikiFile (Join-Path $SourceRoot ".codex/hooks/session_start.py") (Join-Path $TargetRoot ".codex/hooks/session_start.py")
Copy-WikiFile (Join-Path $SourceRoot ".codex/hooks/user_prompt_submit.py") (Join-Path $TargetRoot ".codex/hooks/user_prompt_submit.py")
Copy-WikiFile (Join-Path $SourceRoot ".codex/hooks/wiki_stop.py") (Join-Path $TargetRoot ".codex/hooks/wiki_stop.py")
Copy-WikiFile (Join-Path $SourceRoot "scripts/wiki-maintain.sh") (Join-Path $TargetRoot "scripts/wiki-maintain.sh")
Copy-WikiFile (Join-Path $SourceRoot "scripts/wiki-lint.sh") (Join-Path $TargetRoot "scripts/wiki-lint.sh")
Copy-WikiFile (Join-Path $SourceRoot "scripts/codex-wiki.sh") (Join-Path $TargetRoot "scripts/codex-wiki.sh")
Copy-WikiFile (Join-Path $SourceRoot "scripts/install-llm-wiki.ps1") (Join-Path $TargetRoot "scripts/install-llm-wiki.ps1")
Copy-WikiFile (Join-Path $SourceRoot "scripts/install-llm-wiki.cmd") (Join-Path $TargetRoot "scripts/install-llm-wiki.cmd")
Copy-WikiFile (Join-Path $SourceRoot "AGENTS.md") (Join-Path $TargetRoot "AGENTS.md")
Copy-WikiFile (Join-Path $SourceRoot "wiki/index.md") (Join-Path $TargetRoot "wiki/index.md")
Copy-WikiFile (Join-Path $SourceRoot "wiki/activity-log.md") (Join-Path $TargetRoot "wiki/activity-log.md")
Copy-WikiFile (Join-Path $SourceRoot "wiki/codex-auto-wiki.md") (Join-Path $TargetRoot "wiki/codex-auto-wiki.md")

Write-Host
Write-Host "LLM wiki hooks installed in: $TargetRoot"
Write-Host "Run Codex from that project with:"
Write-Host "  codex -C `"$TargetRoot`""
