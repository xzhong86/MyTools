#!/bin/sh

input=$1
out=$2

if [ -z "$out" ] ; then
    out=output.tar.gz
fi

base64 -i -d $input > output.aes
openssl aes-128-cbc -d -nosalt -in output.aes -out $out -k $PASSWD

rm output.aes

