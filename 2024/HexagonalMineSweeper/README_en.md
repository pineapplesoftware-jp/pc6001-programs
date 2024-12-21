# Hexagonal Minesweeper

(Use chat-GPT translate...)

- [Hexagonal Minesweeper](#hexagonal-minesweeper)
	- [Brief Story](#brief-story)
	- [Operating Conditions](#operating-conditions)
	- [How to Launch the Program](#how-to-launch-the-program)
	- [How to Play and Rules](#how-to-play-and-rules)
		- [Title Screen](#title-screen)
	- [Rules](#rules)
	- [Development Reflection](#development-reflection)
		- [August](#august)
		- [September-October](#september-october)
		- [November](#november)


## Brief Story

I am a bomb disposal expert.
I’ve been tasked with disarming landmines buried somewhere on hexagonal tiles.
Along with my secret weapon to prevent explosions,
I will disarm all the mines and
bring peace back to this area!

## Operating Conditions

- Memory: 32KB required.
- Number of pages: 2 required.

## How to Launch the Program

Here’s how to start the program:

- Connect the white cassette cable to a wav playback device.
- Insert the ROM/RAM cartridge into a PC6001 (original model) and start it up.
(For models after mkII, I'm not sure how to do it, so please manage it somehow 😅)
- When started, it will ask "How Many Pages?"
Press the `2` key, then press the `RETURN` key.
- Type `CLOAD` and press `RETURN` to execute the **CLOAD** command.
- Play the `P6_HMS_32k_p2.WAV` file on your wav playback device.
  - It will be loaded as `HMS322`.
- Type `RUN` and press `RETURN` to execute the **RUN** command.


## How to Play and Rules

### Title Screen

When the game starts, the PINEAPPLE logo will be displayed, followed by the title screen.

<img src="images/hms_titl01.png" width=600 />

On this screen, you can change the following settings using the arrow keys:

- REMAIN TIME: Time limit (9000, 2400, 1200, 200)
- NUM OF MINES: Number of mines (20, 30, 40, 70)
- NUM OF BLOCK: Number of minesweepers (0, 1, 5, 10)

Use the up and down arrows to select an option, and the left and right arrows to change the values.  
When the option is set to "START GAME!", press `SPACE` to start the game.


## Rules

This game is very similar to Microsoft Minesweeper.  
The difference here is that the playfield consists of hexagonal tiles.

<img src="images/hms_main01.png" width=600 />

At the start, all tiles are closed (yellow tiles).  
You control the cross cursor in the center and open the tiles.

```
Keys used:
- Arrow keys: Move the cross cursor
- [SPACE] key: Open the tile at the cursor's location
- [SHIFT] key: Place or remove a flag, question mark, etc., at the cursor's location
- [ESC] key: Exit to the game menu
```

If a mine is present on an opened tile, the mine will explode, and the game is over. If the time limit runs out, the game is over as well.

If there is one or more mines surrounding an opened tile, the number of mines is displayed. If there are no mines around the opened tile, the surrounding six tiles will also be opened.

<img src="images/hms_main03.png" />

If you think a tile might contain a mine, you can place a flag to mark it. Move the cross cursor to the tile you want to mark and press the SHIFT key once to place a flag. Pressing SHIFT again places a question mark, which can be used when you're unsure whether there's a mine. Press SHIFT one more time to remove the flag or question mark.

<img src="images/hms_main04.png" />

If you open all the tiles except the mines within the time limit, you win.

<img src="images/hms_main02.png" width=600 />


## Development Reflection

Minesweeper is a bit frustrating at times, but it’s really fun, right?  
I thought, "What would happen if I made this with hexagonal tiles?" and that's how I started.

It’s been so long since I last programmed on the PC6001 that I decided to just do it as a form of rehabilitation. It’s really fun working with the Z80! 👍

For the assembler, I used AILight’s [AILZ80ASM](https://github.com/AILight/AILZ80ASM).  
Thanks a lot! 🙇‍♂️

In rough terms, I started in August and hoped to finish by September or October.

### August

In August, I ended up spending time thinking about what kind of screen design I wanted, and working on small features.  
That’s basically how the month went by.

<img src="images/hms_idea01.jpg" />

Looking at this paper…  
At first, I thought it would be nice to have an option to select the area size, but after playing it, I found that anything smaller than 14 x 13 tiles was too small, so I scrapped it. Also, the time limit was initially going to be specified in seconds, but that seemed like too much hassle, so I dropped that as well. There’s also a note about the mine explosion being like "UPL’s explosion (Omega Fighter)," but I ended up scrapping that too.

(*) Is the development style still from the 80s?


### September-October

In September and October, I started putting together the main parts of the game, and I managed to get a working game. I also gradually added sound functionality. I also worked on the graphics for the title, including the kanji characters.

For the graphics data, I used a tool called Yonten (SCREEN3), and created the graphics with it.

<img src="images/hms_yonten01.png" />

The functionality is basic, but the custom export feature that allows you to specify how to output data in json format was very useful. The output is in assembler source code.

<img src="images/hms_yonten02.png" />

Here’s an example of the json file:

```json
{
	"Name": "hms_title_asm",
	"ImagePacs": [
		{
			"Name": "title_logo",
			"Width": 16,
			"Height": 31,
			"Locates": [
				{ "X":   0, "Y": 0 },
				{ "X":  16, "Y": 0 },
				{ "X":  32, "Y": 0 },
				{ "X":  48, "Y": 0 },
				{ "X":  64, "Y": 0 },
				{ "X":  80, "Y": 0 },
				{ "X":  96, "Y": 0 },
				{ "X": 112, "Y": 0 },
				{ "X":   0, "Y": 32 },
				{ "X":  16, "Y": 32 }
			]
		}
	]
}
```

Here’s the assembler source that gets output:

```
; --------
; title_logo
; --------
; Locate(0,0)
		DB	00H,2AH,00H,00H
		DB	00H,2AH,00H,00H
			:
		DB	80H,00H,00H,A0H
		DB	80H,00H,02H,80H
; Locate(16,0)
		DB	00H,28H,A8H,00H
		DB	00H,2AH,A8H,00H
			:
```

### November

In November, I worked on fine-tuning the title screen and displaying the PINEAPPLE logo.  
Also, since Minesweeper is a puzzle game but sometimes feels like a game of chance due to the lack of any hints for the mines, I added a new feature to prevent mine explosions as a form of rescue.

I used TINY Yarou-san's [Nan Demo P-Ga MkII](https://www.tiny-yarou.com/datarec.html) for converting it to WAV.
Thank you very much. 🙇‍♂️


