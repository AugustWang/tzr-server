var ajax = new Ajax();
set_loading_info = function(useTime, maxSpeed, minSpeed) {
	ajax.invoke("get", "/user/collect.php?ac=load&load=" + useTime + "&max="+maxSpeed+"&min="+minSpeed, "", null);
}
set_req_map_info = function(time) {
	ajax.invoke("get", "/user/collect.php?ac=e_q_t", "", null);
}
set_rtn_map_info = function(time) {
	ajax.invoke("get", "/user/collect.php?ac=e_r_t", "", null);
}
set_move = function() {
	ajax.invoke("get", "/user/collect.php?ac=move", "", null);
}
open_npc = function(id) {
	ajax.invoke("get", "/user/collect.php?ac=npc&npc_id=" + id, "", null);
}
welcome = function() {
	ajax.invoke("get", "/user/collect.php?ac=welcome", "", null);
}
weapon = function() {
	ajax.invoke("get", "/user/collect.php?ac=weapon", "", null);
}
monster = function(id) {
	ajax.invoke("get", "/user/collect.php?ac=monster&id=" + id, "", null);
}
open_bag = function() {
	ajax.invoke("get", "/user/collect.php?ac=open_bag", "", null);
}
dead = function() {
	ajax.invoke("get", "/user/collect.php?ac=dead", "", null);
}
relive = function() {
	ajax.invoke("get", "/user/collect.php?ac=relive", "", null);
}
levelup = function() {
	ajax.invoke("get", "/user/collect.php?ac=levelup", "", null);
}
finish_m = function(id) {
	ajax.invoke("get", "/user/collect.php?ac=finish_m&id=" + id, "", null);
}
accept_m = function(id) {
	ajax.invoke("get", "/user/collect.php?ac=accept_m&id=" + id, "", null);
}
click_m = function(id) {
	ajax.invoke("get", "/user/collect.php?ac=click_m&id=" + id, "", null);
}
learn_skill = function(id) {
	ajax.invoke("get", "/user/collect.php?ac=learn_skill&id=" + id, "", null);
}
open_skill = function() {
	ajax.invoke("get", "/user/collect.php?ac=open_skill", "", null);
}