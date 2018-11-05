# Red-Discordbot V3
The newest Red-Discordbot in a convenient container

## First Time Setup
Simply run it like so:
```
docker run -it --rm -v /local/folder/for/persistence:/data -e TZ=America/Detroit -e PUID=1000 phasecorex/red-discordbot
```
- `-v /local/folder/for/persistence:/data`: Folder to persist data.
- `-e TZ=America/Detroit`: Specify a timezone.
- `-e PUID=1000`: Specify the user this bot will run as. All files it creates will be owned by this user on the host.
- `-e PGID=1000`: Can also be specified if you want a specific group. If not specified, the PGID will be used as the group.

After the initial setup, you can ctrl+c to kill the bot.

## Subsequent Runs
Once the initial setup is completed, you can run the bot without `-it` or `--rm`. Just make sure you mount the same `/data` directory as before!
```
docker run -v /local/folder/for/persistence:/data -e TZ=America/Detroit -e PUID=1000 phasecorex/red-discordbot
```
Consider adding `-d` to run the container in background.

You should see the bot connect to the server that you set in the setup.
Enjoy!
