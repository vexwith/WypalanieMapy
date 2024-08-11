extends Node

var focused_piece = null #keep track of piece your cursor is on

var ignore_clicks = false #so we dont burn map

var saper_count = 0 #adds 1 for every good square in saper. after 8 destroy bombs effect

#variables saved between playthroughs
var lapa_gained = false #after acquiring lapa it stays on you
