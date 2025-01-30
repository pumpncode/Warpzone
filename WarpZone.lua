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
SMODS.Atlas {key = "modicon", path = "wzicon.png", px = 32, py = 32}
SMODS.Atlas({key = 'guestapp', path = 'guest.png', px = 71, py = 95})

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
    rarity = 2,
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
    pos = { x = 0, y = 0 },
    cost = 8,
    calculate = function(self, card, context)
        if context.joker_main and card.ability.transform == 1 then
            SMODS.calculate_effect({
                message = localize { type = 'variable', key = 'a_chips', vars = {25}},
                chip_mod = 25,
                colour = G.C.CHIPS
            }, card)
            SMODS.calculate_effect({
                message = localize { type = 'variable', key = 'a_mult', vars = {20}},
                mult_mod = 20, 
                colour = G.C.MULT
            }, card)
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
            SMODS.calculate_effect({
                message = "Tax",
                colour = G.C.RED
            }, card)
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
            "{C:inactive}(currently {C:mult}+#1# {C:inactive}Mult){}"
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
        
        if context.after and context.cardarea == G.jokers and not context.blueprint then
		    if(G.GAME.chips + (hand_chips * mult) < G.GAME.blind.chips) then
                card.ability.mult = card.ability.mult + 1
                return {
                    message = "+" .. tostring(card.ability.mult) .. " Mult",
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
        
        if context.after and context.cardarea == G.jokers and not context.blueprint then
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
SMODS.Joker {
    key = "votv",
    name = "Voices of the Void",
    atlas = 'Wzone',
    loc_txt = {
        name = "Voices of the Void",
        text = {
            "Grants {C:attention}bonuses{} to {C:attention}3 cards{}",
            "every round when scored",
            "{C:attention}#4# of #1#{}: {C:chips}+303{} Chips",
            "{C:attention}#5# of #2#{}: {C:mult}+42{} Mult",
            "{C:attention}#6# of #3#{}: {X:mult,C:white}X3.14{} Mult"
        }
    },
    unlocked = true,
    discovered = true,
    eternal_compat = true,
    perishable_compat = true,
    blueprint_compat = true,
    rarity = 3,
    pos = { x = 1, y = 2 },
    cost = 8,
    config = { 
        suit = { 
            suit1 = "Spades",
            suit2 = "Spades",
            suit3 = "Spades"
        },
        rank = {
            rank1 = "Ace",
            rank2 = "Ace",
            rank3 = "Ace"
        },
    },
    loc_vars = function(self, info_queue, card)
        return {
            vars = {card.ability.suit.suit1, card.ability.suit.suit2, card.ability.suit.suit3, card.ability.rank.rank1, card.ability.rank.rank2, card.ability.rank.rank3}
        }
    end,
    set_ability = function(self, card, initial, delay_sprites)
    local suits = { "Spades", "Hearts", "Clubs", "Diamonds" }
		for i = 1, 3 do
			local randomValue = math.ceil(pseudorandom('votv') * 4)
			card.ability.suit["suit" .. i] = suits[randomValue]
		end
    local ranks = { [1] = "Ace", [11] = "Jack", [12] = "Queen", [13] = "King" }
		for i = 1, 3 do
			local randomRank = math.ceil(pseudorandom('votv') * 13)
			card.ability.rank["rank" .. i] = ranks[randomRank] or tostring(randomRank)
		end
	end,
	calculate = function(self, card, context)
	if context.end_of_round and not context.repetition and context.game_over == false then
		local suits = { "Spades", "Hearts", "Clubs", "Diamonds" }
			for i = 1, 3 do
				local randomValue = math.ceil(pseudorandom('votv') * 4)
				card.ability.suit["suit" .. i] = suits[randomValue]
			end
		local ranks = { [1] = "Ace", [11] = "Jack", [12] = "Queen", [13] = "King" }
			for i = 1, 3 do
				local randomRank = math.ceil(pseudorandom('votv') * 13)
				card.ability.rank["rank" .. i] = ranks[randomRank] or tostring(randomRank)
			end
		end
	if context.individual and context.cardarea == G.play then
		if context.other_card:is_suit(card.ability.suit.suit1) and ((card.ability.rank.rank1 == "Ace" and context.other_card:get_id() == 1) or (card.ability.rank.rank1 == "Jack" and context.other_card:get_id() == 11) or (card.ability.rank.rank1 == "Queen" and context.other_card:get_id() == 12) or (card.ability.rank.rank1 == "King" and context.other_card:get_id() == 13) or context.other_card:get_id() == tonumber(card.ability.rank.rank1)) then
			SMODS.calculate_effect({
                message = localize { type = 'variable', key = 'a_chips', vars = {303}},
                chip_mod = 303,
                colour = G.C.CHIPS
            },context.other_card)
		end
		if context.other_card:is_suit(card.ability.suit.suit2) and ((card.ability.rank.rank2 == "Ace" and context.other_card:get_id() == 1) or (card.ability.rank.rank2 == "Jack" and context.other_card:get_id() == 11) or (card.ability.rank.rank2 == "Queen" and context.other_card:get_id() == 12) or (card.ability.rank.rank2 == "King" and context.other_card:get_id() == 13) or context.other_card:get_id() == tonumber(card.ability.rank.rank2)) then
			SMODS.calculate_effect({
                message = localize { type = 'variable', key = 'a_mult', vars = {42}},
                mult_mod = 42, 
                colour = G.C.MULT
            },context.other_card)
		end
		if context.other_card:is_suit(card.ability.suit.suit3) and ((card.ability.rank.rank3 == "Ace" and context.other_card:get_id() == 1) or (card.ability.rank.rank3 == "Jack" and context.other_card:get_id() == 11) or (card.ability.rank.rank3 == "Queen" and context.other_card:get_id() == 12) or (card.ability.rank.rank3 == "King" and context.other_card:get_id() == 13) or context.other_card:get_id() == tonumber(card.ability.rank.rank3)) then
			return {
                x_mult = 3.14,
                colour = G.C.RED,
				card = context.other_card
            }
		end
	end
end
}
SMODS.Joker {
    key = "ironclad",
    name = "Ruby Key",
    atlas = 'Wzone',
    loc_txt = {
        name = "Ruby Key",
        text = {
            "When bought, turns into a",
			"random {C:attention}Ironclad consumable{}",
			"{C:inactive}(can only be bought once, must have room){}"
        }
    },
	no_pool_flag = 'ironclad_bought',
    unlocked = true,
    discovered = true,
    eternal_compat = false,
    perishable_compat = false,
    blueprint_compat = false,
    rarity = 2,
    pos = { x = 2, y = 2 },
    cost = 5,
    add_to_deck = function(self, card, from_debuff)
		play_sound('tarot1')
		card:start_dissolve()
		if #G.consumeables.cards + G.GAME.consumeable_buffer < G.consumeables.config.card_limit then
			G.GAME.pool_flags.ironclad_bought = true
			G.GAME.consumeable_buffer = G.GAME.consumeable_buffer + 1
            local ironcladcons = create_card('GuestAppearance', G.consumeables, nil, nil, nil, nil, nil)
            ironcladcons:add_to_deck()
            G.consumeables:emplace(ironcladcons)
            G.GAME.consumeable_buffer = 0
			end
		end,
}
SMODS.Joker {
    key = "chcard",
    name = "Character Card",
    atlas = 'Wzone',
    loc_txt = {
        name = "Character Card",
        text = {
            "Randomly gains, {C:money}${}, {C:chips}Chips{}, {C:mult}Mult{}",
            "and {X:mult,C:white}XMult{} when beating a {C:attention}Blind{}",
			"according to its {C:attention}difficulty{}",
            "{C:inactive}(Currently {C:chips}+#1#{C:inactive}/{C:mult}+#2#{C:inactive}/{X:mult,C:white}X#3#{C:inactive}){}"
        }
    },
    unlocked = true,
    discovered = true,
    eternal_compat = true,
    perishable_compat = true,
    blueprint_compat = true,
    rarity = 1,
    pos = { x = 3, y = 2 },
    cost = 6,
    config = {
        chips = 0,
        mult = 0,
        xmult = 1
    },
    loc_vars = function(self, info_queue, card)
        return {
            vars = {card.ability.chips, card.ability.mult, card.ability.xmult}
        }
    end,
    calculate = function(self, card, context)
        if context.joker_main and card.ability.chips > 0 then
            SMODS.calculate_effect({
                message = localize { type = 'variable', key = 'a_chips', vars = {card.ability.chips}},
                chip_mod = card.ability.chips,
                colour = G.C.CHIPS
            }, card)
        end
        if context.joker_main and card.ability.mult > 0 then
            SMODS.calculate_effect({
                message = localize { type = 'variable', key = 'a_mult', vars = {card.ability.mult}},
                mult_mod = card.ability.mult, 
                colour = G.C.MULT
            }, card)
        end
        if context.joker_main and card.ability.mult > 1 then
            return {
                Xmult_mod = card.ability.xmult,
                message = localize { type = 'variable', key = 'a_xmult', vars = { card.ability.xmult } }
            }
        end
		
		if context.end_of_round and not context.repetition and context.game_over == false and not context.blueprint then
			local diff
			if G.GAME.blind:get_type() == "Small" then
				diff = 1
			elseif G.GAME.blind:get_type() == "Big" then
				diff = 2
			else
				diff = 4
			end
			for i=1, diff do
				local random = math.ceil(pseudorandom('chcard', 1, 4))
				if random == 1 then
					local randomvalue = math.ceil(pseudorandom('chcard', 1, 10))
					card.ability.chips = card.ability.chips + randomvalue
					SMODS.calculate_effect({
						message = "+" .. tostring(randomvalue) .. " Chips", 
					}, card)
				elseif random == 2 then
					local randomvalue = (math.ceil(pseudorandom('chcard', 1, 4)))/2
					card.ability.mult = card.ability.mult + randomvalue
					SMODS.calculate_effect({
						message = "+" .. tostring(randomvalue) .. " Mult", 
					}, card)
				elseif random == 3 then
					local randomvalue = (math.ceil(pseudorandom('chcard', 1, 4)))/20
					card.ability.xmult = card.ability.xmult + randomvalue
					SMODS.calculate_effect({
						message = "X" .. tostring(randomvalue) .. " Mult", 
					}, card)
				else
					SMODS.calculate_effect({
						dollars = 1, 
					}, card)
				end
			end
		end
	
    end
}

SMODS.ConsumableType {
    key = 'GuestAppearance',
    primary_colour = HEX('c32a2a'),
    secondary_colour = HEX('902e2e'),
    loc_txt = {
        ["name"] = 'Guest Consumable',
        ["collection"] = 'Guest Appearances',
        ["undiscovered"] = {
            ["name"] = 'Not Discovered',
            ["text"] = {
                [1] = 'Purchase or use',
                [2] = 'this card in an',
                [3] = 'unseeded run to',
                [4] = 'learn what it does'
            }
        }
    }
}

SMODS.Consumable{
    set = 'GuestAppearance',
	atlas = 'guestapp',
    key = 'fiendfire',
	loc_txt = {
        name = "Fiend Fire",
        text = {
            "Choose one card, destroy all others",
			"and create a {C:dark_edition}Negative {C:attention}\"Joker\"{}",
			"with {C:mult}Mult bonus{} equal to half the",
			"{C:attention}total ranks{} of all destroyed cards",
        }
    },
	pos = { x = 0, y = 0 },
	can_use = function(self, card)
    if G.hand and (G.hand.highlighted and #G.hand.highlighted == 1) then
        return true
    end    
end,    
use = function(self, card)
	local totalrank = 0
        for i = 1, #G.hand.cards do
            local is_highlighted = false
            for j = 1, #G.hand.highlighted do
                if G.hand.cards[i] == G.hand.highlighted[j] then
                    is_highlighted = true
                    break
                end
            end
            if not is_highlighted then
				totalrank = totalrank + G.hand.cards[i]:get_id()
                G.hand.cards[i]:start_dissolve()
            end
        end
	local custom_jimbo = create_card("Joker", G.jokers, nil, nil, nil, nil, "j_joker")
			custom_jimbo:set_edition({negative = true})
			custom_jimbo.ability.mult = totalrank / 2
            custom_jimbo:add_to_deck()
            G.jokers:emplace(custom_jimbo)
end
}
SMODS.Consumable{
    set = 'GuestAppearance',
	atlas = 'guestapp',
    key = 'bloodletting',
	loc_txt = {
        name = "Bloodletting",
        text = {
            "Gain {C:attention}+1{} hand size",
			"all required scores",
			"are increased by {C:attention}6%{}"
        }
    },
	pos = { x = 1, y = 0 },
	can_use = function(self, card)
        return true 
end,    
use = function(self, card)
	G.hand:change_size(1)
	G.GAME.starting_params.ante_scaling = (G.GAME.starting_params.ante_scaling / 100) * (100 + 6)
	G.GAME.blind.chip_text = number_format(G.GAME.blind.chips)
    G.HUD_blind:get_UIE_by_ID('HUD_blind_count').UIBox:recalculate()
	play_sound('holo1', 1.2 + math.random()*0.1, 0.4)
end
}
SMODS.Consumable{
    set = 'GuestAppearance',
	atlas = 'guestapp',
    key = 'armaments',
	loc_txt = {
        name = "Armaments",
        text = {
            "Add {C:chips}+5{} Chips and a random",
			"{C:attention}enhancement{}, {C:attention}seal{} and",
			"{C:attention}edition{} to {C:attention}1{} selected card",
        }
    },
	pos = { x = 2, y = 0 },
	can_use = function(self, card)
    if G.hand and (G.hand.highlighted and #G.hand.highlighted == 1) then
        return true
    end    
end,    
use = function(self, card)
	local seals = {"Blue","Red","Gold","Purple"}
	local edition = poll_edition('armament',nil,true,true)
	G.hand.highlighted[1]:set_ability(G.P_CENTERS[SMODS.poll_enhancement({guaranteed = true})])
	G.hand.highlighted[1]:set_seal(seals[pseudorandom('armaments', 1, 4)], nil, true)
	G.hand.highlighted[1]:set_edition(edition,true)
	G.hand.highlighted[1].ability.perma_bonus = G.hand.highlighted[1].ability.perma_bonus + 5
end
}

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