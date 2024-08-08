param (
    [string]$version
)

# 디렉토리 이동 Alias
MyProjects
Set-Location ./KISHelper

$fullVersion = "v" + $version

# git 명령어 실행
git checkout dev
git branch release/$fullVersion

git checkout master
git merge --squash release/$fullVersion
git commit -m "Release version $version"

# 이전 태그 가져오기
$prevTag = git describe --tags --abbrev=0

git tag -a $fullVersion -m "Release version $version"
git push origin master --tags

# 릴리즈 브랜치 삭제 (로컬 및 원격)
git branch -d release/$fullVersion
git push origin --delete release/$fullVersion

# 병합된 커밋 메시지 가져오기 (이전 태그 이후부터 현재까지)
$mergedCommits = git log --pretty=format:"%s" $prevTag..HEAD

# 커밋 메시지 분류해 릴리즈 노트 작성
$featureCommits = @()
$fixCommits = @()
$etcCommits = @()

foreach ($commit in $mergedCommits) {
    if ($commit -match '^Feat\..*') {
        $featureCommits += $commit
    } elseif ($commit -match '^Fix\..*') {
        $fixCommits += $commit
    } else {
        $etcCommits += $commit
    }
}

# 병합 커밋 메시지 생성
$releaseNote = "# Release version $version 💖`n"
if ($featureCommits.Count -gt 0) {
    $releaseNote += "`n## 💎 NEW FEATURE 💎`n"
    $featureCommits | ForEach-Object { $releaseNote += "$_`n" }
}
if ($fixCommits.Count -gt 0) {
    $releaseNote += "`n## 🐛  FIX  🐛`n"
    $fixCommits | ForEach-Object { $releaseNote += "$_`n" }
}
if ($etcCommits.Count -gt 0) {
    $releaseNote += "`n## ✏️ ETC ✏️`n"
    $etcCommits | ForEach-Object { $releaseNote += "$_`n" }
}

$newReleaseNotePath = "../RELEASE/$fullVersion.md"
$releaseNote | Out-File -FilePath $newReleaseNotePath -Encoding utf8
code $newReleaseNotePath
Open-URLInChrome("https://github.com/Miensoap/KISHelper")

# maven cenral에 배포
./gradlew publishAllPublicationsToMavenCentralRepository