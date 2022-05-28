
set_proxy() {
    proxy=http://192.168.1.7:7890
    export proxy
    export http_proxy=$proxy
    export https_proxy=$http_proxy
    export HTTP_PROXY=$http_proxy
    export HTTPS_PROXY=$http_proxy
}

unset_proxy() {
    unset proxy
    unset http_proxy
    unset https_proxy
    unset HTTP_PROXY
    unset HTTPS_PROXY
}

set_proxy

