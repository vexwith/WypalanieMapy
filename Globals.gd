extends Node

var focused_piece = null #keep track of piece your cursor is on

var ignore_clicks = false #so we dont burn map

var bomb_clicked = false #dont show saper after failing even once
var saper_count = 0 #adds 1 for every good square in saper. after 8 destroy bombs effect

var undraggable = false #cant drag on non euclidean map

var crawl_mode = false #hills mode

#variables saved between playthroughs
var lapa_gained = false #after acquiring lapa it stays on you

var first_enter = true
var first_restart = true
var say_restart = false

var map_pieces = 0 #cel gry xD

