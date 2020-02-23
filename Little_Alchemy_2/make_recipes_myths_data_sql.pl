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
# From https://au.ign.com/wikis/little-alchemy-2/Myths_and_Monsters_Combinations
# Resulting Element	Ingredient Combination(s)
# Good	Available from start.
# Immortality	Available from start.
# Monster	Available from start.
Achilles	warrior, immortality / hero, immortality
Aegis	tool, Zeus
Aeolus	wind, deity / air, deity
Ankh	mummy, immortality / tool, Baast / tool, Ra / tool, Maahes / tool, Tawaret
Apple of Discord	fruit, evil / fruit tree, evil
Baast	cat, deity / cat, immortality
Baba Yaga	witch, monster
Babe the Blue Ox	cow, Paul Bunyan / cow, giant / livestock, Paul Bunyan / livestock, giant
Banshee	sound, monster / sound, faerie / faerie, monster
Book of the Dead	book, immortality / book, Ra / book, Maahes / book, Tawaret / book, Baast
Bunyip	swamp, monster
Calydonian Boar	wild boar, monster / pig, monster / wild boar, giant / pig, giant
Camazotz	bat, deity
Chang’e	moon, deity / moon, Elixir of Life
Changeling	human, goblin / human, faerie
Chimera	goat, monster / mountain goat, monster
Chinese Dragon	dragon, good / snake, deity / dragon, peach of immortality / snake, peach of immortality / dinosaur, deity / river, deity / waterfall, deity
Cockatrice	chicken, monster / egg, monster
Cosmic Egg	egg, deity
Cthulhu	galaxy, monster / universe, monster / galaxy cluster, monster / solar system, monster / universe, deity / galaxy, deity / galaxy cluster, deity / solar system, deity / space, monster / space, deity
Cupid	love, deity / angel, deity
Curse	magic, evil
Cyclops	mermaid, Poseidon / giant, giant / giant, Zeus / giant, Poseidon
Deity	human, immortality / human, peach of immortality / human, philosopher’s stone / human, fountain of youth / human, elixir of life
Demon	evil, immortality / deity, evil / angel, evil / human, hell
Dionysus	fruit, deity / wine, deity / beer, deity / alcohol, deity / drunk, deity
Djinn	desert, demon / desert, Oni / human, magic lamp / demon, magic lamp / tornado, demon / sand, demon / sand, Oni / sandstorm, demon / sandstorm, Oni / sandstorm, monster / desert, monster / dune, monster / dune, Oni / dune, demon
Domovoi	house, monster / house, elf / house, goblin / domestication, elf / domestication, monster
Dryad	tree, deity / forest, deity / orchard, deity
Durendal	sword, holy water / sword, paladin / tool, paladin / blade, paladin / blade, holy water / sword, good
Elf	big, faierie
Elixir of Life	bottle, philosopher’s stone / bottle, immortality / container, immortality / liquid, immortality
Epona	horse, deity
Evil	human, Pandora’s Box
Faerie	goblin, good
Father Time	time, deity / grim reaper, good
Fenrir	wolf, deity / wolf, giant
Fountain of Youth	fountain, immortality
Gargoyle	stone, monster / statue, monster / rock, monster / castle, monster
Garuda	bird, deity / deity, roc / eagle, deity
Gashadokuro	skeleton, monster / skeleton, giant / bone, monster / bone, giant
Giant	big, monster / big, deity
Goblin	small, monster / small, demon / evil, faerie
Green Man	leaf, deity / plant, deity / grass, deity
Gremlin	airplane, monster / seaplane, monster / pilot, monster / airplane, goblin / seaplane, goblin / pilot, goblin / helicopter, monster / helicopter, goblin
Griffin	lion, monster
Heaven	house, good / house, deity / good, hell
Hell	house, evil / house, hellhound / house, demon / evil, heaven / doghouse, hellhound
Hellhound	dog, demon / dog, evil / wolf, demon / wolf, evil / dog, hell / wolf, hell / animal, hell / animal, evil / animal, demon
Holy Grail	cup, immortality / cup, good
Holy Water	water, good / water, heaven
Hydra	snake, monster / lake, monster
Jackalope	rabbit, monster
Jiangshi	corpse, curse / corpse, evil
Jormungandr	snake, giant / giant, ouroboros / big, ouroboros
Jotunn	ice, giant / snow, giant / arctic, giant / cold, giant
Kanabō	tool, Oni
Kappa	river, demon / stream, demon / turtle, demon / lake, demon
Kelpie	horse, griffin / horse, monster / seahorse, monster
Kitsune	fox, deity
Kraken	sea, monster / ocean, monster / fish, monster / shark, monster
Krampus	Santa, evil / Santa, monster
Maahes	lion, deity
Magic Lamp	container, djinn / lamp, djinn
Mara	night, monster / night, demon / evil, sandman / darkness, monster / darkness, demon
Maui	island, deity / angler, deity / archipelago, deity
Maui’s Fishhook	fishing rod, Maui / tool, Maui
Mimic	treasure, monster / container, monster / box, monster
Mjolnir	hammer, deity / tool, Thor / hammer, Thor
Mothman	moth, monster
Mount Olympus	house, Zeus / house, Vulcan / mountain, Zeus / mountain, deity / mountain, heaven / mountain, Poseidon / mountain, Dionysus / house, Poseidon / house, Dionysus / mountain, Vulcan
Necromancer	wizard, evil / wizard, curse / witch, evil / witch, curse
Necronomicon	book, Cthulhu / story, Cthulhu / book, necromancer
Oni	demon, monster
Ooze	jam, monster / mud, monster / batter, monster / cookie dough, monster / dough, monster / liquid, monster
Orc	evil, orc / big, goblin / monster, elf / human, monster
Ouroboros	snake, immortality / dragon, immortality / small, Jormungandr
Paladin	warrior, holy grail / warrior, holy water / warrior, Durendal / knight, holy grail / knight, holy water / knight, Durendal / knight, good / warrior, good
Pandora’s Box	container, good / container, evil / gift, deity / box, good / box, evil
Paul Bunyan	lumberjack, giant / axe, giant
Peach of Immortality	fruit, immortality / fruit tree, immortality
Philosopher’s Stone	rock, immortality / stone, immortality / alchemist, immortality
Poseidon	ocean, deity / water, deity / sea, deity
Prometheus	fire, giant
Quetzalcoatl	snake, deity / rainforest, deity
Ra	sun, deity / day, deity
Rainbow Serpent	rainbow, deity / double rainbow!, deity / rainbow, Jormungandr, double rainbow!, Jormungandr, oasis, deity / rain, deity
Roc	eagle, giant
Salamander	fire, monster / lizard, monster / lava, monster / volcano, monster
Sandman	good, Mara / sand, monster
Selkie	seal, monster
Shipwreck	boat, Kraken / steamboat, Kraken / sailboat, Kraken / pirate ship, Kraken
Sun Wukong	monkey, deity / monkey, peach of immortality / monkey, immortality
Tawaret	hippo, deity / hippo, immortality
Tengu	bird, monster / bird, demon
Thor	storm, deity / lightning, deity
Troll	bridge, monster / bridge, giant / cave, monster / cave, giant / mountain, monster / mountain range, monster / mountain, giant / mountain range, giant
Valhalla	house, Valkyrie / heaven, Valkyrie / house, Thor
Valkyrie	warrior, deity / warrior, Valhalla
Vodyanoy	frog, monster
Vulcan	volcano, deity / fire, deity / metal, deity / steel, deity
Will-o’-the-Wisp	light, monster / light bulb, monster / lamp, monster
Wolpertinger	squirrel, monster / flying squirrel, monster / squirrel, jackalope / flying squirrel, jackalope
World Turtle	turtle, deity / turtle, giant
Yggdrasil	tree, immortality / tree, heaven
Zeus	sky, deity / deity, Mount Olympus
Ziz	phoenix, big / big, griffin
