import nim_tar, sequtils

var offset = 0

let tarFile = "test.tar"

let opened = open(tarFile)

var archive: Archive = newTarArchive(opened)
let f1 = archive.nextFile(offset)
echo ($f1.content.len)
