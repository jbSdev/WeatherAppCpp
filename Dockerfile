# Build
FROM debian:bookworm-slim AS builder

RUN apt-get update && apt-get install -y --no-install-recommends \
  build-essential \
  cmake \
  git \
  libcurl14-openssl-dev \
  libssl-dev \
  ca-certificates \
  && rm -rf /var/lib/apt/lists/*

Started by user jbSd
Obtained Jenkinsfile from git 
https://github.com/jbSdev/WeatherAppCpp/
[Pipeline] Start of Pipeline
[Pipeline] node
Running on Jenkins in /var/jenkins_home/workspace/WeatherAppPipeline
[Pipeline] {
[Pipeline] stage
[Pipeline] { (Declarative: Checkout SCM)
[Pipeline] checkout
The recommended git tool is: NONE
No credentials specified
 > git rev-parse --resolve-git-dir /var/jenkins_home/workspace/WeatherAppPipeline/.git # timeout=10
Fetching changes from the remote Git repository
 > git config remote.origin.url https://github.com/jbSdev/WeatherAppCpp/ # timeout=10
Fetching upstream changes from https://github.com/jbSdev/WeatherAppCpp/
 > git --version # timeout=10
 > git --version # 'git version 2.47.3'
 > git fetch --tags --force --progress -- https://github.com/jbSdev/WeatherAppCpp/ +refs/heads/*:refs/remotes/origin/* # timeout=10
 > git rev-parse refs/remotes/origin/main^{commit} # timeout=10
Checking out Revision 3cb043a7f592bea981171dd37dc53e7c9ac01021 (refs/remotes/origin/main)
 > git config core.sparsecheckout # timeout=10
 > git checkout -f 3cb043a7f592bea981171dd37dc53e7c9ac01021 # timeout=10
Commit message: "Dockerfile update"
 > git rev-list --no-walk 9c7210f359da6517cc6bb298f33a48a02a77629b # timeout=10
[Pipeline] }
[Pipeline] // stage
[Pipeline] withEnv
[Pipeline] {
[Pipeline] withEnv
[Pipeline] {
[Pipeline] stage
[Pipeline] { (Checkout)
[Pipeline] checkout
The recommended git tool is: NONE
No credentials specified
 > git rev-parse --resolve-git-dir /var/jenkins_home/workspace/WeatherAppPipeline/.git # timeout=10
Fetching changes from the remote Git repository
 > git config remote.origin.url https://github.com/jbSdev/WeatherAppCpp/ # timeout=10
Fetching upstream changes from https://github.com/jbSdev/WeatherAppCpp/
 > git --version # timeout=10
 > git --version # 'git version 2.47.3'
 > git fetch --tags --force --progress -- https://github.com/jbSdev/WeatherAppCpp/ +refs/heads/*:refs/remotes/origin/* # timeout=10
 > git rev-parse refs/remotes/origin/main^{commit} # timeout=10
Checking out Revision 3cb043a7f592bea981171dd37dc53e7c9ac01021 (refs/remotes/origin/main)
 > git config core.sparsecheckout # timeout=10
 > git checkout -f 3cb043a7f592bea981171dd37dc53e7c9ac01021 # timeout=10
Commit message: "Dockerfile update"
[Pipeline] echo
Building commit: 3cb043a
[Pipeline] }
[Pipeline] // stage
[Pipeline] stage
[Pipeline] { (Build Docker Image)
[Pipeline] script
[Pipeline] {
[Pipeline] sh
+ docker build --tag weather-api:3cb043a --tag weather-api:latest .
#0 building with "default" instance using docker driver

#1 [internal] load build definition from Dockerfile
#1 transferring dockerfile: 786B done
#1 DONE 0.1s

#2 [internal] load .dockerignore
#2 transferring context: 2B done
#2 DONE 0.0s

#3 [internal] load metadata for docker.io/library/debian:bookworm-slim
#3 ...

#4 [builder 1/6] FROM docker.io/library/debian:bookworm-slim@sha256:60eac759739651111db372c07be67863818726f754804b8707c90979bda511df
#4 CACHED

#5 [internal] load build context
#5 transferring context: 91B done
#5 DONE 0.1s

#6 [builder 2/6] RUN apt-get update && apt-get install -y --no-install-recommends   build-essential   cmake   git   libcurl14-openssk-dev   libssl-dev   ca-certificates   && rm -rf /var/lib/apt/lists/*
#6 0.863 Get:1 http://deb.debian.org/debian bookworm InRelease [151 kB]
#6 1.148 Get:2 http://deb.debian.org/debian bookworm-updates InRelease [55.4 kB]
#6 1.202 Get:3 http://deb.debian.org/debian-security bookworm-security InRelease [48.0 kB]
#6 1.385 Get:4 http://deb.debian.org/debian bookworm/main arm64 Packages [8690 kB]
#6 ...

#7 [runtime 2/5] RUN apt-get-update && apt-get install -y --no-install-recommends   libcurl14   ca-certificates   && rm -rf /var/lib/apt/lists/*
#7 0.775 /bin/sh: 1: apt-get-update: not found
#7 ERROR: executor failed running [/bin/sh -c apt-get-update && apt-get install -y --no-install-recommends   libcurl14   ca-certificates   && rm -rf /var/lib/apt/lists/*]: exit code: 127

#3 [internal] load metadata for docker.io/library/debian:bookworm-slim
#3 ...

#6 [builder 2/6] RUN apt-get update && apt-get install -y --no-install-recommends   build-essential   cmake   git   libcurl14-openssk-dev   libssl-dev   ca-certificates   && rm -rf /var/lib/apt/lists/*
#6 CANCELED

#3 [internal] load metadata for docker.io/library/debian:bookworm-slim
------
 > [runtime 2/5] RUN apt-get-update && apt-get install -y --no-install-recommends   libcurl14   ca-certificates   && rm -rf /var/lib/apt/lists/*:
0.775 /bin/sh: 1: apt-get-update: not found
------
ERROR: failed to solve: executor failed running [/bin/sh -c apt-get-update && apt-get install -y --no-install-recommends   libcurl14   ca-certificates   && rm -rf /var/lib/apt/lists/*]: exit code: 127
[Pipeline] }
[Pipeline] // script
[Pipeline] }
[Pipeline] // stage
[Pipeline] stage
[Pipeline] { (Smoke Test)
Stage "Smoke Test" skipped due to earlier failure(s)
[Pipeline] getContext
[Pipeline] }
[Pipeline] // stage
[Pipeline] stage
[Pipeline] { (Deploy)
Stage "Deploy" skipped due to earlier failure(s)
[Pipeline] getContext
[Pipeline] }
[Pipeline] // stage
[Pipeline] stage
[Pipeline] { (Verify Deployment)
Stage "Verify Deployment" skipped due to earlier failure(s)
[Pipeline] getContext
[Pipeline] }
[Pipeline] // stage
[Pipeline] stage
[Pipeline] { (Declarative: Post Actions)
[Pipeline] sh
+ docker image prune -f
Total reclaimed space: 0B
[Pipeline] sh
+ docker rm -f weather-api-test
Error response from daemon: No such container: weather-api-test
[Pipeline] echo
Pipeline failed. Check logs above.
[Pipeline] }
[Pipeline] // stage
[Pipeline] }
[Pipeline] // withEnv
[Pipeline] }
[Pipeline] // withEnv
[Pipeline] }
[Pipeline] // node
[Pipeline] End of Pipeline
ERROR: script returned exit code 1
Finished: FAILURE
WORKDIR /build

COPY CMakeLists.txt .
COPY src/ src/

RUN cmake -b build -DCMAKE_BUILD_TYPE=Release \
  && cmake --build build --parallel $(nproc)

# Runtime
FROM debian:bookworm-slim AS runtime

RUN apt-get update && apt-get install -y --no-install-recommends \
  libcurl14 \
  ca-certificates \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY --from=builder /build/build/weather-api /app/weather-api

RUN useradd -r -s /bin/false appuser
USER appuser

EXPOSE 8080

ENTRYPOINT ["./weather-api"]
