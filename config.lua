Config = {}
Config.MaxScore = 99999 -- เพดานคะแนน
Config.CollectPointEnable = false -- เปิดใช้งานการเก็บคะแนน
Config.CollectPoint = 5 -- คะแนนที่ได้รับในการเก็บ
Config.DurationCollect = 30 -- เวลาในการเก็บ วินาที
Config.CooldownTime = 15 -- คูลดาวน์เก็บคะแนน 15 นาที
Config.StealthEnable = true -- เปิดใช้งานการขโมยคะแนน
Config.CollectStealth = 10 -- คะแนนที่ได้รับในการขโมย
Config.DurationStealth = 15 -- เวลาในการขโมยคะแนน วินาที
Config.CooldownStealth = 5 -- คูลดาวน์ขโมยคะแนน 10 นาที
Config.AirdropEnable = false -- เปิดใช้งาน Airdrop
Config.DurationAirdrop = 40 -- เวลาในการเก็บ Airdrop วินาที
Config.CooldownAirdrop = 30 -- คูลดาวน์ Airdrop ตกทุก 30 นาที
Config.NextAirdrop = 15 -- เวลาที่ Airdrop จะหายถ้าไม่มีคนเก็บ 15 นาที
Config.TextAirdrop = "ขณะนี้ Airdrop point ได้ถูกปล่อยออกมาแล้ว"
Config.TextColorAirdrop = { 255, 157, 126 }
Config.AirdropPoint = 10 -- คะแนนในการเก็บ
Config.LocationAirdrop = {
	{
		position = vector3(-2123.5730, 3053.7571, 32.8100)
	},
	{
		position = vector3(-2123.5730, 3053.7571, 32.8100)
	},
}
Config.AirdropItem = true
Config.AirdropItemList = {
	{
		item = "aed_e",
		amount = {3,5},
		rate = 100
	},
	{
		item = "bandage_e",
		amount = {1,2},
		rate = 50
	},
}
Config.HitPropEnable = true
Config.HitPropMAXHP = 200
Config.HitPropMinHPCreate = 50
Config.HITPropReduce = 50
Config.HitPropPoint = 10
Config.HitPropDMG = 1
Config.CooldownnHitprop = 15 -- 15
Config.NextHitprop = 10 -- เวลาที่ Hitprop จะหายถ้าไม่มีคนเก็บ 10 นาที
Config.eventstart = "schoolwar" -- คำสั่งเปิดกิจกรรม
Config.eventstop = "schoolstop" -- คำสั่งปิดกิจกรรม
Config.showDistanceHouse = false -- โชว์ระยะพื้นที่บ้าน
Config.DistanceHouse = 18.5 -- โชว์ระยะพื้นที่บ้าน
Config.RecoverTime = 2.5 -- เวลานอนเตียง 0-100 ใช้เวลา 5 นาที

DataTeam = {
	['b_cover'] = { -- item ที่ใช้แบ่งทีม
		teamLabel = "SPADE", -- ชื่อทีม
		logo = "https://cdn.discordapp.com/attachments/913430004711444490/1077574699225190410/spade.png",
        model = "p_bigdice2",
		center = vector3(-1661.6700, -904.0584, 9.7142), --จุดกึ่งกลางบ้าน
		outside = vector3(-2059.89, 2931.14, 33.81), -- จุดวาปผู้เล่นที่ไม่ใช่เจ้าของบ้านในบริเวณบ้าน ออกเมื่อถูกเก็บคะแนนแล้ว
		coords = vector3(-2107.49, 2893.39, 37.15), -- จุดเก็บคะแนนของบ้าน
		stealthcoords = vector3(-1655.1637, -896.5474, 17.9819), -- จุดขโมยคะแนน
		BedList = { -- จุดนอนเตียง
            {
				objCoords  = {x = -1658.1721, y = -894.9498, z = 10.6988},
                heading = 332.1803
            },
            {
				objCoords  = {x = -1660.8383, y = -892.6248, z = 10.6988},
                heading = 315.5548
            },
            {
				objCoords  = {x = -1663.4756, y = -890.0782, z = 10.6988},
                heading = 321.9800
            },
            {
				objCoords  = {x = -1666.3875, y = -887.7360, z = 10.6988},
                heading = 315.0168
            },
            {
				objCoords  = {x = -1669.3702, y = -885.4225, z = 10.6988},
                heading = 320.5908
            },
            {
				objCoords  = {x = -1680.5863, y = -898.2880, z = 10.6922},
                heading = 139.8614
            },
            {
				objCoords  = {x = -1677.9202, y = -900.6459, z = 10.6988},
                heading = 123.9144
            },
            {
				objCoords  = {x = -1675.2051, y = -903.3205, z = 10.6988},
                heading = 133.0921
            },
            {
				objCoords  = {x = -1672.4891, y = -905.8001, z = 10.6988},
                heading = 138.8759
            },
            {
				objCoords  = {x = -1669.6713, y = -908.1025, z = 10.6988},
                heading = 136.4016
            }
		},
        PropLoc = {
            {
                position = vector3(-1668.3478, -898.4985, 17.9818)
            },
            {
                position = vector3(-1626.2098, -911.3782, 9.6267)
            },
            {
                position = vector3(-1655.1086, -910.0392, 17.9819)
            },
        },
        boss = "steam:4444444114"
	},
	['w_cover'] = {
		teamLabel = "HEART",
		logo = "https://cdn.discordapp.com/attachments/913430004711444490/1077574700072439929/heart.png",
        model = "p_bigdice",
		center = vector3(-1160.0787, -1703.9692, 4.7181),
		outside = vector3(-1927.99, 2997.32, 33.81),
		coords = vector3(-1905.36, 2940.46, 37.18),
		stealthcoords = vector3(-1162.5802, -1711.8376, 12.9857),
		BedList = {
            {
				objCoords  = {x = -1160.0665, y = -1709.3588, z = 5.6320},
                heading = 36.8225
            },
            {
				objCoords  = {x = -1157.5465, y = -1707.5579, z = 5.6320},
                heading = 39.9053
            },
            {
				objCoords  = {x = -1154.3492, y = -1705.6390, z = 5.6320},
                heading = 42.1119
            },
            {
				objCoords  = {x = -1151.3353, y = -1703.6982, z = 5.6320},
                heading = 42.2019
            },
            {
				objCoords  = {x = -1148.9895, y = -1701.9204, z = 5.6320},
                heading = 47.5559
            },
            {
				objCoords  = {x = -1158.7083, y = -1688.3116, z = 5.6320},
                heading = 214.3673
            },
            {
				objCoords  = {x = -1161.1104, y = -1689.9902, z = 5.6320},
                heading = 217.7250
            },
            {
				objCoords  = {x = -1163.7820, y = -1691.8306, z = 5.6320},
                heading = 233.3381
            },
            {
				objCoords  = {x = -1166.5143, y = -1693.6198, z = 5.6320},
                heading = 230.5861
            },
            {
				objCoords  = {x = -1169.1830, y = -1695.8107, z = 5.6320},
                heading = 229.9709
            }
		},
        PropLoc = {
            {
                position = vector3(-1176.8561, -1711.4781, 12.9861)
            },
            {
                position = vector3(-1135.7390, -1707.4650, 4.6637)
            },
            {
                position = vector3(-1158.1403, -1699.2050, 12.9857)
            },
        },
        boss = "steam:4444444444"
	},
}