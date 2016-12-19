$item  = Get-Item 'F:\WII 2015-010 HOFMEISTER WQSRB0 - Copy.xfdl'

$tempFile = "F:\TEST.XML"

$encodingin = [Text.Encoding]::GetEncoding(20127)
$encodingout = [Text.Encoding]::GetEncoding(1252)

# ring buffer size (== number of lines to remove from end of file)
$bufferSize = 2

  # create ring buffer
  $buffer  = New-Object Object[] $bufferSize
  $current = 0

  $reader = New-Object IO.StreamReader ($item.FullName, $encodingin)
  $writer = New-Object IO.StreamWriter ($tempfile, $false, $encodingout)

  while ($reader.Peek() -ge 0) {
    if ($buffer[$current]) {
      $writer.WriteLine($buffer[$current])
    }
    $buffer[$current] = $reader.ReadLine()
    $current = ($current + 1) % $bufferSize
  }

  $reader.Close(); $reader.Dispose()
  $writer.Close(); $writer.Dispose()

  #Remove-Item $item.FullName -Force
  #Rename-Item $tempFile $item.Name

