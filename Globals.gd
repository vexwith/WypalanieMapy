extends Node

var focused_piece = null #keep track of piece your cursor is on

var ignore_clicks = false #so we dont burn map

var bomb_clicked = false #dont show saper after failing even once
var saper_count = 0 #adds 1 for every good square in saper. after 8 destroy bombs effect

var undraggable = false #cant drag on non euclidean map
var trapped = false

var crawl_mode = false #hills mode

#variables saved between playthroughs
var lapa_gained = false #after acquiring lapa it stays on you

var return_trapped = false #after trapping return it stays trapped

var first_enter = true
var first_restart = true
var say_restart = false

var map_pieces = {"saper": false, "non_euclidean": false, "strzalki": false, "hills": false} #cel gry xD

