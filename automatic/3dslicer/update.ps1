import-module au

function global:au_GetLatest {
   $DownloadURI = 'https://download.slicer.org/'
   $download_page = Invoke-WebRequest -Uri $DownloadURI

   $TRow = $download_page.ParsedHtml.getElementsByTagName('tr') | 
               Where-Object {$_.innertext -match 'stable release'} | 
               Select-Object -ExpandProperty innerhtml
   $TData = $TRow -split '</?T[DH]>' | Where-Object {$_ -match 'version'} | Select-Object -First 1

   $HREF = $TData -replace '.*"/([^"]+)".*','$1'
   $version = $TData -replace '.*version ([0-9.]+).*','$1'
   $revision = $TData -replace '.*revision ([0-9.]+).*','$1'

   $url64 = 'https://slicer.kitware.com/midas3/download?' + ($HREF -replace '/','=')

   return @{ 
            Version      = "$version.$revision"
            NamedVersion = $version
            URL64        = $url64
         }
}


function global:au_SearchReplace {
   @{
      "tools\chocolateyInstall.ps1" = @{
         "(^   url64bit\s*=\s*)('.*')"   = "`$1'$($Latest.URL64)'"
         "(^   Checksum64\s*=\s*)('.*')" = "`$1'$($Latest.Checksum64)'"
      }
      "tools\chocolateyUninstall.ps1" = @{
         "(^   softwarename\s*=\s*)('.*')"   = "`$1'Slicer $($Latest.NamedVersion)*'"
      }
   }
}


update -ChecksumFor 64
