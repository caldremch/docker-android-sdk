FROM  ubuntu:22.04

RUN apt-get update
RUN apt-get install -y unzip
RUN apt-get install -y zip
RUN apt-get install -y git
RUN apt-get install -y curl

RUN apt-get install -y --no-install-recommends openjdk-8-jdk
RUN apt-get install -y --no-install-recommends openjdk-11-jdk
RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections && \
	apt-get install -qq -y apt-utils locales
RUN apt-get install -qq --no-install-recommends \
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
	ANDROID_SDK_HOME="/opt/android-sdk" \
	ANDROID_SDK_ROOT="/opt/android-sdk" \
	FLUTTER_HOME="/opt/flutter" \
	ANDROID_NDK="/opt/android-sdk/ndk/latest" \
	ANDROID_NDK_ROOT="/opt/android-sdk/ndk/latest"

ENV ANDROID_SDK_MANAGER=${ANDROID_HOME}/cmdline-tools/latest/bin/sdkmanager
ENV ANDROID_SDK_HOME="$ANDROID_HOME"
ENV ANDROID_NDK_HOME="$ANDROID_NDK"


RUN curl -o sdk-tools.zip https://dl.google.com/android/repository/commandlinetools-linux-9477386_latest.zip

RUN mkdir --parents "$ANDROID_HOME" && \
	unzip -q sdk-tools.zip -d "$ANDROID_HOME" && \
	cd "$ANDROID_HOME" && \
	mv cmdline-tools latest && \
	mkdir cmdline-tools && \
	mv latest cmdline-tools && \
	rm --force sdk-tools.zip


ENV JAVA_HOME="/usr/lib/jvm/java-11-openjdk-amd64"
ENV ANDROID_SDK_HOME="$ANDROID_HOME"
ENV ANDROID_NDK_HOME="$ANDROID_NDK"

ENV PATH="$JAVA_HOME/bin:$PATH:$ANDROID_SDK_HOME/emulator:$ANDROID_SDK_HOME/cmdline-tools/latest/bin:$ANDROID_SDK_HOME/tools:$ANDROID_SDK_HOME/platform-tools:$ANDROID_NDK:$FLUTTER_HOME/bin:$FLUTTER_HOME/bin/cache/dart-sdk/bin"



RUN mkdir --parents "$ANDROID_HOME/.android/"
RUN echo '### User Sources for Android SDK Manager' > "$ANDROID_HOME/.android/repositories.cfg"

RUN echo "platforms" && yes | $ANDROID_SDK_MANAGER "platforms;android-33"
RUN echo "platforms" && yes | $ANDROID_SDK_MANAGER "platforms;android-32"
RUN echo "platforms" && yes | $ANDROID_SDK_MANAGER "platforms;android-31"
RUN echo "platforms" && yes | $ANDROID_SDK_MANAGER "platforms;android-31"
RUN echo "platforms" && yes | $ANDROID_SDK_MANAGER "platforms;android-30"
RUN echo "platforms" && yes | $ANDROID_SDK_MANAGER "platforms;android-29"
RUN echo "platforms" && yes | $ANDROID_SDK_MANAGER "platforms;android-28"
RUN echo "platforms" && yes | $ANDROID_SDK_MANAGER "platforms;android-27"
RUN echo "platforms" && yes | $ANDROID_SDK_MANAGER "platforms;android-26"

RUN yes | $ANDROID_SDK_MANAGER "build-tools;33.0.2"
RUN yes | $ANDROID_SDK_MANAGER "build-tools;33.0.1"
RUN yes | $ANDROID_SDK_MANAGER "build-tools;33.0.0"
RUN yes | $ANDROID_SDK_MANAGER "build-tools;32.0.0"
RUN yes | $ANDROID_SDK_MANAGER "build-tools;31.0.0"
RUN yes | $ANDROID_SDK_MANAGER "build-tools;30.0.3"
RUN yes | $ANDROID_SDK_MANAGER "build-tools;30.0.2"
RUN yes | $ANDROID_SDK_MANAGER "build-tools;30.0.1"
RUN yes | $ANDROID_SDK_MANAGER "build-tools;30.0.0"
RUN yes | $ANDROID_SDK_MANAGER "build-tools;29.0.3"
RUN yes | $ANDROID_SDK_MANAGER "build-tools;29.0.2"
RUN yes | $ANDROID_SDK_MANAGER "build-tools;29.0.1"
RUN yes | $ANDROID_SDK_MANAGER "build-tools;29.0.0"
RUN yes | $ANDROID_SDK_MANAGER "build-tools;28.0.3"
RUN yes | $ANDROID_SDK_MANAGER "build-tools;28.0.2"
RUN yes | $ANDROID_SDK_MANAGER "build-tools;27.0.3"
RUN yes | $ANDROID_SDK_MANAGER "build-tools;26.0.3"

COPY apkShrink.zip .

RUN unzip -q apkShrink.zip -d "$ANDROID_HOME" && \
	rm --force apkShrink.zip

ARG NDK_VERSION="25.2.9519653"
RUN echo "Installing ${NDK_VERSION}" && \
    yes | $ANDROID_SDK_MANAGER ${DEBUG:+--verbose} "ndk;${NDK_VERSION}" > /dev/null && \
    ln -sv $ANDROID_HOME/ndk/${NDK_VERSION} ${ANDROID_NDK}

RUN chmod 775 $ANDROID_HOME $ANDROID_NDK_ROOT/../

VOLUME [ "/root/.gradle", "/projects"]



#flutter install 
RUN git clone --depth 5 -b stable https://github.com/flutter/flutter.git ${FLUTTER_HOME} 

#COPY daemon_proccess.sh .
#RUN nohup daemon_proccess.sh &

#ENTRYPOINT ["exec", "$@"] # TODO
#ENTRYPOINT ["echo", "TODO"]
