Try {

 # Do something tricky

}

Catch {

 # Run this if a terminating error occurred in the Try block

 # The variable $_ represents the error that occurred

 $_

}

Finally {

 # Always run this at the end

}


## Tip  Introduced in Windows PowerShell 3.0, you can use CTRL-J in the ISE to insert a Try, Catch, Finally snippet template to save you some typing.
## We can also catch multiple errors. Here is an example from the ISE snippet:

try

{

 1/0

}

catch [DivideByZeroException]

{

 Write-Host "Divide by zero exception"

}

catch [System.Net.WebException],[System.Exception]

{

 Write-Host "Other exception"

}

finally

{

 Write-Host "cleaning up ..."

}