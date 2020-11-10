# Godot Card Gaming Framework 0.8

This framework is meant to provide well-designed, statically-typed, and well-commented classes which you can plug into any potential card game to provide a polished way to handle typical behaviour expected from cards in a game.

**Important: This is still a pre-release and is subject to heavy changes as I figure things out.**

You can still use it as is, but be aware that newer release might substantially rework how things work, thus requiring a new integration if you want to use them.

Once we hit v1.0 things should become more stable.

Pull requests are more than welcome ;)

## Installation

Copy the src folder to your project

Strictly speaking, the tcsn files inside are optional but **highly recommended** as they come preset with all the node configuration needed to run all interactions defined in the code properly. 

While you could simply use only the provided scripts, you will then need to adapt your own scenes to contain the nodes required with retaining the the correct name.

A notable exception is the optional Board.tcsn. While referenced from the Main.tcsn, this one is the easiest to replace with your own custom board. 
Just remember to adjust Main.tcsn to have your own Board scene under ViewportContainer/Viewport)

**It is strongly suggested you start by importing the provided scenes in src and modify them further to fit your own requirements.**

For example, you can easily switch the CardTemplate.tcsn's Panel (called "Control") to a TextureRect and it will not affect the framework.

However if you forget to add a ViewPopup Control node into your custom CardContainer scene, things will start crashing.

The scripts and scenes inside /srv/custom are option. They are just there to create a sample setup of the capabilties of the framework.


### Global configuration

The framework uses a common singleton called cfc_config to control overall configuration.

1. Add cfc_config.gd as an autoloaded singleton with name 'cfc_config'

2. Edit the `var nodes_map` in cfc_config.gd in the "Behaviour Constants" section, to point to your board and other container scenes (Deck, discard etc)

4. Edit the pile_names and hand_names arrays with the names of your respective piles (deck, discard etc) and hand(s).


### Card class

The below instructions will set up your game to use the `Card` class as a framework for card handling.

1. Extend your card root node's script, from the Card class. If your card scene's root node is not an Area2D, modify the CardTemplate to extend the correct node type

    `extends Card`

   This will allow you to keep your custom code clean, while benefiting from the framework functionality.

   It will also make it easy to upgrade your framework by just copying more recent versions of CardTemplate.gd.

4. If you're not using the provided CardTemplate.tcsn, then the following nodes inside CardTemplate.tcsn are mandatory. Place them in the same indentation and with the same name. Nodes with an asterisk next to their name can be modified to a different type but have to retain their name.
	* Area2D
	* CollisionShape2D
	* Control* (Has to always be a Control-type node)
	* Tween node called "Tween"

If you want a different setup, you will need to modify the relevant code yourself
### Hand Class

The Hand class retains cards face up in an organized fashion. Card which detect being in a Hand container, will always attempt to keep themselves sorted.

The below instructions will set up your game to use the `Hand` class as a framework for hand handling. 

2. Extend your hand's script (attached to your Area2D root node) from the Hand class

   `extends Hand`

2. Connect your card-draw signal to the Hand node and make it call the `draw_card()` (see the Deck.tcsn node for a sample of such a signal)

4. If you're not using the provided Hand.tcsn, then the following nodes inside CardTemplate.tcsn are mandatory. Place them in the same indentation and with the same name. Nodes with an asterisk next to their name can be modified to a different type but have to retain their name.
	* Area2D
	* CollisionShape2D node
	* Control* (Has to always be a Control-type node)
	* ManipulationButtons
	* Tween
	

### Pile Class

The Pile class keeps child cards hidden and acts as a stack from which to pick or put out-of-play cards

The below instructions will set up your game to use the `Pile` class as a framework for pile handling.

2. Extend your pile's script (attached to your Area2D root node) from the Hand class

   `extends Pile`

1. If you're not using the provided Container.tcsn to instance new piles, then you need to add the following nodes. The indentation of the below points the hierarchy of the nodes you need to add, starting with scene root.
	* Area2D
	* CollisionShape2D node
	* Control* (Has to always be a Control-type node)
	* ManipulationButtons
	* Tween


### Board Class

The Board class is keeping track of cards in-play, but also provides some Unit Testing functionality.

The below instructions will set up your game to use the `Board` class as a framework for you main play area (i.e. the play "board").

2. Extend your board script from the Board class

   `extends Board`

1. If you're not using the provided Board.tcsn, then all you need to do is add a Node2D in the root of your game. 

Of course without instancing a few Hand or Pile objects, there won't be anything you can do.

### Viewport Focus

The framework includes two forms of showing details about a card. One is simply to scale up a the card a bit while in hand, and the other is to pop-up a new viewport with a copy of the card object in it.

By default the game has both active, but the viewport focus requires a bit more extensive setup to be usable by your game. Specifically you need to setup a parent scene which utilizes multiple viewports.

If you do not already have anything like this, you can simply use the Main.tcsn scene as a template and modify accordingly. The framework will utilize it automatically if it detects a Main.tcsn as the root.

If you do not want or need the viewport focus, then simply ignore it. However you'll need to make sure table cards are legible as they are since there's no other good way to get a closeup of them without viewports

### Unit Testing

Do the following if you want to use/import the provided unit tests

1. [install Gut](https://github.com/bitwes/Gut/wiki/Install) and do the relevant setup, if you don't have it already.
2. If you followed the standard Gut instructions, you should have already have created the tests folder, copy the test_*.gd from /tests/unit inside your own `res://tests/unit`.
3. Edit TestVars.gd and modify the boardScene const to point to the root board (i.e. where the cards are played) of your game.
4. You need to use the Board class on the root of your game or you need to copy the code inside BoardTemplate.tcsn into your own board (at there's necessary Unit Testing code in there)

## Easy Customation

The classes provide some easy customization options, such as how the card move, where they appear etc
Check the "Behaviour Constants" header at the start of the cfc_config singleton.
For more fine customization, you'll need to modify manually


## Provided features

* Tween animations that look good for card movements.
* Automatic zoom-in on cards when moused over.
* Automatic re-arranging of hand as cards are added or removed.
* Drag & Drop
* Option for multiple hands and piles
* Larger image of card when moving mouse cursor over it
* Pop-up buttons for predefined functions

## Credits

Some initial ideas were taken from this excellent [Godot Card Game Tutorial video series](https://www.youtube.com/watch?v=WjT5sLMD7Kw). This framework uses some of the concepts but also attempts to create better quality code in the process.