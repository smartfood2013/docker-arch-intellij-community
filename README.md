# Intellij Docker Container

A docker container for running IntelliJ inside a docker container

## Why?

I'd just purchased a brand new machine and wanted to keep everything as clean as possible,

By packaging all my applications as docker containers I know exactly what's running on my server at any given time. And if I get a new server I can simply install all my docker files and have a working system up and running again asap.

## Usage

- clone repository
- copy public key into folder
- sudo docker build -t intellij .
- sudo docker run -d -p 127.0.0.1:2222:22 --name intellij intellij

Add the following to ~/.ssh/config

~~~
Host docker-intellij
 User intellij
 Port 2222
 HostName 127.0.0.1
 RemoteForward 64713 localhost:4713
 ForwardX11 yes 
 ForwardX11Trusted yes //Prevents bug with unable to input text in text field
 IdentifiyFile ~/.ssh/alan.hollis
~~~

