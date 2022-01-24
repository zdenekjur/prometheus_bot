#!/bin/bash
YEAR=`date +'%y'`
MONTH=`date +'%m'`
DAY=`date +'%d'`
IMAGE=zdenekj/prometheus_bot

echo "Checking if current session is logged into hub.docker.com ... "
if docker login ; then
    echo "All set"
else
    echo "Login error"
    exit 1
fi

echo "Do you want to build $IMAGE image? [y/n] "
read ANSWER

if [ $ANSWER == "y" ]; then

    echo "preparing standalone binary ..."
    CGO_ENABLED=0 GOOS=linux go build -v -a -ldflags="-w -s" -o prometheus_bot && \
    upx --best --lzma prometheus_bot
    if `ldd prometheus_bot`; then
        echo "Badly compiled binary, exiting ..."
        exit 2
    else
        echo "Compiled binary successfully verified ..."
    fi

    echo "building current version of $IMAGE ..."
    docker build -t ${IMAGE}:v2.0${YEAR}.${MONTH}${DAY} .
    docker push ${IMAGE}:v2.0${YEAR}.${MONTH}${DAY}

    echo "building latest version od $IMAGE ..."
    docker build -t ${IMAGE}:latest .
    docker push ${IMAGE}:latest

else
    echo "exiting with answer: $ANSWER"
    exit 3
fi
