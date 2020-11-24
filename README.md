# game_match3
A Godot Match3/bejeweled/candyCrush style game

# Godot
This is a game build using the Godot engine. 
There are currently no binaries in this project, just use the Godot (free/opensource) engine to play the game.
Used Godot 3.2.4b2 (18nov2020) https://downloads.tuxfamily.org/godotengine/3.2.4/beta2/

# Current state of the game
The game is/was a way for me to learn Godot. The game is not finished and is mainly configured for debugging.
I play/test the game on a linux system using a mouse.

#Currently active:
- background image and music
- Basic colored blocks, nr depends on level dificulty
- overlays : small bomb, large bomb, icing, chain, chains, clock, dice, ...
- bomb explosions,  dice gives lines to random blocks destroyed, 
- background tiles that need a match made on them to turn gold
-   animate (twinkle) background tiles when only a few are left
- way to shape levels with wooden crates and empty spots. define how often new bombs,dice,etc are added to field
- levels.gd file to define multiple levels and load them
- detect 'no more moves' and give 'move' animated hint when player is inactive
- make swapping block possible when other blocks are falling
- tutorial popup banners for (first 3) levels
- 4 levels
- ...

#Todo:
- Animation when key hits lock
- act on play time timeout
- refactoring
- ... juice and pollish ...

![screenshot](https://github.com/krdh/game_match3/blob/master/Gamedesign/Screenshot.png)
