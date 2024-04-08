local Translations = {
    error = {
        ["cancel"] = "Cancelado",
        ["no_truck"] = "Você não tem um caminhão!",
        ["not_enough"] = "Dinheiro Insuficiente (%{value} necessário)",
        ["too_far"] = "Você está muito longe do ponto de entrega",
        ["early_finish"] = "Devido ao término antecipado (Completado: %{completed} Total: %{total}), seu depósito não será devolvido.",
        ["never_clocked_on"] = "Você nunca registrou o ponto!",
        ["all_occupied"] = "Todas as vagas de estacionamento estão ocupadas",
    },
    success = {
        ["clear_routes"] = "Rotas dos usuários limpas, eles tinham %{value} rotas armazenadas",
        ["pay_slip"] = "Você recebeu $%{total}, seu contracheque de %{deposit} foi pago para sua conta bancária!",
    },
    target = {
        ["talk"] = 'Conversar com o Lixeiro',
        ["grab_garbage"] = "Pegar saco de lixo",
        ["dispose_garbage"] = "Descartar Saco de Lixo",
    },
    menu = {
        ["header"] = "Menu Principal do Lixo",
        ["collect"] = "Receber Pagamento",
        ["return_collect"] = "Devolver caminhão e receber pagamento aqui!",
        ["route"] = "Solicitar Rota",
        ["request_route"] = "Solicitar uma Rota de Lixo",
    },
    info = {
        ["payslip_collect"] = "[E] - Contracheque",
        ["payslip"] = "Contracheque",
        ["not_enough"] = "Você não tem dinheiro suficiente para o depósito.. Os custos do depósito são $%{value}",
        ["deposit_paid"] = "Você pagou um depósito de $%{value}!",
        ["no_deposit"] = "Você não tem depósito pago neste veículo..",
        ["truck_returned"] = "Caminhão devolvido, pegue seu contracheque para receber seu pagamento e depósito de volta!",
        ["bags_left"] = "Ainda há %{value} sacos!",
        ["bags_still"] = "Ainda há %{value} saco ali!",
        ["all_bags"] = "Todos os sacos de lixo acabaram, vá para o próximo local!",
        ["depot_issue"] = "Houve um problema no depósito, por favor, retorne imediatamente!",
        ["done_working"] = "Você terminou de trabalhar! Volte para o depósito.",
        ["started"] = "Você começou a trabalhar, local marcado no GPS!",
        ["grab_garbage"] = "[E] Pegar um saco de lixo",
        ["stand_grab_garbage"] = "Fique aqui para pegar um saco de lixo.",
        ["dispose_garbage"] = "[E] Descartar Saco de Lixo",
        ["progressbar"] = "Colocando saco no lixo..",
        ["garbage_in_truck"] = "Coloque o saco em seu caminhão..",
        ["stand_here"] = "Fique aqui..",
        ["found_crypto"] = "Você encontrou um cryptostick no chão",
        ["payout_deposit"] = "(+ $%{value} de depósito)",
        ["store_truck"] =  "[E] - Guardar Caminhão de Lixo",
        ["get_truck"] =  "[E] - Caminhão de Lixo",
        ["picking_bag"] = "Pegando saco de lixo..",
        ["talk"] = "[E] Conversar com o Lixeiro",
    },    
}

if GetConvar('qb_locale', 'en') == 'pt-br' then
    Lang = Locale:new({
        phrases = Translations,
        warnOnMissing = true,
        fallbackLang = Lang,
    })
end
