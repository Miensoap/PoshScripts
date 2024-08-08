param(
    [int]$DayNumber
)

# Day00 형식의 폴더 이름 생성
$folderName = "Day{0:00}" -f $DayNumber

# template.md 파일에서 내용 읽기
$templatePath = "E:\User\your\template.md"
$templateContent = Get-Content -Path $templatePath -Raw

# README.md 파일 생성 및 내용 작성
$readmeContent = $templateContent -replace "# Day", "# $folderName"
$readmePath = "README.md"
Set-Content -Path $readmePath -Value $readmeContent

# Gist 생성
$gistDescription = "your description - $folderName"
$gistOutput = gh gist create $readmePath -d "$gistDescription"

# Gist URL 추출
$gistUrl = $gistOutput | Select-String -Pattern "https://gist.github.com/.*" | ForEach-Object { $_.Matches[0].Value }

if ($gistUrl) {
    Write-Host "Gist 생성 성공 : $gistUrl"
   
    # Gist URL을 Chrome에서 열기
    Open-URLInChrome -URL $gistUrl

    # Gist를 같은 폴더명으로 클론
    git clone $gistUrl $folderName

    # 원래의 파일 삭제
    Remove-Item -Path $readmePath -Force

    # 클론한 폴더로 이동
    Set-Location $folderName

    # VSCode 열기
    code .
   
    Write-Host "$folderName Gist 클론 성공!"
} else {
    Write-Host "Gist URL을 찾을 수 없습니다."
}