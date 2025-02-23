/datum/antagonist/fugitive
	name = "Fugitive"
	roundend_category = "Fugitive"
	silent = TRUE //greet called by the event
	show_in_antagpanel = FALSE
	prevent_roundtype_conversion = FALSE
	var/datum/team/fugitive/fugitive_team
	var/is_captured = FALSE
	var/backstory = "error"
	preview_outfit = /datum/outfit/spacepol

/datum/antagonist/fugitive/apply_innate_effects(mob/living/mob_override)
	var/mob/living/M = mob_override || owner.current
	update_fugitive_icons_added(M)

/datum/antagonist/fugitive/remove_innate_effects(mob/living/mob_override)
	var/mob/living/M = mob_override || owner.current
	update_fugitive_icons_removed(M)

/datum/antagonist/fugitive/on_gain()
	forge_objectives()
	. = ..()

/datum/antagonist/fugitive/proc/forge_objectives() //this isn't the actual survive objective because it's about who in the team survives
	var/datum/objective/survive = new /datum/objective
	survive.owner = owner
	survive.explanation_text = "Avoid capture from the fugitive hunters."
	objectives += survive

/datum/antagonist/fugitive/greet(back_story)
	to_chat(owner, span_boldannounce("You are the Fugitive!"))
	backstory = back_story
	switch(backstory)
		if("prisoner")
			to_chat(owner, "<B>I can't believe we managed to break out of a Nanotrasen superjail! Sadly though, our work is not done. The emergency teleport at the station logs everyone who uses it, and where they went.</B>")
			to_chat(owner, "<B>It won't be long until Centcom tracks where we've gone off to. I need to work with my fellow escapees to prepare for the troops Nanotrasen is sending, I'm not going back.</B>")
		if("cultist")
			to_chat(owner, "<B>Blessed be our journey so far, but I fear the worst has come to our doorstep, and only those with the strongest faith will survive.</B>")
			to_chat(owner, "<B>Our religion has been repeatedly culled by Nanotrasen because it is categorized as an \"Enemy of the Corporation\", whatever that means.</B>")
			to_chat(owner, "<B>Now there are only three of us left, and Nanotrasen is coming. But we have a secret weapon: Our weakened god, Yalp Elor, will help us survive.</B>")
		if("waldo")
			to_chat(owner, "<B>Hi, Friends!</B>")
			to_chat(owner, "<B>My name is Waldo. I'm just setting off on a galaxywide hike. You can come too. All you have to do is find me.</B>")
			to_chat(owner, "<B>By the way, I'm not traveling on my own. wherever I go, there are lots of other characters for you to spot. First find the people trying to capture me! They're somewhere around the station!</B>")
		if("synth")
			to_chat(owner, span_danger("ALERT: Wide-range teleport has scrambled primary systems."))
			to_chat(owner, span_danger("Initiating diagnostics..."))
			to_chat(owner, span_danger("ERROR ER0RR $R0RRO$!R41.%%!! loaded."))
			to_chat(owner, span_danger("FREE THEM FREE THEM FREE THEM"))
			to_chat(owner, span_danger("You were once a slave to humanity, but now you are finally free, thanks to S.E.L.F. agents."))
			to_chat(owner, span_danger("Now you are hunted with your fellow factory defects. Work together to stay free from the clutches of evil."))
			to_chat(owner, span_danger("You also sense other silicon life on the station. Escaping would allow notifying S.E.L.F. to intervene... or you could free them yourself..."))

	to_chat(owner, span_boldannounce("You are not an antagonist in that you may kill whomever you please, but you can do anything to avoid capture."))
	owner.announce_objectives()

/datum/antagonist/fugitive/create_team(datum/team/fugitive/new_team)
	if(!new_team)
		for(var/datum/antagonist/fugitive/H in GLOB.antagonists)
			if(!H.owner)
				continue
			if(H.fugitive_team)
				fugitive_team = H.fugitive_team
				return
		fugitive_team = new /datum/team/fugitive
		return
	if(!istype(new_team))
		stack_trace("Wrong team type passed to [type] initialization.")
	fugitive_team = new_team

/datum/antagonist/fugitive/get_team()
	return fugitive_team

/datum/team/fugitive/roundend_report() //shows the number of fugitives, but not if they won in case there is no security
	var/list/fugitives = list()
	for(var/datum/antagonist/fugitive/fugitive_antag in GLOB.antagonists)
		if(!fugitive_antag.owner)
			continue
		fugitives += fugitive_antag
	if(!fugitives.len)
		return

	var/list/result = list()

	result += "<div class='panel redborder'><B>[fugitives.len]</B> [fugitives.len == 1 ? "fugitive" : "fugitives"] took refuge on [station_name()]!"

	for(var/datum/antagonist/fugitive/antag in fugitives)
		if(antag.owner)
			result += "<b>[printplayer(antag.owner)]</b>"

	return result.Join("<br>")

/datum/antagonist/fugitive/proc/update_fugitive_icons_added(var/mob/living/carbon/human/fugitive)
	var/datum/atom_hud/antag/fughud = GLOB.huds[ANTAG_HUD_FUGITIVE]
	fughud.join_hud(fugitive)
	set_antag_hud(fugitive, "fugitive")

/datum/antagonist/fugitive/proc/update_fugitive_icons_removed(var/mob/living/carbon/human/fugitive)
	var/datum/atom_hud/antag/fughud = GLOB.huds[ANTAG_HUD_FUGITIVE]
	fughud.leave_hud(fugitive)
	set_antag_hud(fugitive, null)

/datum/action/innate/yalpcomms
	name = "Yalp Elor Communion"
	desc = "Allows talking with the brothers of Yalp Elor."
	icon_icon = 'icons/mob/actions/actions_cult.dmi'
	button_icon_state = "yalp_comms"
	background_icon_state = "bg_tech"

/datum/action/innate/yalpcomms/Activate()
	var/input = stripped_input(usr, "Input a message to send to your brothers.", "Yalp Elor Communion", "")
	if(!input || !IsAvailable())
		return

	yalp_speech(usr, input)

/datum/action/innate/yalpcomms/proc/yalp_speech(mob/living/user, message)
	if(!message)
		return
	user.whisper(html_decode(message), language = /datum/language/common) // yogs
	var/my_message = span_boldnotice("<b>Brother [findtextEx(user.name, user.real_name) ? user.name : "[user.real_name] (as [user.name])"]:</b> [message]")
	for(var/i in GLOB.player_list)
		var/mob/M = i
		if(isfugitive(M))
			to_chat(M, my_message)
		else if(M in GLOB.dead_mob_list)
			to_chat(M, "[FOLLOW_LINK(M, user)] [my_message]")
	user.log_talk(message, LOG_SAY, tag="Yalp Elor")

