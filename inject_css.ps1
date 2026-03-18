$ErrorActionPreference = 'Stop'
$root = "d:\DATA\Projects\LibraryManagementWebsite\src\main\webapp\WEB-INF\views\admin"
$skip = @("sidebar.jsp","librarian_sidebar.jsp","header_lib.jsp","book-detail-modal.jsp","borrow-detail-modal.jsp","sidebar.jsp.bak","librarian_sidebar.jsp.bak")

$cssLink = '    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin-panel.css" />'
$fontLink = '    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">'

$allFiles = Get-ChildItem $root -Filter *.jsp -Recurse

foreach ($f in $allFiles) {
    if ($skip -contains $f.Name) {
        Write-Host "SKIP: $($f.Name)"
        continue
    }

    $content = [System.IO.File]::ReadAllText($f.FullName, [System.Text.Encoding]::UTF8)

    if ($content -match 'admin-panel\.css') {
        Write-Host "ALREADY HAS CSS: $($f.Name)"
        continue
    }

    $changed = $false

    # Add CSS link before </head>
    if ($content.Contains('</head>')) {
        $content = $content.Replace('</head>', "$fontLink`r`n$cssLink`r`n</head>")
        $changed = $true
    }

    # Add panel-body class to body
    if ($content -match '<body\s*>') {
        $content = $content -replace '<body(\s*)>', '<body class="panel-body">'
        $changed = $true
    }
    elseif ($content -match '<body\s+class="([^"]*)"') {
        $cls = $Matches[1]
        if (-not $cls.Contains('panel-body')) {
            $content = $content -replace '<body\s+class="([^"]*)"', '<body class="panel-body $1"'
            $changed = $true
        }
    }

    if ($changed) {
        [System.IO.File]::WriteAllText($f.FullName, $content, (New-Object System.Text.UTF8Encoding $true))
        Write-Host "UPDATED: $($f.Name)"
    }
    else {
        Write-Host "NO CHANGE: $($f.Name)"
    }
}
Write-Host "Done!"
