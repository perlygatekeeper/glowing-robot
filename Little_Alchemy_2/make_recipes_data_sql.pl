#!/usr/bin/env perl
# A perl script to read in recipe_data.txt and output sql.

my $name = $0; $name =~ s'.*/''; # remove path--like basename
my $usage = "usage:\n$name [-opt1] [-opt2] [-opt3]";

use strict;
use warnings;

my $sql_statement_format;
$sql_statement_format  = "INSERT INTO recipes ( product, ingredient_1, ingredient_2, last_modified, date_added )\n";
$sql_statement_format .= " SELECT e1.id, e2.id, e3.id, now(), now()\n";
$sql_statement_format .= " FROM elements e1, elements e2, elements e3\n";
$sql_statement_format .= " WHERE e1.name = '%s' AND e2.name = '%s' AND e3.name = '%s';\n";

while (<DATA>) {
  next if (/^\s*$|^\s*#/); # skip white, blank and commented lines.
  chomp;
  my ( $product, $ingredients_string ) = ( $_ =~ /([^\t]+)\t(.*)$/ );
  foreach my $ingredients ( split( m;\s/\s;, $ingredients_string ) ) {
      my $ingredient_1 = '';
      my $ingredient_2 = '';
      ($ingredient_1, $ingredient_2 ) = ( $ingredients =~ /([^,]+), (.*)/ );
      $ingredient_1 =~ s/\b(.)/\U$1/g;
      $ingredient_2 =~ s/\b(.)/\U$1/g;
#     printf "(%s)\t\t(%s)\n", $product, $ingredients;
#     printf "(%s)\t\t(%s)\t\t(%s)\n", $product, $ingredient_1, $ingredient_2;
      if ( $product and $ingredient_1 and $ingredient_2 ) {
        printf $sql_statement_format, $product, $ingredient_1, $ingredient_2;
      } else {
        printf STDERR "ERROR: (%s) (%s) (%s)-> (%s) (%s)\n", $_, $product, $ingredients, $ingredient_1, $ingredient_2;
      }
  }
}

exit 0;

__END__
# from https://www.ign.com/wikis/little-alchemy-2/Little_Alchemy_2_Cheats_-_List_of_All_Combinations
# on Fri Feb 21 2020
# Resulting Element	Ingredient Combination(s)
# Time	Unlocked through progression.
# Air	Available from start.
# Earth	Available from start.
Fire	fire, alcohol / fire, coal
Water	ice, heat / snow, heat
#
Acid Rain	rain, smoke / rain, smog / rain, sickness / cloud, smoke / cloud, smog / cloud, sickness / rain, city
Airplane	metal, bird / steel, bird / bird, machine / bird, steam engine / bird, train / bird, car / bird, boat / bird, steamboat / bird, sailboat / metal, owl / steel, owl / steam engine, owl / metal, vulture / steel, vulture / metal, duck / steel, duck / metal, seagull / steel, seagull / metal, bat / steel, bat / metal, eagle / steel, eagle / steel, pigeon / metal, pigeon / metal, hummingbird / steel, hummingbird / metal, crow / steel, crow / owl, machine / vulture, machine / duck, machine / seagull, machine / bat, machine / eagle, machine / pigeon, machine / hummingbird, machine / crow, machine / pilot, container
Alarm Clock	clock, sound / clock, dawn / clock, bell / sound, watch / watch, dawn / watch, bell
Alchemist	human, gold / gold, philosophy
Alcohol	time, juice / wheat, fruit / wheat, juice / fruit, sun
Algae	water, plant / grass, pond / grass, lake / water, grass
Alien	life, space / life, galaxy / life, galaxy cluster / life, solar system / life, Mars / life, Venus / life, Mercury / life, Jupiter / life, Saturn
Allergy	dust, human / human, pollen
Alligator	lizard, river / swamp, lizard / lizard, lake
Alpaca	mountain, sheep / sheep, mountain range / sheep, mountain goat
Ambulance	car, hospital / car, doctor
Angel	bird, human / human, light
Angler	human, fishing rod / sailor, fishing rod
Animal	life, land / life, forest / life, mountain / life, mountain range / life, beach / life, desert
Ant	grass, animal / grass, spider
Ant Farm	farm, ant / ant, jar / glass, ant / farm, anthill / jar, anthill / farm, anthill
Antarctica	desert, snow / desert, ice / snow, continent / ice, continent
Anthill	house, ant / ant, container / ant, hill / earth, ant / ant, land / ant, soil
Apron	fabric, cook / baker, fabric
Aquarium	water, glass / glass, fish / glass, puddle / glass, pond / fish, container / small, swimming pool
Archeologist	human, ruins / ruins, science
Archipelago	island, island / sea, island / ocean, island
Arctic	ocean, cold / sea, cold
Armadillo	animal, armor / armor, dog / armor, cat
Armor	metal, fabric / steel, fabric
Arrow	bullet, wood / wood, bow
Ash	fire, mineral / fire, plant / fire, tree / water, campfire / time, campfire / rain, campfire / storm, campfire / fire, grass / phoenix, paper / campfire, paper / fire, paper / sun, vampire / vampire, dawn
Astronaut	human, space / human, spaceship / human, space station / human, rocket / human, moon / human, Mars / human, solar system / human, Mercury / human, Jupiter / human, Saturn / human, Venus / human, moon rover
Atmosphere	air, planet / air, sky
Atomic Bomb	energy, explosion / explosion, big / explosion, explosion
Aurora	electricity, atmosphere / electricity, Antarctica / sky, Antarctica / sky, electricity / electricity, arctic / sky, arctic / sun, atmosphere
Avalanche	earthquake, snow / wave, glacier / earthquake, glacier / earthquake, mountain / wave, mountain / earthquake, mountain range / wave, mountain range / glacier, sound / mountain, sound / gun, glacier / gun, mountain / gun, mountain range
Axe	blade, wood / tool, wood / stone, wood / tool, lumberjack
Bacon	fire, pig / campfire, pig / fire, ham / campfire, ham
Bacteria	life, primordial soup / life, small / mud, life
Baker	human, bakery / human, bread / human, banana bread / human, pizza / human, toast / human, batter / human, pie / human, donut / human, cookie / human, cookie dough / human, dough
Bakery	house, bread / house, baker / house, donut / house, cake / bread, city / baker, city / city, donut / city, cake / bread, village / baker, village / village, donut / village, cake / baker, container
Banana	fruit, monkey
Banana Bread	bread, banana / dough, banana
Bandage	blood, fabric / sword, fabric / blade, fabric
Bank	house, gold / skyscraper, gold / house, safe / skyscraper, safe / house, money / skyscraper, money / city, gold / city, safe / city, money / money, container / house, vault
Barn	house, cow / house, livestock / house, hay / house, farm / field, house / livestock, container / cow, container / horse, container / pig, container / hay, container / house, sheep / sheep, container / hay bale, container / house, goat / goat, container
Bat	sky, mouse / air, mouse / atmosphere, mouse / bird, mouse / mouse, hummingbird
Batter	milk, flour / flour, coconut milk
Battery	electricity, container / energy, container / electricity, mineral / electricity, ore
Bayonet	blade, gun / gun, sword / axe, gun
BBQ	metal, campfire / steel, campfire / campfire, garden / campfire, house / campfire, meat
Beach	ocean, sand / sea, sand / sand, lake / water, sand / sand, wave
Beaver	wood, animal / animal, dam / animal, river / animal, stream
Bee	animal, flower / animal, garden
Beehive	house, bee / tree, bee / forest, bee / wall, bee / wood, bee / bee, container
Beekeeper	human, beehive / farmer, beehive / human, bee / farmer, bee
Beer	wheat, alcohol
Bell	metal, sound / steel, sound / wood, sound / metal, hammer / steel, hammer
Bicycle	wheel, wheel / wheel, chain / wheel, machine
Big	universe, philosophy / galaxy, philosophy / galaxy cluster, philosophy / solar system, philosophy / sun, philosophy / planet, philosophy
Bird	sky, animal / air, animal / animal, airplane / sky, egg / air, egg / egg, airplane / time, dinosaur / time, pterodactyl
Birdcage	bird, container / bird, wall / bird, safe
Birdhouse	bird, house / bird, wall / egg, container
Black Hole	pressure, star / pressure, sun / star, darkness / sun, darkness
Blade	stone, metal / stone, steel / metal, rock / steel, rock
Blender	glass, blade / blade, electricity / blade, windmill / blade, wind turbine / blade, motion
Blizzard	storm, snow / snow, hurricane / tornado, snow / wind, snow / snow, snow / snow, big
Blood	human, blade / sword, warrior
Blood Bag	blood, container / blood, sack / blood, bottle
Boat	water, wood / ocean, wood / sea, wood / wood, lake / wood, river
Boiler	pressure, metal / pressure, tool / steam, metal / steam, tool / pressure, container
Bone	time, corpse / corpse, vulture / corpse, wolf / meat, wolf / meat, vulture
Bonsai Tree	tree, scissors / tree, pottery / tree, small / tree, wire
Book	paper, legend / wood, paper / newspaper, newspaper / story, container / fairy tale, container / legend, container / idea, container
Bottle	milk, container / water, container / coconut milk, container / juice, container / oil, container / alcohol, container / wine, container / beer, container / chocolate milk, container / soda, container / perfume, container / liquid, container
Boulder	big, rock / small, hill / rock, rock / stone, rock / earth, rock / stone, big
Bow	wood, rope / wood, wire
Box	pizza, container / pencil, container / cookie, container / cereal, container / donut, container / cake, container / crayon, container
Bread	fire, dough / dough, warmth / energy, dough
Brick	fire, mud / mud, sun / fire, clay / clay, sun / stone, clay
Bridge	wood, river / metal, river / steel, river / wood, stream / metal, stream / steel, stream
Broom	wood, hay
Bucket	wood, container / yogurt, container / river, bottle / paint, container / paint, bottle / chicken wing, container / chicken wing, box
Bullet	gunpowder, metal / gunpowder, steel / gunpowder, tool / gunpowder, container
Bulletproof Vest	bullet, armor / gun, armor
Bus	car, car / train, car / car, city / car, big
Butcher	human, meat / human, ham
Butter	pressure, milk / energy, milk / milk, motion / tool, milk
Butterfly	animal, flower / animal, garden / rainbow, animal / double rainbow!, animal
Butterfly Net	butterfly, net / bee, net
Cable Car	car, mountain / wire, mountain / car, mountain range / wire, mountain range / mountain, rope / rope, mountain range
Cactus	plant, sand / sand, tree / plant, desert / tree, desert
Cage	metal, wolf / steel, wolf / wolf, wall / metal, fox / steel, fox / wall, fox / metal, lion / steel, lion / wall, lion / hamster, container / house, hamster / wall, hamster
Cake	dough, candle / donut, candle / bread, sugar
Camel	desert, horse / desert, animal / livestock, desert / cow, desert / desert, saddle / desert, horseshoe / sand, horse / sand, livestock / sand, cow / dune, horse / livestock, dune / cow, dune / animal, dune
Campfire	fire, wood / wood, flamethrower
Candle	thread, wax / fire, wax / light, wax / flashlight, wax / lamp, wax
Candy Cane	Christmas tree, sugar / sugar, Christmas stocking / sugar, Santa / sugar, reindeer
Cannon	gunpowder, pirate ship / gunpowder, castle / gun, castle / gun, pirate ship
Canvas	fabric, paint
Car	metal, wheel / steel, wheel / bicycle, bicycle / wheel, bicycle / motorcycle, motorcycle / wheel, motorcycle / motorcycle, machine / wagon, combustion engine / cart, combustion engine
Caramel	sugar, heat
Carbon Dioxide	human, oxygen / plant, night / tree, night / grass, night / animal, oxygen / fish, oxygen / bird, oxygen
Carrot	snowman, vegetable / sun, snowman / grass, vegetable / garden, vegetable
Cart	wood, wheel
Cashmere	tool, mountain goat / thread, mountain goat / fabric, mountain goat / scissors, mountain goat / wool, mountain goat
Castle	stone, knight / knight, wall / house, knight / stone, warrior / warrior, wall / house, warrior / knight, container / house, vampire / vampire, wall / monarch, container / house, monarch / wall, monarch
Cat	milk, animal / animal, coconut milk / night, animal
Catnip	plant, cat / grass, cat / cat, flower
Cauldron	metal, witch / steel, witch / fireplace, witch / campfire, witch / metal, pottery / steel, pottery
Cave	house, wolf / house, lion / house, fox / house, bat / bat, container / wolf, container / lion, container / fox, container
Caviar	roe, salt / roe, cook
Centaur	human, horse / horse, story
Cereal	milk, wheat / wheat, chocolate milk / wheat, coconut milk
Chain	metal, rope / steel, rope / metal, wire / steel, wire
Chainsaw	axe, machine / axe, electricity / lumberjack, machine / lumberjack, electricity / axe, motion
Chameleon	lizard, rainbow / lizard, double rainbow! / rainbow, snake / double rainbow!, snake / turtle, rainbow / turtle, double rainbow!
Charcoal	fire, wood / fire, tree / fire, corpse / fire, organic matter
Cheese	tool, milk / time, milk / milk, cook / milk, bacteria
Cheeseburger	cheese, hamburger / cheese, sandwich
Chicken	bird, domestication / bird, livestock / bird, farmer / egg, domestication / egg, livestock / egg, farmer / bird, barn / egg, barn / bird, farm / egg, farm
Chicken Coop	house, chicken / chicken, wall / chicken, barn / chicken, container
Chicken Soup	water, chicken / water, chicken wing / chicken, liquid / chicken wing, liquid
Chicken wing	chicken, bone / chicken, BBQ
Chill	air, cold / human, cold / human, ice
Chimney	house, fireplace / smoke, brick / fireplace, brick / smoke, fireplace / house, smoke / stone, smoke / stone, fireplace
Chocolate	milk, sugar / oil, sugar / sugar, seed / coconut milk, choclate
Chocolate Milk	milk, chocolate / coconut milk, chocolate
Christmas Stocking	fireplace, wool / Christmas tree, wool / wool, reindeer / wool, Santa
Christmas Tree	tree, light bulb / tree, star / tree, candle / tree, light / tree, gift
Cigarette	tobacco, paper
City	village, village / skyscraper, skyscraper / village, skyscraper / skyscraper, container / bank, container / skyscraper, bank / bank, post office / skyscraper, post office / village, big
Clay	mud, sand / stone, liquid / sand, mineral / liquid, rock / stone, mineral / rock, mineral / mud, stone
Clock	time, electricity / time, wheel / time, tool / time, machine / sundial, machine / tool, sundial / wheel, sundial / electricity, sundial / cuckoo, container / watch, big
Closet	broom, container / container, toolbox / umbrella, container / vacuum cleaner, container / robot vacuum, container
Cloud	atmosphere, mist / water, atmosphere / sky, mist / water, sky
Coal	pressure, organic matter / earth, peat / stone, peat / rock, peat / time, peat / pressure, peat
Coconut	fruit, palm / palm, nuts / palm, vegetable / meat, palm / fruit, beach / beach, vegetable
Coconut Milk	milk, coconut / tool, coconut / coconut, hammer / sword, coconut / blade, coconut / axe, coconut
Coffin	wood, corpse / corpse, container / vampire, container
Cold	rain, human / human, mountain range / human, mountain / human, snow / wind, human / storm, human / space, thermometer
Combustion Engine	machine, petroleum / steam engine, petroleum / wheel, petroleum / explosion, machine / explosion, steam engine
Computer	tool, hacker / electricity, hacker / wire, hacker / hacker, machine / email, container
Computer Mouse	computer, mouse / animal, computer
Confetti	paper, scissors / blade, paper
Constellation	star, star
Container	safe, philosophy / pottery, philosophy / house, philosophy / philosophy, box / philosophy, bottle / philosophy, bucket
Continent	big, land / land, land / mountain range, mountain range / earth, land
Cook	human, fruit / human, campfire / human, vegetable / human, nuts
Cookbook	recipe, recipe / book, cook
Cookie	cookie dough, heat / fire, cookie dough / baker, cookie dough / cookie dough, cookie cutter / dough, cookie cutter
Cookie Cutter	blade, dough / blade, cookie dough
Cookie Dough	dough, sugar / dough, chocolate / dough, cookie
Coral	ocean, tree / sea, tree / ocean, fossil / sea, fossil / ocean, bone / sea, bone
Corpse	bullet, human / human, blade / human, death / human, grim reaper / time, human / explosion, human / human, arrow
Cotton	cloud, plant / plant, fabric / plant, thread / plant, wool / plant, sheep
Cotton Candy	air, sugar / sugar, thread / cloud, sugar
Cow	livestock, barn / field, livestock / livestock, grass / farmer, livestock
Crayon	rainbow, pencil / double rainbow!, pencil / rainbow, wax / double rainbow!, wax / pencil, paint / wax, paint
Crow	bird, scarecrow / bird, field / scarecrow, pigeon / field, pigeon / owl, scarecrow / field, owl / scarecrow, hummingbird / field, hummingbird
Crystal Ball	glass, witch / glass, wizard / glass, magic / witch, snow globe / wizard, snow globe / snow globe, magic
Cuckoo	bird, clock / clock, owl / clock, hummingbird / bird, alarm clock / owl, alarm clock / alarm clock, hummingbird
Cup	smoothie, container / tea, container / milkshake, container / smoothie, bottle / tea, bottle / milk shake, bottle
Current	ocean, motion / sea, motion / ocean, heat / sea, heat / ocean, cold / sea, cold / ocean, science / sea, science
Cutting Board	wood, cook
Cyborg	human, robot / engineer, robot / lumberjack, robot / robot, sailor / robot, baker / robot, cook / doctor, robot / farmer, robot / firefighter, robot / robot, pilot / astronaut, robot / electrician, robot
Cyclist	human, bicycle / human, wheel
Dam	beaver, river / wall, river / tree, beaver / beaver, stream / wall, stream / house, beaver / beaver, lake / water, beaver
Darkness	sky, night / sky, twilight
Dawn	time, night / day, night
Day	sky, sun / sun, night / time, sun / time, dawn
Death	time, life / corpse, philosophy / skeleton, philosophy / grave, philosophy / graveyard, philosophy
Desert	sand, sand / sand, land / sand, cactus / sand, lizard / sand, vulture
Dew	grass, fog / water, grass / plant, fog / tree, fog / grass, dawn / plant, dawn / tree, dawn / water, dawn / fog, dawn
Diamond	pressure, coal
Dinosaur	time, lizard / lizard, big
Diver	human, scuba tank / swimmer, scuba tank / ocean, scuba tank / sea, scuba tank / lake, scuba tank
Doctor	human, hospital / human, stethoscope
Dog	wolf, domestication / farmer, wolf / wolf, farm / barn, wolf / field, wolf / wolf, bone / campfire, wolf
Doge	dog, internet / dog, computer
Doghouse	house, dog / dog, wall / dog, container / house, husky / wall, husky / husky, container
Domestication	farmer, animal / human, animal / animal, science / farmer, science
Don Quixote	windmill, knight / windmill, story / windmill, legend / windmill, hero
Donut	dough, oil / oil, cookie dough / wheel, dough / wheel, cookie dough
Double Rainbow!	rainbow, rainbow
Dough	water, flour / flour, puddle / rain, flour
Dragon	fire, lizard / air, lizard / sky, lizard / lizard, airplane / lizard, legend / lizard, story
Drone	airplane, robot / robot, helicopter / robot, paper airplane / robot, seaplane
Drum	wood, leather / wood, fabric / wood, music
Drunk	human, alcohol / human, wine / human, beer
Dry Ice	cold, carbon dioxide / ice, carbon dioxide
Duck	water, bird / bird, pond / bird, lake / time, duckling / duckling, big / water, owl / owl, pond / owl, lake / water, pigeon / pond, pigeon / pigeon, lake / water, chicken / chicken, pond / chicken, lake
Duckling	egg, duck
Dune	wind, desert / wind, sand / wind, beach / sand, desert / desert, sandstorm
Dust	earth, air / air, soil / air, land
Dynamite	gunpowder, wire / gunpowder, pipe / gunpowder, container
Eagle	bird, mountain / bird, mountain range
Earthquake	earth, motion / motion, continent
Eclipse	moon, sun
Egg	bird, bird / turtle, turtle / lizard, lizard / vulture, vulture / phoenix, phoenix / chicken, chicken / dragon, dragon / penguin, penguin / owl, owl / dinosaur, dinosaur / duck, duck / seagull, seagull / eagle, eagle / scorpion, scorpion / spider, spider / pigeon, pigeon / fish, fish / piranha, piranha / parrot, parrot / peacock, peacock / hummingbird, hummingbird / chameleon, chameleon / ostrich, ostrich / woodpecker, woodpecker / bee, bee / crow, crow / frog, frog / pterodactyl, pterodactyl / ant, ant / tyrannosaurus rex, tyrannosaurus rex / moth, moth / life, container / butterfly, butterfly / snake, snake / flying fish, flying fish
Egg Timer	egg, clock / egg, alarm clock / egg, watch
Electric Car	electricity, car / electricity, wagon / car, wind turbine / wagon, wind turbine / solar cell, car / solar cell, wagon
Electric Eel	fish, electricity
Electrician	human, electricity / human, wire
Electricity	wind, wind turbine / wind turbine, motion / storm, wind turbine / sandstorm, wind turbine / sun, solar cell / light, solar cell / solar cell, star / metal, lightning / steel, lightning / storm, science
Email	computer, letter / letter, internet / letter, computer mouse / electricity, letter
Energy	fire, atmosphere / fire, science / heat, science / fire, fire
Engineer	human, machine / human, steam engine
Eruption	pressure, volcano / lava, pressure / volcano, time
Excalibur	stone, sword / sword, legend / sword, story / sword, monarch / sword, lake / sword, fairy tale
Explosion	fire, gunpowder / gunpowder, electricity / gunpowder, lightning / pressure, volcano / fire, petroleum / explosion, petroleum / pressure, petroleum / heat, petroleum / lava, petroleum / volcano, petroleum
Fabric	thread, machine / tool, thread / wheel, thread
Fairy Tale	story, monarch / story, castle / knight, story / dragon, story / unicorn, story
Family	human, human / human, house / love, container
Family tree	tree, family / tree, village / time, family
Farm	farmer, house / farmer, barn / house, barn / farmer, container / house, tractor
Farmer	plant, human / human, grass / human, pitchfork / human, field / human, barn / human, plow
Faun	human, goat / human, mountain goat / goat, legend / mountain goat, legend / goat, wizard / wizard, mountain goat / goat, magic / mountain goat, magic
Fence	wood, wall / wood, field / field, wall / grass, wall / garden, wall / wood, garden
Field	earth, farmer / farmer, land / earth, tool / tool, land / earth, plow / land, plow / farmer, soil / tool, soil / soil, plow
Fire Extinguisher	fire, carbon dioxide / pressure, carbon dioxide / metal, carbon dioxide / steel, carbon dioxide / boiler, carbon dioxide
Firefighter	fire, human / human, firetruck / human, fire extinguisher
Fireplace	campfire, house / campfire, brick / campfire, wall / wood, container / campfire, container
Firestation	house, firefighter / house, firetruck / firefighter, land / firefighter, village / firefighter, city
Firetruck	firefighter, car / firefighter, wagon / fire, car / fire, wagon / car, fire extinguisher / wagon, fire extinguisher
Fireworks	sky, explosion / explosion, atmosphere
Fish	water, animal / animal, lake / sea, animal / ocean, animal / water, egg / egg, lake / sea, egg / ocean, egg
Fishing Rod	tool, fish / wood, fish / fish, wire / tool, swordfish / wood, swordfish / wire, swordfish / tool, piranha / wood, piranha / wire, piranha / fish, thread / swordfish, thread / piranha, thread
Flamethrower	fire, gun / volcano, gun / campfire, gun
Flashlight	tool, light / tool, light bulb / human, lamp / tool, lamp
Flood	rain, rain / rain, river / rain, lake / rain, big / rain, time / house, river / river, city / tsunami, city / house, tsunami
Flour	wheat, wheat / stone, wheat / wheat, windmill / wheel, wheat / wheat, rock
Flower	plant, garden / grass, garden / grass, seed / garden, seed / plant, rainbow / plant, double rainbow! / grass, rainbow / grass, double rainbow!
Flute	wind, wood / air, wood
Flying Fish	bird, fish / sky, fish / air, fish
Flying Squirrel	bird, squirrel / squirrel, hummingbird / squirrel, pigeon / seagull, squirrel / air, squirrel / airplane, squirrel / squirrel, seaplane / squirrel, helicopter
Fog	earth, cloud / cloud, hill / cloud, mountain / cloud, city / cloud, field / cloud, forest
Force Knight	human, light sword / warrior, light sword / knight, light sword
Forest	tree, tree / plant, tree / tree, land / earth, tree / tree, container
Fortune Cookie	paper, cookie / paper, cookie dough / paper, gingerbread man
Fossil	earth, dinosaur / stone, dinosaur / dinosaur, rock / time, dinosaur / time, bone / earth, bone / stone, bone / stone, corpse / time, grave / bone, rock / corpse, rock / earth, skeleton / stone, skeleton / skeleton, rock / time, skeleton
Fountain	water, statue / statue, stream
Fox	chicken, animal / chicken, wolf / chicken, dog / wolf, chicken coop / animal, chicken coop / dog, chicken coop
Frankensteins Monster	corpse, legend / corpse, lightning / corpse, electricity / corpse, story / zombie, electricity / zombie, lightning / story, monster / corpse, monster / story, monster / corpse, monster
French Fries	oil, vegetable / oil, potato / fire, potato
Fridge	metal, cold / steel, cold / cold, machine / metal, ice / steel, ice / electricity, cold / cold, container / ice, container / ice cream, container
Frog	animal, pond / egg, pond / egg, puddle / animal, puddle
Frozen Yogurt	cold, yogurt / ice, yogurt
Fruit	time, flower / water, flower / rain, flower / tree, flower / tree, farmer / farmer, orchard
Fruit Tree	tree, fruit / wood, fruit / plant, fruit
Galaxy	solar system, solar system / star, star / star, solar system / space, space / space, solar system / star, space / solar system, container / supernova, container / star, container
Galaxy Cluster	galaxy, galaxy / galaxy, container
Garage	house, car / house, ambulance / house, motorcycle / house, bus / car, container / ambulance, container / motorcycle, container / bus, container / car, wall / wall, ambulance / wall, motorcycle / wall, bus / barn, car / barn, ambulance / barn, motorcycle / barn, bus / house, sleigh / sleigh, container / wall, sleigh / barn, sleigh / house, electric car / electric car, container / wall, electric car / barn, electric car / house, snowmobile / snowmobile, container / wall, snowmobile / barn, snowmobile / house, tractor / tractor, container / wall, tractor / barn, tractor / house, RV / RV, container / wall, RV / barn, RV / house, ice cream truck / ice cream truck, container / wall, ice cream truck / barn, ice cream truck
Garden	plant, grass / plant, house / flower, flower / grass, flower / plant, flower / house, flower / flower, lawn / plant, lawn / flower, container
Gardener	human, garden / farmer, garden
Gas	air, idea / air, science / energy, liquid
Geyser	earth, steam / steam, hill / steam, mountain / steam, pressure
Ghost	graveyard, night / grave, night / night, gravestone / night, castle / graveyard, story / graveyard, legend / grave, legend / grave, story / gravestone, legend / gravestone, story / night, story / night, legend
Gift	Christmas tree, Santa / Santa, Christmas stocking / Santa, chimney / fireplace, Santa / cookie, Santa / milk, Santa / Santa, wrapping paper / Christmas tree, wrapping paper / Christmas stocking, wrapping paper / fireplace, wrapping paper
Gingerbread House	house, gingerbread man / house, dough / house, cookie dough / house, cookie / house, donut / house, cake
Gingerbread Man	life, dough / dough, magic / life, cookie / cookie, magic / story, cookie / life, cookie dough / cookie dough, magic / story, cookie dough / dough, story
Glacier	ice, mountain / snow, mountain / ice, mountain range / snow, mountain range / time, ice
Glass	fire, sand / sand, heat / sand, electricity / sand, lightning
Glasses	glass, metal / glass, steel / glass, glass / glass, human / human, lens / lens, lens
Gnome	garden, statue / garden, story / garden, fairy tale / garden, legend
Goat	livestock, mountain / livestock, hill / livestock, mountain range / cow, mountain / cow, hill / cow, mountain range
Gold	metal, sun / steel, sun / metal, rainbow / steel, rainbow / metal, butter / steel, butter / sand, metal / sand, steel / metal, light / steel, light / metal, alchemist / steel, alchemist
Golem	clay, story / clay, legend / life, statue / story, statue / statue, legend
Granite	lava, pressure / pressure, stone / pressure, rock
Grass	earth, plant / plant, land
Grave	earth, coffin / field, coffin / earth, corpse / field, corpse / forest, corpse / forest, coffin / grave, gravestone / coffin, gravestone / coffin, container
Gravestone	stone, grave / grave, rock / stone, death / rock, death / stone, graveyard / graveyard, rock
Graveyard	grave, grave / field, grave / grave, land / gravestone, gravestone / field, gravestone / gravestone, land / gravestone, container
Greenhouse	plant, glass / glass, grass / glass, tree / plant, aquarium / aquarium, grass / aquarium, tree / plant, container / glass, garden
Grenade	explosion, metal / explosion, steel / explosion, warrior
Grilled Cheese	cheese, toast
Grim Reaper	human, scythe / corpse, scythe / zombie, scythe / scythe, death / boat, scythe / scythe, river / death, deity / death, deity
Gun	metal, bullet / bullet, steel / metal, bow / steel, bow / bullet, bow / gunpowder, bow / bullet, container
Gunpowder	charcoal, mineral / fire, dust / energy, mineral / energy, charcoal / energy, dust
Gust	wind, small / air, small
Hacker	human, computer / human, computer mouse / human, glasses / human, internet
Hail	cloud, ice / rain, ice / storm, ice / wind, ice / steam, ice / sky, ice
Ham	meat, smoke / smoke, pig
Hamburger	bread, meat / cheese, meat
Hammer	metal, tool / steel, tool / stone, tool / tool, rock / tool, woodpecker
Hamster	wheel, mouse / mouse, domestication / rat, domestication / wheel, rat
Hangar	airplane, container / house, airplane / airplane, wall / airplane, barn / seaplane, container / house, seaplane / wall, seaplane / barn, seaplane / helicopter, container / house, helicopter / wall, helicopter / barn, helicopter / rocket, container / house, rocket / wall, rocket / barn, rocket / spaceship, container / house, spaceship / wall, spaceship / barn, spaceship
Harp	angel, music / angel, musician / wire, angel / wire, music
Hay	grass, scythe / farmer, grass / grass, sun / grass, grass / grass, barn / grass, farm / grass, pitchfork / barn, pitchfork / pitchfork, farm / farmer, pitchfork
Hay Bale	hay, hay / hay, tractor / barn, hay / hay, machine
Heat	fire, idea / fire, science / lava, philosophy / air, energy
Hedge	plant, fence / leaf, fence / garden, fence / plant, wall / wall, leaf / garden, wall
Hedgehog	animal, needle / mouse, needle / needle, rat
Helicopter	blade, airplane / windmill, airplane / airplane, wind turbine / blade, seaplane / windmill, seaplane / seaplane, wind turbine
Hero	human, legend / dragon, knight / human, story / human, lightning
Hill	big, boulder / mountain, small / earth, boulder / stone, boulder / boulder, boulder
Hippo	horse, river / water, horse / cow, river / water, cow
Honey	flower, bee / bee, beehive / time, bee / bee, bee / beehive, beekeeper
Horizon	earth, sky / sky, continent / sky, land / ocean, sky / sea, sky / sky, lake
Horse	field, animal / livestock, hay / animal, land / livestock, barn / livestock, horseshoe / animal, horseshoe / animal, saddle / livestock, saddle
Horseshoe	metal, horse / steel, horse
Hospital	house, sickness / house, ambulance / house, doctor / sickness, wall / wall, ambulance / doctor, wall / doctor, container
Hot Chocolate	chocolate milk, heat / chocolate, heat
Hourglass	sand, glass / sand, time / glass, time / sand, container / time, container
House	wall, wall / human, wall / tool, wall / fireplace, container / family, container
Human	time, animal / life, clay / time, monkey / tool, animal / tool, monkey
Hummingbird	bird, flower / owl, flower / pigeon, flower / seagull, flower / bird, garden / owl, garden / garden, pigeon / garden, seagull / bird, small / bird, bee / bird, butterfly
Hurricane	ocean, tornado / sea, tornado / ocean, storm / sea, storm
Husky	snow, dog / ice, dog / Antarctica, dog / dog, arctic / blizzard, dog / dog, glacier
Ice	water, cold / water, solid / cold, puddle / puddle, solid
Ice Cream	milk, cold / milk, ice / milk, snow
Ice Cream Truck	car, ice cream / ice cream, bus / ice cream, wagon
Ice Sculpture	ice, statue
Iceberg	sea, ice / ocean, ice / sea, Antarctica / ocean, Antarctica / sea, arctic / ocean, arctic
Iced Tea	ice, tea / cold, tea / snow, tea
Idea	human, light bulb / light bulb, engineer / light bulb, science / science, science / engineer, engineer / hacker, hacker / lumberjack, lumberjack / farmer, farmer / firefighter, firefighter / electrician, electrician / astronaut, astronaut / warrior, warrior / butcher, butcher / doctor, doctor / pilot, pilot / baker, baker / sailor, sailor / surfer, surfer / swimmer, swimmer / cyclist, cyclist / knight, knight / monarch, monarch / angler, angler / mailman, mailman / gardener, gardener / philosophy, philosophy / science, philosophy / skier, skier / diver, diver / librarian, librarian / alchemist, alchemist
Igloo	house, ice / house, snow / house, cold / house, snowman
Internet	computer, computer / wire, computer / computer, web / computer, net
Island	volcano, ocean / volcano, sea
Ivy	plant, wall / grass, wall
Jack-O-Lantern	fire, pumpkin / pumpkin, candle / light, pumpkin / night, pumpkin / ghost, pumpkin / skeleton, pumpkin / skeleton, vegetable / ghost, vegetable / night, vegetable
Jam	juice, sugar / fruit, machine / fruit, juice / juice, machine / fruit, heat
Jar	jam, container / jam, bottle / glass, jam / jam, bucket
Jerky	meat, sun / sun, steak / meat, heat / steak, heat
Juice	pressure, fruit / earth, fruit / stone, fruit / fruit, rock / explosion, fruit / water, fruit / pressure, vegetable / stone, vegetable / vegetable, rock / explosion, vegetable / water, vegetable
Jupiter	cloud, planet / storm, planet / planet, big / planet, gas / big, Saturn
Kaiju	dinosaur, city / dinosaur, skyscraper / dinosaur, legend / dinosaur, story
Katana	blade, heat / blade, shuriken / sword, shuriken / blade, ninja / sword, ninja
Kite	wind, paper / sky, paper / air, paper
Knife	blade, cook / sword, cook
Knight	human, armor / warrior, armor / warrior, hero / warrior, horse
Lake	water, pond / pond, big / sea, small / pond, pond
Lamp	metal, light bulb / steel, light bulb
Land	soil, soil / big, soil / earth, earth / earth, stone / small, continent
Lasso	cow, rope / horse, rope / pig, rope / wild boar, rope / sheep, rope / goat, rope
Lava	fire, earth / earth, heat / earth, liquid
Lava Lamp	lava, lamp / fire, lamp / volcano, lamp
Lawn	grass, container / house, grass / field, lawn mower / grass, lawn mower
Lawn Mower	tool, grass / electricity, scythe / scythe, helicopter / scythe, windmill / field, helicopter / tool, scythe / scythe, machine / grass, machine / scythe, motion
Leaf	wind, tree / wind, flower / wind, orchard / wind, forest
Leather	blade, cow / blade, pig / blade, sheep / cow, sword / sword, pig / sword, sheep / tool, cow / tool, sheep / tool, pig
Legend	time, story / story, big / story, story / story, fairy tale / time, fairy tale
Lens	glass, tool / glass, engineer
Letter	paper, pencil
Librarian	human, library / human, book
Library	book, container / house, book
Life	electricity, primordial soup / time, primordial soup / storm, primordial soup / volcano, primordial soup / ocean, electricity / sea, electricity / electricity, lake / ocean, lightning / sea, lightning / lake, lightning / primordial soup, lightning
Light	electricity, light bulb / electricity, flashlight
Light Bulb	glass, electricity / glass, light / light, container
Light Sword	light, sword / energy, sword / electricity, sword / sword, space / sword, force knight
Lighthouse	ocean, light / sea, light / house, light / beach, light / ocean, spotlight / sea, spotlight / house, spotlight / beach, spotlight
Lightning	cloud, electricity / storm, electricity / rain, electricity / energy, storm / energy, cloud / energy, rain / storm, land
Lion	animal, cat / blood, cat / cat, big / cat, monarch
Liquid	water, idea / water, science / energy, solid
Little Alchemy	small, alchemist
Livestock	field, animal / farmer, animal / animal, domestication / animal, barn
Lizard	stone, animal / animal, rock / stone, egg / egg, rock / dinosaur, small / swamp, animal / swamp, egg / blood, cold
Log cabin	wood, house
Love	human, human
Lumberjack	human, axe / human, chainsaw / human, wood / tree, human
Mac and Cheese	cheese, pasta
Machine	tool, wheel / tool, tool / boiler, wheel / boiler, tool / boiler, chain / tool, chain / tool, engineer
Magic	life, rainbow / life, double rainbow! / energy, wizard / energy, witch
Magma	lava, science / volcano, science
Mailbox	letter, box / mailman, box / metal, letter / steel, letter / wood, letter / metal, mailman / steel, mailman / wood, mailman
Mailman	human, letter / human, newspaper / letter, mailbox
Manatee	sea, cow / ocean, cow / fish, cow / cow, lake / cow, river
Map	paper, land / paper, hill / mountain, paper / paper, mountain range / paper, continent / ocean, paper / sea, paper / paper, lake / paper, river / paper, city / paper, village
Maple Syrup	heat, sap / sugar, sap
Mars	rust, planet / desert, planet
Marshmallows	campfire, sugar
Mayonnaise	egg, oil
Meat	tool, livestock / tool, chicken / tool, pig / tool, cow / tool, animal / tool, fish / tool, swordfish / tool, flying fish / tool, shark / tool, frog / axe, livestock / axe, chicken / axe, pig / axe, cow / axe, animal / axe, fish / axe, swordfish / axe, flying fish / axe, shark / axe, frog / livestock, sword / chicken, sword / sword, pig / cow, sword / animal, sword / sword, shark / livestock, butcher / chicken, butcher / pig, butcher / cow, butcher / animal, butcher / fish, butcher / butcher, swordfish / butcher, flying fish / butcher, shark / butcher, frog / fish, net / swordfish, net / shark, net / piranha, net / flying fish, net
Medusa	human, snake / snake, legend / snake, story / snake, hero
Mercury	planet, small / planet, heat
Mermaid	human, fish / fish, legend / fish, magic / swimmer, magic / fish, swimmer
Metal	fire, ore / heat, ore / tool, ore
Meteor	atmosphere, meteoroid / sky, meteoroid / air, meteoroid / night, meteoroid / day, meteoroid
Meteoroid	stone, space / space, rock / space, boulder / stone, solar system / solar system, rock / solar system, boulder / sun, rock / stone, sun / sun, boulder
Microscope	glass, bacteria / bacteria, glasses / bacteria, safety glasses / tool, lens / bacteria, lens
Milk	farmer, cow / tool, cow / water, cow / farmer, goat / tool, goat / water, goat / cow, liquid / goat, liquid
Milk Shake	milk, ice cream / ice cream, yogurt / water, ice cream
Mineral	stone, organic matter / rock, organic matter / earth, organic matter / boulder, organic matter / hill, organic matter / mountain, organic matter
Minotaur	human, cow / cow, werewolf / cow, story / cow, legend
Mirror	glass, metal / glass, steel / glass, wood
Mist	water, air / air, steam / air, rain
Mold	time, bread / bread, bacteria / bacteria, vegetable / fruit, bacteria / time, vegetable / time, fruit
Monarch	human, castle / human, Excalibur
Money	paper, gold / diamond, paper / paper, bank
Monkey	tree, animal
Moon	sky, cheese / sky, planet / sky, stone / night, planet / stone, night / earth, night / cheese, night / sky, time
Moon Rover	moon, car / moon, electric car
Moss	plant, stone / stone, grass / stone, algae / plant, rock / grass, rock / algae, rock / plant, boulder / grass, boulder / algae, boulder
Moth	moon, butterfly / night, butterfly / butterfly, candle / light, butterfly / lamp, butterfly / flashlight, butterfly
Motion	wind, science / wind, idea / wind, philosophy / tornado, science / tornado, philosophy / stream, science / stream, philosophy / river, philosophy / river, science
Motorcycle	bicycle, machine / steel, bicycle / metal, bicycle / steam engine, bicycle / bicycle, combustion engine
Mountain	big, hill / earth, earthquake / earth, hill / hill, hill / earthquake, hill / earth, big
Mountain Goat	mountain, goat / goat, mountain range
Mountain Range	mountain, mountain / mountain, continent
Mouse	cheese, animal / cheese, barn / house, cheese / cheese, farm / cheese, wall
Mousetrap	wood, cheese / metal, cheese / steel, cheese / blade, mouse
Mud	water, earth / water, soil
Mummy	corpse, pyramid / pyramid, fabric / corpse, fabric / human, pyramid
Music	flute, musician / sheet music, musician / drum, musician / musician, pan flute
Musician	human, flute / human, music / human, sheet music / human, drum / human, pan flute
Narwhal	fish, unicorn / ocean, unicorn / sea, unicorn / water, unicorn / unicorn, shark / unicorn, swordfish / unicorn, flying fish
Needle	metal, thread / steel, thread / tool, thread
Nessie	lake, legend / story, lake / dinosaur, legend / dinosaur, story
Nest	tree, bird / bird, hay / egg, hay / tree, egg / bird, grass / egg, grass / bird, house / egg, container
Net	angler, rope / fish, rope / swordfish, rope / fishing rod, rope / flying fish, rope
Newspaper	paper, paper / paper, story / letter, letter
Night	sky, moon / time, day / time, moon / time, twilight
Ninja	human, shuriken / human, katana
Ninja Turtle	turtle, ninja / turtle, shuriken / turtle, katana
Nuts	tree, farmer / tree, domestication / tree, field
Oasis	water, desert / desert, puddle / desert, pond / desert, lake / desert, river / desert, stream / tree, desert / desert, palm
Obsidian	water, lava / lava, cold / lava, glass
Ocean	water, sea / sea, big / tide, container / sea, sea
Oil	pressure, sunflower / stone, sunflower / wheel, sunflower / sunflower, windmill
Omelette	fire, egg / egg, heat / egg, tool
Optical Fiber	wire, light / light, rope / light, internet
Orchard	fruit tree, fruit tree / field, fruit tree / tree, fruit tree / farmer, fruit tree / fruit tree, farm / forest, fruit tree / fruit tree, container
Ore	hammer, boulder / earth, hammer / hammer, rock / stone, hammer / hammer, hill / mountain, hammer
Organic Matter	life, death / life, science / bacteria, death / corpse, science
Origami	bird, paper / animal, paper / paper, eagle / paper, seagull / owl, paper / paper, pigeon / cow, paper / horse, paper / dog, paper / paper, cat / paper, lion / paper, hummingbird / chicken, paper / penguin, paper / duck, paper / paper, vulture
Ostrich	earth, bird / sand, bird / earth, eagle / sand, eagle / earth, chicken / sand, chicken / bird, big
Owl	bird, night / bird, wizard / bird, twilight / bird, moon
Oxygen	plant, sun / tree, sun / grass, sun / sun, algae / plant, carbon dioxide / tree, carbon dioxide / grass, carbon dioxide / algae, carbon dioxide
Ozone	oxygen, oxygen / electricity, oxygen / electricity, atmosphere / air, electricity
Paint	water, rainbow / water, double rainbow! / water, pencil / pottery, rainbow / tool, rainbow / pottery, double rainbow! / tool, double rainbow! / rainbow, liquid / double rainbow!, liquid / pencil, liquid
Painter	human, paint / human, canvas / human, painting
Painting	canvas, painter / paint, canvas
Paleontologist	human, dinosaur / human, fossil / dinosaur, science / fossil, science
Palm	tree, beach / island, tree / sand, tree
Pan Flute	flute, flute
Paper	pressure, wood / water, wood / wood, machine / wood, blender
Paper Airplane	airplane, paper
Paper Cup	paper, cup
Parachute	pilot, fabric / pilot, umbrella / airplane, fabric / airplane, umbrella / sky, umbrella / atmosphere, umbrella
Park	forest, city / forest, village / garden, city / garden, village / grass, city / grass, village / field, city / field, village
Parrot	bird, pirate / bird, pirate ship / pirate, pigeon / pigeon, pirate ship
Pasta	egg, flour
Peacock	bird, leaf / bird, double rainbow!, bird, rainbow
Peanut Butter	butter, nuts / pressure, nuts
Peat	plant, swamp / pressure, swamp / time, swamp / time, grass
Pebble	stone, small / earth, small / small, rock
Pegasus	bird, horse / sky, horse / bird, unicorn / sky, unicorn
Pencil	wood, charcoal / coal, wood
Pencil Sharpener	blade, pencil / pencil, blender / sword, pencil
Penguin	bird, Antarctica / bird, cold / bird, ice / bird, snow / animal, Antarctica
Penicillin	doctor, mold / mold, science / idea, mold / hospital, mold
Perfume	water, flower / steam, flower / alcohol, flower / water, rose / steam, rose / alcohol, rose / water, sunflower / steam, sunflower / sunflower, alcohol
Petroleum	pressure, fossil / time, fossil / fossil, liquid / water, fossil
Philosophy	human, idea / human, story / egg, chicken
Phoenix	fire, bird / fire, death / fire, life / fire, egg
Picnic	grass, sandwich / sandwich, beach / sandwich, fabric / sandwich, lawn / sandwich, garden
Pie	dough, fruit / fruit, cookie dough / dough, meat / fruit, baker / fruit, bakery
Pig	mud, livestock / mud, animal / mud, cow
Pigeon	bird, letter / bird, city / bird, statue / bird, skyscraper / bird, village
Piggy Bank	pig, money / pottery, pig / pig, gold
Pilot	human, airplane / human, seaplane
Pinocchio	life, wood / golem, story / wood, story
Pipe	wood, tobacco / tool, tobacco / tobacco, container
Piranha	fish, blood / fish, wolf
Pirate	sword, sailor / sailor, pirate ship / gun, sailor / bayonet, sailor
Pirate Ship	sailboat, pirate / boat, pirate / steam engine, pirate / pirate, container / house, pirate
Pitchfork	tool, hay / metal, hay / steel, hay
Pizza	cheese, dough / cheese, bread / cheese, wheel
Planet	continent, continent / ocean, continent / earth, space / earth, solar system / earth, sky
Plankton	water, life / ocean, life / sea, life / water, bacteria / ocean, bacteria / sea, bacteria
Plant	tree, small / water, seed / soil, seed / land, seed / earth, seed / grass, big / algae, land / earth, algae / life, soil / rain, soil
Plasma	star, science / sun, science / pressure, heat / heat, heat
Platypus	beaver, duck / bird, beaver / beaver, seagull
Plow	earth, metal / metal, field / earth, steel / steel, field / earth, wood / wood, field / tool, field
Polar Bear	animal, ice / animal, arctic
Pollen	dust, plant / wind, plant / dust, flower / wind, flower
Pond	water, puddle / puddle, big / lake, small / puddle, puddle
Popsicle	ice, juice / cold, juice / wood, juice / snow, juice
Post Office	house, mailman / wall, mailman / mailman, container / house, letter / wall, letter / letter, mailman / letter, letter
Potato	earth, vegetable
Potter	human, pottery / human, clay
Pottery	clay, wheel / clay, tool
Pressure	air, air / atmosphere, atmosphere / air, atmosphere / geyser, science / ocean, ocean
Primordial Soup	lava, ocean / lava, sea / ocean, planet / earth, ocean / sea, planet / earth, sea
Printer	paper, computer / newspaper, computer
Prism	glass, rainbow / glass, double rainbow! / rainbow, crystal ball / double rainbow!, crystal ball
Pterodactyl	air, dinosaur / sky, dinosaur / airplane, dinosaur / bird, dinosaur / dinosaur, eagle / dinosaur, vulture
Puddle	water, water / pond, small
Pumpkin	field, vegetable / farmer, vegetable / vegetable, jack-o-lantern / plant, jack-o-lantern
Pyramid	stone, desert / grave, desert / graveyard, desert / desert, mountain / desert, hill / desert, gravestone / mummy, container
Quicksand	sand, swamp
Quicksilver	metal, liquid
Rabbit	animal, carrot / rabbit, rabbit
Rain	cloud, heat / fire, idea / fire, science
Rainbow	rain, sun / rain, light / water, light / cloud, light / water, sun / sun, prism / light, prism
Rainforest	rain, forest
Rat	animal, pirate ship / sailboat, animal / mouse, pirate ship / sailboat, mouse / mouse, city / mouse, skyscraper / mouse, village / mouse, big
Recipe	flour, paper / meat, paper / paper, baker / paper, bakery / paper, vegetable / fruit, paper / flour, newspaper / meat, newspaper / newspaper, baker / newspaper, vegetable / newspaper, bakery / newspaper, vegetable / fruit, newspaper / paper, cook
Reed	plant, pond / plant, puddle / grass, pond / grass, puddle / swamp, grass / plant, swamp / plant, river / grass, river
Reindeer	animal, Santa / livestock, Santa / Christmas tree, animal / livestock, Christmas tree / animal, Christmas stocking
Ring	diamond, metal / diamond, gold / diamond, steel / love, gold / diamond, love / metal, love / steel, love / love, gold
River	lake, motion / big, stream / water, mountain / rain, mountain / rain, hill
Rivulet	puddle, motion / stream, small
Robot	life, armor / metal, life / steel, life / metal, golem / steel, golem / golem, armor
Robot Vacuum	robot, vacuum cleaner / robot, broom / computer, vacuum cleaner / computer, broom
Rock	big, pebble / small, boulder / pebble, pebble / stone, pebble / earth, pebble
Rocket	airplane, atmosphere / metal, atmosphere / steel, atmosphere / train, atmosphere / atmosphere, machine / boat, atmosphere / steamboat, atmosphere / atmosphere, car / atmosphere, pirate ship
Roe	egg, fish / water, egg / ocean, egg / sea, egg / egg, lake / egg, flying fish
Roller Coaster	train, park / car, park / cart, park / wagon, park
Rope	thread, thread / wire, thread / tool, wire / tool, sailboat / tool, pirate ship / tool, boat
Rose	plant, love / love, flower / blade, flower / plant, blade
Ruins	time, castle / time, house / time, village / time, city / time, skyscraper / time, farm / time, hospital
Ruler	wood, pencil
Rust	air, metal / air, steel / wind, metal / wind, steel / metal, oxygen / steel, oxygen
RV	house, car / house, bus
Sack	flour, container / salt, container / letter, container
Saddle	horse, leather / tool, horse / horse, fabric
Safe	metal, money / steel, money / metal, gold / steel, gold / gun, container / gold, container
Safety Glasses	tool, glasses / explosion, glasses / engineer, glasses / glasses, bulletproof vest / armor, glasses
Sailboat	wind, boat / boat, fabric / wind, steamboat / steamboat, fabric
Sailor	human, boat / human, sailboat / human, steamboat / ocean, human / sea, human / human, lake
Salt	ocean, sun / sea, sun / fire, ocean / fire, sea / ocean, mineral / sea, mineral
Sand	air, stone / wind, stone / air, rock / wind, rock / air, pebble / wind, pebble
Sand Castle	sand, castle / beach, castle / desert, castle / dune, castle
Sandpaper	sand, paper / sand, fabric
Sandstone	stone, sand / sand, rock / earth, sand
Sandstorm	storm, sand / tornado, sand / sand, motion / storm, desert / tornado, desert / wind, desert / desert, motion
Sandwich	bread, meat / bread, bacon / cheese, bread / bread, vegetable / bread, ham
Santa	human, Christmas tree / human, Christmas stocking / Christmas tree, legend / Christmas stocking, legend / Christmas tree, story / story, Christmas stocking
Sap	tree, blade
Saturn	ring, planet / small, Jupiter
Scalpel	blade, doctor / blade, hospital / blade, ambulance / sword, doctor / sword, hospital / sword, ambulance
Scarecrow	human, hay / hay, statue / golem, hay / statue, farm / barn, statue / pumpkin, sack / jack-o-lantern, sack / hay, sack
Science	human, telescope / human, microscope / human, universe
Scissors	blade, blade / sword, sword / blade, sword / blade, paper / sword, paper
Scorpion	animal, dune / sand, animal / dune, spider / sand, spider / desert, spider
Scuba Tank	air, container / atmosphere, container / oxygen, container
Scythe	blade, grass / blade, wheat / grass, sword / wheat, sword / axe, grass / axe, wheat
Sea	water, lake / lake, big / ocean, small / lake, lake
Seagull	sea, bird / ocean, bird / bird, beach / sea, pigeon / ocean, pigeon / beach, pigeon / sea, rat / ocean, rat / beach, rat
Seahorse	ocean, horse / sea, horse / water, horse / fish, horse / horse, lake
Seal	sea, dog / ocean, dog / dog, arctic / dog, lake / water, dog
Seaplane	sea, airplane / ocean, airplane / airplane, lake / water, airplane
Seasickness	boat, sickness / steamboat, sickness / sailboat, sickness / ocean, sickness / sea, sickness / sickness, lake
Seaweed	ocean, plant / sea, plant / plant, lake / ocean, grass / sea, grass
Seed	plant, pollen / bee, pollen / time, flower
Sewing Machine	needle, machine / electricity, needle / robot, needle / thread, machine / electricity, thread / robot, thread
Shark	ocean, blood / sea, blood / ocean, wolf / sea, wolf / fish, blood / fish, wolf
Sheep	livestock, wool / livestock, hill / livestock, land / cloud, livestock / goat, domestication / mountain goat, domestication
Sheet Music	paper, music / music, book
Shovel	tool, gardner
Shuriken	blade, star / sword, star / metal, star / steel, star / blade, ninja
Sickness	human, bacteria / swamp, human / human, sickness
Silo	wheat, container / house, wheat / wheat, barn / wheat, wall / wheat, farm / wheat, safe / wheat, bank
Skateboard	wheel, snowboard / wheel, skier / wheel, ski goggles
Skeleton	time, corpse / bone, bone / corpse, bone
Ski Goggles	snow, glasses / snow, sunglasses / cold, glasses / cold, sunglasses / glasses, glacier / glacier, sunglasses / glasses, skier / sunglasses, skier
Skier	human, ski goggles / human, mountain / human, mountain range
Sky	air, cloud / sun, atmosphere / light, atmosphere / moon, sun
Skyscraper	sky, house / sky, village / house, big / cloud, house
Sleigh	snow, cart / snow, wagon / ice, cart / ice, wagon / cart, arctic / wagon, arctic / Antarctica, cart / Antarctica, wagon
Sloth	time, animal / tree, manatee
Small	bacteria, philosophy / oxygen, philosophy / carbon dioxide, philosophy / ozone, philosophy / pebble, philosophy / rivulet, philosophy / ant, philosophy / spider, philosophy / bee, philosophy / confetti, philosophy / scorpion, philosophy / seahorse, philosophy
Smog	smoke, fog / fog, city / smoke, city / atmosphere, city / air, city
Smoke	earth, gas / water, campfire / time, campfire / storm, campfire / fire, plant / fire, grass / fire, tree / fire, wood / fire, air
Smoke Signal	campfire, fabric / smoke, fabric / smoke, letter
Smoothie	fruit, blender / fruit, ice / fruit, cold
Snake	animal, rope / wire, animal / electric eel, land
Snow	rain, cold / steam, cold / rain, mountain / rain, mountain range
Snow Globe	snow, crystal ball / snowman, crystal ball / snowball, crystal ball / crystal ball, snowmobile / Santa, crystal ball / Christmas tree, crystal ball / Christmas stocking, crystal ball / blizzard, crystal ball / ice, crystal ball / cold, crystal ball / glass, snow / glass, snowman / glass, snowball / glass, snowmobile / glass, Santa / glass, Christmas tree / glass, Christmas stocking / glass, blizzard
Snowball	stone, snow / snow, rock / earth, snow / human, snow
Snowboard	wood, snow / snow, surfer / wood, ice / ice, surfer / mountain, surfer / surfer, mountain range
Snowman	human, snow / snow, carrot / snowball, carrot / coal, snow / coal, snowball / snowball, snowball
Snowmobile	snow, motorcycle / snow, car / glacier, motorcycle / car, glacier / ice, motorcycle / ice, car
Soap	ash, oil / ash, wax / oil, wax / clay, wax / clay, oil
Soda	water, carbon dioxide / juice, carbon dioxide / carbon dioxide, tea
Soil	earth, life / earth, organic matter / life, land / land, organic matter
Solar Cell	tool, sun / tool, light / sun, machine / sun, electricity / energy, sun
Solar System	planet, planet / sun, planet / sun, container / planet, container / Mars, container / Mercury, container / Venus, container / Jupiter, container
Solid	earth, idea / earth, science
Sound	air, wave / human, wave / wave, wolf / wave, animal
Space	sky, star / sun, star / moon, star / night, solar system / sky, solar system
Space Station	house, space / space, wall / space, village / house, atmosphere / atmosphere, wall / atmosphere, village
Spaceship	airplane, space / metal, space / steel, space / space, pirate ship / boat, space / steamboat, space / car, space / astronaut, container
Spaghetti	thread, pasta / wire, pasta / pasta, rope
Sphinx	lion, statue / desert, statue / statue, pyramid / stone, lion
Spider	animal, thread / animal, web / animal, net
Spotlight	light, machine / metal, light / steel, light
Sprinkles	sugar, confetti / rainbow, sugar / double rainbow!, sugar / sugar, paint
Squirrel	tree, mouse / plant, mouse / mouse, nuts / animal, nuts
Star	sky, night / night, telescope / space, telescope / sky, space / night, space / sun, space
Starfish	fish, star / sea, star / ocean, star
Statue	stone, hammer / hammer, boulder / human, medusa / hacker, medusa / engineer, medusa / lumberjack, medusa / pilot, medusa / sailor, medusa / firefighter, medusa / farmer, medusa / surfer, medusa / astronaut, medusa / butcher, medusa / doctor, medusa / baker, medusa / drunk, medusa / mirror, medusa
Steak	meat, BBQ / fire, cow / cow, BBQ / fire, meat
Steam	water, heat / water, fire / water, lava / water, gas
Steam Engine	steam, machine / steam, wheel / boiler, wheel
Steamboat	steam engine, boat / steam engine, sailboat / steam engine, pirate ship / ocean, steam engine / sea, steam engine
Steel	metal, charcoal / coal, metal / metal, mineral / ash, metal
Steel Wool	steel, wool / metal, wool / wire, wool
Stethoscope	tool, doctor / doctor, drum / doctor, sound / tool, sound / tool, hospital
Stone	earth, solid / earth, pressure / air, lava
Storm	cloud, electricity / electricity, atmosphere / cloud, cloud / rain, wind
Story	human, campfire / human, hero
Stream	pond, motion / big, rivulet / river, small
String Phone	wire, paper cup / thread, paper cup / wire, cup / thread, cup
Stun Gun	gun, electricity / electricity, bow / energy, gun / energy, bow / gun, wire
Sugar	fire, juice / energy, juice / energy, fruit / fire, fruit / fire, alcohol / energy, alcohol / fire, beer / energy, beer / fire, wine / energy, wine
Sun	sky, light / fire, sky / day, space / sky, day / fire, planet / light, planet / light, day
Sundial	wheel, sun / wheel, day / wheel, light / tool, sun / tool, day / tool, light / sun, watch / sun, clock / light, watch / clock, light
Sunflower	plant, sun / sun, flower
Sunglasses	sun, glasses / beach, glasses / day, glasses / sky, glasses / light, glasses
Supernova	explosion, star / explosion, sun / explosion, galaxy / explosion, space
Surfer	human, wave / human, beach
Sushi	fish, seaweed / caviar, seaweed
Swamp	mud, grass / mud, tree / algae, lake / algae, pond / lake, reed / pond, reed / tree, lake
Sweater	tool, wool / human, wool
Swim Goggles	water, glasses / water, sunglasses / glasses, lake / sunglasses, lake / sea, glasses / sea, sunglasses / ocean, glasses / ocean, sunglasses / glasses, river / sunglasses, river
Swimmer	water, human / human, swim goggles / human, pond / human, swimming pool
Swimming Pool	house, lake / house, swimmer / aquarium, big
Sword	blade, wood / metal, blade / steel, blade
Swordfish	fish, sword / blade, fish / sword, shark / blade, shark
Syringe	doctor, needle / tool, needle
Tank	armor, car / gun, car / metal, car / steel, car
Tea	water, leaf / human, leaf / leaf, heat
Telescope	sky, glass / glass, star / glass, space / glass, moon / glass, planet / glass, Mercury / glass, Mars / glass, Jupiter / glass, Saturn / glass, galaxy / glass, galaxy cluster / glass, universe / glass, supernova
Tent	wood, fabric / house, fabric / village, fabric / wall, fabric
The One Ring	volcano, ring / ring, magic
Thermometer	glass, quicksilver / tool, quicksilver / engineer, quicksilver
Thread	tool, cotton / cotton, cotton / wheel, cotton / cotton, machine
Tide	ocean, moon / sea, moon / ocean, time / sea, time
Titanic	steamboat, iceberg / boat, iceberg / iceberg, legend / steamboat, legend
Toast	fire, bread / fire, sandwich / bread, warmth / sandwich, warmth
Tobacco	plant, smoke / grass, smoke / fire, plant
Tool	metal, human / steel, human / human, wood / stone, human / human, rock / metal, wood / steel, wood / stone, wood / wood, rock
Toolbox	tool, container / tool, safe / hammer, container / hammer, box / tool, box / ruler, container / ruler, box / steel wool, container / steel wool, box / chain, box / chain, container
Tornado	storm, storm / storm, wind / storm, motion / wind, big / wind, wind / wind, motion
Toucan	bird, rainbow / bird, palm / palm, seagull / palm, pigeon / palm, owl / bird, double rainbow!
Tractor	farmer, car / field, car / farmer, wagon / field, wagon / cow, car / cow, wagon
Train	steel, steam engine / metal, steam engine / steam engine, wheel / steam engine, wagon
Trainyard	train, container / train, house / train, wall / train, garage
Treasure	pirate, treasure map / pirate ship, treasure map / island, treasure map / sailor, treasure map
Treasure Map	pirate, map / map, pirate ship / map, treasure / island, map
Tree	plant, big / plant, wood / nest, container
Treehouse	tree, house / tree, wood
Trojan Horse	wood, horse / horse, machine / horse, statue
Tsunami	ocean, earthquake / sea, earthquake / ocean, explosion / sea, explosion / ocean, meteor / sea, meteor
Tunnel	engineer, mountain / engineer, mountain range / engineer, hill / train, mountain / train, mountain range / train, hill / mountain, cave / hill, cave / mountain range, cave
Turtle	sand, egg / beach, animal / lizard, beach / egg, beach
Twilight	day, night / time, day
Tyrannosaurus Rex	meat, dinosaur / blood, dinosaur / dinosaur, monarch
UFO	rocket, alien / airplane, alien / alien, spaceship / alien, space station / sky, alien / alien, container
Umbrella	rain, tool / rain, fabric / storm, fabric / storm, tool
Unicorn	horse, legend / rainbow, horse / double rainbow!, horse / horse, story / horse, magic
Universe	galaxy cluster, galaxy cluster / space, container / galaxy cluster, container
Vacuum Cleaner	electricity, broom / broom, machine
Vampire	human, blood / human, vampire / human, bat
Vase	plant, pottery / pottery, flower / rose, container / flower, container / pottery, rose / rose, bottle / flower, bottle / plant, bottle
Vault	safe, big
Vegetable	field, farmer / forest, farmer / plant, farmer / plant, field / plant, domestication
Venus	acid rain, planet / planet, smog / volcano, planet
Village	house, house / family, family / house, container / bakery, container / house, bakery
Vine	rope, rainforest / thread, rainforest / wire, rainforest
Vinegar	wine, oxygen / air, wine / time, wine
Volcano	lava, mountain / fire, mountain / pressure, mountain / earth, lava / lava, hill / fire, hill / pressure, hill / lava, container
Vulture	bird, corpse / corpse, eagle / corpse, hummingbird / corpse, owl / corpse, pigeon / corpse, penguin / chicken, corpse / corpse, duck / bird, desert / desert, eagle / desert, hummingbird / desert, owl / desert, pigeon / desert, penguin / desert, duck
Wagon	horse, cart / cart, fabric / house, cart / cart, wall / cow, cart
Wall	brick, brick / wood, wood / stone, stone
Wand	wood, wizard / sword, wizard / tool, wizard / pencil, wizard
Warmth	air, heat / human, heat
Warrior	human, sword / human, bow
Watch	human, clock / clock, small
Water Gun	water, gun / gun, stream / gun, puddle
Water Lily	pond, flower / flower, puddle / flower, lake / flower, stream
Water Pipe	water, pipe
Waterfall	mountain, river / river, mountain range / river, hill / mountain, lake / mountain range, lake / lake, hill
Wave	ocean, wind / ocean, storm / sea, wind / sea, storm / wind, lake / storm, lake / ocean, hurricane / sea, hurricane / lake, hurricane
Wax	bee, beehive / wall, beehive / blade, beehive / sword, beehive / tool, beehive / beehive, beekeeper
Web	thread, spider / cotton, spider / fabric, spider / spider, net
Werewolf	human, wolf / human, werewolf
Wheat	grass, domestication / farmer, grass / field, grass
Wheel	tool, motion / stone, motion / metal, motion / steel, motion / water, tool / tool, stream / tool, river
Wild Boar	animal, pig / forest, pig / pig, hill
Wind	air, motion / atmosphere, motion / air, pressure
Wind Turbine	electricity, windmill / windmill, machine / electrician, windmill / electricity, wind
Windmill	wind, house / wind, wheel / wind, wheat / wind, flour / wheel, wall
Windsurfer	wind, surfer
Wine	fruit, alcohol
Wire	metal, electricity / steel, electricity / electricity, rope / metal, rope / steel, rope
Witch	wizard, broom / human, broom / broom, legend / story, broom / broom, magic / broom, cauldron / cauldron, legend / story, cauldron
Wizard	human, magic / human, rainbow / human, double rainbow! / human, unicorn
Wolf	moon, animal / animal, dog / forest, dog / blood, dog
Wood	tree, tool / tree, axe / tree, chainsaw / tree, sword / tree, lumberjack / tool, forest / axe, forest / forest, chainsaw / forest, lumberjack
Woodpecker	bird, wood / tree, bird / bird, forest
Wool	tool, sheep / scissors, sheep / blade, sheep
Wrapping Paper	paper, gift / Christmas tree, paper / paper, Christmas stocking / paper, Santa
Yeti	mountain, story / story, mountain range / glacier, story / Antarctica, story / mountain, legend / mountain range, legend / glacier, legend / Antarctica, legend /
Yogurt	milk, bacteria / bacteria, ice cream
Zombie	life, corpse / corpse, story / corpse, bacteria / human, zombie
Zoo	animal, container / animal, cage
