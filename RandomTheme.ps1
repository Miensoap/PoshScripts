function Get-ValidThemes {
    param (
        [string]$FilePath
    )
    # 주석과 공백 라인 제거
    Get-Content -Path $FilePath | Where-Object { $_.Trim() -ne '' -and $_ -notmatch '^\s*#' }
}

# 랜덤 테마로 설정하는 함수
function Set-RandomOhMyPoshTheme {
    $themes = Get-ValidThemes -FilePath "C:\Users\your\themes.txt"
    $selected_theme = $themes | Get-Random
    Set-OhMyPoshTheme $selected_theme
}

# 입력한 테마로 설정하는 함수
function Set-OhMyPoshTheme {
    param (
        [string]$ThemeName
    )

    $base_url = "https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/"
    $terminal_theme_url = "${base_url}${ThemeName}.omp.json"

    Set-Item -Path Env:TERMINAL_THEME -Value $terminal_theme_url

    Write-Output "Oh My Posh Theme: $ThemeName"

    oh-my-posh init pwsh --config $env:TERMINAL_THEME | Invoke-Expression
}

function Show-OhMyPoshThemesList {
    $themes = Get-ValidThemes -FilePath "C:\Users\your\themes.txt"
    $themes
}

Set-Alias -Name list-themes -Value Show-OhMyPoshThemesList
Set-Alias -Name set-theme -Value Set-OhMyPoshTheme

Set-Alias -Name random-theme -Value Set-RandomOhMyPoshTheme
Set-RandomOhMyPoshTheme