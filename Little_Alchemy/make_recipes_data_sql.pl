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
      printf $sql_statement_format, $product, $ingredient_1, $ingredient_2;
  }
}

exit 0;

__END__
# https://www.ign.com/wikis/little-alchemy/Little_Alchemy_Cheats_-_List_of_All_Combinations
# Air	Available from start.
# Earth	Available from start.
# Fire	Available from start.
# Water	Available from start.
Acid Rain	rain, smoke / rain, smog
Airplane	bird, steel / bird, metal
Alarm Clock	clock, sound
Alcohol	fruit, time / juice, time
Algae	water, plant / sea, plant / ocean, plant
Alien	life, space
Allergy	human, dust
Alligator	lizard, swamp / lizard, river
Alpaca	mountain, sheep
Ambulance	car, hospital / car, doctor
Angel	human, bird
Angler	human, fishing rod
Ant	grass, wild animal / wild animal, sugar
Antarctica	snow, desert / ice, desert
Aquarium	water, glass / glass, fish
Archipelago	isle, isle
Armadillo	wild animal, armor
Armor	tool, metal / tool, steel
Ash	volcano, energy
Astronaut	human, moon / rocket, human / human, space station / human, space
Astronaut Ice Cream	ice cream, astronaut
Atmosphere	air, pressure / sky, pressure
Atomic Bomb	energy, explosion
Aurora	sun, Antarctica / sky, Antarctica / Antarctica, atmosphere
Avalanche	energy, snow
Axe	blade, wood
Bacon	pig, fire
Bacteria	swamp, life
Baker	human, flour / human, bread / human, dough
Bakery	house, baker / house, bread
Banana	fruit, monkey
Banana Bread	bread, banana
Bandage	blood, fabric
Bank	house, money / house, gold / house, safe
Barn	cow, house / livestock, house / house, hay
Bat	mouse, bird / mouse, sky
Batman	bat, human
Batter	flour, milk
Bayonet	gun, blade / gun, sword
BBQ	campfire, meat / campfire, garden
Beach	sea, sand / ocean, sand
Beaver	wild animal, wood / wild animal, dam
Bee	flower, wild animal
Beehive	bee, house / bee, tree
Beer	alcohol, wheat
Bicycle	wheel, wheel
Bird	air, life / life, sky / egg, air / egg, sky
Birdhouse	bird, house
Black Hole	star, pressure
Blade	metal, stone
Blender	glass, blade / blade, electricity
Blizzard	snow, snow / snow, storm / snow, wind
Blood	human, blade
Blueprint	engineer, paper
Boat	water, wood
Boiler	steam, metal
Bone	corpse, time
Bonsai Tree	tree, pottery / tree, scissors
Book	paper, wood / paper, story
Bread	dough, fire
Brick	clay, fire / mud, fire / mud, sun / clay, sun
Bridge	river, wood / river, metal / river, steel
Broom	wood, hay
Bullet	gunpowder, metal
Bulletproof Vest	bullet, armor
Bus	car, car
Butcher	human, meat
Butter	energy, milk / milk, pressure
Butterfly	flower, wild animal
Cactus	desert, plant / sand, plant
Cake	dough, candle
Camel	desert, wild animal / desert, horse / livestock, desert
Campfire	fire, wood
Candle	wax, thread / wax, fire
Candy Cane	sugar, Christmas tree
Cannon	gunpowder, pirate ship / gunpowder, castle
Cape	hero, fabric
Car	wheel, metal
Caramel	sugar, fire
Carbon Dioxide	human, oxygen / plant, night / tree, night
Carrot	snowman, vegetable / sun, snowman
Cart	wheel, wood
Cashmere	tool, mountain goat / thread, mountain goat / fabric, mountain goat / scissors, mountain goat / wool, mountain goat
Castle	house, knight
Cat	wild animal, milk
Catnip	cat, plant
Cauldron	metal, witch / steel, witch / fireplace, witch / campfire, witch
Caviar	hard roe, human
Centaur	horse, human
Cereal	wheat, milk
Chain	metal, rope / steel, rope
Chainsaw	axe, electricity
Chameleon	lizard, rainbow
Charcoal	fire, wood
Cheese	time, milk
Cheeseburger	cheese, hamburger
Chicken	egg, livestock / livestock, bird / bird, farmer
Chicken Soup	water, chicken
Chicken wing	chicken, bone
Chimney	house, fireplace / smoke, brick / fireplace, brick
Christmas Stocking	wool, fireplace
Christmas Tree	light bulb, tree / tree, star
Cigarette	tobacco, paper
City	village, village / skyscraper, skyscraper
Clay	sand, mud
Clock	time, tool / time, wheel / time, electricity
Cloud	air, steam
Coal	pressure, plant / sun, snowman
Coconut	palm, fruit
Coconut Milk	coconut, tool / milk, coconut
Coffin	wood, corpse
Cold	human, rain
Computer	electricity, nerd / wire, nerd / tool, nerd
Computer Mouse	mouse, computer
Confetti	paper, blade / paper, scissors
Cookbook	book, recipe / recipe, recipe
Constellation	star, star
Cookie	dough, sugar
Corpse	human, gun / human, grim reaper
Cotton	plant, cloud
Cow	grass, livestock
Crayon	rainbow, pencil / rainbow, wax
Crow	bird, scarecrow / bird, field
Crown	gold, monarch / metal, monarch
Crystal Ball	witch, glass / wizard, glass
Cuckoo	clock, bird
Cyborg	human, robot
Cyclist	bicycle, human
Dam	beaver, river / beaver, tree / beaver, wood / wall, river
Darth Vader	jedi, fire / jedi, lava
Day	sun, time / night, sun / time, night / sky, sun
Desert	sand, sand / sand, cactus
Dew	water, grass / fog, grass
Diamond	pressure, coal
Dinosaur	lizard, time
Doctor	human, hospital
Dog	wild animal, human
Doge	dog, computer
Doghouse	dog, house
Don Quixote	windmill, knight
Donut	dough, oil
Double Rainbow!	rainbow, rainbow
Dough	flour, water
Dragon	lizard, fire
Drone	airplane, robot
Drum	wood, leather
Drunk	human, alcohol / beer, human / human, wine
Dry Ice	carbon dioxide, cold / ice, carbon dioxide
Duck	bird, lake / water, bird / bird, pond / time, duckling
Duckling	egg, duck
Dune	sand, wind / desert, wind / beach, wind
Dust	earth, air / sun, vampire / day, vampire
Dynamite	gunpowder, wire
Eagle	mountain, bird
Earthquake	earth, energy / earth, wave
Eclipse	sun, moon
Egg	life, stone / bird, bird / turtle, turtle / lizard, lizard
Egg Timer	egg, clock / egg, watch
Electric Car	car, electricity
Electric Eel	fish, electricity
Electrician	human, electricity / human, wire
Electricity	metal, energy / solar cell, sun / wind turbine, wind / light, solar cell
Email	letter, computer / letter, internet
Energy	air, fire / plant, sun
Engineer	human, tool
Eruption	volcano, energy
Excalibur	sword, stone
Explosion	gunpowder, fire
Fabric	thread, tool
Fairy Tale	story, monarch / story, castle / knight, story / dragon, story
Family	human, house
Family tree	tree, family
Farm	farmer, house / farmer, barn
Farmer	human, plant / field, human / human, pitchfork
Faun	goat, human
Fence	wall, wood
Field	earth, farmer / earth, tool
Fire Extinguisher	fire, carbon dioxide / pressure, carbon dioxide / metal, carbon dioxide
Fireman	human, fire / human, firetruck
Fireplace	house, campfire / campfire, brick / campfire, wall
Firetruck	fireman, car
Fireworks	explosion, sky
Fish	hard roe, time
Fish and Chips	fish, French fries
Fishing Rod	tool, fish / wood, fish
Flamethrower	fire, gun
Flashlight	tool, light
Flood	rain, rain / rain, time
Flour	wheat, stone / windmill, wheat
Flower	plant, garden
Flute	wood, wind
Flying Fish	fish, bird / sky, fish
Flying Squirrel	squirrel, bird / squirrel, wind / squirrel, airplane / sky, squirrel
Fog	earth, cloud
Forest	tree, tree
Fortune Cookie	paper, cookie
Fossil	dinosaur, time / dinosaur, earth / stone, dinosaur
Fountain	statue, water
Fox	chicken, wild animal
Frankenstein	zombie, electricity / electricity, corpse
French fries	oil, vegetable
Fridge	metal, cold / electricity, cold / metal, ice
Frog	wild animal, pond
Fruit	tree, farmer / sun, tree
Fruit Tree	fruit, tree
Galaxy	star, star
Garden	plant, plant / flower, flower / plant, grass / house, grass
Gardener	human, garden
Geyser	steam, earth
Ghost	graveyard, night / castle, night
Gift	Santa, Christmas tree / Santa, Christmas stocking / Santa, cookie / Santa, chimney / Santa, fireplace
Gingerbread house	house, dough / house, gingerbread man
Gingerbread man	life, dough
Glacier	ice, mountain
Glass	fire, sand / sand, electricity
Glasses	glass, metal / glass, glass
Gnome	garden, statue
Goat	livestock, mountain
Godzilla	dinosaur, city
Gold	metal, sun / metal, rainbow
Golem	clay, life
Granite	lava, pressure
Grass	plant, earth
Grave	coffin, earth / corpse, earth
Gravestone	grave, stone
Graveyard	grave, grave / gravestone, gravestone
Greenhouse	plant, glass / window, window
Grenade	explosion, metal
Grilled cheese	cheese, toast
Grim Reaper	human, scythe / corpse, scythe
Gun	metal, bullet
Gunpowder	fire, dust
Hail	rain, ice / ice, storm / ice, cloud
Ham	meat, smoke
Hamburger	meat, bread
Hammer	metal, wood
Hamster	wheel, mouse
Hard Roe	egg, water / egg, sea / egg, ocean / egg, pond / fish, fish
Harp	angel, music
Hay	farmer, grass / grass, scythe / grass, sun
Hay bale	hay, hay
Hedge	plant, fence / leaf, fence
Helicopter	blade, airplane / windmill, airplane
Herb	plant, sickness / sickness, leaf
Hero	knight, dragon
Hippo	horse, river / horse, water
Honey	bee, flower / bee, beehive
Horizon	sky, earth / sea, sky / ocean, sky
Horse	hay, livestock
Horseshoe	metal, horse
Hospital	house, sickness / house, ambulance / house, doctor
Hourglass	sand, glass
House	wall, wall
Human	earth, life
Hummingbird	bird, flower
Hurricane	wind, energy
Husky	snow, dog / ice, dog
Ice	water, cold
Iceberg	sea, ice / ocean, ice / sea, Antarctica / ocean, Antarctica
Ice Cream	milk, ice
Ice cream truck	car, ice cream
Iced tea	ice, tea / cold, tea
Idea	human, light bulb / light bulb, nerd
Igloo	house, ice / house, snow
Internet	computer, computer / computer, wire / computer, web
Isle	ocean, volcano / volcano, sea
Ivy	plant, wall
Jack-O-Lantern	pumpkin, fire / blade, pumpkin / pumpkin, candle
Jam	juice, sugar
Jedi	lightsaber, human / knight, lightsaber
Jerky	meat, sun / meat, salt
Juice	water, fruit / pressure, fruit
Keyboard Cat	cat, music
Kite	wind, paper / sky, paper
Knight	human, armor
Lake	water, pond / river, dam
Lamp	metal, light bulb
Lasso	cow, rope / horse, rope
Lava	earth, fire
Lava Lamp	lava, lamp
Lawn Mower	grass, tool / electricity, scythe
Leaf	tree, wind
Leather	cow, blade / pig, blade
Lemonade	fruit, water
Letter	paper, pencil
Library	house, book
Life	swamp, energy / love, time
Light	light bulb, electricity / electricity, flashlight
Light Bulb	electricity, glass
Lighthouse	light, house / light, beach / light, ocean / light, sea
Lightsaber	light, sword / energy, sword / electricity, sword
Lion	wild animal, cat
Livestock	farmer, life / wild animal, human / farmer, wild animal
Lizard	egg, swamp
Log cabin	wood, house
Love	human, human
Lumberjack	axe, human / human, chainsaw
Mac and Cheese	cheese, pasta
Mailman	human, letter
Manatee	cow, sea
Map	paper, earth
Mars	rust, planet
Marshmallows	sugar, campfire
Mayonnaise	egg, oil
Meat	cow, tool / livestock, butcher / cow, butcher / pig, butcher / pig, tool / blade, livestock
Medusa	human, snake
Mermaid	human, fish
Metal	fire, stone
Meteor	meteoroid, atmosphere / sky, meteoroid
Meteoroid	stone, space
Microscope	glass, bacteria / bacteria, glasses
Milk	farmer, cow / cow, human
Milk Shake	milk, ice cream
Minotaur	human, cow
Mirror	glass, metal
Mold	time, bread
Monarch	human, castle / Excalibur, human / crown, human
Money	paper, gold
Monkey	tree, wild animal
Moon	sky, cheese / sky, stone
Moss	plant, stone / algae, stone
Moth	moon, butterfly / night, butterfly
Motorcycle	bicycle, energy / bicycle, steel
Mountain	earthquake, earth
Mountain Goat	mountain, goat / goat, mountain range
Mountain Range	mountain, mountain
Mouse	cheese, wild animal
Mousetrap	wood, cheese / metal, cheese
Mud	water, earth
Mummy	corpse, pyramid
Music	human, flute / human, sound
Narwhal	unicorn, ocean / unicorn, water / sea, unicorn
Needle	metal, thread / metal, hay
Nerd	human, glasses
Nessie	story, lake
Nest	bird, tree / bird, hay / egg, hay
Newspaper	paper, paper
Night	moon, time / time, day / sky, moon
Ninja	shuriken, human
Ninja Turtle	turtle, ninja
Nut	tree, squirrel / fruit, squirrel
Oasis	desert, water
Obsidian	lava, water
Ocean	sea, sea / water, sea
Oil	sunflower, pressure
Oil Lamp	clay, oil / potter, oil / oil, rope / glass, oil / fire, oil
Omelette	egg, fire
Optical Fiber	wire, light
Orchard	fruit tree, fruit tree / field, fruit tree
Origami	bird, paper
Ostrich	bird, earth / bird, sand
Owl	night, bird / bird, wizard
Oxygen	plant, sun / plant, carbon dioxide
Ozone	oxygen, oxygen / oxygen, electricity
Paint	water, rainbow / water, pencil
Palm	isle, tree / tree, beach
Paper	wood, pressure
Paper Airplane	airplane, paper
Parachute	pilot, fabric / pilot, umbrella
Parrot	bird, pirate
Pasta	flour, egg
Peacock	bird, rainbow
Pegasus	bird, horse / sky, horse / bird, unicorn
Pencil	wood, coal / wood, charcoal
Pencil Sharpener	blade, pencil
Penguin	ice, wild animal / ice, bird / bird, snow
Penicillin	doctor, mold
Perfume	water, rose / water, flower / steam, rose / steam, flower / alcohol, rose / alcohol, flower
Petroleum	fossil, time / fossil, pressure
Phoenix	fire, bird
Picnic	grass, sandwich / beach, sandwich
Pie	dough, fruit
Pig	livestock, mud
Pigeon	bird, city / bird, letter / bird, statue
Piggy Bank	pig, money / pottery, pig
Pillow	cotton, fabric
Pilot	airplane, human / seaplane, human
Pinocchio	wood, life
Pipe	tobacco, wood
Piranha	fish, blood
Pirate	sword, sailor / sailor, pirate ship
Pirate Ship	sailboat, pirate / boat, pirate
Pitchfork	tool, hay
Pizza	cheese, dough
Planet	earth, space
Plankton	water, life / sea, life
Plant	rain, earth
Platypus	beaver, duck
Pond	water, garden
Popsicle	juice, ice
Pottery	fire, clay / clay, wheel / clay, tool
Pressure	earth, earth / air, air
Printer	paper, computer
Prism	glass, rainbow
Pterodactyl	air, dinosaur / bird, dinosaur
Puddle	snowman, flamethrower / sun, ice / sun, snowman
Pumpkin	vegetable, fire / vegetable, light
Pyramid	desert, stone / desert, grave
Quicksand	sand, swamp
Rabbit	wild animal, carrot
Rain	water, air
Rainbow	rain, sun / rain, light
Rat	wild animal, pirate ship / sailboat, wild animal
Recipe	flour, paper / paper, baker
Reindeer	Santa, wild animal / livestock, Santa
Ring	diamond, metal / diamond, gold
River	mountain, water / rain, mountain
Robot	metal, life / steel, life / life, armor
Rocket	airplane, space
Roller Coaster	train, mountain / mountain, cart
Roomba	robot, vacuum cleaner
Rope	thread, thread
Rose	plant, love / flower, love
Ruins	time, castle / time, house
Ruler	wood, pencil
Rust	air, metal / metal, oxygen / steel, oxygen / air, steel
RV	car, house
Saddle	horse, leather
Safe	metal, money / metal, gold / steel, money / steel, gold
Safety Glasses	explosion, glasses / tool, glasses / engineer, glasses
Sailboat	boat, wind / boat, fabric
Sailor	human, boat / human, sailboat
Salt	sea, sun / ocean, sun / fire, sea / fire, ocean
Sand	air, stone
Sand Castle	sand, castle
Sandpaper	sand, paper
Sandstone	stone, sand
Sandstorm	sand, energy / sand, storm / sand, hurricane
Sandwich	bread, ham / cheese, bread / bread, bacon
Santa	human, Christmas tree
Saturn	ring, planet
Scalpel	blade, doctor / blade, hospital
Scarecrow	human, hay
Scissors	blade, blade
Scorpion	wild animal, sand / wild animal, dune
Scythe	blade, grass / blade, wheat
Sea	water, water
Seagull	bird, sea / bird, ocean / bird, beach
Seahorse	horse, sea / ocean, horse / fish, horse
Seal	dog, sea
Seaplane	airplane, water / airplane, ocean / airplane, sea
Seasickness	sickness, sea / sickness, ocean / boat, sickness / steamboat, sickness / sailboat, sickness
Seaweed	plant, sea / plant, ocean
Sewing Machine	electricity, needle / robot, needle
Shark	ocean, wild animal / sea, wild animal / sea, blood / blood, ocean
Sheep	cloud, livestock
Sheet Music	paper, music
Shuriken	star, blade
Sickness	human, bacteria / human, sickness / human, rain
Skateboard	snowboard, wheel
Skeleton	corpse, time / bone, bone
Ski Goggles	glasses, snow
Sky	air, cloud
Skyscraper	house, sky
Sledge	snow, cart / snow, wagon
Sloth	wild animal , time
Smog	smoke, fog / fog, city
Smoke	fire, wood
Smoke Signal	campfire, fabric / smoke, fabric
Smoothie	fruit, blender
Snake	wild animal, wire
Snow	steam, cold
Snowball	snow, human
Snowboard	wood, snow / snow, surfer
Snow globe	glass, snow / snow, crystal ball
Snowman	snow, human / snowball, snowball / snow, carrot / snowball, carrot
Snowmobile	snow, motorcycle / snow, car
Soap	oil, ash
Soap Bubble	air, soap / water, soap
Soda	water, carbon dioxide / juice, carbon dioxide
Solar Cell	sun, tool
Solar System	sun, planet
Sound	air, wave
Space	sky, star / sun, star / moon, star
Spaceship	airplane, astronaut
Space Station	space, house
Spaghetti	thread, pasta
Sphinx	human, lion
Spider	wild animal, thread
Sprinkles	sugar, confetti
Squirrel	mouse, tree
Star	sky, night / night, telescope
Starfish	fish, star / sea, star / ocean, star
Statue	stone, tool / human, medusa
Steak	fire, cow / meat, BBQ
Steam	water, fire / water, energy
Steamboat	steam engine, water / steam engine, boat
Steam Engine	boiler, tool / boiler, wheel
Steel	metal, coal
Steel Wool	steel, wool / wire, wool
Stethoscope	tool, doctor
Stone	air, lava
Storm	energy, cloud / cloud, electricity
Story	human, campfire
Sugar	fruit, energy / juice, fire / juice, energy
Sun	fire, sky
Sundial	clock, sun
Sunflower	plant, sun / flower, sun
Sunglasses	sun, glasses / beach, glasses
Super nova	explosion, star
Surfer	human, wave
Sushi	fish, seaweed / caviar, seaweed
Swamp	mud, plant / mud, grass
Sweater	wool, tool / human, wool
Swim Goggles	glasses, water
Swimmer	human, swim goggles
Sword	blade, metal / blade, steel
Swordfish	fish, sword
Tank	car, armor / car, gun
Taser	gun, electricity
Tea	water, leaf
Telescope	glass, sky / glass, star / glass, space
Tent	wood, fabric / house, fabric
The One Ring	volcano, ring
Thread	cotton, tool / wheel, wool
Tide	sea, moon / ocean, moon
Time	sand, glass
Titanic	steamboat, iceberg
Toast	sandwich, fire / bread, fire
Tobacco	plant, fire
Tool	metal, human
Toucan	bird, rainbow
Tractor	farmer, car / field, car
Train	steam engine, steel / steam engine, metal / steam engine, wheel / steam engine, wagon
Treasure	pirate, treasure map
Treasure map	pirate, map
Tree	plant, time
Treehouse	tree, house
Trojan Horse	horse, wood
Tsunami	ocean, earthquake / sea, earthquake
Tunnel	engineer, mountain
Turtle	egg, sand
Twilight	day, night
Tyrannosaurus Rex	meat, dinosaur
UFO	rocket, alien / airplane, alien
Umbrella	tool, rain / rain, fabric
Unicorn	rainbow, horse / rainbow, life / double rainbow!, horse / double rainbow!, life
Vacuum Cleaner	electricity, broom
Vampire	human, blood / human, vampire
Vase	plant, pottery / pottery, flower
Vegetable	field, fruit
Village	house, house
Vinegar	time, wine / air, wine / wine, oxygen
Volcano	lava, earth / lava, mountain / fire, mountain
Vulture	bird, corpse
Wagon	cart, horse
Wall	brick, brick
Wallet	leather, money
Wand	wizard, wood
Warrior	sword, human
Watch	human, clock
Water Gun	water, gun
Water Lilly	flower, pond
Water Pipe	water, pipe
Waterfall	mountain, river
Waterwheel	water, wheel / wheel, river
Wave	ocean, wind / sea, wind
Wax	bee, beehive
Web	spider, thread
Werewolf	wolf, human / werewolf, human
Wheat	field, farmer / plant, farmer
Wheel	tool, wood
Wild Animal	forest, life
Wild Boar	pig, wild animal / pig, forest
Wind	pressure, air / air, energy
Windmill	house, wind / wheel, wind
Wind Turbine	windmill, electricity
Window	glass, house
Wine	fruit, alcohol
Wire	electricity, metal
Witch	human, broom / wizard, broom
Wizard	human, energy
Wolf	dog, forest / wild animal, moon / wild animal, dog
Wood	tool, tree
Woodpecker	bird, wood
Wool	sheep, tool / scissors, sheep
Wrapping Paper	gift, paper
X-ray	light, bone / light, skeleton
Yak	cow, mountain
Yoda	jedi, swamp
Yogurt	milk, bacteria
Zombie	corpse, life
