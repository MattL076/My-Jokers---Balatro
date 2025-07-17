--- STEAMODDED HEADER
--- MOD_NAME: Joker of all Trades
--- MOD_ID: JOAT
--- MOD_AUTHOR: [Kinkade]
--- MOD_DESCRIPTION: A mod designed around common english idioms reimagined as jokers in Balatro.
--- PREFIX: joat
-----------------------------------------
--------MOD CODE-------------------------
local mod = SMODS.current_mod



-- Register image asset
SMODS.Atlas({
    key = "JOAT",
    path = "Joat_Jokers.png",
    px = 71,
    py = 95,
    atlas_table = "ASSET_ATLAS"
}):register()

-- The Early Bird
SMODS.Joker{
    name = "The Early Bird",
    key = "joat_early_bird",
    cost = 6,
    rarity = 2,
    unlocked = true,
    discovered = true,
    eternal_compat = true,
    blueprint_compat = true,
    atlas = "JOAT",
    pos = { x = 1, y = 0 },

    loc_txt = {
        name = "The Early Bird",
        text = {
            [1] = "{C:mult}+#1#{} Mult on {C:attention}First{}",
            [2] = "{C:attention}Hand{} of the Round",
            [3] = "{C:inactive}The early bird gets the worm"
        }
    },

    config = { extra = {
        mult = 30
    }},
    loc_vars = function(self,info_queue,card)
        return {vars = {card.ability.extra.mult}}
    end,



    calculate = function(self, card, context)
        if context.joker_main then
            if G.GAME.current_round.hands_played == 0 then
                return {
                    card = card,
                    mult = card.ability.extra.mult,
                }
            end
        end
    end
}





-- Omelette
SMODS.Joker{
    name  = "Omelette",
    key   = "joat_omelette",
    cost  = 4,
    rarity = 1,
    unlocked = true,
    discovered = true,
    eternal_compat   = false,
    blueprint_compat = true,
    atlas = "JOAT",
    pos   = {x = 2, y = 0},

    loc_txt = {
        name = "Omelette",
        text = {
            [1] = "{X:mult,C:white}X#1#{} Mult",
            [2] = "Lasts {C:attention}#2#{} more rounds",
            [3] = "Selling {C:attention}\"Egg\" resets timer to 5",
            [4] = "Also adds {X:mult,C:white}X#3#{} Mult",
            [5] = "{C:attention}#4# Egg(s) sold{}",
            [6] = "{C:inactive}You have to break a couple eggs to make an omelette"
        }
    },

    -- ── State ────────────────────────────────────────────────────────────
    config = {extra = {
        xmult            = 3,    -- base ×Mult
        rounds_remaining = 5,    -- countdown
        xmult_inc        = 0.5,  -- +0.5× per Egg
        eggs_sold        = 0
    }},

    -- ── Tooltip variables ────────────────────────────────────────────────
    loc_vars = function(self,_,card)
        local ex = card.ability.extra
        return {vars = {
            ex.xmult,
            ex.rounds_remaining,
            ex.xmult_inc,
            ex.eggs_sold
        }}
    end,

    -- ── Main logic (runs many times each hand) ───────────────────────────
    calculate = function(self, card, context)

        -- A) main scoring pass  → apply ×Mult
        if context.joker_main then
            return {
                card      = card,
                Xmult_mod = card.ability.extra.xmult,      -- multiply Mult
                message   = localize{type='variable', key='a_xmult',
                                     vars={card.ability.extra.xmult}},
                colour    = G.C.MULT
            }
        end

        if context.selling_card then
            local sold_key = context.card
                         and context.card.config
                         and context.card.config.center
                         and context.card.config.center.key      -- ← this never nil
        
        
            if sold_key == 'j_egg' then          -- real Egg
        
                local ex = card.ability.extra
                ex.xmult            = ex.xmult + ex.xmult_inc
                ex.rounds_remaining = 5
                ex.eggs_sold        = ex.eggs_sold + 1
        
                card_eval_status_text(card, 'extra', nil, nil, nil, {
                    message = localize{type='variable', key='a_xmult',
                                       vars={ex.xmult}},
                })
                return nil, true                 -- tell engine we handled it
            end
        end

        if context.end_of_round and
           not context.repetition and
           not context.individual and
           not context.blueprint
        then
            local ex = card.ability.extra
            ex.rounds_remaining = ex.rounds_remaining - 1

            local ret = {
                message = "Spoiling",
                card    = card,
                colour  = G.C.RED
            }

            if ex.rounds_remaining <= 0 then
                card:remove()
                ret.message = "Spoiled"
            end
            return ret        -- engine creates the popup
        end
    end
}

    
-- Joaker Of All Trades
SMODS.Joker{
    name = "Joker of All Trades",
    key = "joat_joat",
    cost = 7,
    rarity = 2,
    unlocked = true,
    discovered = true,
    eternal_compat = true,
    blueprint_compat = true,
    atlas = "JOAT",
    pos = { x = 3, y = 0 },

    loc_txt = {
        name = "Joker of All Trades",
        text = {
            [1] = "{C:mult}+#1#{} Mult and {C:chips}+#2#{} Chips",
            [2] = "also {X:mult,C:white}X#3#{} Mult and {C:money}$#4#",
            [3] = "when triggered",
            [4] = "{C:inactive}Jack Of All Trades, master of none"
        }
    },

    config = { extra = {
        mult = 10,
        chips = 40,
        xmult = 1.5,
        money = 2
    }},

    loc_vars = function(self,info_queue,card)
        return {vars = {card.ability.extra.mult,card.ability.extra.chips,card.ability.extra.xmult,card.ability.extra.money}}
    end,



    calculate = function(self, card, context)
        if context.joker_main then
            return {
                card = card,
                mult = card.ability.extra.mult,
                chips = card.ability.extra.chips,
                Xmult_mod = card.ability.extra.xmult,
                message   = localize{type='variable', key='a_xmult',
                                     vars={card.ability.extra.xmult}},
                colour    = G.C.MULT,
                dollars = card.ability.extra.money,
            }
        end
    end
}


