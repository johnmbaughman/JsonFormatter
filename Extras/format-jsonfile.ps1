[CmdletBinding()]
Param(
    [parameter(Mandatory = $true, Position = 1)]
    [String]$InFile,
    
    [parameter(Mandatory = $true, Position = 2)]
    [String]$OutFile,
    
    [parameter(Mandatory = $false)]
    [Int]$IndentSize = 4
)

Begin {
    $str = Get-Content $InFile
    $indentString = [String]::new(' ', $IndentSize)
    $indent = 0
    $quoted = $false
    $string = @()
}

Process {
    for ($i = 0; $i -lt $str.length; $i++){
        $char = $str[$i]

        switch ($char){
            { @('{','[') -contains $_ } {
                $string += ,$char
                if (!$quoted){
                    $string += ,"`n"
                    $loop = ++$indent
                    for($j = 0; $j -lt $loop; $j++) {
                        $string += ,$indentString
                    }
                }
                break
            }
            { @('}',']') -contains $_ } {
                if (!$quoted){
                    $string += ,"`n"
                    $loop = --$indent
                    for($j = 0; $j -lt $loop; $j++) {
                        $string += ,$indentString
                    }
                }
                $string += ,$_
                break
            }
            { @('"',"'") -contains $_ } {
                $string += ,$_
                $escaped = $false
                $index = $i
                while ($index -gt 0 -and $str[--$index] -eq '\\') {
                    $escaped = !$escaped
                }
                if (!$escaped) {
                    $quoted = !$quoted
                }
                break
            }
            ',' {
                $string += ,$char
                if (!$quoted) {
                    $string += ,"`n"
                    for($j = 0; $j -lt $indent; $j++) {
                        $string += ,$indentString
                    }
                }
                break
            }
            ':' {
                $string += ,$char
                if (!$quoted) {                        
                    $string += ,' '
                }
                break
            }
            default {
                $string += ,$char
                break
            }
        }
    }
}

End {
    Write-Host $($string -join '')
    $($string -join '') | Out-File $OutFile
}