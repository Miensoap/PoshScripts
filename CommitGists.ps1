# 사용자 설정
$githubUsername = "your_name"
$accessToken = "your_token"
$myEmail = "your_email"
$targetRepoUrl = "https://github.com/your_repository.git"

rmrf ./GistTemp

# Gist 목록 가져오기
$perPage = 50
$gists = Invoke-RestMethod -Headers @{Authorization = "token $accessToken"} -Uri "https://api.github.com/users/$githubUsername/gists?per_page=$perPage"
$gists = $gists | Sort-Object -Property created_at
$gists.Count

# 임시 디렉토리 생성
$tempDir = New-Item -ItemType Directory -Path "./" -Name "GistTemp"
Set-Location $tempDir.FullName

# 타깃 저장소 클론
git clone $targetRepoUrl consolidated-gists

#init commit 없을때는 오류나서 사용해야함
function initRepo {
    Set-Location "consolidated-gists"
    echo "readme" > README.md
    git add .
    git commit -m"init"
    cd ..
}

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
    # 공백을 제거
    $title = $title -replace " ", ""
    # 콜론을 제거
    $title = $title -replace ":", ""
    # 쉼표를 제거
    $title = $title -replace ",", ""
    # 기타 특수문자를 제거
    $title = $title -replace "[^\w\-가-힣]", ""
    return $title
}

# 각 Gist를 로컬에서 미러링하고 서브트리로 추가
foreach ($gist in $gists) {
    $gistId = $gist.id
    $shortGistId = $gistId.Substring(0, 6)
    $repoName = "gist-$shortGistId"

    $dateString = ConvertDateString -date $gist.created_at
    $prefix = ConvertToFileName -title "$dateString - $($gist.description)"

    # 새 로컬 레포지토리를 생성
    mkdir $repoName
    cd $repoName
    git init

    git remote add $shortGistId https://gist.github.com/$gistId.git
    git pull $shortGistId main
    git remote remove $shortGistId
    cd ..

    # consolidated-gists의 서브트리로 등록
    Set-Location "consolidated-gists"
    git subtree add --prefix $prefix ../$repoName master
    cd ..
}

# 최종적으로 원격 저장소에 푸시
Set-Location "consolidated-gists"
git push --all