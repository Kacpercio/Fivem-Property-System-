Config = {}

Config.Targets = {
    {
        coords = vector3(266.06, -1007.97, -100.90),
        length = 0.2,
        width = 1.0,
        name = "apartywyjscie",
        debugPoly = false,
        size = vec3(3, 1.4, 4),
        options = {
            {
                event = "property:exit",
                icon = "fas fa-sign-out-alt",
                label = "Wyjdź",
                distance = 2.5,
            },
        }
    },
    {
        coords = vector3(259.78, -1004.76, -99.01),
        length = 0.2,
        width = 1.0,
        size = vec3(1, 1.4, 4),
        debugPoly = false,
        name = "szafka",
        options = {
            {
                event = "property:stash",
                icon = "fas fa-box-open",
                label = "Otwórz szafkę",
                distance = 1.5,
            },
            {
                event = "property:getClothes",
                icon = "fas fa-shirt",
                label = "Przebierz się",
                distance = 1.5,
            },
            {
                event = "property:removeClothes",
                icon = "fas fa-shirt",
                label = "Usuń ubranie",
                distance = 1.5,
            },
            {
                event = "property:addClothes",
                icon = "fas fa-shirt",
                label = "Dodaj ubranie",
                distance = 1.5,
            },
        },
    },
}

Config.Blipy = {

    {title="Mieszkanie Socjalne", colour=5, id=475, x = -934.4319, y = -1522.7072, z = 5.1751},
}

Config.Enter = vector4(265.9881, -1005.5045, -99.8722, 355.5367)

Config.Exit = vector4(-936.82, -1522.86, 5.18, 400)
