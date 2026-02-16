# Codename Altfactor

An Experimental Alpine/Arch based image for the Recore A8 3d printer mainboard.

Current state: Unfinished, Not working, Untested, U-boot building.

## Why?

Less is more.

Is it viable to make a slimmer image?

## Requirements

- x86 linux
- Docker

## Build

Run `build.sh` to build artifacts.
Docker buildx is used.

## Clean

Run `./clean.sh` to remove local build artifacts (`out/`), the Buildx builder/cache used by `build.sh`, and any local Docker images matching `alpfactor*`.

