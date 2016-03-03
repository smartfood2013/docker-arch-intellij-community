FROM base/arch
MAINTAINER Alan Hollis, @alan01252

RUN grep -i SigLevel /etc/pacman.conf
RUN sed -i "/^SigLevel/a SigLevel = Never" /etc/pacman.conf
RUN grep -i SigLevel /etc/pacman.conf
RUN pacman-db-upgrade /var/lib/pacman
RUN echo 'Server = http://archlinux.mirrors.uk2.net/$repo/os/$arch' > /etc/pacman.d/mirrorlist && \
    echo en_US.UTF-8 UTF-8 > /etc/locale.gen && \
    locale-gen && \
    echo LANG="en_US.UTF-8" > /etc/locale.conf && \
    pacman -Syu --ignore filesystem --noconfirm && \
	pacman-db-upgrade /var/lib/pacman && \
    pacman -S supervisor --noconfirm && \
    mkdir -p /home/nobody && \
    chown -R nobody:users /home/nobody && \
    chmod -R 775 /home/nobody && \
    pacman -Scc --noconfirm

ENV HOME /root
ENV LANG en_US.UTF-8



RUN pacman --quiet --noconfirm -S base-devel
RUN pacman --quiet --noconfirm -S yajl
RUN pacman --quiet --noconfirm -S libpulse
RUN pacman --quiet --noconfirm -S libcups
RUN pacman --quiet --noconfirm -S fontconfig
RUN pacman --quiet --noconfirm -S ttf-dejavu
RUN pacman --quiet --noconfirm -S openssh
RUN pacman --quiet --noconfirm -S jre8-openjdk
RUN pacman --quiet --noconfirm -S jdk8-openjdk
RUN pacman --quiet --noconfirm -S xorg-xauth
RUN pacman --quiet --noconfirm -S xorg-xclock
RUN pacman --quiet --noconfirm -S nodejs
RUN pacman --quiet --noconfirm -S npm

RUN mkdir /var/run/sshd
RUN /usr/bin/ssh-keygen -A

RUN useradd intellij -p "*" -d "/home/intellij/" -s /bin/bash -u 5001 
RUN mkdir -p /home/intellij/.ssh
ADD younus.raza.pub /home/intellij/.ssh/authorized_keys
RUN chown -R intellij:intellij /home/intellij/
RUN chown -R intellij:intellij /home/intellij/.ssh

RUN useradd -m -g users -G wheel -s /bin/bash younus -p '*'
#RUN su younus
RUN sed -i '$ a nobody ALL=(ALL) NOPASSWD: ALL' /etc/sudoers
RUN sed -i '$ a younus ALL=(ALL) NOPASSWD: ALL' /etc/sudoers
RUN pacman --quiet --noconfirm -S git
WORKDIR /tmp/scratch
RUN git clone https://aur.archlinux.org/package-query.git
RUN git clone https://aur.archlinux.org/yaourt.git
RUN chmod -R 777 /tmp/scratch/package-query
RUN cd package-query
WORKDIR /tmp/scratch/package-query
RUN sudo -u nobody makepkg -si --noconfirm --needed
RUN cd ..
RUN chmod -R 777 /tmp/scratch/yaourt
RUN cd /tmp/scratch/yaourt
WORKDIR /tmp/scratch/yaourt
RUN sudo -u nobody makepkg -si --noconfirm
RUN cd ..
# RUN su
RUN yaourt --quiet --noconfirm -Sy intellij-idea-community-edition

RUN echo "/usr/share/intellijidea-ce/bin/idea.sh" >> /usr/local/bin/intellij
RUN chmod 755 /usr/local/bin/intellij

RUN sed -i 's/#PermitEmptyPasswords no/PermitEmptyPasswords yes/' /etc/ssh/sshd_config && \
	sed -i 's/UsePAM yes/UsePAM no/' /etc/ssh/sshd_config && \
	sed -i 's/#PermitTunnel no/PermitTunnel yes/' /etc/ssh/sshd_config && \
	sed -i 's/#X11Forwarding no/X11Forwarding yes/' /etc/ssh/sshd_config && \
	sed -i 's/#X11UseLocalhost yes/X11UseLocalhost no/' /etc/ssh/sshd_config && \
	sed -i 's/#AddressFamily any/AddressFamily any/' /etc/ssh/sshd_config && \
	sed -ri 's/#PubkeyAuthentication yes/PubkeyAuthentication yes/g' /etc/ssh/sshd_config


RUN sed -i 's/heavy/medium/' /usr/share/intellijidea-ce/bin/idea.properties

CMD ["/usr/sbin/sshd", "-D"]

EXPOSE 22