-- Some Slack
SMODS.Joker{
    name = "Some Slack",
    key = "joat_some_slack",
    cost = 4,
    rarity = 1,
    unlocked = true,
    discovered = true,
    eternal_compat = true,
    blueprint_compat = true,
    atlas = "JOAT",
    pos = { x = 4, y = 0 },

    loc_txt = {
        name = "Some Slack",
        text = {
            [1] = "Rounds money {C:attention}up {}to the nearest",
            [2] = "Increment of {C:money}#1#",
            [3] = "at the end of shop",
            [4] = "{C:inactive}Cut me some slack"
        }
    },

    config = { extra = {
        money = 5
    }},

    loc_vars = function(self,info_queue,card)
        return {vars = {card.ability.extra.money}}
    end,



    calculate = function(self, card, context)
        if context.ending_shop then                           -- correct flag
            print("Shop ended")
    
            local cash  = tonumber(G.GAME.dollars)        -- plain number
            local give  = (5 - (cash % 5)) % 5             -- top-up to next 5
    
            return {
                dollars = give,                            -- engine adds +$give
                card    = card,
                message = "+$" .. give,
                colour  = G.C.MONEY
            }
        end
    end
}
    



-- The Perfect Storm
SMODS.Joker{
    name = "The Perfect Storm",
    key = "joat_perfect_storm",
    cost = 7,
    rarity = 2,
    unlocked = true,
    discovered = true,
    eternal_compat = true,
    blueprint_compat = true,
    atlas = "JOAT",
    pos = { x = 5, y = 0 },


    config = { extra = {
        xmult = 2,
        xmult_inc = .25,
        rounds = 0,
    }},




    loc_txt = {
        name = "The Perfect Storm",
        text = {
            [1] = "Gives {X:mult,C:white}X#1# {} Mult every hand increases by {X:mult,C:white}X#2# {} Every round",
            [2] = "Gives {X:mult,C:white}X.05{} every {C:attention}3rd hand",
            [3] = "{C:attention}#3# hands remaining",
            [4] = "{C:inactive}Weather The Perfect Storm"
        }
    },

    loc_vars = function(self,info_queue,card)
        local curr_rounds = tonumber(card.ability.extra.rounds)
        local rnds_remaining = 2- curr_rounds
        return {vars = {card.ability.extra.xmult,card.ability.extra.xmult_inc,rnds_remaining}}
    end,

    calculate = function(self, card, context)
        if context.joker_main then
            if card.ability.extra.rounds ~= 2 then
                card.ability.extra.rounds = card.ability.extra.rounds + 1
                return {
                    card = card,
                    Xmult_mod = card.ability.extra.xmult,
                    message   = localize{type='variable', key='a_xmult',
                                     vars={card.ability.extra.xmult}},
                    colour    = G.C.MULT,
                }
            end
            if card.ability.extra.rounds == 2 then
                card.ability.extra.rounds = 0
                return {
                    card = card,
                    Xmult_mod = 0.05,
                    message   = "Struck X.05",
                    colour    = G.C.MULT,
                }
            end
        end

        if context.end_of_round             -- we are on the clean-up frame
   and not context.individual       -- ignore per-card passes
   and not context.repetition       -- ignore Pinata / Déjà-Vu
   and not context.blueprint        -- ignore Blueprint copies
then
    card.ability.extra.xmult =
        card.ability.extra.xmult + card.ability.extra.xmult_inc

    return {
        card    = card,
        message = "Growing",
        colour  = G.C.RED
    }
end

        
    end
}




