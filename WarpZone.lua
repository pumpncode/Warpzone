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
SMODS.Atlas({key = 'disco', path = 'disco.png', px = 71, py = 95})
SMODS.Atlas({key = 'enhancers', path = 'enhancers.png', px = 71, py = 95})
SMODS.Atlas({key = 'stickers', path = 'stickers.png', px = 71, py = 95})

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
		fullblind = 0,
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
			card.ability.fullblind = G.GAME.blind.chips
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
        if context.individual then
            if context.cardarea == G.play and card.ability.transform == 1 then
                G.E_MANAGER:add_event(Event({trigger = 'after',delay = 0.1,func = function()
                    G.GAME.blind.chips = math.floor(G.GAME.blind.chips - ( card.ability.fullblind * 0.008))
                    G.GAME.blind.chip_text = number_format(G.GAME.blind.chips)
                    
                    local chips_UI = G.hand_text_area.blind_chips
                    G.FUNCS.blind_chip_UI_scale(G.hand_text_area.blind_chips)
                    G.HUD_blind:recalculate() 
                    chips_UI:juice_up()
					card:juice_up()
                    if not silent then play_sound('chips2') end
                    return true end }))
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
		if context.blueprint then return end
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
    rarity = 2,
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
	pixel_size = { w = 60, h = 95},
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
		if context.blueprint then return end
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
    rarity = 2,
    pos = { x = 1, y = 2 },
    cost = 5,
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
			local randomValue = math.ceil(pseudorandom('votv', 0.0000000000000000001, 4))
			card.ability.suit["suit" .. i] = suits[randomValue]
		end
    local ranks = { [1] = "Ace", [11] = "Jack", [12] = "Queen", [13] = "King" }
		for i = 1, 3 do
			local randomRank = math.ceil(pseudorandom('votv', 0.0000000000000000001, 13))
			card.ability.rank["rank" .. i] = ranks[randomRank] or tostring(randomRank)
		end
	end,
	calculate = function(self, card, context)
	if context.end_of_round and not context.repetition and context.game_over == false then
		local suits = { "Spades", "Hearts", "Clubs", "Diamonds" }
			for i = 1, 3 do
				local randomValue = math.ceil(pseudorandom('votv', 0.0000000000000000001, 4))
				card.ability.suit["suit" .. i] = suits[randomValue]
			end
		local ranks = { [1] = "Ace", [11] = "Jack", [12] = "Queen", [13] = "King" }
			for i = 1, 3 do
				local randomRank = math.ceil(pseudorandom('votv', 0.0000000000000000001, 13))
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
				card = card
            }
		end
	end
