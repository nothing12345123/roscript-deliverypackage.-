Locales = {
    ['en'] = {
        ['start_delivery'] = 'Start Delivery',
        ['drive_faggio'] = 'Rental Faggio',
        ['receive_package'] = 'You have received the package!',
        ['already_have_package'] = 'You already have a package!',
        ['no_package'] = 'You do not have a package!',
        ['delivery_complete'] = 'Delivery completed!',
        ['delivery_complete_reward'] = 'You received a reward of $%s.',
        ['delivery_cancelled'] = 'Delivery cancelled...',
        ['special_item_received'] = 'You have received a special item!',
        ['not_enough_money'] = 'You do not have enough money! $%s needed.',
        ['npc_out'] = 'NPC has come out!',
        ['knock_door'] = 'Knock on the door',
        ['give_newspaper'] = 'Give newspaper'
    },

}

function _U(key, ...)
    local locale = Locales['en'] 
    local str = locale[key] or key
    return string.format(str, ...)
end