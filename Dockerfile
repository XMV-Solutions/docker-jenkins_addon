FROM jenkins:latest

LABEL maintainer="David Koller (XMV) <david.koller@xmv.de>"

# Install node.js and newman
RUN curl -sL https://deb.nodesource.com/setup_10.x | bash 
RUN apt-get update && apt-get install nodejs build-essential -y
RUN npm i -g newman

# Install dotnet 
RUN wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.asc.gpg
RUN sudo mv microsoft.asc.gpg /etc/apt/trusted.gpg.d/
RUN wget -q https://packages.microsoft.com/config/debian/9/prod.list
RUN mv prod.list /etc/apt/sources.list.d/microsoft-prod.list
RUN chown root:root /etc/apt/trusted.gpg.d/microsoft.asc.gpg
RUN chown root:root /etc/apt/sources.list.d/microsoft-prod.list
RUN package=$(apt-cache search dotnet-sdk | tail -n 1 | grep -P "^[^\s]*") && apt-get update && apt-get install $package

# Jenkins stuff
ARG user=jenkins
ARG group=jenkins
ARG uid=1000
ARG gid=1000
ARG http_port=8080
ARG agent_port=50000

ENV JENKINS_HOME /var/jenkins_home
ENV JENKINS_SLAVE_AGENT_PORT ${agent_port}

VOLUME /var/jenkins_home

EXPOSE ${http_port}

EXPOSE ${agent_port}
USER ${user}

ENTRYPOINT ["/bin/tini", "--", "/usr/local/bin/jenkins.sh"]