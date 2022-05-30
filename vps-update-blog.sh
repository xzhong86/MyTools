#!/bin/sh

repo=$1
html_dir=$2

cd $HOME
mkdir -p ./tmp

[ -d ./tmp/$repo ] || rm -fr $HOME/tmp/$repo

git clone /git/$repo.git ./tmp/$repo

jekyll build -s ./tmp/$repo -d /var/www/html/$html_dir

echo "Access http://zpzhong.cn/$html_dir"