end
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
	pixel_size = { w = 60, h = 60},
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
				diff = 2
			elseif G.GAME.blind:get_type() == "Big" then
				diff = 4
			else
				diff = 6
			end
			for i=1, diff do
				local random = math.ceil(pseudorandom('chcard', 0.0000000000000000001, 5))
				if random == 1 then
					local randomvalue = math.ceil(pseudorandom('chcard', 0.0000000000000000001, 10))
					card.ability.chips = card.ability.chips + randomvalue
					SMODS.calculate_effect({
						message = "+" .. tostring(randomvalue) .. " Chips", 
					}, card)
				elseif random == 3 then
					local randomvalue = (math.ceil(pseudorandom('chcard', 0.0000000000000000001, 4)))/2
					card.ability.mult = card.ability.mult + randomvalue
					SMODS.calculate_effect({
						message = "+" .. tostring(randomvalue) .. " Mult", 
					}, card)
				elseif random == 5 then
					local randomvalue = (math.ceil(pseudorandom('chcard', 0.0000000000000000001, 4)))/20
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
SMODS.Joker {
    key = "discojoker",
    name = "What Kind of Joker Are You?",
    atlas = 'disco',
    loc_txt = {
        name = "What Kind of Joker Are You?",
        text = {
            "Effect {C:attention}changes{} after every hand",
			"played, efficacy depends on",
			"{C:green}random Dice Score{}"
        }
    },
    unlocked = true,
    discovered = true,
    eternal_compat = true,
    perishable_compat = true,
    blueprint_compat = true,
    rarity = 3,
	loc_vars = function(self, info_queue, card)
		if card.ability.skill.type ~= 0 then
		local totalbonus = 0
			if (card.ability.skill.type == 4 or card.ability.skill.type == 5) and card.ability.skill.attribute == 1 then
				local joker_count = 0
				for i = 1, #G.jokers.cards do
					local current = G.jokers.cards[i].label
					if string.find(string.lower(current), "joker") then
						joker_count = joker_count + 1
					end
				end
				totalbonus = card.ability.dice.bonus + joker_count - 1
			else
				totalbonus = card.ability.dice.bonus
			end
			if card.ability.skill.type == 3 and card.ability.skill.attribute == 3 then
				info_queue[#info_queue+1] =  {key = 'e_negative_consumable', set = 'Edition', config = {extra = 1}}
			end
			if card.ability.skill.type == 4 or card.ability.skill.type == 5 then
				if card.ability.skill.attribute == 1 then
					info_queue[#info_queue+1] = {key = 'e_negative', set = 'Edition', config = {extra = 1}}
				end
			end
			
			info_queue[#info_queue + 1] = {
							set = "Other",
							key = 'discostats',
							specific_vars = {(card.ability.dice.die1+card.ability.dice.die2),totalbonus,(card.ability.dice.die1+card.ability.dice.die2+totalbonus),card.ability.extra.mult,card.ability.extra.chips}, --table of the variable you want to pass on in the info_queue
						}
		end
	    local skill_matrix = {
		[1] = { [1] = 'logic', [2] = 'volition', [3] = 'endurance', [4] = 'handeye' },
		[2] = { [1] = 'encyclopedia', [2] = 'inlandempire', [3] = 'painthreshold', [4] = 'perception' },
		[3] = { [1] = 'rhetoric', [2] = 'empathy', [3] = 'physicalinstrument', [4] = 'reactionspeed' },
		[4] = { [1] = 'drama', [2] = 'authority', [3] = 'electrochemistry', [4] = 'savoirfaire' },
		[5] = { [1] = 'conceptualization', [2] = 'espritdecorps', [3] = 'shivers', [4] = 'interfacing' },
		[6] = { [1] = 'visualcalculus', [2] = 'suggestion', [3] = 'halflight', [4] = 'composure' }
		}

		local skill_type = card.ability.skill.type
		local skill_attribute = card.ability.skill.attribute

		if skill_matrix[skill_type] and skill_matrix[skill_type][skill_attribute] then
			return {
				key = skill_matrix[skill_type][skill_attribute],
				set = 'Joker'
			}
		end
	end,
	config = { 
        skill = { 
            type = 0,
            attribute = 0
        },
        dice = {
            die1 = 0,
            die2 = -3,
			bonus = 0
        },
		extra = { 
            chips = 0,
            mult = 0,
			money = 0
        },
		switch = 0,
		empathydiscard = 0,
    },
    pos = { x = 0, y = 0 },
	soul_pos = { x = 0, y = 1 },
    cost = 5,
	update = function(self, card)
		card.children.center:set_sprite_pos({x=card.ability.skill.type, y=card.ability.skill.attribute})
		card.children.floating_sprite:set_sprite_pos({x=card.ability.dice.die1, y=card.ability.dice.die2+4})
	end,
    add_to_deck = function(self, card, from_debuff)
		card.ability.skill.type = math.ceil(pseudorandom('discojoker', 0.0000000000000000001, 6))
		card.ability.skill.attribute = math.ceil(pseudorandom('discojoker', 0.0000000000000000001, 4))
		if next(SMODS.find_card('j_oops')) then
			card.ability.dice.die1 = 6
			card.ability.dice.die2 = 6
		else
			card.ability.dice.die1 = math.ceil(pseudorandom('discojoker', 0.0000000000000000001, 6))
			card.ability.dice.die2 = math.ceil(pseudorandom('discojoker', 0.0000000000000000001, 6))
		end
	end,
	calc_dollar_bonus = function(self, card)
		local bonus = card.ability.extra.money
		card.ability.extra.money = 0
		if bonus > 0 then return bonus end
	end,
	calculate = function(self, card, context)
		if context.joker_main then
			if card.ability.extra.chips > 0 then
				SMODS.calculate_effect({
					message = localize { type = 'variable', key = 'a_chips', vars = {card.ability.extra.chips}},
					chip_mod = card.ability.extra.chips,
					colour = G.C.CHIPS
				}, card)
			end
			if card.ability.extra.mult > 0 then
				SMODS.calculate_effect({
					message = localize { type = 'variable', key = 'a_mult', vars = {card.ability.extra.mult}},
					mult_mod = card.ability.extra.mult, 
					colour = G.C.MULT
				}, card)
			end
			if card.ability.skill.type == 6 and card.ability.skill.attribute == 3 then
				return {
                Xmult_mod = (card.ability.dice.die1 + card.ability.dice.die2 + card.ability.dice.bonus)/4,
                message = localize { type = 'variable', key = 'a_xmult', vars = { (card.ability.dice.die1 + card.ability.dice.die2 + card.ability.dice.bonus)/4 } }
				}
			end
		end
		if context.before then
			if next(context.poker_hands['Pair']) and #context.scoring_hand == 2 and not context.blueprint and card.ability.skill.type == 1 and card.ability.skill.attribute == 2 then
				G.E_MANAGER:add_event(Event({trigger = 'after',delay = 0.1,func = function()
					copy_card(context.scoring_hand[2],context.scoring_hand[1])
					context.scoring_hand[1] = context.scoring_hand[2]
				return true end}))
			elseif card.ability.skill.type == 2 and card.ability.skill.attribute == 2 then
				local _card = copy_card(context.scoring_hand[math.ceil(pseudorandom('discojoker', 0.0000000000000000001, #context.scoring_hand))], nil, nil, G.playing_card)
				if card.ability.dice.die1 + card.ability.dice.die2 + card.ability.dice.bonus >= 9 then
							local edition = poll_edition('discojoker',nil,true,true)
							_card:set_edition(edition, true)
						end
				_card:add_to_deck()
				G.deck.config.card_limit = G.deck.config.card_limit + 1
				table.insert(G.playing_cards, _card)
				G.hand:emplace(_card)
				_card.states.visible = nil
				G.E_MANAGER:add_event(Event({
					func = function()
						_card:start_materialize()
						return true
					end
				})) 
			return {
				message = localize('k_copied_ex'),
				colour = G.C.CHIPS,
				card = card,
				playing_cards_created = {true}
			}
			elseif card.ability.skill.type == 4 and card.ability.skill.attribute == 2 and next(context.poker_hands['Straight']) and card.ability.dice.die1 + card.ability.dice.die2 + card.ability.dice.bonus >= 4 then
				local lowest
			local lowestvalue = 999
			for i = 1, #context.scoring_hand do
				if context.scoring_hand[i].base.id < lowestvalue then
					lowestvalue = context.scoring_hand[i].base.id
					lowest = i
				end
			end
			context.scoring_hand[lowest].ability.perma_bonus = context.scoring_hand[lowest].ability.perma_bonus or 0
			context.scoring_hand[lowest].destroy_me_pls = true
			for i = 1, #context.scoring_hand do
				if context.scoring_hand[i] ~= context.scoring_hand[lowest] then
					context.scoring_hand[i].ability.perma_bonus = context.scoring_hand[i].ability.perma_bonus or 0
					context.scoring_hand[i].ability.perma_bonus = context.scoring_hand[i].ability.perma_bonus + context.scoring_hand[lowest].base.nominal + context.scoring_hand[lowest].ability.perma_bonus
					SMODS.calculate_effect({
						extra = {message = localize('k_upgrade_ex'), colour = G.C.CHIPS},
						colour = G.C.CHIPS,
						}, context.scoring_hand[i])
				end
			end
			print(context.scoring_hand[lowest])
			elseif card.ability.skill.type == 6 and card.ability.skill.attribute == 2 then
				if card.ability.dice.die1 + card.ability.dice.die2 + card.ability.dice.bonus >= 8 then
					context.scoring_hand[math.ceil(pseudorandom('discojoker', 0.0000000000000000001, #context.scoring_hand))]:set_seal(SMODS.poll_seal({guaranteed = true, type_key = seal_type}))
					return {
                        message = "Success!",
                    }
				else
					card.ability.dice.bonus = card.ability.dice.bonus + 1
					return {
                        message = "Failure!",
                    }
				end
			elseif card.ability.skill.type == 1 and card.ability.skill.attribute == 3 then
				if card.ability.dice.die1 + card.ability.dice.die2 + card.ability.dice.bonus >= 30 then
					G.GAME.round_resets.hands = G.GAME.round_resets.hands + 1
					ease_hands_played(1)
					SMODS.calculate_effect({
						message = "Success!", 
					}, card)
				else
					card.ability.dice.bonus = card.ability.dice.bonus + 2
					SMODS.calculate_effect({
						message = "Failure!", 
					}, card)
				end
			elseif card.ability.skill.type == 2 and card.ability.skill.attribute == 3 then
				if card.ability.dice.die1 + card.ability.dice.die2 + card.ability.dice.bonus >= 18 then
					G.GAME.round_resets.discards = G.GAME.round_resets.discards + 1
					ease_discard(1)
					SMODS.calculate_effect({
						message = "Success!", 
					}, card)
				else
					card.ability.dice.bonus = card.ability.dice.bonus + 1
					SMODS.calculate_effect({
						message = "Failure!", 
					}, card)
				end
			elseif card.ability.skill.type == 1 and card.ability.skill.attribute == 4 then
				if card.ability.dice.die1 + card.ability.dice.die2 + card.ability.dice.bonus >= 20 then
					G.hand:change_size(1)
					SMODS.calculate_effect({
						message = "Success!", 
					}, card)
				else
					card.ability.dice.bonus = card.ability.dice.bonus + 1
					SMODS.calculate_effect({
						message = "Failure!", 
					}, card)
				end
			elseif card.ability.skill.type == 5 and card.ability.skill.attribute == 3 then
				if card.ability.dice.die1 + card.ability.dice.die2 + card.ability.dice.bonus >= 10 then
					G.E_MANAGER:add_event(Event({
						func = (function()
						add_tag(Tag('tag_ethereal'))
						play_sound('generic1', 0.9 + math.random()*0.1, 0.8)
						play_sound('holo1', 1.2 + math.random()*0.1, 0.4)
						return true
						end)
						}))
					SMODS.calculate_effect({
						message = "Success!", 
					}, card)
				else
					SMODS.calculate_effect({
						message = "Failure!", 
					}, card)
				end
			elseif 
				card.ability.skill.type == 4 and card.ability.skill.attribute == 4 then
					if card.ability.dice.die1 + card.ability.dice.die2 + card.ability.dice.bonus >= 10 then
						SMODS.calculate_effect({
							message = "Success!", 
							}, card)
						for k, v in ipairs(context.scoring_hand) do
							if v.ability.set ~= "Enhanced" then
								v:set_ability(G.P_CENTERS[SMODS.poll_enhancement({guaranteed = true})])
							end
						end
					else
						SMODS.calculate_effect({
							message = "Failure!", 
							}, card)
					end
			elseif card.ability.skill.type == 2 and card.ability.skill.attribute == 4 then
				if card.ability.dice.die1 + card.ability.dice.die2 + card.ability.dice.bonus >= 4 and #G.consumeables.cards + G.GAME.consumeable_buffer < G.consumeables.config.card_limit then
					for i = 1, G.consumeables.config.card_limit - #G.consumeables.cards - G.GAME.consumeable_buffer do
						local world = create_card('Tarot', G.consumeables, nil, nil, nil,true,'c_world')
						world:add_to_deck()
						G.consumeables:emplace(world)
						G.GAME.consumeable_buffer = 0
						SMODS.calculate_effect({
						message = "Success!", 
					}, card)
					end
				elseif card.ability.dice.die2 + card.ability.dice.bonus <= 4 then
					card.ability.dice.bonus = card.ability.dice.bonus + 3
					SMODS.calculate_effect({
						message = "Failure!", 
					}, card)
				end
			elseif card.ability.skill.type == 5 and card.ability.skill.attribute == 4 and #G.consumeables.cards + G.GAME.consumeable_buffer < G.consumeables.config.card_limit then
				local planet
				card:juice_up()
				if card.ability.dice.die1 + card.ability.dice.die2 + card.ability.dice.bonus <= 7 then
					planet = create_card('Planet', G.consumeables, nil, nil, nil, nil, nil)
				elseif card.ability.dice.die1 + card.ability.dice.die2 + card.ability.dice.bonus <= 14 then
					local _handname, _played, _order = 'High Card', -1, 100
					for k, v in pairs(G.GAME.hands) do
						if v.played > _played or (v.played == _played and _order > v.order) then
							_played = v.played
							_handname = k
						end
					end
					for k, v in pairs(G.P_CENTER_POOLS.Planet) do
						if v.config.hand_type == _handname then
							planet = create_card('Planet', G.consumeables, nil, nil, nil, true, v.key)
						end
					end
				else
					planet = create_card('Spectral', G.consumeables, nil, nil, nil, true, 'c_black_hole')
				end
				planet:add_to_deck()
				G.consumeables:emplace(planet)
				G.GAME.consumeable_buffer = 0
			elseif card.ability.skill.type == 6 and card.ability.skill.attribute == 4 then
				local _handname, _played, _order = 'High Card', -1, 100
				for k, v in pairs(G.GAME.hands) do
					if v.played > _played or (v.played == _played and _order > v.order) then
						_played = v.played
						_handname = k
					end
				end
				if next(context.poker_hands[_handname]) then
					card.ability.extra.mult = card.ability.extra.mult + card.ability.dice.die1 + card.ability.dice.die2 + card.ability.dice.bonus
					SMODS.calculate_effect({
						message = "Upgrade", 
					}, card)
				end
			end
		end
		if context.before and context.cardarea == G.jokers then
			if card.ability.skill.type == 2 and card.ability.skill.attribute == 1 then
				if card.ability.dice.die1 + card.ability.dice.die2 + card.ability.dice.bonus >= 7 then
					card.ability.extra.chips = card.ability.extra.chips + 20
					SMODS.calculate_effect({
						message = "Success!", 
					}, card)
				else
					card.ability.dice.bonus = card.ability.dice.bonus + 1
					SMODS.calculate_effect({
						message = "Failure!", 
					}, card)
				end
			elseif (card.ability.skill.type == 4 or card.ability.skill.type == 5) and card.ability.skill.attribute == 1 then
				local joker_count = 0
				for i = 1, #G.jokers.cards do
					local current = G.jokers.cards[i].label
					if string.find(string.lower(current), "joker") then
						joker_count = joker_count + 1
					end
				end
				if card.ability.skill.type == 4 and joker_count + card.ability.dice.die1 + card.ability.dice.die2 + card.ability.dice.bonus - 1 >= 12 then
					local nega_jimbo = create_card("Joker", G.jokers, nil, nil, nil, nil, "j_joker")
					nega_jimbo:set_edition({negative = true})
					nega_jimbo:add_to_deck()
					G.jokers:emplace(nega_jimbo)
					SMODS.calculate_effect({
						message = "Success!", 
					}, card)
				elseif card.ability.skill.type == 5 and joker_count + card.ability.dice.die1 + card.ability.dice.die2 + card.ability.dice.bonus - 1 >= 20 then
					local nega_abstract = create_card("Joker", G.jokers, nil, nil, nil, nil, "j_abstract")
					nega_abstract:set_edition({negative = true})
					nega_abstract:add_to_deck()
					G.jokers:emplace(nega_abstract)
					SMODS.calculate_effect({
						message = "Success!", 
					}, card)
				else
					SMODS.calculate_effect({
						message = "Failure!", 
					}, card)
				end
			elseif card.ability.skill.type == 3 and card.ability.skill.attribute == 2 then
				if card.ability.empathydiscard == 1 then
					card.ability.empathydiscard = 0
				else
					card.ability.extra.mult = card.ability.extra.mult + card.ability.dice.die1 + card.ability.dice.die2 + card.ability.dice.bonus
				SMODS.calculate_effect({
						message = "Upgrade", 
					}, card)
				end
			end
		end
		if context.after and context.cardarea == G.jokers then
			if (G.GAME.chips + (hand_chips * mult) > G.GAME.blind.chips) and card.ability.skill.type == 1 and card.ability.skill.attribute == 1 then
				card.ability.extra.mult = card.ability.extra.mult + card.ability.dice.die1 + card.ability.dice.die2 + card.ability.dice.bonus
				SMODS.calculate_effect({
						message = "Upgrade", 
					}, card)
			end
			if card.ability.skill.type == 5 and card.ability.skill.attribute == 2 then
				card.ability.extra.money = card.ability.dice.die1 + card.ability.dice.die2 + card.ability.dice.bonus
				SMODS.calculate_effect({
						message = "Success!", 
					}, card)
			end
			card.ability.switch = 1
		end
		if context.discard then
			if card.ability.skill.type == 3 and card.ability.skill.attribute == 1 then
				if #context.full_hand == 1 then
					card.ability.dice.bonus = card.ability.dice.bonus + 1
					if card.ability.dice.die1 + card.ability.dice.die2 + card.ability.dice.bonus >= 10 then
						return {
						message = "Upgrade",
						delay = 0.45, 
						remove = true,
						card = card
						}
					else
						return {
						message = "Upgrade",
						delay = 0.45,
						card = card
						}
					end
				end
			elseif card.ability.skill.type == 3 and card.ability.skill.attribute == 2 then
				card.ability.empathydiscard = 1
				return {
					message = "Failure!",
					}
			end
		end
		if context.individual and context.cardarea == G.play then
			if card.ability.skill.type == 6 and card.ability.skill.attribute == 1 then
				context.other_card.ability.perma_bonus = context.other_card.ability.perma_bonus or 0
				context.other_card.ability.perma_bonus = context.other_card.ability.perma_bonus + card.ability.dice.die1 + card.ability.dice.die2 + card.ability.dice.bonus
				return {
					extra = {message = localize('k_upgrade_ex'), colour = G.C.CHIPS},
					colour = G.C.CHIPS,
					card = card
				}
			end
		end
		if context.hand_drawn and card.ability.switch == 1 then
			card.ability.switch = 0
			if hand_chips then
				if hand_chips * mult < G.GAME.blind.chips/5 and not (card.ability.skill.type == 6 and card.ability.skill.attribute == 3)then
					card.ability.skill.type = 6
					card.ability.skill.attribute = 3
				else
				card.ability.skill.type = math.ceil(pseudorandom('discojoker', 0.0000000000000000001, 6))
				card.ability.skill.attribute = math.ceil(pseudorandom('discojoker', 0.0000000000000000001, 4))
				end
			else
				card.ability.skill.type = math.ceil(pseudorandom('discojoker', 0.0000000000000000001, 6))
				card.ability.skill.attribute = math.ceil(pseudorandom('discojoker', 0.0000000000000000001, 4))
			end
			if next(SMODS.find_card('j_oops')) then
				card.ability.dice.die1 = 6
				card.ability.dice.die2 = 6
			else
				card.ability.dice.die1 = math.ceil(pseudorandom('discojoker', 0.0000000000000000001, 6))
				card.ability.dice.die2 = math.ceil(pseudorandom('discojoker', 0.0000000000000000001, 6))
			card:juice_up()
			end
		end
		if context.game_over and card.ability.skill.type == 1 and card.ability.skill.attribute == 2 then
			if card.ability.dice.die1 + card.ability.dice.die2 + card.ability.dice.bonus >= 12 then
				return {
                        message = "Success!",
                        saved = true,
                    }
			else
				return {
                        message = "Failure!",
                    }
			end
		end
		if context.selling_card then
			if context.card.config.center_key == 'j_burglar' then
				card.ability.skill.type = 5
				card.ability.skill.attribute = 2
				card.ability.switch = 0
				card:juice_up()
			elseif context.card.ability.consumeable and card.ability.skill.type == 4 and card.ability.skill.attribute == 3 then
				card.ability.skill.type = 1
				card.ability.skill.attribute = 2
				card.ability.switch = 0
				card:juice_up()
			end
		end
		if context.using_consumeable then
			if card.ability.skill.type == 3 and card.ability.skill.attribute == 3 and card.ability.dice.die1 + card.ability.dice.die2 + card.ability.dice.bonus >= 8 and not (context.consumeable.edition and context.consumeable.edition.negative) then
				local negconsumeable = copy_card(context.consumeable)
				negconsumeable:set_edition({negative = true})
				negconsumeable:add_to_deck()
				G.consumeables:emplace(negconsumeable)
				card.ability.dice.die1 = math.ceil(pseudorandom('discojoker', 0.0000000000000000001, 6))
				card.ability.dice.die2 = math.ceil(pseudorandom('discojoker', 0.0000000000000000001, 6))
				card:juice_up()
				return {
                        message = "Copied"
                    }
			elseif card.ability.skill.type == 4 and card.ability.skill.attribute == 3 then
				card.ability.extra.chips = card.ability.extra.chips + card.ability.dice.die1 + card.ability.dice.die2 + card.ability.dice.bonus
				return {
						message = "Upgrade",
						delay = 0.45,
						card = card
						}
			end
		end
		if context.pre_discard and card.ability.skill.type == 3 and card.ability.skill.attribute == 4 then
			local upgradetimes = 1
			local text,disp_text = G.FUNCS.get_poker_hand_info(G.hand.highlighted)
			local _handname, _played, _order = 'High Card', -1, 100
			for k, v in pairs(G.GAME.hands) do
				if v.played > _played or (v.played == _played and _order > v.order) then
				_played = v.played
				_handname = k
				end
			end
			if _handname == text then
				if (card.ability.dice.die1 + card.ability.dice.die2 + card.ability.dice.bonus)/10 >= 1 then
					upgradetimes = math.floor((card.ability.dice.die1 + card.ability.dice.die2 + card.ability.dice.bonus)/10 + 0.5)
				end
				card_eval_status_text(context.blueprint_card or card, 'extra', nil, nil, nil, {message = localize('k_upgrade_ex')})
				for i = 1, upgradetimes do
					update_hand_text({sound = 'button', volume = 0.7, pitch = 0.8, delay = 0.3}, {handname=localize(text, 'poker_hands'),chips = G.GAME.hands[text].chips, mult = G.GAME.hands[text].mult, level=G.GAME.hands[text].level})
					level_up_hand(context.blueprint_card or card, text, nil, 1)
				end
			update_hand_text({sound = 'button', volume = 0.7, pitch = 1.1, delay = 0}, {mult = 0, chips = 0, handname = '', level = ''})
            card.ability.switch = 1
			end
			if context.destroying_card then
				print(context.destroying_card.destroy_me_pls)
			end
		end
		if context.destroying_card and context.destroying_card.destroy_me_pls then
			return {
					remove = true
				}
		end
	end		
}
SMODS.Joker {
    key = "horn",
    name = "Joker's Horn",
    atlas = 'Wzone',
    loc_txt = {
        name = "Joker's Horn",
        text = {
            "Last played card gives",
			"{X:chips,C:white}X2{} Chips when scored",
        }
    },
	pixel_size = { w = 50, h = 93},
    unlocked = true,
    discovered = true,
    eternal_compat = true,
    perishable_compat = true,
    blueprint_compat = true,
    rarity = 1,
    pos = { x = 4, y = 2 },
    cost = 4,
    calculate = function(self, card, context)
    if context.individual and context.cardarea == G.play then
        if context.other_card == context.scoring_hand[#context.scoring_hand] then
			return {
				xchips = 2,
				card = card
				}
			end
		end
	end 

}
SMODS.Joker {
    key = "hollowness",
    name = "Hollowness",
    atlas = 'Wzone',
    loc_txt = {
        name = "Hollowness",
        text = {
            "After {C:attention}2{} rounds, sell",
			"this card to make all",
			"cards in hand {C:dark_edition}Negative{}",
			"{C:inactive}(Currently {C:attention}#1#{C:inactive}/2)"
        }
    },
	config = {loyalty_remaining = 0
	},
	loc_vars = function(self, info_queue, card)
		info_queue[#info_queue+1] =  {key = 'e_negative_playing_card', set = 'Edition', config = {extra = 1}}
		return {
            vars = {card.ability.loyalty_remaining}
        }
	end,
    unlocked = true,
    discovered = true,
    eternal_compat = false,
    perishable_compat = true,
    blueprint_compat = false,
    rarity = 3,
    pos = { x = 0, y = 3 },
    cost = 6,
	calculate = function(self, card, context)
		if context.blueprint then return end
		if (context.first_hand_drawn or context.open_booster) and card.ability.loyalty_remaining >= 2 then
            local eval = function() return G.hand and not G.RESET_JIGGLES end
            juice_card_until(card, eval, true)
        end
		if context.end_of_round and context.main_eval and not context.repetition then
			if card.ability.loyalty_remaining < 2 then
			card.ability.loyalty_remaining = card.ability.loyalty_remaining + 1
				return {
				message = tostring(card.ability.loyalty_remaining)  ..  "/2",
				}
			end
		end
		if context.selling_self and card.ability.loyalty_remaining >= 2 then
			if G.hand then
				for i = 1, #G.hand.cards do
					G.hand.cards[i]:set_edition({negative = true})
				end
			else
				return {
				message = "No Hand!",
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
	pixel_size = { w = 52, h = 73},
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
			local cardlist = {'c_Wzon_fiendfire','c_Wzon_bloodletting','c_Wzon_armaments'}
            local ironcladcons = create_card('GuestAppearance', G.consumeables, nil, nil, nil, nil, pseudorandom_element(cardlist))
            ironcladcons:add_to_deck()
            G.consumeables:emplace(ironcladcons)
            G.GAME.consumeable_buffer = 0
			end
		end,
}
SMODS.Joker {
    key = "silent",
    name = "Emerald Key",
    atlas = 'Wzone',
    loc_txt = {
        name = "Emerald Key",
        text = {
            "When bought, turns into a",
			"random {C:attention}Silent consumable{}",
			"{C:inactive}(can only be bought once, must have room){}"
        }
    },
	pixel_size = { w = 52, h = 73},
	no_pool_flag = 'silent_bought',
    unlocked = true,
    discovered = true,
    eternal_compat = false,
    perishable_compat = false,
    blueprint_compat = false,
    rarity = 2,
    pos = { x = 1, y = 3 },
    cost = 3,
    add_to_deck = function(self, card, from_debuff)
		play_sound('tarot1')
		card:start_dissolve()
		if #G.consumeables.cards + G.GAME.consumeable_buffer < G.consumeables.config.card_limit then
			G.GAME.pool_flags.silent_bought = true
			G.GAME.consumeable_buffer = G.GAME.consumeable_buffer + 1
			local cardlist = {'c_Wzon_distraction','c_Wzon_bouncingflask','c_Wzon_calculatedgamble'}
            local silentcons = create_card('GuestAppearance', G.consumeables, nil, nil, nil, nil, pseudorandom_element(cardlist))
            silentcons:add_to_deck()
            G.consumeables:emplace(silentcons)
            G.GAME.consumeable_buffer = 0
			end
		end,
}
SMODS.Joker {
    key = "defect",
    name = "Sapphire Key",
    atlas = 'Wzone',
    loc_txt = {
        name = "Sapphire Key",
        text = {
            "When bought, turns into a",
			"random {C:attention}Defect consumable{}",
			"{C:inactive}(can only be bought once, must have room){}"
        }
    },
	pixel_size = { w = 52, h = 73},
	no_pool_flag = 'defect_bought',
    unlocked = true,
    discovered = true,
    eternal_compat = false,
    perishable_compat = false,
    blueprint_compat = false,
    rarity = 2,
    pos = { x = 3, y = 3 },
    cost = 3,
    add_to_deck = function(self, card, from_debuff)
		play_sound('tarot1')
		card:start_dissolve()
		if #G.consumeables.cards + G.GAME.consumeable_buffer < G.consumeables.config.card_limit then
			G.GAME.pool_flags.defect_bought = true
			G.GAME.consumeable_buffer = G.GAME.consumeable_buffer + 1
			local cardlist = {'c_Wzon_zap','c_Wzon_coolheaded','c_Wzon_darkness'}
            local silentcons = create_card('GuestAppearance', G.consumeables, nil, nil, nil, nil, pseudorandom_element(cardlist))
            silentcons:add_to_deck()
            G.consumeables:emplace(silentcons)
            G.GAME.consumeable_buffer = 0
			end
		end,
}
SMODS.Joker {
    key = "exoticaceofspades",
    name = "Exotic Ace of Spades",
    atlas = 'Wzone',
    loc_txt = {
        name = "Exotic Ace of Spades",
        text = {
            "Retrigger all played cards",
			"with {C:spades}Spade{} suit",
			"Defeating a blind grants {C:dark_edition}Foil{}",
			"to your next {C:attention}#1#{} scoring cards",
			"{C:inactive}(can currently foil {C:attention}#2#{C:inactive} cards)"
        }
		,boxes = {2,3}
    },
	config = {how_many = 6, bullets = 0
	},
	loc_vars = function(self, info_queue, card)
		return {
            vars = {card.ability.how_many, card.ability.bullets}
        }
	end,
    unlocked = true,
    discovered = true,
    eternal_compat = true,
    perishable_compat = true,
    blueprint_compat = true,
    rarity = 2,
    pos = { x = 2, y = 3 },
    cost = 7,
	calculate = function(self, card, context)
		if context.cardarea == G.play and context.repetition and not context.repetition_only then
			if card.ability.bullets > 0 and not context.other_card.edition and not context.blueprint then
				card.ability.bullets = card.ability.bullets - 1
				local __card = context.other_card
				G.E_MANAGER:add_event(Event({trigger = 'after',delay = 0.3,func = function()
				card:juice_up()
                __card:set_edition({foil = true})
                return true end }))
				SMODS.calculate_effect({
						message = "Foil",
						colour = G.C.CHIPS,
						}, __card)
			end
			if context.other_card:is_suit("Spades") then
				return {
					message = 'Again!',
					repetitions = 1,
					card = card
				}
			end
		end
		if context.end_of_round and not context.blueprint and context.main_eval and not context.repetition then
			card.ability.bullets = card.ability.bullets + card.ability.how_many
			return {
					message = 'Memento Mori',
					colour = G.C.CHIPS,
					card = card
				}
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
			"and create a {C:dark_edition}Negative \"{C:attention}Joker{}\"",
			"with {C:mult}Mult bonus{} equal to half the",
			"{C:attention}total ranks{} of all destroyed cards",
        }
    },
	pos = { x = 0, y = 0 },
	can_use = function(self, card)
    if G.hand and (G.hand.highlighted and #G.hand.highlighted == 1) and #G.hand.cards > 1 then
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
	G.E_MANAGER:add_event(Event({trigger = 'after',delay = 0.2,func = function()
            G.hand:unhighlight_all();
        return true end }))
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
	local edition = poll_edition('armament',nil,true,true)
	G.hand.highlighted[1]:set_ability(G.P_CENTERS[SMODS.poll_enhancement({guaranteed = true})])
	G.hand.highlighted[1]:set_seal(SMODS.poll_seal({guaranteed = true, type_key = seal_type}))
	G.hand.highlighted[1]:set_edition(edition,true)
	G.hand.highlighted[1].ability.perma_bonus = G.hand.highlighted[1].ability.perma_bonus + 5
	G.E_MANAGER:add_event(Event({trigger = 'after',delay = 0.2,func = function()
            G.hand:unhighlight_all();
        return true end }))
end
}
SMODS.Consumable{
    set = 'GuestAppearance',
	atlas = 'guestapp',
    key = 'distraction',
	loc_txt = {
        name = "Distraction",
        text = {
            "{C:chips}+1{} hand this",
			"round, creates a",
			"random {C:attention}consumable"
        }
    },
	pos = { x = 3, y = 0 },
	can_use = function(self, card)
	if G.GAME.blind.in_blind then
        return true
	end
end,    
use = function(self, card)
	ease_hands_played(1)
	local randomcons = create_card('Consumeables', G.consumeables, nil, nil, nil, nil, nil)
    randomcons:add_to_deck()
    G.consumeables:emplace(randomcons)
	G.GAME.consumeable_buffer = 0
end
}
SMODS.Consumable{
    set = 'GuestAppearance',
	atlas = 'guestapp',
    key = 'bouncingflask',
	loc_txt = {
        name = "Bouncing Flask",
        text = {
            "Enhances {C:attention}1{} random card into",
			"a {C:attention}Poisonous Card 3{} times",
			"{C:inactive}(can improve already Poisonous Cards)"
        }
    },
	loc_vars = function(self, info_queue, card)
		info_queue[#info_queue+1] =  G.P_CENTERS.m_Wzon_poisonous
	end,
	pos = { x = 4, y = 0 },
	can_use = function(self, card)
    if G.hand then
		return true 
	end
end,    
use = function(self, card)
	local chosencard
	for i = 1, 3 do
		G.E_MANAGER:add_event(Event({trigger = 'after',delay = 0.1,func = function()
		chosencard = pseudorandom_element(G.hand.cards)
		chosencard:juice_up(0.3, 0.5)
		if chosencard.config.center and chosencard.config.center == G.P_CENTERS.m_Wzon_poisonous then
			if not chosencard.edition then
				chosencard:set_edition("e_foil",true)
			else
				if not chosencard.seal then
					chosencard:set_seal("Red",true)
				else
					chosencard.ability.perma_bonus = chosencard.ability.perma_bonus or 0
					chosencard.ability.perma_bonus = chosencard.ability.perma_bonus + 20
				end
			end
		else
			chosencard:set_ability("m_Wzon_poisonous")
		end
		return true end }))
	end
end
}
SMODS.Consumable{
    set = 'GuestAppearance',
	atlas = 'guestapp',
    key = 'calculatedgamble',
	loc_txt = {
        name = "Calculated Gamble",
        text = {
            "Gain {C:mult}+1{} discard",
        }
    },
	pos = { x = 5, y = 0 },
	can_use = function(self, card)
        return true 
end,    
use = function(self, card)
	G.GAME.round_resets.discards = G.GAME.round_resets.discards + 1
	ease_discard(1)
	play_sound('holo1', 1.2 + math.random()*0.1, 0.4)
end
}
SMODS.Consumable{
    set = 'GuestAppearance',
	atlas = 'guestapp',
    key = 'zap',
	loc_txt = {
        name = "Zap",
        text = {
            "Channel {C:attention}Lightning{} on {C:attention}1{}",
			"selected card or Joker"
        }
    },
	loc_vars = function(self, info_queue, card)
		info_queue[#info_queue+1] = {key = 'Wzon_lightning', set = 'Other'}
	end,
	pos = { x = 6, y = 0 },
	can_use = function(self, card)
        if ((G.hand and (G.hand.highlighted and #G.hand.highlighted == 1)) and not (G.jokers and (G.jokers.highlighted and #G.jokers.highlighted == 1))) or (not (G.hand and (G.hand.highlighted and #G.hand.highlighted == 1)) and (G.jokers and (G.jokers.highlighted and #G.jokers.highlighted == 1))) then
        return true
    end  
end,    
use = function(self, card)
	if #G.hand.highlighted == 1 then
		G.hand.highlighted[1]:juice_up()
		G.hand.highlighted[1]:add_sticker("Wzon_lightning", true)
		G.hand:unhighlight_all()
	else
		G.jokers.highlighted[1]:juice_up()
		G.jokers.highlighted[1]:add_sticker("Wzon_lightning", true)
		G.jokers:unhighlight_all()
	end
	play_sound('generic1', 0.9 + math.random()*0.1, 0.8)
end
}
SMODS.Consumable{
    set = 'GuestAppearance',
	atlas = 'guestapp',
    key = 'coolheaded',
	loc_txt = {
        name = "Coolheaded",
        text = {
            "Channel {C:attention}Frost{} on {C:attention}1{}",
			"selected card or Joker,",
			"draw {C:attention}1{} card"
        }
    },
	loc_vars = function(self, info_queue, card)
		info_queue[#info_queue+1] = {key = 'Wzon_frost', set = 'Other'}
	end,
	pos = { x = 7, y = 0 },
	can_use = function(self, card)
        if ((G.hand and (G.hand.highlighted and #G.hand.highlighted == 1)) and not (G.jokers and (G.jokers.highlighted and #G.jokers.highlighted == 1))) or (not (G.hand and (G.hand.highlighted and #G.hand.highlighted == 1)) and (G.jokers and (G.jokers.highlighted and #G.jokers.highlighted == 1))) then
        return true
    end  
end,    
use = function(self, card)
	if #G.hand.highlighted == 1 then
		G.hand.highlighted[1]:juice_up()
		G.hand.highlighted[1]:add_sticker("Wzon_frost", true)
		G.hand:unhighlight_all()
	else
		G.jokers.highlighted[1]:juice_up()
		G.jokers.highlighted[1]:add_sticker("Wzon_frost", true)
		G.jokers:unhighlight_all()
	end
	play_sound('generic1', 0.9 + math.random()*0.1, 0.8)
	if G.GAME.blind.in_blind then
		G.FUNCS.draw_from_deck_to_hand(1)
	end
end
}
SMODS.Consumable{
    set = 'GuestAppearance',
	atlas = 'guestapp',
    key = 'darkness',
	loc_txt = {
        name = "Darkness",
        text = {
            "Channel {C:attention}Dark{} on",
			"{C:attention}1{} selected Joker"
        }
    },
	loc_vars = function(self, info_queue, card)
		info_queue[#info_queue+1] = {key = 'Wzon_dark', set = 'Other'}
	end,
	pos = { x = 8, y = 0 },
	can_use = function(self, card)
        if G.jokers and (G.jokers.highlighted and #G.jokers.highlighted == 1) then
        return true
    end  
end,    
use = function(self, card)
	G.jokers.highlighted[1]:juice_up()
	G.jokers.highlighted[1]:add_sticker("Wzon_dark", true)
	G.jokers:unhighlight_all()
	play_sound('generic1', 0.9 + math.random()*0.1, 0.8)
end
}

local old_g_funcs_check_for_buy_space = G.FUNCS.check_for_buy_space --thank you More Fluff!
G.FUNCS.check_for_buy_space = function(card)
	if card.config.center_key == "j_Wzon_stack" then
		return true
	end
	if card.config.center_key == "j_Wzon_ironclad" or card.config.center_key == "j_Wzon_silent" or card.config.center_key == "j_Wzon_defect" then
		if #G.consumeables.cards + G.GAME.consumeable_buffer >= G.consumeables.config.card_limit then
			alert_no_space(card, G.consumeables)
			return false
		end
	end
	return old_g_funcs_check_for_buy_space(card)
end

SMODS.Enhancement{
    key = "poisonous",
    atlas = "enhancers",
    pos = {x = 0, y = 0},
    loc_txt={
        name="Poisonous Card",
        text = {
            "Reduces Blind by",
            "current amount of",
            "{C:chips}Chips{} when scored"
        }
    },
	in_pool = function(self)
        return false
    end,
	calculate = function(self,card,context)
        if context.main_scoring and context.cardarea == G.play then
			local chips_to_subtract = hand_chips
			G.E_MANAGER:add_event(Event({trigger = 'after',delay = 0.1,func = function()
                    G.GAME.blind.chips = G.GAME.blind.chips - chips_to_subtract
                    G.GAME.blind.chip_text = number_format(G.GAME.blind.chips)
                    
                    local chips_UI = G.hand_text_area.blind_chips
                    G.FUNCS.blind_chip_UI_scale(G.hand_text_area.blind_chips)
                    G.HUD_blind:recalculate() 
                    chips_UI:juice_up()
					card:juice_up()
                    if not silent then play_sound('chips2') end
                    return true end }))
		end
	end
}
SMODS.Sticker{
    key = "lightning",
    atlas = "stickers",
    pos = {x = 0, y = 0},
    loc_txt={
        name="Lightning",
		label="Lightning",
        text = {
            "{X:mult,C:white}X2{} Mult"
        }
    },
	default_compat = true,
	rate = 0,
	badge_colour = HEX("d0e029"),
	calculate = function(self,card,context)
        if (context.joker_main--[[post_joker]] and card.ability.set == "Joker") or (context.main_scoring and context.cardarea == G.play and (card.ability.set == 'Enhanced' or card.ability.set == 'Default')) then
			return {
                Xmult_mod = 2,
                message = localize { type = 'variable', key = 'a_xmult', vars = { 2 } }
            }
		end
	end
}
SMODS.Sticker{
    key = "frost",
    atlas = "stickers",
    pos = {x = 1, y = 0},
    loc_txt={
        name="Frost",
		label="Frost",
        text = {
            "{C:chips}+100{} Chips"
        }
    },
	default_compat = true,
	rate = 0,
	badge_colour = HEX("8deff0"),
	calculate = function(self,card,context)
        if (context.joker_main and card.ability.set == "Joker") or (context.main_scoring and context.cardarea == G.play and (card.ability.set == 'Enhanced' or card.ability.set == 'Default')) then
			return {
                chip_mod = 100,
				colour = G.C.CHIPS,
                message = localize { type = 'variable', key = 'a_chips', vars = { 100 } }
            }
		end
	end
}
SMODS.Sticker{
    key = "dark",
    atlas = "stickers",
    pos = {x = 2, y = 0},
    loc_txt={
        name="Dark",
		label="Dark",
        text = {
            "Sell the {C:attention}Joker{} this is applied",
			"to after two rounds to",
			"create a {C:dark_edition}Negative{} {C:attention}Joker{}",
			"of the same {C:attention}rarity{}"
        }
    },
	default_compat = true,
	rate = 0,
	badge_colour = HEX("b056df"),
	calculate = function(self,card,context)
		if context.before and not card.ability.darkorbturns then
			card.ability.darkorbturns = 0
		end
        if context.end_of_round and context.main_eval and not context.repetition and card.ability.darkorbturns < 2 then
			card.ability.darkorbturns = card.ability.darkorbturns + 1
			return {
				message = tostring(card.ability.darkorbturns)  ..  "/2",
				}
		elseif context.end_of_round and context.main_eval and card.ability.darkorbturns >= 2 then
			return {
				message = tostring(card.ability.darkorbturns)  ..  "/2",
				}
		end
		if context.selling_self and card.ability.darkorbturns and card.ability.darkorbturns >= 2 then
			local rarities = {"Common", "Uncommon", "Rare", "Legendary"}
			local _rarity = rarities[card.config.center.rarity]
			SMODS.add_card { set = 'Joker', rarity = _rarity, edition = "e_negative" }
		end
	end
}

G.localization.descriptions.Other["masquerade_reminder"] = {
        name = "Masquerade the Blazing Dragon", --tooltip name
       text = {
           "{C:chips}+25{} Chips",
           "{C:mult}+20{} Mult",
           "Reduces full blind by",
		   "{C:attention}0.8%{} for every scoring card"
       }
   }
G.localization.descriptions.Other["discostats"] = {
        name = "Joker Stats",
       text = {
           "{C:chips}+#5#{} Chips",
           "{C:mult}+#4#{} Mult",
           "{C:green}Dice Score:",
		   "{C:green}#3# (#1# + #2# Bonus)"
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
            "Reduces full blind by 0.8%",
			"for every scoring card"
			},
    }	
G.localization.descriptions.Joker['turtle'] =  {
        name = 'A Turtle',
        text = {"Not eternal"
			},
    }
G.localization.descriptions.Joker['logic'] =  {
        name = 'Logic',
        text = {"Gains {C:mult}Mult{} equal to",
			"{C:green}Dice Score{} if hand",
			"beats the blind"
			},
    }
G.localization.descriptions.Joker['encyclopedia'] =  {
        name = 'Encyclopedia',
        text = {"Gains {C:chips}+20{} chips when hand is",
			"played if Dice Score is {C:green}7 or{},",
			"more, gains {C:green}+1{} permanent",
			"Dice Score otherwise"
			},
    }
G.localization.descriptions.Joker['rhetoric'] =  {
        name = 'Rhetoric',
        text = {"Gains {C:green}+1{} permanent dice",
			"score whenever you discard only",
			"{C:attention}1{} card, also destroy it if Dice",
			"Score becomes {C:green}10 or more{}"
			},
    }
G.localization.descriptions.Joker['drama'] =  {
        name = 'Drama',
        text = {"Creates {C:attention}1{} {C:dark_edition}Negative{} \"{C:attention}Joker{}\" when",
			"hand is played if Dice Score is {C:green}12",
			"{C:green}or more{}, jokers with \"{C:attention}Joker{}\"",
			"{C:attention}in name{} grant {C:green}+1{} Dice Score"
			},
    }
G.localization.descriptions.Joker['conceptualization'] =  {
        name = 'Conceptualization',
        text = {"Creates {C:attention}1{} {C:dark_edition}Negative{} \"{C:attention}Abstract Joker{}\"",
			"when hand is played if Dice Score is {C:green}20",
			"{C:green}or more{}, jokers with \"{C:attention}Joker{}\"",
			"in name grant {C:green}+1{} Dice Score"
			},
    }
G.localization.descriptions.Joker['visualcalculus'] =  {
        name = 'Visual Calculus',
        text = {"Every played {C:attention}card{} permanently",
			"gains {C:chips}Chips{} equal to {C:green}Dice",
			"{C:green}Score{} when scored"
			},
    }
G.localization.descriptions.Joker['volition'] =  {
        name = 'Volition',
        text = {"Converts the {C:attention}left{} card into the {C:attention}right{}",
			"card if played hand is a {C:attention}Pair{}, prevents",
			"Death if Dice Score is {C:green}12 or more{}"
			},
    }
G.localization.descriptions.Joker['inlandempire'] =  {
        name = 'Inland Empire',
        text = {"Adds a permanent copy of a random played card",
			"to deck and draw it to {C:attention}hand{}, add a random",
			"{C:attention}Edition{} to it if Dice Score is {C:green}9 or more{}"
			},
    }
G.localization.descriptions.Joker['empathy'] =  {
        name = 'Empathy',
        text = {"Gains {C:mult}Mult{} equal to",
			"{C:green}Dice Score{} if hand is played",
			"without {C:attention}discarding{} any card"
			},
    }
G.localization.descriptions.Joker['authority'] =  {
        name = 'Authority',
        text = {"Destroys the lowest card in {C:attention}hand{} and",
			"gives {C:attention}double{} its {C:chips}Chips{} to all other",
			"ones if played hand is a {C:attention}Straight{}",
			"and Dice Score is {C:green}4 or more{}"
			},
    }
G.localization.descriptions.Joker['espritdecorps'] =  {
        name = 'Esprit de Corps',
        text = {"Earns {C:money}${} equal to {C:green}Dice Score{}",
			"when hand is played, also {C:attention}appears{}",
			"when you sell a \"{C:attention}Burglar{}\"",
			},
    }
G.localization.descriptions.Joker['suggestion'] =  {
        name = 'Suggestion',
        text = {"Add a random {C:attention}Seal{} to a random",
			"played card if Dice Score is {C:green}8",
			"{C:green}or more{}, gains {C:green}+1{} permanent",
			"Dice Score otherwise",
			},
    }
G.localization.descriptions.Joker['endurance'] =  {
        name = 'Endurance',
        text = {"Gains {C:chips}+1{} hand when hand is",
			"played if Dice Score is {C:green}30 or",
			"{C:green}more{}, gains {C:green}+2{} permanent",
			" Dice Score otherwise"
			},
    }
G.localization.descriptions.Joker['painthreshold'] =  {
        name = 'Pain Threshold',
        text = {"Gains {C:mult}+1{} discard when hand is",
			"played if Dice Score is {C:green}18 or",
			"{C:green}more{}, gains {C:green}+1{} permanent",
			" Dice Score otherwise"
			},
    }
G.localization.descriptions.Joker['physicalinstrument'] =  {
        name = 'Physical Instrument',
        text = {"Creates a {C:dark_edition}Negative{} copy of every",
			"non-{C:dark_edition}Negative{} {C:attention}consumable{} you use if",
			"Dice Score is {C:green}8 or more{}, {C:attention}rerolls{}",
			"dice after every use"
			},
    }
G.localization.descriptions.Joker['electrochemistry'] =  {
        name = 'Electrochemistry',
        text = {"Gains {C:chips}Chips{} equal to {C:green}Dice Score{} when",
			"you use a {C:attention}consumable{}, swaps",
			"to \"{C:purple}Volition{}\" if you sell one"
			},
    }
G.localization.descriptions.Joker['shivers'] =  {
        name = 'Shivers',
        text = {"Creates an {C:attention}Etheral Tag{} when hand",
			"is played if Dice Score is",
			"{C:green}10 or more{}"
			},
    }
G.localization.descriptions.Joker['halflight'] =  {
        name = 'Half Light',
        text = {"{X:mult,C:white}XMult{} equal to {C:attention}1/4{} of {C:green}Dice Score{},",
			"always {C:attention}appears{} if previous {C:attention}hand{} scored",
			"less than {C:attention}1/5{} of blind's required score"
			},
    }
G.localization.descriptions.Joker['handeye'] =  {
        name = 'Hand/Eye Coordination',
        text = {"Gains {C:attention}+1{} hand size when hand is",
			"played if Dice Score is {C:green}20 or",
			"{C:green}more{}, gains {C:green}+1{} permanent",
			" Dice Score otherwise"
			},
    }
G.localization.descriptions.Joker['perception'] =  {
        name = 'Perception',
        text = {"Fills consumable slots with copies of \"{C:tarot}The World (XXI){}\"",
			"when hand is played if Dice Score is {C:green}4 or {C:green}more{},",
			"gains {C:green}+3{} permanent Dice Score otherwise"
			},
    }
G.localization.descriptions.Joker['reactionspeed'] =  {
        name = 'Reaction Speed',
        text = {"{C:attention}Discard{} your {C:attention}most played{} poker hand",
			"to upgrade it a number of times equal",
			"to {C:attention}1/10{} of your {C:green}Dice Score {C:inactive}(rounded,",
			"{C:inactive}minimum 1){} and {C:attention}transform{} this again"
			},
    }
G.localization.descriptions.Joker['savoirfaire'] =  {
        name = 'Savoir Faire',
        text = {"{C:attention}Enhance{} all unenhanced cards in",
			"played hand if Dice Score is {C:green}10",
			"{C:green}or more{}"
			},
    }
G.localization.descriptions.Joker['interfacing'] =  {
        name = 'Interfacing',
        text = {"Creates a {C:planet}Planet{} card when hand is",
			"played, result varies depending on",
			"{C:green}Dice Score{}..."
			},
    }
G.localization.descriptions.Joker['composure'] =  {
        name = 'Composure',
        text = {"Gains {C:mult}Mult{} equal to",
			"{C:green}Dice Score{} if you play",
			"your {C:attention}most played poker{} hand"
			},
    }