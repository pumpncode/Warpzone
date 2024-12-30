--- STEAMODDED HEADER
--- MOD_NAME: Warp Zone!
--- MOD_ID: Wzone
--- MOD_AUTHOR: [Freh]
--- MOD_DESCRIPTION: Adds interesting and unique jokers based on references.
--- DEPENDENCIES: [Steamodded>=1.0.0~ALPHA-0812d]
--- BADGE_COLOR: c9052b
--- PREFIX: Wzon
----------------------------------------------
------------MOD CODE -------------------------

-- Creates an atlas for cards to use
SMODS.Atlas {
    -- Key for code to find it with
    key = "Wzone",
    -- The name of the file, for the code to pull the atlas from
    path = "jokers.png",
    -- Width of each sprite in 1x size
    px = 71,
    -- Height of each sprite in 1x size
    py = 95
}

SMODS.Joker {
    key = "aluber",
    name = "Aluber the Jester",
    atlas = 'Wzone',
    loc_txt = {
        name = "Aluber the Jester",
        text = {
            "you shouldn't be reading this"
        }
    },
    unlocked = true,
    discovered = true,
    eternal_compat = true,
    perishable_compat = true,
    blueprint_compat = true,
    rarity = 3,
    config = {
        transform = 0,
    },
    loc_vars = function(self, info_queue, card)
        if card.ability.transform == 0 then
            info_queue[#info_queue+1] = { set = 'Other', key = 'masquerade_reminder' }
            return {
                vars = {card.ability.transform},
                key = 'aluberbase', set = 'Joker'
            }
        else
            return {
                vars = {card.ability.transform},
                key = 'masquerade', set = 'Joker'
            }
        end
    end,
    -- Which atlas key to pull from.
    pos = { x = 0, y = 0 },
    -- Cost of card in shop.
    cost = 8,
    -- The functioning part of the joker, looks at context to decide what step of scoring the game is on, and then gives a 'return' value if something activates.
    calculate = function(self, card, context)
        if context.joker_main and card.ability.transform == 1 then
            SMODS.eval_this(card, {
                message = localize { type = 'variable', key = 'a_chips', vars = {25}},
                chip_mod = 25,
                colour = G.C.CHIPS
            })
            SMODS.eval_this(card, {
                message = localize { type = 'variable', key = 'a_mult', vars = {20}},
                mult_mod = 20, 
                colour = G.C.MULT
            })
        end

        if context.first_hand_drawn and card.ability.transform == 0 and not context.blueprint then
            local eval = function() return G.GAME.current_round.discards_used == 0 and not G.RESET_JIGGLES end
            juice_card_until(card, eval, true)
        end

        if context.discard and card.ability.transform == 0 and not context.blueprint then
            if G.GAME.current_round.discards_used <= 0 and #context.full_hand == 1 then
                card:flip()
                card.ability.transform = 1
                card:flip()
                return {
                    message = "Transform",
                    delay = 0.45, 
                    remove = true,
                    card = card
                }
            end
        end
        
        if context.before and card.ability.transform == 1 then
            SMODS.eval_this(card, {
                message = "Tax",
                colour = G.C.RED
            })
        end

        if context.individual then
            if context.cardarea == G.play and card.ability.transform == 1 then
                local taxedchips = (G.GAME.blind.chips * 0.992)
                G.GAME.blind.chips = taxedchips
                G.GAME.blind.chip_text = number_format(G.GAME.blind.chips)
                G.HUD_blind:get_UIE_by_ID('HUD_blind_count').UIBox:recalculate()
                --card:juice_up()
            end
        end

        if context.end_of_round and card.ability.transform == 1 and not context.blueprint then
            card:flip()
            card.ability.transform = 0
            card:flip()
            return {
                message = "Transform"
            }
        end
    end,

    update = function(self, card)
        if card.ability.transform == 1 then
            card.children.center:set_sprite_pos({x=1, y=0})
        else
            card.children.center:set_sprite_pos({x=0, y=0})
        end
    end
}
SMODS.Joker {
    key = "meatboy",
    name = "Meat Boy",
    atlas = 'Wzone',
    loc_txt = {
        name = "Meat Boy",
        text = {
            "{C:mult}+1{} Mult per hand played", 
            "without beating the blind",
            "{C:inactive}currently {C:mult}+#1# {C:inactive}Mult{}"
        }
    },
    unlocked = true,
    discovered = true,
    eternal_compat = true,
    perishable_compat = true,
    blueprint_compat = true,
    rarity = 1,
    config = {
        mult = 0,
    },
    loc_vars = function(self, info_queue, card)
        return {
            vars = {card.ability.mult}
        }
    end,
    pos = { x = 2, y = 0 },
    cost = 5,
    calculate = function(self, card, context)
        if context.joker_main and card.ability.mult > 0 then
            return {
                mult_mod = card.ability.mult,
                message = localize { type = 'variable', key = 'a_mult', vars = { card.ability.mult } }
            }
        end
        
        if context.after and context.cardarea == G.jokers then
		    if(G.GAME.chips + (hand_chips * mult) < G.GAME.blind.chips) then
                card.ability.mult = card.ability.mult + 1
                return {
                    message = '+1 Mult',
                    card = card
                }
			end
        end
    end
}
SMODS.Joker {
    key = "malganis",
    name = "Big Scary Demon",
    atlas = 'Wzone',
    loc_txt = {
        name = "Big Scary Demon",
        text = {
            "You cannot die", 
            "{C:green}#1# in 2{} chance to",
            "turn into a turtle",
			"at end of round"
        }
    },
    unlocked = true,
    discovered = true,
    eternal_compat = false,
    perishable_compat = true,
    blueprint_compat = false,
    rarity = 2,
    config = {
        turtle = false,
    },
    loc_vars = function(self, info_queue, card)
	    if not card.ability.turtle then
			return {
				vars = {G.GAME.probabilities.normal}
			}
		else
			return {
				{vars = {G.GAME.probabilities.normal}},
				key = 'turtle', set = 'Joker'
				}
		end
    end,
    pos = { x = 3, y = 0 },
    cost = 5,
    calculate = function(self, card, context)
        if context.game_over and not card.ability.turtle then
		    if pseudorandom('malganis') < G.GAME.probabilities.normal / 2 then
			    card:flip()
				card.ability.turtle = true
				card:flip()
				return {
                    message = "Turtle",
					saved = true,
                    delay = 0.45,
                    card = card,
                }
			else
            return {
                        message = "Safe",
                        saved = true,
                        colour = G.C.RED
                    }
			end
        end
        
        if context.end_of_round and not context.repetition and context.game_over == false and not card.ability.turtle then
		    if pseudorandom('malganis') < G.GAME.probabilities.normal / 2 then
			    card:flip()
				card.ability.turtle = true
				card:flip()
                return {
                    message = "Turtle",
                    delay = 0.45,
                    card = card,
                }
			else
			    return {
                    message = "Safe",
                    delay = 0.45,
                    card = card,
                }
			end
	    end	
    end,
	update = function(self, card)
        if card.ability.turtle then
            card.children.center:set_sprite_pos({x=4, y=0})
        else
            card.children.center:set_sprite_pos({x=3, y=0})
        end
    end
}
SMODS.Joker {
    key = "wwreason",
    name = "War Without Reason",
    atlas = 'Wzone',
    loc_txt = {
        name = "War Without Reason",
        text = {
            "Gains {X:mult,C:white}X0.1{} Mult every", 
            "time played hand beats",
            "your {C:attention}best hand{}",
			"{C:inactive}(Currently {X:mult,C:white}X#1#{}{C:inactive} Mult)",
			"{C:inactive}(score to beat: {}{C:attention}#2#{}{C:inactive}){}"
        }
    },
    unlocked = true,
    discovered = true,
    eternal_compat = true,
    perishable_compat = true,
    blueprint_compat = true,
    rarity = 3,
    config = {
        xmult = 1,
		score = 0,
    },
    loc_vars = function(self, info_queue, card)
        return {
            vars = {card.ability.xmult,card.ability.score}
        }
    end,
    pos = { x = 0, y = 1 },
    cost = 8,
    calculate = function(self, card, context)
        if context.joker_main then
            return {
                Xmult_mod = card.ability.xmult,
                message = localize { type = 'variable', key = 'a_xmult', vars = { card.ability.xmult } }
            }
        end
        
        if context.after and context.cardarea == G.jokers then
		    if hand_chips * mult > card.ability.score then
                card.ability.xmult = card.ability.xmult + 0.1
				card.ability.score = hand_chips * mult
                return {
                    message = 'Upgrade!',
                    card = card
                }
			end
        end
    end
}
SMODS.Joker {
    key = "stack",
    name = "Stack",
    atlas = 'Wzone',
    loc_txt = {
        name = "Stack",
        text = {
            "{C:dark_edition}+1{} Joker slot"
        }
    },
    unlocked = true,
    discovered = true,
    eternal_compat = true,
    perishable_compat = true,
    blueprint_compat = false,
    rarity = 2,
    pos = { x = 1, y = 1 },
    cost = 3,
    add_to_deck = function(self, card, from_debuff)
		G.jokers.config.card_limit = G.jokers.config.card_limit + 1
		end,
	remove_from_deck = function(self, card, from_debuff)
		G.jokers.config.card_limit = G.jokers.config.card_limit - 1
		end
}
SMODS.Joker {
    key = "unocard",
    name = "Uno Card",
    atlas = 'Wzone',
    loc_txt = {
        name = "One Card",
        text = {
            "If {C:attention}final hand{} of round is",
            "a {C:attention}High Card{}, destroy all",
            "unplayed cards in hand"
        }
    },
    unlocked = true,
    discovered = true,
    eternal_compat = true,
    perishable_compat = true,
    blueprint_compat = false,
    rarity = 2,
    pos = { x = 2, y = 1 },
    cost = 5,
    config = {
        color = 0,
    },
    set_ability = function(self, card, initial, delay_sprites)
        card.ability.color = (pseudorandom('unocard') * 4)
    end,
    update = function(self, card)
        if card.ability.color <= 1 then
            card.children.center:set_sprite_pos({x=2, y=1})
        elseif card.ability.color <= 2 then
            card.children.center:set_sprite_pos({x=3, y=1})
        elseif card.ability.color <= 3 then
            card.children.center:set_sprite_pos({x=4, y=1})
        else
            card.children.center:set_sprite_pos({x=0, y=2})
        end
    end,
    calculate = function(self, card, context)
        if context.cardarea == G.hand and G.GAME.current_round.hands_left == 0 and context.scoring_name == "High Card" then
            for i = 1, #G.hand.cards do
                G.hand.cards[i]:start_dissolve()
            end
        end
    end
}


function SMODS.INIT.Warpzone()
G.localization.descriptions.Other["masquerade_reminder"] = {
        name = "Masquerade the Blazing Dragon", --tooltip name
       text = {
           "{C:chips}+25{} Chips",
           "{C:mult}+20{} Mult",
           "Reduces blind by 0.8%",
		   "for every scoring card"
       }
   }
   
G.localization.descriptions.Joker['aluberbase'] =  {
        name = 'Aluber the Jester',
        text = {"If {C:attention}first discard{} of round", 
            "has only {C:attention}1{} card, destroy",
            "it and {C:attention}transform{} this card",
			"for the remainder of the blind"
			},
    }
	
G.localization.descriptions.Joker['masquerade'] =  {
        name = 'Masquerade the Blazing Dragon',
        text = {"{C:chips}+25{} Chips", 
            "{C:mult}+20{} Mult",
            "Reduces blind by 0.8%",
			"for every scoring card"
			},
    }
	
G.localization.descriptions.Joker['turtle'] =  {
        name = 'A Turtle',
        text = {"Not eternal"
			},
    }
end
