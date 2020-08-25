# Setting 4K Movie Posters

## Requirements

* PowerShell 7
  * Windows: [chocolatey package](https://chocolatey.org/packages/powershell-core)
  * macOS: [homebrew](https://formulae.brew.sh/cask/powershell)
  * Source: [source](https://github.com/PowerShell/PowerShell/releases/tag/v7.0.3)
* A 4K plex library
  * Tested with Plex Movie Scanner
  * Tested with Plex Movie Agent
* The Movie Database v3 API
* Magick version 7.0.10-25 or newer
  * Windows: [chocolatey package](https://chocolatey.org/packages/imagemagick)
  * macOS: [homebrew](https://formulae.brew.sh/formula/imagemagick)
  * Source: [imagemagick](https://imagemagick.org/script/download.php)

* To use, clone this repository and import the .psm1 

```PowerShell

Import-Module /path/to/plexfunctions.psm1

$splat = @{
    "PlexToken" = "plextoken"
    "TMDBToken" = "tmdbtoken"
    "4KLogoPath" = "./4k_logo.jpg"
    "PosterPath" = "/path/to/posterpath"
    "PlexURL" = "https://plexurl:port"
    "4KLibraryName" = "Name of 4K Movie Library"
    "SkipSSL" = $true ## if you have an un-trusted SSL certificate
}

Set-4KMoviePoster @splat

```
