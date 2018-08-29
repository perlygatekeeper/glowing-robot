#!/usr/bin/env perl 

use Test::Most tests => 1;
use Data::Dumper;

    is( $thing->id,                  $id,                                    'id accessor' ); 
    ok( $thing->creator->isa('Thingiverse::User'),                           'is the creator a Thingiverse::User object' ); 
    is( $thing->creator->id,         $creator_id,                            'creator_id correct' ); 

    ok( $thing->default_image->isa('Thingiverse::Image'),                    'is the default_image a Thingiverse::Image object' ); 
    is( $thing->default_image->id,   $default_image_id,                      "default_images's id correct" ); 

  like( $thing->name,                qr(Rounded Rectangular Parallelepiped),                              'name                accessor' ); 
  like( $thing->instructions,        qr(Using the following options),                                     'instructions        accessor' ); 
  like( $thing->instructions_html,   qr(Using the following options),                                     'instructions_html   accessor' ); 
  like( $thing->description,         qr(Customized version of http://www.thingiverse.com/thing:313179),   'description         accessor' ); 
  like( $thing->description_html,    qr(Customized version of .*http://www.thingiverse.com/thing:313179), 'description_html    accessor' ); 
  like( $thing->license,             qr(Creative Commons),                                                'license             accessor' ); 
    is( $thing->public_url,          $public_url,                                                         'public_url          accessor' ); 
    is( $thing->url,                 $url,                                                                'url                 accessor' ); 
    is( $thing->images_url,          $url . '/images',                                                    'images_url          accessor' ); 
    is( $thing->categories_url,      $url . '/categories',                                                'categories_url      accessor' ); 
    is( $thing->ancestors_url,       $url . '/ancestors',                                                 'ancestors_url       accessor' ); 
    is( $thing->tags_url,            $url . '/tags',                                                      'tags_url            accessor' ); 
    is( $thing->files_url,           $url . '/files',                                                     'files_url           accessor' ); 
    is( $thing->derivatives_url,     $url . '/derivatives',                                               'derivatives_url     accessor' ); 
    is( $thing->likes_url,           $url . '/likes',                                                     'likes_url           accessor' ); 
    is( $thing->layouts_url,         $layout_url,                                                         'layouts_url         accessor' ); 
  like( $thing->is_wip,              qr(true|false),                                                      'is_wip              accessor' ); 
  like( $thing->is_liked,            qr(true|false),                                                      'is_liked            accessor' ); 
  like( $thing->is_private,          qr(true|false),                                                      'is_private          accessor' ); 
  like( $thing->in_library,          qr(true|false),                                                      'in_library          accessor' ); 
  like( $thing->is_collected,        qr(true|false),                                                      'is_collected        accessor' ); 
  like( $thing->is_purchased,        qr(true|false),                                                      'is_purchased        accessor' ); 
  like( $thing->is_published,        qr(true|false),                                                      'is_published        accessor' ); 
  like( $thing->added,               qr(^2014-04-29T\d\d:\d\d:\d\d\+00:00$),                              'added               accessor' );
  like( $thing->modified,            qr(^2014-04-29T\d\d:\d\d:\d\d\+00:00$),                              'modified            accessor' );
  like( $thing->like_count,          qr(^\d+),                                                            'like_count          accessor' );
  like( $thing->file_count,          qr(^\d+),                                                            'file_count          accessor' );
  like( $thing->layout_count,        qr(^\d+),                                                            'layout_count        accessor' );
  like( $thing->collect_count,       qr(^\d+),                                                            'collect_count       accessor' );
  like( $thing->print_history_count, qr(^\d+),                                                            'print_history_count accessor' );


if ( 0 ) {
  print "nothing\n";
}

exit 0;
__END__
