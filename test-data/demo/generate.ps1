param(
  [string]$Zig = "zig"
)

$ErrorActionPreference = "Stop"
Push-Location -LiteralPath $PSScriptRoot
try {
  & $Zig cc `
    -target x86_64-windows-gnu `
    -g `
    -gcodeview `
    -O0 `
    -fdeclspec `
    -fno-sanitize=undefined `
    "-fdebug-compilation-dir=/moonpdb/test-data/demo" `
    "-ffile-prefix-map=$env:USERPROFILE=/build" `
    -c sample.c `
    -o sample.obj
  if ($LASTEXITCODE -ne 0) { throw "Zig compile failed: $LASTEXITCODE" }

  & $Zig lld-link `
    /entry:moonpdb_entry `
    /subsystem:console `
    /nodefaultlib `
    /debug `
    /pdb:sample-tiny.pdb `
    /out:sample-tiny.exe `
    sample.obj
  if ($LASTEXITCODE -ne 0) { throw "LLD link failed: $LASTEXITCODE" }
} finally {
  Remove-Item -LiteralPath (Join-Path $PSScriptRoot "sample.obj") `
    -ErrorAction SilentlyContinue
  Pop-Location
}