-- The Second Mouse
SMODS.Joker{
    name = "The Second Mouse",
    key = "joat_second_mouse",
    cost = 6,
    rarity = 2,
    unlocked = true,
    discovered = true,
    eternal_compat = true,
    blueprint_compat = true,
    atlas = "JOAT",
    pos = { x = 6, y = 0 },

    loc_txt = {
        name = "The Second Mouse",
        text = {
            [1] = "Generates a {C:attention}random negative tarot{}",
            [2] = "card on {C:attention}last played hand{} of round",
            [3] = "{C:inactive}The second mouse gets the cheese"
        }
    },

    calculate = function(self, card, context)
        if G.GAME.current_round.hands_left == 0 and context.joker_main then
            print("last hand")

            G.E_MANAGER:add_event(Event({
                func = function() 
                    local newcard = create_card('Tarot',G.consumeables, nil, nil, nil, nil, nil, 'yin')
                    newcard:set_edition({ negative = true }, true)
                    newcard:add_to_deck()
                    G.consumeables:emplace(newcard)
                    G.GAME.consumeable_buffer = 0
                    return true

                    
                end}))  
                return {
                    card = card,
                    message = "Patience",
                    colour = G.C.MULT,
                }
        end


        
    end
}



-- The Worm
SMODS.Joker{
    name = "The Worm",
    key = "joat_the_worm",
    cost = 6,
    rarity = 2,
    unlocked = true,
    discovered = true,
    eternal_compat = false,
    blueprint_compat = false,
    atlas = "JOAT",
    pos = { x = 7, y = 0 },

    loc_txt = {
        name = "The Worm",
        text = {
            [1] = "When {C:attention} sold {} trigger all \"End of Shop\" effects",
            [2] = "{C:inactive}The Early Bird gets the worm"
        }
    },


    calculate = function(self, card, context)

        if context.selling_self then
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                func = function()
                    SMODS.calculate_context({
                    ending_shop = true,
                    dollars = G.GAME.dollars
                    })
                    return true
                end
            }))
        end



    end
}




-- The Cheese
SMODS.Joker{
    name = "The Cheese",
    key = "joat_the_cheese",
    cost = 9,
    rarity = 3,
    unlocked = true,
    discovered = true,
    eternal_compat = false,
    blueprint_compat = false,
    atlas = "JOAT",
    pos = { x = 8, y = 0 },

    loc_txt = {
        name = "The Cheese",
        text = {
            [1] = "{C:green}#1# in #2# {}to give {C:attention} negative",
            [2] = "to a {C:attention}random joker {} when {C:attention} sold",
            [3] = "Chance increases by 1 every round end",
            [4] = "{C:inactive}Second Mouse gets the Cheese"
        }
    },

    config = { extra = {
        chance = 1,
        out_of = 100
    }},

    loc_vars = function(self,info_queue,card)
        return {vars = {G.GAME.probabilities.normal * card.ability.extra.chance, card.ability.extra.out_of}}
    end,



    calculate = function(self, card, context)
        if context.end_of_round and (context.other_card == nil) then
            card.ability.extra.chance = card.ability.extra.chance + 1
            return {
                card = card,
                message = "patient",
                colour = G.C.CARD
            }
        end


        local odds  = (G.GAME.probabilities.normal * card.ability.extra.chance)
                    / card.ability.extra.out_of              -- 1/3 → 2/3 with Oops!



        if context.selling_self then
            if  pseudorandom('the_cheese') < odds then

                self.eligible_editionless_jokers = {}
                for k, v in pairs(G.jokers.cards) do
                    if v.ability.set == 'Joker' and (not v.edition) and v ~= card then
                        table.insert(self.eligible_editionless_jokers, v)
                    end
                end


                local temp_pool = self.eligible_editionless_jokers
                if temp_pool ~= nil then
                    local eligible_card = pseudorandom_element(temp_pool)
                    eligible_card:set_edition('e_negative', true)
                end
                return 
       
            else
                return {
                    message = "Impatient",
                    colour = G.C.RED
                }
            end
        end



    end
}






