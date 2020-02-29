# AutoSsh docker container

A docker container with autossh installed.
Autossh is configured using a config.json.
This file must be present in `/data/config.json`
If file does not exist the container will create one. 

Docker compose example
```
version: "3.7"
services:
  autossh:
    image: robg66/autossh
    volumes:
      - /path-to-data-folder:/config
```
