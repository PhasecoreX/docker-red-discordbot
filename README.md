# Red-DiscordBot V3
The newest Red-DiscordBot in a convenient multi-arch container

[![Docker Pulls](https://img.shields.io/docker/pulls/phasecorex/red-discordbot)](https://hub.docker.com/r/phasecorex/red-discordbot)
[![Build Status](https://github.com/PhasecoreX/docker-red-discordbot/workflows/build/badge.svg)](https://github.com/PhasecoreX/docker-red-discordbot/actions?query=workflow%3Abuild)
[![Chat Support](https://img.shields.io/discord/608057344487849989)](https://discord.gg/QzdPp2b)
[![BuyMeACoffee](https://img.shields.io/badge/buy%20me%20a%20coffee-donate-orange)](https://buymeacoff.ee/phasecorex)
[![PayPal](https://img.shields.io/badge/paypal-donate-blue)](https://paypal.me/pcx)

## Why This Image?

There are many reasons that this image is better (or as good as) the others out there:

- **Doesn't run as root**: You can specify exactly which user you want the bot to run and create files as.
- **Easy to set up**: Just run one docker command and your new bot is ready to join your server.
- **Always up-to-date**: The bot will always update itself to the latest PyPi release on every (re)start.
- **Runs on most servers**: Can run on a normal x86-64 server, as well as arm(64) devices (Raspberry Pi).
- **Update notifications**: Integrates with [UpdateNotify](https://github.com/PhasecoreX/PCXCogs) to notify you when there is a Red-DiscordBot or Docker image update ready.
- **It's pretty small**: Image size has been reduced as much as possible, only including the bare minimum to run Red-DiscordBot as well as a vast majority of 3rd party cogs.

## Quick Start

Just do this:

```
docker run -v /local_folder_for_persistence:/data -e TOKEN=bot_token -e PREFIX=. phasecorex/red-discordbot
```

Red-DiscordBot will start up with the specified token and prefix, and after updating, it will show the invite URL. Use this to add the bot to your server.

Here is an explanation of the command:

- `-v /local_folder_for_persistence:/data`: Folder to persist Red-DiscordBot data. You could also use a named volume.
- `-e TOKEN=bot_token`: The bot token you want Red-DiscordBot to use.
- `-e PREFIX=.`: The prefix you want Red-DiscordBot to use. You can specify more than one prefix by additionally using the environment variables `PREFIX2`, `PREFIX3`, `PREFIX4`, and `PREFIX5`.

Note: For the first run (with a new `/data` mount), the container might take a little bit longer to start while the Red-DiscordBot software is updated. Subsequent (re)starts will be pretty fast.

Optional environment variables to make your life easier:

- `-e TZ=America/Detroit`: Specify a timezone. By default, this is UTC.
- `-e PUID=1000`: Specify the user Red-DiscordBot will run as. All files it creates will be owned by this user on the host. By default, this is 1000.
- `-e PGID=1000`: Can also be specified if you want a specific group. By default, this is whatever PUID is set to (which by default, is 1000).

Once you like how it's working, you can add these:

- `--name red-discordbot`: A nice name for the docker container, for easy management.
- `-d`: Run container in the background. The name set above comes in handy for managing it.

You can also remove the `OWNER`, `TOKEN`, and `PREFIX`es after the initial run, as they are saved to the bots config. This allows for you to use the `[p]set prefix` command, and makes subsequent runs as simple as:

```
docker run -v /local_folder_for_persistence:/data phasecorex/red-discordbot
```

Enjoy!

### One Time Configurations

A few of the environment variables can be used to configure Red-DiscordBot, but are persisted to the bots internal configuration. Thus, once they are used once, you are free to remove them from your Docker run command or Docker compose file. These are the environment variables:

- `OWNER`: To set a new owner of the bot
- `TOKEN`: To set a new token for the bot
- `PREFIX` (as well as `PREFIX2`-`PREFIX5`): To set new prefixes for the bot

If you see any of the following messages, you know that the setting were applied successfully, and you're free to remove the environment variable from your setup:

```
Setting bot owner...
Setting bot token...
Setting bot prefix(es)...
```

You can of course just leave the environment variables in place, but if you want a faster startup, you can remove the environment variables.

### Docker Compose

As with any Docker run command, you can also specify it as a docker-compose.yml file for easier management. Here is an example:

```yaml
version: "3.2"
services:
  redbot:
    container_name: redbot
    image: phasecorex/red-discordbot
    restart: unless-stopped
    volumes:
      - ./redbot:/data
    environment:
      - TOKEN=your_bot_token_goes_here
      - PREFIX=.
      - TZ=America/Detroit
      - PUID=1000
```

And again, subsequent runs you can omit the `OWNER`, `TOKEN`, and `PREFIX`es from the docker-compose.yml file.

### Updates

If you find out that Red-DiscordBot was updated, simply issue the `[p]restart` command. Red-DiscordBot will gracefully shut down, update itself, and then start back up.

Consider using the [UpdateNotify](https://github.com/PhasecoreX/PCXCogs) cog I created to get notifications when Red-DiscordBot (or this Docker image) updates!

## More Advanced Stuff

### Niceness

By default, Red-DiscordBot (and the Lavalink audio server) will run at the niceness that Docker itself is running at (usually zero). If you would like to change that, simply define the `NICENESS` environment variable:

- `NICENESS=10`

Niceness has a range of -20 (highest priority, least nice to other processes) to 19 (lowest priority, very nice to other processes). Setting this to a value less than the default (higher priority) will require that you start the container with `--cap-add=SYS_NICE`. Setting it above the default will not need that capability set. If you are on a lower powered device or shared VPS that allows it, this option may help with audio stuttering when set to a lower (negative) value.

### Dashboard (or other RPC software)

Any software that needs to communicate to Red-DiscordBot via RPC can only do so when the container is running in host networking mode. Since the RPC port only listens on localhost (for security purposes), it would normally only be listening inside its own container. Setting the container to host networking mode allows for other software (running on the host) to connect successfully.

### redbot-setup

`redbot-setup` can be run manually, in case you want to set up the bot yourself or to convert it's datastore. It can only be run in interactive mode, like so:

```
docker run -it --rm -v /local_folder_for_persistence:/data phasecorex/red-discordbot redbot-setup [OPTIONS] COMMAND [ARGS]...
```

By default, Red-DiscordBot will use the JSON datastore. If you would like to use a different datastore (Postgres for example), specify it in the `STORAGE_TYPE` environment variable:

```
docker run -it --rm -v /local_folder_for_persistence:/data -e STORAGE_TYPE=postgres phasecorex/red-discordbot redbot-setup [OPTIONS] COMMAND [ARGS]...
```

You can [check the official Red-DiscordBot documentation](https://docs.discord.red/en/latest/install_linux_mac.html#installing-red) to find out what datastores are available. The example on the page looks like this:

```
python -m pip install -U Red-DiscordBot[postgres]
                                        ^^^^^^^^
                                        Set STORAGE_TYPE to this value
```

You can also do this on your first run if you want to set up the bot to use a non-JSON datastore right off the bat. Do note that you MUST use the instance name of `docker` for things to work properly.

### Migrating From a Non-Docker Environment

Migrating to this container should be fairly easy. Simply copy your `cogs` and `core` folder into the `/data` folder that is to be mounted.

If you were using a non-JSON datastore, you will need to copy your `config.json` file (usually found in `~/.config/Red-DiscordBot/config.json`) into the `/data` folder. Be sure to set the `DATA_PATH` to `/data`, and double check if you need to update the `STORAGE_DETAILS` `host` value.

### Version Freeze

By default, Red-DiscordBot will check for updates on each (re)start of the container. If for some reason you want to have Red-DiscordBot stay at a certain version, you can use the `REDBOT_VERSION` environment variable to specify this. The format is the same as a [version specifier](https://www.python.org/dev/peps/pep-0440/#version-specifiers) for a pip package:

- `REDBOT_VERSION="==3.2.1"`: Version Matching. Must be version 3.2.1
- `REDBOT_VERSION="~=3.2.1"`: Compatible release. Same as >= 3.2.1, == 3.2.*

Do note: If you need to use a version of Red-DiscordBot that is below 3.4.13, you will need to use the images tagged with `*-py38`, as those are the last ones that use Python 3.8. Also note that those tagged images are no longer updated, and you really should be using the latest Red-DiscordBot and not using this `REDBOT_VERSION` environment variable at all.

### Extra Arguments

The environment variable `EXTRA_ARGS` can be used to append extra arguments to the bots startup command. This can be used for a plethora of things, such as:

- `--no-cogs`: Starts Red with no cogs loaded, only core
- `--dry-run`: Makes Red quit with code 0 just before the login. This is useful for testing the boot process.
- `--debug`: Sets the loggers level as debug
- And many other, more powerful arguments.

Specify multiple arguments at once by surrounding them all with double quotes:

- `EXTRA_ARGS="--no-cogs --dry-run --debug"`

The typical user will not need to use this environment variable.

### Custom Red-DiscordBot Package

Intended for developers or users who know what they're doing, the `CUSTOM_REDBOT_PACKAGE` environment variable allows for specifying exactly what package pip should install. Specifying this environment variable will also ignore the `STORAGE_TYPE` and `REDBOT_VERSION` variables, as it's assumed you will provide any of that information in this environment variable. This can be useful for testing the bleeding edge Red-DiscordBot updates from GitHub:

- `CUSTOM_REDBOT_PACKAGE=git+https://github.com/Cog-Creators/Red-DiscordBot.git`
- `CUSTOM_REDBOT_PACKAGE=git+https://github.com/Cog-Creators/Red-DiscordBot.git@7d30e3de14264b86b5d18bac619ad476473d4467`

The typical user SHOULD NOT use this. If you do use this environment variable, little to no support will be provided, as I assume you know what you are doing. If you want to switch back to a regular Red-DiscordBot install, you will need remove this environment variable, and you most likely will need to delete the `venv` folder inside the `/data` folder. If you don't, it may see that your custom version is newer than the PyPi official release, and it will not downgrade automatically.

## Extending This Image

This image will run Red-DiscordBot as a non-root user. This is great, until you want to install any cogs that depend on external libraries or pip packages. To get around this, the image will run Red-DiscordBot in a python virtual environment. You can see this in the folder `/data/venv`. This allows for Red-DiscordBot to install any package it wants as the non-root user. This also allows for Red-DiscordBot to always be up-to-date when it first launches.

Some pip packages will require external libraries, so some of the popular ones (the ones I need for my bot) are included in the `extra`/`extra-audio` tag. If you find that Red-DiscordBot cannot install a popular cog, you can either let me know for including the package in this tag, or you can extend this image, running `apt-get install -y --no-install-recommends` to install your dependencies:

```dockerfile
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

## Image Tags

### core (Alias: noaudio)

This tag contains the bare minimum to run Red-DiscordBot (no Java, so no Audio cog support).

### core-audio (Aliases: latest, audio)

The default version. It's the same as core, but with Java included so that you can use the Audio cog.

### extra

Same as core, but it has added packages that at least make these cogs work:

- CrabRave
- NotSoBot
- ReTrigger (OCR feature)

But remember, no Java, so no Audio cog support.

### extra-audio (Alias: full)

Same as extra, but with Java included so that you can use the Audio cog.

Basically, pick if you want bare minimum (core) or extra 3rd party cog support (extra), then add the "-audio" to the tag if you want the Audio cog to work.