-- Rolling Snowball
SMODS.Joker{
    name = "Rolling Snowball",
    key = "joat_rolling_snowball",
    cost = 4,
    rarity = 1,
    unlocked = true,
    discovered = true,
    eternal_compat = true,
    blueprint_compat = true,
    atlas = "JOAT",
    pos = { x = 3, y = 1 },

    loc_txt = {
        name = "Rolling Snowball",
        text = {
            [1] = "When {C:attention}Played Cards{} give less than {C:chips}+#1# {}chips ",
            [2] = "This joker gains {C:chips}+#2# {}chips",
            [3] = "Currently {C:chips}+#3# {}chips",
            [4] = "{C:inactive}Keep the Ball Rolling"
        }
    },

    config = { extra = {
        chips_limit = 10,
        chips_inc = 10,
        chips_current = 0,
        chips_total = 0
    }},


    loc_vars = function(self,info_queue,card)
        return {vars = {card.ability.extra.chips_limit, card.ability.extra.chips_inc, card.ability.extra.chips_current}}
    end,


    calculate = function(self, card, context)

        if context.before and context.cardarea ==  G.jokers then
            card.ability.extra.chips_total = 0
        end

        if context.individual and context.cardarea == G.play then
            card.ability.extra.chips_total = card.ability.extra.chips_total + context.other_card:get_chip_bonus()
        end




        
        if context.joker_main then
            print(card.ability.extra.chips_total)
            if card.ability.extra.chips_total < card.ability.extra.chips_limit then
                card.ability.extra.chips_current = card.ability.extra.chips_current + card.ability.extra.chips_inc
            end
            return {
                card = card,
                chips = card.ability.extra.chips_current
            }
        end




    end
}






-- Master of One
SMODS.Joker{
    name = "Master of One",
    key = "joat_master",
    cost = 8,
    rarity = 3,
    unlocked = true,
    discovered = true,
    eternal_compat = true,
    blueprint_compat = true,
    atlas = "JOAT",
    pos = { x = 9, y = 0 },

    loc_txt = {
        name = "Master of One",
        text = {
            [1] = "{C:attention}Retrigger all played {C:attention}Aces once",
            [2] = "{C:green}#1# in #2#{} to retrigger a second time",
            [4] = "{C:inactive}Is still better than a Master of One"
        }
    },

    config = { extra = {
        chance = 1,
        out_of = 3
    }},


    loc_vars = function(self,info_queue,card)
        return {vars = {card.ability.extra.chance * G.GAME.probabilities.normal, card.ability.extra.out_of}}
    end,

    -- only act during the repetition pass, and only if a target card exists
    

    calculate = function(self, card, context)
        
        if not (context and context.repetition and context.other_card) then
            return
        end

        -- played Aces: IDs 0,13,26,39  (id % 13 == 0)
        local target = context.other_card
        if context.cardarea == G.play and target:get_id() == 14 then
            local extra = card.ability.extra         -- your config table
            local odds  = (G.GAME.probabilities.normal * extra.chance)
                        / extra.out_of              -- 1/3 → 2/3 with Oops!

            local reps  = 1
            if pseudorandom('master_of_one') < odds then
                reps = reps + 1
            end

            return {repetitions = reps, message = 'Masterful!'}
    end
end
}



-----------------------------------------
--------MOD CODE END---------------------