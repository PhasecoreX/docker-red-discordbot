# Red-Discordbot V3
The newest Red-Discordbot in a convenient multi-arch container

[![Build Status](https://ci.pcxserver.com/api/badges/PhasecoreX/docker-red-discordbot/status.svg)](https://ci.pcxserver.com/PhasecoreX/docker-red-discordbot)
[![Image Size](https://images.microbadger.com/badges/image/phasecorex/red-discordbot.svg)](https://microbadger.com/images/phasecorex/red-discordbot)
[![Donate to support my code](https://img.shields.io/badge/Paypal-Donate-blue.svg)](https://paypal.me/pcx)

## First Time Setup
Simply run it like so:
```
docker run -it --rm -v /local/folder/for/persistence:/data -e TZ=America/Detroit -e PUID=1000 phasecorex/red-discordbot
```
- `-v /local/folder/for/persistence:/data`: Folder to persist data.
- `-e TZ=America/Detroit`: Specify a timezone.
- `-e PUID=1000`: Specify the user Red-Discordbot will run as. All files it creates will be owned by this user on the host.
- `-e PGID=1000`: Can also be specified if you want a specific group. If not specified, the PUID will be used as the group.

After this initial setup, add the bot to your server with the displayed URL. Once the bot joins, you are free to ctrl+c to kill Red-Discordbot.

## Subsequent Runs
Once the initial setup is completed, you can run Red-Discordbot without `-it` or `--rm`. Just make sure you mount the same `/data` directory as before!
```
docker run --name red-discordbot --restart always -d -v /local/folder/for/persistence:/data -e TZ=America/Detroit -e PUID=1000 phasecorex/red-discordbot
```
You should see Red-Discordbot connect to the server that you set in the setup.

Enjoy!

## Updates
If you hear that Red-Discordbot was updated, simply issue the `[p]restart` command. Red-Discordbot will gracefully shut down, and if you have set up your container to always restart (`--restart always`), it will come back up after updating to the latest version. If you do not have automatic restart enabled for the docker container, just rerun the above comand and Red-Discordbod will update itself and start.

Alternatively, consider using the [UpdateNotify](https://github.com/PhasecoreX/PCXCogs) cog I created to get notifications when Red-Discordbot updates!

## Notes
This image will run Red-Discordbot as a non-root user. This is great, until you want to install any cogs that depend on external libraries or pip packages. To get around this, the image will run Red-Discordbot in a python virtual environment. You can see this in the directory `/data/venv`. This allows for Red-Discordbot to install any package it wants as the non-root user. This also allows for Red-Discordbot to always be up-to-date when it first launches.

Some pip packages will require external libraries, so some of the popular ones (the ones I need for my bot) are included. If you find that Red-Discordbot cannot install a popular cog, you can either let me know for including the package in this image, or you can extend this image, running `apk add --no-cache` to install your dependencies:

```
FROM phasecorex/red-discordbot

RUN apt-get update; \
    apt-get install -y --no-install-recommends \
        your \
        packages \
        here \
    ; \
    rm -rf /var/lib/apt/lists/*;
```

No need to define anything else, as the VOLUME and CMD will be the defaults.

## Versions

### latest/audio
The default version. It contains Java so that you can use the Audio cog. You can extend this one (or any of the other versions) to add your own packages for your own 3rd party cogs.

### noaudio
This version only contains the bare minimum to run Red-Discordbot (no Java, so no Audio cog support).

### full
This is the version that I use. It is the same as the latest version, but with added packages. It will be occasionally updated with more dependencies that popular cogs need. If you need another dependency for your cog, let me know, and I'll consider adding it.
