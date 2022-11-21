param(
    [string] $Repository,
    [string] $Title
)

$url = "https://api.github.com/repos/$Repository/pulls?state=open&per_page=100"
$titles = curl -s -H 'Accept: application/vnd.github.v3+json' $url | ConvertFrom-Json | ForEach-Object { $_.title }

$issueCode = $Title -replace '^\s*(\w+-\d+)\s*:.*$', '$1'
$lookFor = "${issueCode}:"
if (($titles | ? { $_ -and $_.Trim().StartsWith($lookFor) }).Count -gt 0) { exit 0 }
Set-Failed "Couldn't find any pull request whose title starts with `"$lookFor`" in $Repository. Please create one."