FROM ubuntu:22.04

# ubuntu default: dash shell, see `ls -al /bin/sh`

RUN apt-get --quiet update --yes
RUN apt-get install -y apt-transport-https ca-certificates

# replace default sources
RUN mv /etc/apt/sources.list /etc/apt/sources.list.bak
COPY sources.list /etc/apt/sources.list
RUN apt-get --quiet update --yes

RUN apt-get --quiet install -y zip git curl
# for aapt, see more search ldconfig
RUN apt-get --quiet install -y wget unzip tar lib32stdc++6 lib32z1

RUN apt-get install -y --no-install-recommends openjdk-8-jdk
RUN apt-get install -y --no-install-recommends openjdk-11-jdk
RUN apt-get install -qq --no-install-recommends \
	apt-utils \
	locales \
	autoconf \
	build-essential \
	cmake \
	file \
	git-lfs \
	gpg-agent \
	less \
	libc6-dev \
	libgmp-dev \
	libmpc-dev \
	libmpfr-dev \
	libxslt-dev \
	libxml2-dev \
	m4 \
	ncurses-dev \
	ocaml \
	openjdk-17-jdk \
	openssh-client \
	pkg-config \
	software-properties-common \
	tzdata \
	vim-tiny \
	wget \
	zipalign \
	s3cmd \
	python3-pip \
	zlib1g-dev > /dev/nul \
	&& apt-get -y clean && apt-get -y autoremove && rm -rf /var/lib/apt/lists/* && \
	echo 'debconf debconf/frontend select Dialog' | debconf-set-selections


ENV ANDROID_HOME="/opt/android-sdk" \
	ANDROID_SDK_HOME="$ANDROID_HOME" \
	ANDROID_SDK_ROOT="$ANDROID_HOME" \
	ANDROID_NDK="/opt/android-sdk/ndk/latest" \
	ANDROID_NDK_ROOT="$ANDROID_NDK" \
	ANDROID_NDK_HOME="$ANDROID_NDK" \
	FLUTTER_HOME="/opt/flutter"

ARG ANDROID_SDK_MANAGER="$ANDROID_HOME"/cmdline-tools/latest/bin/sdkmanager
ARG ANDROID_CMD_TOOLS="$ANDROID_HOME"/cmdline-tools/latest
RUN mkdir -p "$ANDROID_CMD_TOOLS"
RUN wget -nv https://dl.google.com/android/repository/commandlinetools-linux-9477386_latest.zip -O /tmp/sdk-tools.zip
RUN unzip -q /tmp/sdk-tools.zip -d "$ANDROID_CMD_TOOLS"
RUN mv "$ANDROID_CMD_TOOLS"/cmdline-tools/* "$ANDROID_CMD_TOOLS"

# CMD ["export" "JAVA_HOME=`/usr/libexec/java_home -v 11`"]
ENV JAVA_HOME="/usr/lib/jvm/java-11-openjdk-amd64"

ENV AAPT_HOME="${ANDROID_HOME}/build-tools/33.0.2"

ENV LANG=C.UTF-8
ENV PATH="$PATH:$AAPT_HOME:$ANDROID_SDK_HOME/emulator:$ANDROID_SDK_HOME/cmdline-tools/latest/bin:$ANDROID_SDK_HOME/tools:$ANDROID_SDK_HOME/platform-tools:$ANDROID_NDK:$FLUTTER_HOME/bin:$FLUTTER_HOME/bin/cache/dart-sdk/bin"

RUN mkdir --parents "$ANDROID_HOME/.android/"
RUN echo '### User Sources for Android SDK Manager' > "$ANDROID_HOME/.android/repositories.cfg"

# only download required build-tools, platform-tools, platforms
RUN echo "platforms" && yes | $ANDROID_SDK_MANAGER "platforms;android-33" >/dev/null
RUN echo "platforms" && yes | $ANDROID_SDK_MANAGER "platforms;android-32" >/dev/null
RUN echo "platforms" && yes | $ANDROID_SDK_MANAGER "platforms;android-31" >/dev/null
RUN echo "platforms" && yes | $ANDROID_SDK_MANAGER "platforms;android-31" >/dev/null
RUN echo "platforms" && yes | $ANDROID_SDK_MANAGER "platforms;android-30" >/dev/null
RUN echo "platforms" && yes | $ANDROID_SDK_MANAGER "platforms;android-29" >/dev/null
RUN echo "platforms" && yes | $ANDROID_SDK_MANAGER "platforms;android-28" >/dev/null
RUN echo "platforms" && yes | $ANDROID_SDK_MANAGER "platforms;android-27" >/dev/null
RUN echo "platforms" && yes | $ANDROID_SDK_MANAGER "platforms;android-26" >/dev/null

RUN yes | $ANDROID_SDK_MANAGER "build-tools;33.0.2" >/dev/null
RUN yes | $ANDROID_SDK_MANAGER "build-tools;33.0.1" >/dev/null
RUN yes | $ANDROID_SDK_MANAGER "build-tools;33.0.0" >/dev/null
RUN yes | $ANDROID_SDK_MANAGER "build-tools;32.0.0" >/dev/null
RUN yes | $ANDROID_SDK_MANAGER "build-tools;31.0.0" >/dev/null
RUN yes | $ANDROID_SDK_MANAGER "build-tools;30.0.3" >/dev/null
RUN yes | $ANDROID_SDK_MANAGER "build-tools;30.0.2" >/dev/null
RUN yes | $ANDROID_SDK_MANAGER "build-tools;30.0.1" >/dev/null
RUN yes | $ANDROID_SDK_MANAGER "build-tools;30.0.0" >/dev/null
RUN yes | $ANDROID_SDK_MANAGER "build-tools;29.0.3" >/dev/null
RUN yes | $ANDROID_SDK_MANAGER "build-tools;29.0.2" >/dev/null
RUN yes | $ANDROID_SDK_MANAGER "build-tools;29.0.1" >/dev/null
RUN yes | $ANDROID_SDK_MANAGER "build-tools;29.0.0" >/dev/null
RUN yes | $ANDROID_SDK_MANAGER "build-tools;28.0.3" >/dev/null
RUN yes | $ANDROID_SDK_MANAGER "build-tools;28.0.2" >/dev/null
RUN yes | $ANDROID_SDK_MANAGER "build-tools;27.0.3" >/dev/null
RUN yes | $ANDROID_SDK_MANAGER "build-tools;26.0.3" >/dev/null

RUN echo y | "$ANDROID_SDK_MANAGER" "platform-tools" >/dev/null
RUN yes | "$ANDROID_SDK_MANAGER" --licenses


COPY apkShrink.zip .
RUN unzip -q apkShrink.zip -d "$ANDROID_HOME" && \
	rm --force apkShrink.zip

# only download while project with cmake
ARG NDK_VERSION="25.2.9519653"
RUN echo "Installing ${NDK_VERSION}" && \
	yes | "$ANDROID_SDK_MANAGER" ${DEBUG:+--verbose} "ndk;${NDK_VERSION}" > /dev/null && \
	ln -sv $ANDROID_HOME/ndk/${NDK_VERSION} ${ANDROID_NDK}

# for what reason
RUN chmod 775 $ANDROID_HOME $ANDROID_NDK_ROOT/../

VOLUME [ "/root/.gradle", "/projects"]
WORKDIR "/projects"

# flutter install and specify tag name 2.10.5
RUN git clone --depth 5 -b 3.3.8 https://github.com/flutter/flutter.git ${FLUTTER_HOME} 
RUN flutter doctor

# COPY android-build-apk /usr/bin/android-build-apk
# ENTRYPOINT ["android-build-apk"]

ENTRYPOINT ["git"]
CMD ["--help"]
