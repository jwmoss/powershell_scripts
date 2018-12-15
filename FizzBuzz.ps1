1..100 | ForEach-Object {
    if (($_ % 3 -eq 0) -and ($_ % 5 -eq 0)) {Write-Output "FizzBuzz"} 
    elseif ($_ % 3 -eq 0) {Write-Output "Fizz"}
    elseif ($_ % 5 -eq 0) {Write-Output "Buzz"}
    else {$_} 
}