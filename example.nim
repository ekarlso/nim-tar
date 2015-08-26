import nim_tar, strutils

let tarFile = "test.tar"

let opened = open(tarFile)

var archive: Archive = newTarArchive(opened)
#let file = archive.readArchiveFile()

for file in archive.iterFiles():
    echo(file.header.name)
    echo(file.header.mode)
    echo(file.header.uid)
    echo(file.header.gid)
    echo(file.header.size)
    echo(file.header.mktime)
    echo(file.header.chksum)
    echo(file.header.typeflag)
    echo(file.header.linkname)
    echo(file.header.magic)
    echo(file.header.version)
    echo(file.header.uname)
    echo(file.header.gname)
    echo(file.header.devmajor)
    echo(file.header.devminor)
    echo(file.header.prefix)
    echo("Content $#" % $file.content)
