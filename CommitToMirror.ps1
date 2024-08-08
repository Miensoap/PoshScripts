param (
    [Parameter(Mandatory = $true)]
    [string]$gistUrl
)

# 사용자 설정
$githubUsername = "your_name"
$accessToken = "your_token"
$myEmail = "your_email"
$targetRepoUrl = "https://github.com/your_repository.git"

function ConvertDateString {
    param (
        [Parameter(Mandatory = $true)]
        [DateTime]$date
    )
    return $date.ToString("yyyyMMdd")
}

function ConvertToFileName {
    param (
        [string]$title
    )
    $title = $title -replace " ", ""
    $title = $title -replace ":", ""
    $title = $title -replace ",", ""
    $title = $title -replace "[^\w\-가-힣]", ""
    return $title
}

# 새로운 gist URL에서 gist ID 추출
$gistId = $gistUrl.Split('/')[-1]

# Gist 정보를 가져오기
$gist = Invoke-RestMethod -Headers @{Authorization = "token $accessToken"} -Uri "https://api.github.com/gists/$gistId"
$shortGistId = $gistId.Substring(0, 6)
$repoName = "gist-$shortGistId"

$dateString = ConvertDateString -date $gist.created_at
$prefix = ConvertToFileName -title "$dateString - $($gist.description)"

# 새 레포지토리에 gist 커밋 내역 복사
mkdir $repoName
cd $repoName
git init

git remote add $shortGistId https://gist.github.com/$gistId.git
git pull $shortGistId main
git remote remove $shortGistId

pwd

# Mirror 레포지토리의 서브트리로 추가
cd ..
git clone $targetRepoUrl mirror
cd mirror
if (Test-Path $prefix) {
    rmrf $prefix
    git add .
    git commit -m "update subtree $prefix"
}
git subtree add --prefix $prefix ../$repoName master
git push --all


# 디렉토리 정리
cd ..
rmrf $repoName
rmrf ./mirror