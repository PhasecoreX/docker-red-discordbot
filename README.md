# Red-Discordbot V3
The newest Red-Discordbot in a convenient container

## First Time Setup
Simply run it like so:
```
docker run -it --rm -v /local/folder/for/persistence:/data -e TZ=America/Detroit -e PUID=1000 phasecorex/red-discordbot
```
- `-v /local/folder/for/persistence:/data`: Folder to persist data.
- `-e TZ=America/Detroit`: Specify a timezone.
- `-e PUID=1000`: Specify the user Red-Discordbot will run as. All files it creates will be owned by this user on the host.
- `-e PGID=1000`: Can also be specified if you want a specific group. If not specified, the PUID will be used as the group.

After the initial setup, you can ctrl+c to kill Red-Discordbot.

## Subsequent Runs
Once the initial setup is completed, you can run Red-Discordbot without `-it` or `--rm`. Just make sure you mount the same `/data` directory as before!
```
docker run -v /local/folder/for/persistence:/data -e TZ=America/Detroit -e PUID=1000 phasecorex/red-discordbot
```
Consider adding `-d` to run the container in background.

You should see Red-Discordbot connect to the server that you set in the setup.
Enjoy!

## Notes
This image will run Red-Discordbot as a non-root user. This is great, until you want to install any cogs that depend on external libraries or pip packages. To get around this, the image will run Red-Discordbot in a python virtual environment. You can see this in the directory `/data/venv`. This allows for Red-Discordbot to install any package it wants as the non-root user. This also allows for Red-Discordbot to always be up-to-date when it first launches.

Some pip packages will require external libraries, so some of the popular ones (the ones I need for my bot) are included. If you find that Red-Discordbot cannot install a cog, you can either let me know for including the package in this image, or you can extend this image, running pip3 to install your dependencies:

```
FROM phasecorex/red-discordbot

# matplotlib needs these
RUN apk add --no-cache freetype-dev libpng-dev
```

No need to define anything else, as the VOLUME and CMD will be the defaults.
