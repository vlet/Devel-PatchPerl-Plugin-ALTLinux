use strict;
use warnings;
use Test::More;

BEGIN { use_ok('Devel::PatchPerl::Plugin::ALTLinux') }

subtest 'patchperl' => sub {
    ok( Devel::PatchPerl::Plugin::ALTLinux->can('patchperl'),
        'method patchperl exists' );
};

done_testing;
