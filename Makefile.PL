use inc::Module::Install;

name 'Devel-PatchPerl-Plugin-ALTLinux';
all_from 'lib/Devel/PatchPerl/Plugin/ALTLinux.pm';

requires 'File::pushd';

test_requires 'Test::More';

WriteAll;
