package regular_n_gon;
use Moose;
use Carp;
use Math::Combinatorics:

has 'piece' => ( isa => 'Int', is => 'ro', required => 1, );
has 'board' => ( isa => 'Num', is => 'ro', required => 0, lazy =>1, builder=>'_find_internal_angle' );
 
sub _find_internal_angle {
    my $self = shift;
	return 0 if ( not $self->sides );
	return pi - pi2/$self->sides;
}

sub in_degrees {
    my $self  = shift;
    my $angle = shift;
	return $angle*180/pi;
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;
__END__
     1	21:57	df -H
     2	20:25	cd /tmp
     3	20:26	vi sukudo.txt
     4	20:27	rm .sukudo.txt.swp
     5	20:27	vim -r sukudo.txt
     6	20:27	vim sukudo.txt
     7	22:30	cd Downloads
     8	22:30	rm *.torrent
     9	22:32	df -sk * | sort -n | less
    10	22:32	du -sk * | sort -n | less
    11	22:32	du sh *
    12	22:33	du sk * | sort -n | less
    13	22:34	du -sh *
    14	12:24	a du
    15	12:25	which du
    16	12:25	/usr/bin/du -sh *
    17	12:25	/usr/bin/du -s -h *
    18	12:25	/usr/bin/du sh *
    19	12:25	/usr/bin/du -h *
    20	12:25	/usr/bin/du h *
    21	12:25	/usr/bin/du h
    22	12:25	/usr/bin/du -sh
    23	12:26	/usr/bin/du -s *
    24	12:26	man du
    25	12:26	/usr/bin/du -d 0 *
    26	12:26	/usr/bin/du -d 0 wind_turbine_stl.stl
    27	12:27	ls -l | less
    28	12:27	rm -i -- ----------
    29	20:50	du -sk * | sort -n | tee /tmp/dusk
    30	20:50	du -sk -- * | sort -n | tee /tmp/dusk
    31	20:55	cd h
    32	20:55	h
    33	21:00	cd Documents/
    34	21:01	cd Nationwide/
    35	21:03	ls B*
    36	21:04	cd Books\ 2015\ 07\ 08/
    37	21:09	ls -ld B*
    38	21:10	cd ../Downloads/
    39	21:10	find . -name 'Cate*'
    40	21:10	find . -name 'Cat*'
    41	21:11	cd Books\ Categories/
    42	21:11	du -sk *
    43	21:11	a ipoodle
    44	21:13	pu ,,/../Down
    45	21:13	pu ~Down
    46	21:13	pu ~/Downloads/
    47	22:26	rm The-Wolfs-Bane.jpg Love-Machine.jpg
    48	22:26	rm -- -PAXP-deijE.gif
    49	22:28	du -sk * | sort -n
    50	22:37	rm -r Books-copied\ to\ USB\ on\ 20141124/
    51	22:38	df
    52	21:30	cd New\ Books/
    54	13:19	c
    55	13:19	screen -r -D
    56	13:19	screen -r
    57	13:20	screen
    58	13:20	cd bin
    59	13:20	vi glue
    61	13:20	perl oldglue
    62	13:20	perl -c oldglue
    63	13:21	perl -c newglue
    64	13:21	perl -c glue
    65	13:26	diff glue oldglue
    66	21:43	which git
    67	21:43	sudo git
    68	21:44	git status
    69	21:44	git pull
    70	23:19	vi newglue
    71	23:31	./rev_bytes
    72	23:31	vi rev_bytes
    73	0:12	gicam 'more work on rev_bytes'
    75	23:09	mcd drive_ya_nuts
    76	0:03	git add -f drive_ya_nuts/
    77	0:03	git add -f drive_ya_nuts/*
    79	0:05	mv Projects/drive_ya_nuts/ glowing-robot/
    80	0:06	git rm Projects/drive_ya_nuts/dyn.pl
    81	0:06	git rm Projects/drive_ya_nuts
    82	0:06	cd glowing-robot/
    83	0:06	git add drive_ya_nuts/dyn.pl
    84	0:06	git add drive_ya_nuts
    85	0:06	gis
    86	0:07	gpull
    87	0:07	gicam "add project drive_ya_nuts"
    88	0:07	cd drive_ya_nuts/
    89	0:18	gicam "finished first pass at notes in drive_ya_nuts (dyn) project"
    92	0:03	gicam "more notes in drive_ya_nuts (dyn) project"
    93	0:03	gpush
    94	0:03	exit
    97	20:32	ack --help
    98	20:32	locate oose | less
    99	20:51	locate oose | grep -i -v 'Choose' | less
   100	20:52	locate oose | grep -i -v 'Choose' | grep -i -v Loose | less
   106	21:14	ls -ltr | less
   107	21:14	ls -ltr -R | less
   110	21:15	cd Projects/
   113	21:16	cd PFEN/
   116	21:31	cd Thingiverse/
   118	21:31	cd JSON/
   123	21:36	cd Notes
   125	21:47	cd
   126	21:47	cd etc
   128	21:47	cd perllib/
   130	21:47	cd test/
   134	21:49	cd examples/
   138	21:50	cd shapes/
   140	21:51	ll
   141	21:54	lr
   142	21:55	vi dodecagon.pl
   143	22:01	vi sized_regular_n_gon.pm
   147	22:02	rm .regular_n_gon.pm.swp
   148	22:02	ls -a
   149	22:02	vi regular_n_gon.pm
   152	22:04	cd -
   153	22:04	pu ~/glowing-robot/drive_ya_nuts/
   157	22:04	echo =1
   158	22:04	echo =1/* (
   159	22:04	echo =1/*
   160	22:05	ls =1/*
   161	22:05	ls =1/reg*
   162	22:05	cp =1/reg* board.pm
   164	22:05	locate oose | grep -i -v 'Choose' | grep -i -v Loose | grep -i -v Caboose | less
   165	0:00	cd ..
   167	0:00	vi dyn.pl
   169	0:01	search perl
   170	0:02	search perl | less
   171	0:03	a | grep search
   172	0:03	a | grep port
   173	0:03	installed
   174	0:04	installed | p5
   175	0:04	installed | grep p5
   176	0:04	installed | grep p5 | less
   177	0:04	sudo su -
   178	0:05	sudo su
   182	20:10	cd Moose/
   184	20:11	cp ~/etc/perllib/examples/Moose/shapes/* .
   186	20:11	vi triangle.pl
   191	20:13	man Algorithm-Combinatorics
   192	20:14	module_version Algorithm::Combinatorics
   193	20:14	module_version Math::Combinatorics
   194	20:14	rpm
   195	20:14	a rpm
   196	20:15	echo $MANPATH
   197	20:15	pp -m
   198	20:15	locate Combinatorics
   199	20:17	man Algorithm::Combinatorics
   201	20:32	ls
   202	20:32	vi board.pm
   203	20:33	h >> board.pm
