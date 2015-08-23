FROM ubuntu:trusty
MAINTAINER zhouzhi <2929715148@qq.com>

# replace sources
ADD sources.list /etc/apt/sources.list

# change timezone
RUN echo "Asia/Shanghai" > /etc/timezone && \
                dpkg-reconfigure -f noninteractive tzdata

# no Upstart or DBus
# https://github.com/dotcloud/docker/issues/1724#issuecomment-26294856
RUN apt-mark hold initscripts udev plymouth mountall
RUN dpkg-divert --local --rename --add /sbin/initctl && ln -sf /bin/true /sbin/initctl

# install package and configuration
RUN apt-get update && apt-get install -y --no-install-recommends xterm supervisor
RUN apt-get install -y --no-install-recommends x11vnc xvfb

RUN apt-get update \
 && apt-get install -y software-properties-common curl \
 && apt-add-repository -y ppa:webupd8team/java \
 && apt-get update \
 && echo debconf shared/accepted-oracle-license-v1-1 select true | sudo debconf-set-selections \
 && echo debconf shared/accepted-oracle-license-v1-1 seen true | sudo debconf-set-selections
RUN apt-get install -y oracle-java8-set-default

RUN apt-get update && apt-get install -y --no-install-recommends lxde

ENV ECLIPSE eclipse-jee-luna-SR2-linux-gtk-x86_64.tar.gz
RUN curl -O http://download.eclipse.org/technology/epp/downloads/release/luna/SR1a/"$ECLIPSE"
RUN tar -vxzf $ECLIPSE -C /usr/local/
COPY org.eclipse.ui.ide.prefs /usr/local/eclipse/configuration/.settings/org.eclipse.ui.ide.prefs

RUN rm /etc/X11/app-defaults/XTerm && rm /etc/xdg/lxsession/LXDE/autostart && rm $ECLIPSE \
 && mkdir /root/Desktop/ \
 && ln -s /usr/local/eclipse/eclipse /root/Desktop/eclipse
COPY XTerm /etc/X11/app-defaults/XTerm
COPY autostart /etc/xdg/lxsession/LXDE/autostart
COPY desktop-items-0.conf /root/.config/pcmanfm/LXDE/desktop-items-0.conf

RUN adduser --disabled-password --quiet --gecos '' eclipse \
 && chown -R root:eclipse /usr/local/eclipse \
 && chmod -R 775 /usr/local/eclipse

COPY noVNC /noVNC/
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

#USER eclipse
EXPOSE 6080
 
CMD ["/usr/bin/supervisord"]
