# muhaddil_bed_configurator

A simple FiveM script to spawn a configurable NPC and adjust its position and rotation for bed animations for ambulance scripts for example.

## Features

* Spawn a configurable NPC near the player.
* NPC follows the camera position.
* Rotate NPC with arrow keys (left/right) or with the mouse wheel.
* Adjust NPC height with arrow keys (up/down).
* Save NPC position, rotation, and offset for easy configuration.
* Cancel configuration at any time.

## Commands

* `/configbed` – Start configuring bed NPC positions.
* `/confighelp` – Show help message with available commands.

## Controls

* **Camera follow:** NPC automatically follows where you look.
* **Rotate:** Left/Right arrows/Mouse Wheel
* **Adjust height:** Up/Down arrows
* **Save configuration:** Enter
* **Cancel configuration:** Esc

## Installation

1. Add the resource folder to your server’s `resources` directory.
2. Add `start muhaddil_bed_configurator` to your `server.cfg`.
3. Use `/configbed` in-game to start configuring NPC positions.