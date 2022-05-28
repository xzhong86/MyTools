#!/bin/sh

input=$1

openssl aes-128-cbc -nosalt -in $input -out output.aes -k $PASSWD
base64 -w 120 output.aes

rm output.aes

