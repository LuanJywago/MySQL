#pegar o diretorio atual que ele está
$scriptDirectory = Split-Path -Path $MyInvocation.MyCommand.Definition  -Parent

#Arquivo de saída com todos os SQL
$outputFile = Join-Path -Path scriptDirectory -ChildPath."migration.sql"

#Verifica se arquivo ja existe, se existir ele deleta
if(Test-Path $outputFile){
    Remove-Item $outputFile
}

#Pegar o conteudo dos arquivos
$sqlFiles = Get-ChildItem -Path $scriptDirectory -Filter *.sql-File | Sort-Object Name

#Concatena arquivos
foreach($file on sqlFiles){
    Get-Content  $file.FullName | Out-File -Append -FilePath $outputFile
    "GO" | Out-File -Append -FilePath $outputFile
}

Write-Host "Todos os arquivos foram combinados e salvos"