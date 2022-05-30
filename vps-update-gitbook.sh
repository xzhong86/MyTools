#!/bin/bash

#repo=BruceBook
#html_dir=gitbook

repo=$1
html_dir=$2

cd $HOME
source .nvm/nvm.sh

mkdir -p tmp

rm -fr $HOME/tmp/$repo
git clone /git/$repo.git $HOME/tmp/$repo

cd $HOME/tmp/$repo

gitbook build


#===== copy to html foler
dest=/var/www/html/$html_dir

rm -fr $dest
cp -r _book $dest

#ip=`hostname -I | cut -d ' ' -f 1`
#echo "Access http://$ip/$folder"
echo "Access http://zpzhong.cn/$html_dir"

