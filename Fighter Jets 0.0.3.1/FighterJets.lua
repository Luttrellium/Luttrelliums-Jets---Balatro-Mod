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
    name = 'SUPCruise',
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
    config = { extra = { Xmult = 1, Xmult_gain = 0.5, is_jet_joker = true } },
    rarity = 2, -- Uncommon
    atlas = 'SuperCruiseatlas',
    pos = { x = 0, y = 0 },
    cost = 6,
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.Xmult, card.ability.extra.Xmult_gain } }
    end,

    calculate = function(self, card, context)
        if context.joker_main then -- CAN BE RETRIGGERED
            return {
                message = localize { type = 'variable', key = 'a_xmult', vars = { card.ability.extra.Xmult } },
                Xmult_mod = card.ability.extra.Xmult,
            }
        end

        -- UPGRADE CONTEXT 'IF' - BEAT STAKE IN A SINGLE HAND - DOES NOT RETRIGGER EVER
        if G.GAME.current_round.hands_played <= 1 and context.end_of_round and context.cardarea == G.jokers and not context.retrigger_joker then
            card.ability.extra.Xmult = card.ability.extra.Xmult + card.ability.extra.Xmult_gain
            return {
                message = 'Cruising!',
                sound = 'LJet_SCruiseUpgrade',
                colour = G.C.MULT,
            }
        end

        -- RESET IF 'UPGRADE' NOT FULFILLED - MORE THAN ONE HAND PER BLIND IS USED - DOES NOT RETRIGGER EVER
        if G.GAME.current_round.hands_played == 1 and context.hand_drawn and card.ability.extra.Xmult ~= 1 and not context.retrigger_joker then
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
    config = { extra = { is_jet_joker = true } },
    rarity = 3,
    atlas = 'PepsiHarrieratlas',
    pos = { x = 0, y = 0 },
    cost = 9,
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
                -- This method works. One caveat, though, is that if multiple Diet Colas are going to be spawned
                --(either through retriggers or multiple PepsiHarriers), they all spawn at once. I want to fix this,
                --but don't know how atm. You can see below my many attmepts at it.
            }
        end

            --Attempted EventManager Iteration
            --[[return {
                G.E_MANAGER:add_event(Event({
                    trigger = "after",
                    delay = 0.5,
                    func = function()
                        SMODS.add_card({key = 'j_diet_cola'})
                        G.jokers.cards[#G.jokers.cards]:set_edition('e_negative', nil, true)
                        return true
                    end,
                
                })),

                sound = 'LJet_PHarrierSpawn',
                message = 'Pepsi!',
                -- This method also works fine, with each diet cola being created sequentially, but the sounds
                -- and messages that should accompany each Diet cola don't really work. *Sigh...*
            }
        end
    end]]--

    --[[ ChatGPT Attempt 1 - Kinda worked, somewhat an improvement, but flawed for reasons I can't remember
    calculate = function(self, card, context) 
        if context.setting_blind then
            local num_spawns = 1
            local delay = 0
    
            for i = 1, num_spawns do
                G.E_MANAGER:add_event(Event({
                    trigger = "after",
                    delay = delay,
                    func = function()
                        SMODS.add_card({key = 'j_diet_cola'})
                        G.jokers.cards[#G.jokers.cards]:set_edition('e_negative', nil, true)
                        return true
                    end
                }))
                delay = delay + 0.5  -- Stagger the spawns
            end
    
            -- Sound and message play immediately as in Method 1 (correct behavior)
            return {
                sound = 'LJet_PHarrierSpawn',
                message = 'Pepsi!'
            }
        end
    end]]--

    --[[ ChatGPT Attempt 2 - Garbage
    calculate = function(self, card, context) 
        if context.setting_blind then
            if not G.pepsi_spawn_queue then
                G.pepsi_spawn_queue = {}
                G.pepsi_spawn_delay = 0
            end
    
            -- Add a Diet Cola spawn to the global queue
            table.insert(G.pepsi_spawn_queue, function()
                SMODS.add_card({key = 'j_diet_cola'})
                G.jokers.cards[#G.jokers.cards]:set_edition('e_negative', nil, true)
            end)
    
            -- Start processing the queue only if it hasn’t started already
            if #G.pepsi_spawn_queue == 1 then
                G.E_MANAGER:add_event(Event({
                    trigger = "after",
                    delay = G.pepsi_spawn_delay,
                    func = function()
                        if #G.pepsi_spawn_queue > 0 then
                            local spawn_func = table.remove(G.pepsi_spawn_queue, 1)
                            spawn_func()
                            
                            -- Schedule the next spawn in sequence
                            if #G.pepsi_spawn_queue > 0 then
                                G.E_MANAGER:add_event(Event({
                                    trigger = "after",
                                    delay = 0.5, -- Stagger delay for sequential spawns
                                    func = function()
                                        G.pepsi_spawn_delay = G.pepsi_spawn_delay + 0.5
                                        return true
                                    end
                                }))
                            else
                                -- Reset delay when all queued spawns are complete
                                G.pepsi_spawn_delay = 0
                            end
                        end
                        return true
                    end
                }))
            end
    
            -- Sound and message play immediately for each trigger
            return {
                sound = 'LJet_PHarrierSpawn',
                message = 'Pepsi!'
            }
        end]]--
    end
}



-- AIRCRAFT CARRIER JOKER

SMODS.Atlas {
	-- Key for code to find it with
	key = "AircraftCarrieratlas",
	-- The name of the file, for the code to pull the atlas from
	path = "AircraftCarrier.png",
	-- Width of each sprite in 1x size
	px = 71,
	-- Height of each sprite in 1x size
	py = 95
}

SMODS.current_mod.optional_features = { retrigger_joker = true }

SMODS.Joker {
    key = 'ACarrier',
    loc_txt = {
        name = 'Aircraft Carrier',
        text = {
            "Retriggers all {C:attention}Aircraft{} type Jokers",
        }
    },
    rarity = 2, -- Uncommon
    atlas = 'AircraftCarrieratlas',
    pos = { x = 0, y = 0 },
    cost = 5,
    loc_vars = function(self, info_queue, card)

    end,

    calculate = function(self, card, context)
        if context.retrigger_joker_check and context.other_card ~= card and context.other_card.ability.extra and context.other_card.ability.extra.is_jet_joker and not (context.other_card.ability.name == 'SUPCruise' and context.other_context.end_of_round) then
            return {
                repetitions = 1,
                message = "Refuelled!",
            }
        end
    end
}