# Red-DiscordBot V3
The newest Red-DiscordBot in a convenient multi-arch container

[![Docker Pulls](https://img.shields.io/docker/pulls/phasecorex/red-discordbot)](https://hub.docker.com/r/phasecorex/red-discordbot)
[![Image Size](https://images.microbadger.com/badges/image/phasecorex/red-discordbot.svg)](https://microbadger.com/images/phasecorex/red-discordbot)
[![Build Status](https://cloud.drone.io/api/badges/PhasecoreX/docker-red-discordbot/status.svg)](https://cloud.drone.io/PhasecoreX/docker-red-discordbot)
[![Chat Support](https://img.shields.io/discord/608057344487849989)](https://discord.gg/QzdPp2b)
[![Donate to support my code](https://img.shields.io/badge/Paypal-Donate-blue.svg)](https://paypal.me/pcx)

## Why This Image?
There are many reasons that this image is better (or as good as) the others out there:
- **Doesn't run as root**: You can specify exactly which user you want it to run as and create files as.
- **Easy to set up**: Just run one docker command and your new bot will join your server.
- **Always up-to-date**: The bot will always update itself to the latest PyPi release on every (re)start.
- **Update notifications**: Integrates with [UpdateNotify](https://github.com/PhasecoreX/PCXCogs) to notify you when there is a Red-DiscordBot or Docker image update ready.
- **It's pretty small**: Image size has been reduced as much as possible, only including the bare minimum to run Red-DiscordBot as well as a vast majority of 3rd party cogs.

## How To Run
Just do this:
```
docker run -v /local_folder_for_persistence:/data -e TOKEN=bot_token -e PREFIX=. phasecorex/red-discordbot
```
- `-v /local_folder_for_persistence:/data`: Folder to persist Red-DiscordBot data. You could also use a named volume.
- `-e TOKEN=bot_token`: The bot token you want Red-DiscordBot to use.
- `-e PREFIX=.`: The prefix you want Red-DiscordBot to use.

Note: For the first run (with a new `/data` mount), the container might take a little bit longer to start while the Red-DiscordBot software is updated. Subsequent (re)starts will be pretty fast.

Optional environment variables to make your life easier:
- `-e TZ=America/Detroit`: Specify a timezone. By default, this is UTC.
- `-e PUID=1000`: Specify the user Red-DiscordBot will run as. All files it creates will be owned by this user on the host. By default, this is 1000.
- `-e PGID=1000`: Can also be specified if you want a specific group. By default, this is whatever PUID is set to (which by default, is 1000).

Once you like how it's working, add these:
- `--name red-discordbot`: A nice name for the docker container, for easy management.
- `-d`: Run container in the background. The name set above comes in handy for managing it.

Red-DiscordBot will start up with the specified token and prefix, and after updating, it will show the invite URL. Use this to add the bot to your server.

Enjoy!

### Docker Compose
As with any Docker run command, you can also specify it as a docker-compose.yml file for easier management. Check the examples folder for example docker-compose.yml files based on the run command above.

### Updates
If you find out that Red-DiscordBot was updated, simply issue the `[p]restart` command. Red-DiscordBot will gracefully shut down, update itself, and then start back up.

Consider using the [UpdateNotify](https://github.com/PhasecoreX/PCXCogs) cog I created to get notifications when Red-DiscordBot updates!

## Some Extra Stuff

### Multiple Prefixes
You can specify more than one prefix by using the environment variables `PREFIX2`, `PREFIX3`, `PREFIX4`, and `PREFIX5`.

### Complex Prefixes
If you want to use a prefix that has spaces in it (such as "Red, "), you will need to set up the bot the traditional way. See below for that process. Once you have that set up, you will be able to edit the `/local_folder_for_persistence/core/settings.json` file and specify more complex prefixes. Restart your bot (`[p]restart`) to have these edits take effect.

### The Traditional Setup Process
If you don't like specifying the bot token as an environment variable, or you would like to have support for more complex prefixes, run the bot like this once (make sure to use your `/data` volume):
```
docker run -it --rm -v /local_folder_for_persistence:/data phasecorex/red-discordbot
```
This will guide you through a setup process that will ask you for a token and a prefix. Once these are set and your bot connects to your server, you can ctrl+c to kill the bot. Now, you can use the normal command/docker-compose for running your bot (see the How To Run section), but without specifying the TOKEN and PREFIX environment variables:
```
docker run -v /local_folder_for_persistence:/data phasecorex/red-discordbot
```

## More Advanced Stuff

### MongoDB Conversion
If you used to use this container with MongoDB, it won't be used anymore with the latest Red-DiscordBot. Fortunately, the conversion from MongoDB to json should happen automatically when the bot starts. Once it has been converted, feel free to modify your Docker command/docker-compose.yml and remove the `STORAGE_TYPE` and all `MONGODB_*` environment variables, as they are no longer necessary. If you were volume mounting your `/config` folder, you don't really need to do that anymore either.

As I (PhasecoreX) don't use MongoDB at all, I can only provide a limited amount of support for this. I assume if you're using MongoDB you already have a decent understanding on how things work. I wish you the best of luck.

### Extra Arguments
The environment variable `EXTRA_ARGS` can be used to append extra arguments to the bots startup command. This can be used for a plethora of things, such as:
- `--no-cogs`: Starts Red with no cogs loaded, only core
- `--dry-run`: Makes Red quit with code 0 just before the login. This is useful for testing the boot process.
- `--debug`: Sets the loggers level as debug
- And many other, more powerful arguments.

Specify multiple arguments at once by surrounding them all with double quotes:
- `EXTRA_ARGS="--no-cogs --dry-run --debug"`

The typical user will not need to use this environment variable.

### Niceness
By default, Red-DiscordBot (and the Lavalink audio server) will run at the niceness that Docker itself is running at (usually zero). If you would like to change that, simply define the `NICENESS` environment variable:
- `NICENESS=10`

Niceness has a range of -20 (highest priority, least nice to other processes) to 19 (lowest priority, very nice to other processes). Setting this to a value less than the default (higher priority) will require that you start the container with `--cap-add=SYS_NICE`. Setting it above the default will not need that capability set. If you are on a lower powered device or shared VPS that allows it, this option may help with audio stuttering when set to a lower (negative) value.

## Extending This Image
This image will run Red-DiscordBot as a non-root user. This is great, until you want to install any cogs that depend on external libraries or pip packages. To get around this, the image will run Red-DiscordBot in a python virtual environment. You can see this in the directory `/data/venv`. This allows for Red-DiscordBot to install any package it wants as the non-root user. This also allows for Red-DiscordBot to always be up-to-date when it first launches.

Some pip packages will require external libraries, so some of the popular ones (the ones I need for my bot) are included in the `full` tag. If you find that Red-DiscordBot cannot install a popular cog, you can either let me know for including the package in this tag, or you can extend this image, running `apt-get install -y --no-install-recommends` to install your dependencies:

```
FROM phasecorex/red-discordbot

RUN apt-get update; \
    apt-get install -y --no-install-recommends \
        your \
        extra \
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
This version only contains the bare minimum to run Red-DiscordBot (no Java, so no Audio cog support).

### full
This is the version that I use. It is the same as the latest version, but with added packages. It will be occasionally updated with more dependencies that popular cogs need. If you need another dependency for your cog, let me know, and I'll consider adding it.
