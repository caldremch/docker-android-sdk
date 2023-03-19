FROM  ubuntu:22.04

RUN apt-get update
RUN apt-get install -y unzip
RUN apt-get install -y zip
RUN apt-get install -y git

RUN apt-get install -y --no-install-recommends openjdk-8-jdk
RUN apt-get install -y --no-install-recommends openjdk-11-jdk

ENV ANDROID_HOME="/opt/android-sdk" \
	ANDROID_SDK_HOME="/opt/android-sdk" \
	ANDROID_SDK_ROOT="/opt/android-sdk" \
	ANDROID_NDK="/opt/android-sdk/ndk/latest" \
	ANDROID_NDK_ROOT="/opt/android-sdk/ndk/latest" \

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

ENV PATH="$JAVA_HOME/bin:$PATH:$ANDROID_SDK_HOME/emulator:$ANDROID_SDK_HOME/cmdline-tools/latest/bin:$ANDROID_SDK_HOME/tools:$ANDROID_SDK_HOME/platform-tools"



RUN mkdir --parents "$ANDROID_HOME/.android/"
RUN	echo '### User Sources for Android SDK Manager' > "$ANDROID_HOME/.android/repositories.cfg"

RUN echo "platforms" && yes | $ANDROID_SDK_MANAGER "platforms;android-33"
RUN echo "platforms" && yes | $ANDROID_SDK_MANAGER "platforms;android-32"
RUN echo "platforms" && yes | $ANDROID_SDK_MANAGER "platforms;android-31"
RUN echo "platforms" && yes | $ANDROID_SDK_MANAGER "platforms;android-31"
RUN echo "platforms" && yes | $ANDROID_SDK_MANAGER "platforms;android-30"
RUN echo "platforms" && yes | $ANDROID_SDK_MANAGER "platforms;android-29"
RUN echo "platforms" && yes | $ANDROID_SDK_MANAGER "platforms;android-28"
RUN echo "platforms" && yes | $ANDROID_SDK_MANAGER "platforms;android-27"
RUN echo "platforms" && yes | $ANDROID_SDK_MANAGER "platforms;android-26"

RUN yes | $ANDROID_SDK_MANAGER "build-tools;33.0.0"
RUN yes | $ANDROID_SDK_MANAGER "build-tools;32.0.0"
RUN yes | $ANDROID_SDK_MANAGER "build-tools;31.0.0"
RUN yes | $ANDROID_SDK_MANAGER "build-tools;30.0.0"
RUN yes | $ANDROID_SDK_MANAGER "build-tools;30.0.2"


VOLUME [ "/root/.gradle", "/projects"]

COPY daemon_proccess.sh .
RUN nohup daemon_proccess.sh &