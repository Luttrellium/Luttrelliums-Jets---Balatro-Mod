-- SUPER CRUISE JOKER

SMODS.Atlas {
	-- Key for code to find it with
	key = "SuperCruiseatlas",
	-- The name of the file, for the code to pull the atlas from
	path = "SuperCruising.png",
	-- Width of each sprite in 1x size
	px = 70,
	-- Height of each sprite in 1x size
	py = 95
}

SMODS.Sound {
    key = 'LJet_SCruiseUpgrade',
    path = 'SuperCruising.ogg',
}

SMODS.Sound {
    key = 'LJet_SCruiseReset',
    path = 'SpoolDown.ogg',
}

SMODS.Joker {
    key = 'SCruise',
    loc_txt = {
        name = 'Super-Cruising',
        text = {
            "For every {C:attention}consecutive blind{} beaten",
            "with a {C:attention}single hand{},",
            "this Joker gains {X:mult,C:white}x#2#{} Mult",
            "{C:attention}Resets{} if more than {C:attention}1{} hand is played",
            "{C:inactive}(Currently {X:mult,C:white}x#1#{}{C:inactive} Mult){}",
        }
    },
    config = { extra = { Xmult = 1, Xmult_gain = 0.5 } },
    rarity = 2, -- Uncommon
    atlas = 'SuperCruiseatlas',
    pos = { x = 0, y = 0 },
    cost = 5,
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.Xmult, card.ability.extra.Xmult_gain } }
    end,

    calculate = function(self, card, context)
        if context.joker_main then
            return {
                message = localize { type = 'variable', key = 'a_xmult', vars = { card.ability.extra.Xmult } },
                Xmult_mod = card.ability.extra.Xmult,
            }
        end

        -- UPGRADE CONTEXT 'IF' - BEAT STAKE IN A SINGLE HAND
        if G.GAME.current_round.hands_played <= 1 and context.end_of_round and context.cardarea == G.jokers then
            card.ability.extra.Xmult = card.ability.extra.Xmult + card.ability.extra.Xmult_gain
            return {
                message = 'Cruising!',
                sound = 'LJet_SCruiseUpgrade',
                colour = G.C.MULT,
            }
        end
        
        -- RESET IF 'UPGRADE' NOT FULFILLED - MORE THAN ONE HAND PER BLIND IS USED
        if G.GAME.current_round.hands_played == 1 and context.hand_drawn and card.ability.extra.Xmult ~= 1 then
            card.ability.extra.Xmult = 1
            return{
                message = 'Subsonic...',
                sound = 'LJet_SCruiseReset',
                colour = G.C.ATTENTION,
            }
        end
    end
}



-- PEPSI HARRIER JOKER

SMODS.Atlas {
	-- Key for code to find it with
	key = "PepsiHarrieratlas",
	-- The name of the file, for the code to pull the atlas from
	path = "PepsiHarrier.png",
	-- Width of each sprite in 1x size
	px = 70,
	-- Height of each sprite in 1x size
	py = 95
}

SMODS.Sound {
    key = 'LJet_PHarrierSpawn',
    path = 'PepsiSpawn.ogg',
}

SMODS.Joker {
    key = 'PHarrier',
    loc_txt = {
        name = 'Pepsi, Where\'s My Jet?',
        text = {
            "Creates a {C:dark_edition}Negative {C:green}Diet Cola",
            "when {C:attention}Blind{} is selected",

        }
    },
    rarity = 3,
    atlas = 'PepsiHarrieratlas',
    pos = { x = 0, y = 0 },
    cost = 7,
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue + 1] = G.P_CENTERS.j_diet_cola
    end,

    calculate = function(self, card, context)
        if context.setting_blind then
            return {
                SMODS.add_card({key = 'j_diet_cola'}),
                sound = 'LJet_PHarrierSpawn',
                G.jokers.cards[#G.jokers.cards]:set_edition('e_negative', nil, true),
                message = 'Pepsi!'
            }
        end
    end
}