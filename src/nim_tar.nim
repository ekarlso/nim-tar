import parseutils, sequtils, strutils

type
  Header* = object
    name*: array[100, char]
    mode*: array[8, char]
    uid*: array[8, char]
    gid*: array[8, char]
    size*: array[12, char]
    mktime*: array[12, char]
    chksum*: array[8, char]
    typeflag*: char
    linkname*: array[100, char]
    magic*: array[6, char]
    version*: array[2, char]
    uname*: array[32, char]
    gname*: array[32, char]
    devmajor*: array[8, char]
    devminor*: array[8, char]
    prefix*: array[155, char]
    gnu_longname*: ref char
    gnu_longlink*: ref char

  ArchiveFile* = object
    header*: Header
    contentStart*: int
    contentEnd*: int
    content*: seq[char]

  Archive* = object
    file: File # Underlying file obj
    files*: seq[ArchiveFile]
    position*: int # Current position
    size*: int

  ArchiveException = object of Exception

proc newHeader*(): Header =
  result = Header()

proc toHeader(buffer: var array[512, char]): Header =
  result = newHeader()
  result.name[0..99] = buffer[0..99]
  result.mode[0..7] = buffer[100..107]
  result.uid[0..7] = buffer[108..115]
  result.gid[0..7] = buffer[116..123]
  result.size[0..11] = buffer[124..135]
  result.mktime[0..11] = buffer[136..147]
  result.chksum[0..7] = buffer[148..155]
  result.typeflag = buffer[156]
  result.linkname[0..99] = buffer[157..256]
  result.magic[0..5] = buffer[257..262]
  result.version[0..1] = buffer[263..264]
  result.uname[0..31] = buffer[265..296]
  result.gname[0..31] = buffer[297..328]
  result.devmajor[0..7] = buffer[329..336]
  result.devminor[0..7] = buffer[337..344]
  result.prefix[0..154] = buffer[345..499]

# Return header.size as int
proc getSize(header: Header): int =
  discard parseOct($header.size, result)

proc newTarArchive*(f: File): Archive =
  let size: int = cast[int](getFileSize(f))
  result = Archive(
    file: f,
    size: size
  )

proc nextFile*(archive: Archive, offset: var int): ArchiveFile =
  var
    headerBuffer: array[0..511, char]
    readCount: int

  readCount = readChars(archive.file, headerBuffer, offset, 512)
  if readCount != 512:
    raise newException(ArchiveException, "Could not read 512 bytes")

  let
    header = headerBuffer.toHeader()
    start = offset + 511 # Header start
    size = header.getSize()

  echo ("NF Offset $#" % $offset)
  echo ("Start $#" % $start)
  echo ("Size $#" % $size)

  var
    buffer: seq[char] = newSeq[char]()
  readCount = readChars(archive.file, buffer, start, 100)
  #if buffer.len != size:
  #  raise newException(ArchiveException, "Could not read $#" % $size)
  echo ("Buffer $#" % $buffer)

  result = ArchiveFile(
    header: header,
    contentStart: start,
    contentEnd: start + size,
    content: @[])

  offset = start + size + 1


iterator iterFiles*(archive: var Archive): ArchiveFile =
  var offset = 0
  while offset <= archive.size:
    echo ("Offset $#" % $offset)

    var file = archive.nextFile(offset)
    echo ("Offset $#" % $offset)

    yield file
