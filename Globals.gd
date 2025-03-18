extends Node

var focused_piece = null #keep track of piece your cursor is on

var detail_mode = false #mode that shows you details

var ignore_clicks = false #so we dont burn map

var bomb_clicked = false #dont show saper after failing even once
var saper_count = 0 #adds 1 for every good square in saper. after 8 destroy bombs effect

var undraggable = false #cant drag on non euclidean map
var trapped = false #cant drag while eaten

var crawl_mode = false #hills mode
var fire_mode = false #works the same as crawl mode but with different reset and bgm

var treasure = false #got map piece from event strzalkowy
var ptak_event = false #got map piece from ptak event
var map_saved = false #got map piece from flame minigame

var kontynuuj = false #load from menu

var reset_dark = false #reseting from dark map

var map_state_log : Array = [] #all previous map states

#variables saved between playthroughs
var lapa_gained = false #after acquiring lapa it stays on you

var return_trapped = false #after trapping return it stays trapped

var first_enter = true
var first_restart = true
var say_restart = false

var wypalenia = 0 #after 3 wypalenia spawn a message once

var map_pieces = {"blue": false, "dark": false, "flame": false, "non_euclidean": false,
				  "ptak_event": false, "saper": false, "strzalki": false, "wide_map": false} #cel gry xD


