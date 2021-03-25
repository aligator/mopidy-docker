# Mopidy docker

A Dockerfile for Mopidy including support for spotify, mpd and others.

Based on https://github.com/IVData/dockerfiles/tree/master/mopidy

Example docker compose:
```yaml
version: "3.3"
services:
  mopidy:
    build: .
    ports:
      - 6600:6600 # MPD
      - 6680:6680 # http stream
    volumes:
      # Optionally mount the data folder
      #- ./data:/home/mopidy/mopidy
      # Optionally mount the music folder
      #- ./music:/mopidy/music
      # Note: An example config will be used if not provided.
      - ./config/mopidy.conf:/home/mopidy/.config/mopidy/mopidy.conf
      # Has to be adapted to the used snapcast image and the fifo file has to be configured in the config.
      - snapcast:/tmp/snapcast
    environment:
      OWNER: 1000
      GROUP: 1000
      # You can add other apt packages which get installed on startup
      # if you need them for a pip package.
      # APT_PACKAGES: "..."
      # Directly supported are: (The config may has to be adapted. Other packages may work too.)
      # PIP_PACKAGES: "Mopidy-TuneIn Mopidy-GMusic Mopidy-Spotify Mopidy-Iris"
      PIP_PACKAGES: "Mopidy-MPD Mopidy-Spotify"
      # Optionally: enable full update on next start. May break things, you could also rebuild the image.
      #UPDATE=true

  snapcast:
    image: ... # any snapcast image will do. Mine is located at https://github.com/aligator/snapcast-docker
    ports:
      - 1704:1704
      - 1705:1705
      - 1780:1780
    environment:
      OWNER: 1000
      GROUP: 1000
    volumes:
      - snapcast:/tmp/snapcast
      
volumes:
  snapcast:
```