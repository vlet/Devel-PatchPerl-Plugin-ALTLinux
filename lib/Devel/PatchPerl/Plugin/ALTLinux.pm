package Devel::PatchPerl::Plugin::ALTLinux;
use strict;
use File::pushd qw(pushd);

our $VERSION = '0.1';

my %perls = (
    '5.16.1' => [
        [ \&_patch_Configure ],
        [ \&_patch_Errno ],
        [ \&_patch_ExtUtils_Install ],
        [ \&_patch_ExtUtils_Liblist_Kid ],
        [ \&_patch_linux_sh ],
        [ \&_patch_Cwd ],
        [ \&_patch_perlbug ],
        [ \&_patch_ExtUtils_MM_Any ],
        [ \&_patch_ExtUtils_MM_Unix ],
        [ \&_patch_Storable ],
        [ \&_patch_Makefile_SH ],
        [ \&_patch_installperl ],
    ],
);

my $patchexe;

sub patchperl {
    my ( $name, %args ) = @_;
    $patchexe = $args{patchexe};

    my $dir = pushd( $args{source} );
    for my $s ( @{ $perls{ $args{version} } } ) {
        my $sub = shift @$s;
        $sub->( @$s, $args{version} );
    }
}

sub _patch {
    my $patch = shift;
    my ($sub) = map { /_patch_(.+)$/ } ( caller(1) )[3];
    print "Applied patch $sub\n";
    my $pid = open my $fh, "|-", $patchexe, '-s', '-p1', '--read-only=ignore'
      or die $!;
    print $fh $patch;
    close $fh;
    my $status = $? >> 8;
    die "patch $sub failed with status $status" if $status;
}

sub _patch_Configure {

    # Define options
    _patch(<<'PATCH');
--- a/Configure
+++ b/Configure
@@ -349,7 +349,7 @@ lkflags=''
 locincpth=''
 optimize=''
 cf_email=''
-cf_by=''
+cf_by='ALTLinux'
 cf_time=''
 charbits=''
 charsize=''
@@ -982,7 +982,7 @@ i_varargs=''
 i_varhdr=''
 i_vfork=''
 d_inc_version_list=''
-inc_version_list=''
+inc_version_list='none'
 inc_version_list_init=''
 installprefix=''
 installprefixexp=''
@@ -996,7 +996,7 @@ libc=''
 ldlibpthname=''
 libperl=''
 shrpenv=''
-useshrplib=''
+useshrplib='true'
 glibpth=''
 libpth=''
 loclibpth=''
@@ -1038,17 +1038,17 @@ malloctype=''
 usemallocwrap=''
 usemymalloc=''
 installman1dir=''
-man1dir=''
+man1dir='none'
 man1direxp=''
 man1ext=''
 installman3dir=''
-man3dir=''
+man3dir='none'
 man3direxp=''
 man3ext=''
 modetype=''
 multiarch=''
 mydomain=''
-myhostname=''
+myhostname='localhost'
 phostname=''
 c=''
 n=''
@@ -1070,7 +1070,7 @@ d_perl_otherlibdirs=''
 otherlibdirs=''
 package=''
 spackage=''
-pager=''
+pager='/usr/bin/less -isR'
 api_revision=''
 api_subversion=''
 api_version=''
@@ -1082,7 +1082,7 @@ subversion=''
 version=''
 version_patchlevel_string=''
 perl5=''
-perladmin=''
+perladmin='root@localhost'
 perlpath=''
 d_nv_preserves_uv=''
 d_nv_zero_is_allbits_zero=''
@@ -1226,7 +1226,7 @@ usekernprocpathname=''
 ccflags_uselargefiles=''
 ldflags_uselargefiles=''
 libswanted_uselargefiles=''
-uselargefiles=''
+uselargefiles='true'
 uselongdouble=''
 usemorebits=''
 usemultiplicity=''
@@ -1239,9 +1239,9 @@ useperlio=''
 usesocks=''
 d_oldpthreads=''
 use5005threads=''
-useithreads=''
+useithreads='true'
 usereentrant=''
-usethreads=''
+usethreads='true'
 incpath=''
 mips_type=''
 usrinc=''
@@ -1331,7 +1331,7 @@ inclwanted=''
 
 : Enable -DEBUGGING and -DDEBUGGING from the command line
 EBUGGING=''
-DEBUGGING=''
+DEBUGGING='maybe'
 
 libnames=''
 : change the next line if compiling for Xenix/286 on Xenix/386
@@ -1580,12 +1580,13 @@ shift
 rm -f options.awk
 
 : set up default values
-fastread=''
-reuseval=false
+fastread='yes'
+reuseval=true
 config_sh=''
-alldone=''
+alldone='cont'
 error=''
-silent=''
+silent=true
+realsilent=true
 extractsh=''
 override=''
 knowitall=''
PATCH
}

sub _patch_Errno {

    # Errno.pm: removed version check (debian)
    _patch(<<'PATCH');
--- a/ext/Errno/Errno_pm.PL
+++ b/ext/Errno/Errno_pm.PL
@@ -333,10 +333,6 @@ require Exporter;
 use Config;
 use strict;
 
-"\$Config{'archname'}-\$Config{'osvers'}" eq
-"$archname-$Config{'osvers'}" or
-	die "Errno architecture ($archname-$Config{'osvers'}) does not match executable architecture (\$Config{'archname'}-\$Config{'osvers'})";
-
 our \$VERSION = "$VERSION";
 \$VERSION = eval \$VERSION;
 our \@ISA = 'Exporter';

PATCH
}

sub _patch_ExtUtils_Install {

    # ExtUtils/Install.pm: changed permissions 0444 -> 0644
    _patch(<<'PATCH');
--- a/dist/ExtUtils-Install/lib/ExtUtils/Install.pm
+++ b/dist/ExtUtils-Install/lib/ExtUtils/Install.pm
@@ -822,7 +822,7 @@ sub install { #XXX OS-SPECIFIC
                 utime($atime,$mtime + $Is_VMS,$targetfile) unless $dry_run>1;
 
 
-                $mode = 0444 | ( $mode & 0111 ? 0111 : 0 );
+                $mode = 0644 | ( $mode & 0111 ? 0111 : 0 );
                 $mode = $mode | 0222
                     if $realtarget ne $targetfile;
                 _chmod( $mode, $targetfile, $verbose );
@@ -1224,7 +1224,7 @@ sub pm_to_blib {
         }
         my($mode,$atime,$mtime) = (stat $from)[2,8,9];
         utime($atime,$mtime+$Is_VMS,$to);
-        _chmod(0444 | ( $mode & 0111 ? 0111 : 0 ),$to);
+        _chmod(0644 | ( $mode & 0111 ? 0111 : 0 ),$to);
         next unless $from =~ /\.pm$/;
         _autosplit($to,$autodir);
     }

PATCH
}

sub _patch_ExtUtils_Liblist_Kid {

    # ExtUtils/Liblist/Kid.pm: disable RPATH for /lib /lib64 /usr/lib /usr/lib64
    _patch(<<'PATCH');
--- a/cpan/ExtUtils-MakeMaker/lib/ExtUtils/Liblist/Kid.pm
+++ b/cpan/ExtUtils-MakeMaker/lib/ExtUtils/Liblist/Kid.pm
@@ -56,6 +56,9 @@ sub _unix_os2_ext {
     my ( $pwd )   = cwd();    # from Cwd.pm
     my ( $found ) = 0;
 
+    # don't use LD_RUN_PATH for standard dirs
+    $ld_run_path_seen{$_}++ for qw(/lib /lib64 /usr/lib /usr/lib64);
+
     foreach my $thislib ( split ' ', $potential_libs ) {
 
         # Handle possible linker path arguments.

PATCH
}

sub _patch_linux_sh {

    # hints/linux.sh: canonicalize path names (ALT#26249)
    _patch(<<'PATCH');
--- a/hints/linux.sh
+++ b/hints/linux.sh
@@ -175,7 +175,8 @@ fi
 
 case "$plibpth" in
 '') plibpth=`LANG=C LC_ALL=C $gcc -print-search-dirs | grep libraries |
-	cut -f2- -d= | tr ':' $trnl | grep -v 'gcc' | sed -e 's:/$::'`
+	cut -f2- -d= | tr ':' $trnl | grep -v 'gcc' | sed -e 's:/$::' |
+	xargs -rn1 readlink -e`
     set X $plibpth # Collapse all entries on one line
     shift
     plibpth="$*"

PATCH
}

sub _patch_Cwd {

    # Cwd.xs: use libc realpath(3) instead of bsd_realpath()
    _patch(<<'PATCH');
--- a/dist/Cwd/Cwd.xs
+++ b/dist/Cwd/Cwd.xs
@@ -11,6 +11,9 @@
 #   include <unistd.h>
 #endif
 
+/* ALT: use libc realpath(3) instead of bsd_realpath() */
+#define bsd_realpath realpath
+#if 0
 /* The realpath() implementation from OpenBSD 3.9 to 4.2 (realpath.c 1.13)
  * Renamed here to bsd_realpath() to avoid library conflicts.
  */
@@ -218,6 +221,7 @@ bsd_realpath(const char *path, char resolved[MAXPATHLEN])
 	return (resolved);
 }
 #endif
+#endif
 
 #ifndef SV_CWD_RETURN_UNDEF
 #define SV_CWD_RETURN_UNDEF \

PATCH
}

sub _patch_perlbug {

    # perlbug.PL: adjust dependencies
    _patch(<<'PATCH');
--- a/utils/perlbug.PL
+++ b/utils/perlbug.PL
@@ -94,14 +94,11 @@ use File::Basename 'basename';
 sub paraprint;
 
 BEGIN {
-    eval { require Mail::Send;};
+    eval "require Mail::Send;";
     $::HaveSend = ($@ eq "");
-    eval { require Mail::Util; } ;
+    eval "require Mail::Util;";
     $::HaveUtil = ($@ eq "");
-    # use secure tempfiles wherever possible
-    eval { require File::Temp; };
-    $::HaveTemp = ($@ eq "");
-    eval { require Module::CoreList; };
+    eval "require Module::CoreList;";
     $::HaveCoreList = ($@ eq "");
 };
 
@@ -962,18 +959,10 @@ EOF
 }
 
 sub filename {
-    if ($::HaveTemp) {
-	# Good. Use a secure temp file
-	my ($fh, $filename) = File::Temp::tempfile(UNLINK => 1);
-	close($fh);
-	return $filename;
-    } else {
-	# Bah. Fall back to doing things less securely.
-	my $dir = File::Spec->tmpdir();
-	$filename = "bugrep0$$";
-	$filename++ while -e File::Spec->catfile($dir, $filename);
-	$filename = File::Spec->catfile($dir, $filename);
-    }
+    require File::Temp;
+    my ($fh, $filename) = File::Temp::tempfile(UNLINK => 1);
+    close($fh);
+    return $filename;
 }
 
 sub paraprint {

PATCH
}

sub _patch_ExtUtils_MM_Any {

    # ExtUtils/MM_Any.pm: disabled CPAN::Meta under rpm
    _patch(<<'PATCH');
--- a/cpan/ExtUtils-MakeMaker/lib/ExtUtils/MM_Any.pm
+++ b/cpan/ExtUtils-MakeMaker/lib/ExtUtils/MM_Any.pm
@@ -787,6 +787,8 @@ CMD
 
 sub _has_cpan_meta {
     return eval {
+      die "CPAN::Meta disabled under rpm"
+          if $ENV{RPM_ARCH} && $ENV{RPM_OS} && !$ENV{PERL_CORE};
       require CPAN::Meta;
       CPAN::Meta->VERSION(2.112150);
       1;

PATCH
}

sub _patch_ExtUtils_MM_Unix {

    # ExtUtlis/MM_Unix.pm: link perl extensions with -lperl -lpthread
    # ExtUtlis/MM_Unix.pm: (fixin): shebang patch
    _patch(<<'PATCH');
--- a/cpan/ExtUtils-MakeMaker/lib/ExtUtils/MM_Unix.pm
+++ b/cpan/ExtUtils-MakeMaker/lib/ExtUtils/MM_Unix.pm
@@ -893,6 +893,10 @@ sub dynamic_lib {
 
     return '' unless $self->has_link_code;
 
+    my $extra_libs = '';
+    $extra_libs .= ' -L$(PERL_INC) -lperl' if $Config{useshrplib};
+    $extra_libs .= ' -lpthread' if $Config{perllibs} =~ /pthread/;
+
     my($otherldflags) = $attribs{OTHERLDFLAGS} || "";
     my($inst_dynamic_dep) = $attribs{INST_DYNAMIC_DEP} || "";
     my($armaybe) = $attribs{ARMAYBE} || $self->{ARMAYBE} || ":";
@@ -908,6 +912,7 @@ ARMAYBE = '.$armaybe.'
 OTHERLDFLAGS = '.$ld_opt.$otherldflags.'
 INST_DYNAMIC_DEP = '.$inst_dynamic_dep.'
 INST_DYNAMIC_FIX = '.$ld_fix.'
+EXTRALINK_LIBS = '.$extra_libs.'
 
 $(INST_DYNAMIC): $(OBJECT) $(MYEXTLIB) $(BOOTSTRAP) $(INST_ARCHAUTODIR)$(DFSEP).exists $(EXPORT_LIST) $(PERL_ARCHIVE) $(PERL_ARCHIVE_AFTER) $(INST_DYNAMIC_DEP)
 ');
@@ -952,7 +957,7 @@ $(INST_DYNAMIC): $(OBJECT) $(MYEXTLIB) $(BOOTSTRAP) $(INST_ARCHAUTODIR)$(DFSEP).
     push @m, sprintf <<'MAKE', $ld_run_path_shell, $ldrun, $ldfrom, $libs;
 	%s$(LD) %s $(LDDLFLAGS) %s $(OTHERLDFLAGS) -o $@ $(MYEXTLIB)	\
 	  $(PERL_ARCHIVE) %s $(PERL_ARCHIVE_AFTER) $(EXPORT_LIST)	\
-	  $(INST_DYNAMIC_FIX)
+	  $(INST_DYNAMIC_FIX) $(EXTRALINK_LIBS)
 MAKE
 
     push @m, <<'MAKE';
@@ -1081,44 +1086,29 @@ sub fixin {    # stolen from the pink Camel book, more or less
     my ( $self, @files ) = @_;
 
     for my $file (@files) {
-        my $file_new = "$file.new";
-        my $file_bak = "$file.bak";
 
-        open( my $fixin, '<', $file ) or croak "Can't process '$file': $!";
+        my @stat = stat $file;
+        chmod $stat[2] & 07777 | 0600, $file unless -w $file;
+        open my $fh, "+<", $file or croak "Can't process '$file': $!";
         local $/ = "\n";
-        chomp( my $line = <$fixin> );
+        chomp( my $line = <$fh> );
         next unless $line =~ s/^\s*\#!\s*//;    # Not a shbang file.
 
         my $shb = $self->_fixin_replace_shebang( $file, $line );
         next unless defined $shb;
 
-        open( my $fixout, ">", "$file_new" ) or do {
-            warn "Can't create new $file: $!\n";
-            next;
-        };
+        # Read the rest and rewind.
+        local $/;
+        my $rest = <$fh>;
+        seek $fh, 0, 0;
 
         # Print out the new #! line (or equivalent).
         local $\;
-        local $/;
-        print $fixout $shb, <$fixin>;
-        close $fixin;
-        close $fixout;
-
-        chmod 0666, $file_bak;
-        unlink $file_bak;
-        unless ( _rename( $file, $file_bak ) ) {
-            warn "Can't rename $file to $file_bak: $!";
-            next;
-        }
-        unless ( _rename( $file_new, $file ) ) {
-            warn "Can't rename $file_new to $file: $!";
-            unless ( _rename( $file_bak, $file ) ) {
-                warn "Can't rename $file_bak back to $file either: $!";
-                warn "Leaving $file renamed as $file_bak\n";
-            }
-            next;
-        }
-        unlink $file_bak;
+        print $fh $shb, $rest;
+        truncate $fh, tell $fh;
+        close $fh;
+        chmod $stat[2] & 07777, $file if @stat && ( stat[2] & 0200 ) == 0; # restore mode
+        utime @stat[8,9] => $file if @stat; # preserve timestamps
     }
     continue {
         system("$Config{'eunicefix'} $file") if $Config{'eunicefix'} ne ':';
@@ -1185,10 +1175,6 @@ sub _fixin_replace_shebang {
             $shb .= ' ' . $arg if defined $arg;
             $shb .= "\n";
         }
-        $shb .= qq{
-eval 'exec $interpreter $arg -S \$0 \${1+"\$\@"}'
-    if 0; # not running under some shell
-} unless $Is{Win32};    # this won't work on win32, so don't
     }
     else {
         warn "Can't find $cmd in PATH, $file unchanged"

PATCH
}

sub _patch_Storable {

    # Storable.pm: avoid early dependency on Log::Agent
    _patch(<<'PATCH');
--- a/dist/Storable/Storable.pm
+++ b/dist/Storable/Storable.pm
@@ -23,26 +23,32 @@ use vars qw($canonical $forgive_me $VERSION);
 
 $VERSION = '2.34';
 
-BEGIN {
-    if (eval { local $SIG{__DIE__}; require Log::Agent; 1 }) {
-        Log::Agent->import;
-    }
-    #
-    # Use of Log::Agent is optional. If it hasn't imported these subs then
-    # provide a fallback implementation.
-    #
-    if (!exists &logcroak) {
-        require Carp;
-        *logcroak = sub {
-            Carp::croak(@_);
-        };
-    }
-    if (!exists &logcarp) {
-	require Carp;
-        *logcarp = sub {
-          Carp::carp(@_);
-        };
-    }
+sub logcroak {
+    goto &Log::Agent::logcroak
+	if do {
+	    local ($@, $!, $SIG{__DIE__});
+	    eval { require Log::Agent };
+	    exists &Log::Agent::logcroak;
+	};
+    goto &Carp::croak
+	if do {
+	    local ($@, $!);
+	    require Carp;
+	};
+}
+
+sub logcarp {
+    goto &Log::Agent::logcarp
+	if do {
+	    local ($@, $!, $SIG{__DIE__});
+	    eval { require Log::Agent };
+	    exists &Log::Agent::logcarp;
+	};
+    goto &Carp::carp
+	if do {
+	    local ($@, $!);
+	    require Carp;
+	};
 }
 
 #

PATCH
}

sub _patch_Makefile_SH {

    # Makefile.SH: set libperl soname
    _patch(<<'PATCH');
--- a/Makefile.SH
+++ b/Makefile.SH
@@ -795,7 +795,7 @@ $(LIBPERL): $& $(obj) $(DYNALOADER) $(LIBPERLEXPORT)
 	true)
 		$spitshell >>$Makefile <<'!NO!SUBS!'
 	rm -f $@
-	$(LD) -o $@ $(SHRPLDFLAGS) $(obj) $(DYNALOADER) $(libs)
+	$(LD) -o $@ $(SHRPLDFLAGS) $(obj) $(DYNALOADER) $(libs) -Wl,-soname,$(LIBPERL)
 !NO!SUBS!
 		case "$osname" in
 		aix)

PATCH
}

sub _patch_installperl {

    # installperl: changed permissions 0444 -> 0644, 0555 -> 0755
    _patch(<<'PATCH');
--- a/installperl
+++ b/installperl
@@ -401,9 +401,9 @@ foreach my $file (@corefiles) {
     if (copy_if_diff($file,"$installarchlib/CORE/$file")) {
 	if ($file =~ /\.(\Q$so\E|\Q$dlext\E)$/) {
 	    strip("-S", "$installarchlib/CORE/$file") if $^O =~ /^(rhapsody|darwin)$/;
-	    chmod(0555, "$installarchlib/CORE/$file");
+	    chmod(0755, "$installarchlib/CORE/$file");
 	} else {
-	    chmod(0444, "$installarchlib/CORE/$file");
+	    chmod(0644, "$installarchlib/CORE/$file");
 	}
     }
 }
@@ -801,7 +801,7 @@ sub installlib {
             if (copy_if_diff($_, "$installlib/$name")) {
                 strip("-S", "$installlib/$name")
                     if $^O =~ /^(rhapsody|darwin)$/ and /\.(?:so|$dlext|a)$/;
-                chmod(/\.(so|$dlext)$/ ? 0555 : 0444, "$installlib/$name");
+                chmod(/\.(so|$dlext)$/ ? 0755 : 0644, "$installlib/$name");
             }
 	}
     }

PATCH
}

1;

__END__

=head1 NAME

Devel::PatchPerl::Plugin::ALTLinux - Devel::PatchPerl plugin to apply ALTLinux patches to your Perl build

=head1 SYNOPSIS

    $ PERL5_PATCHPERL_PLUGIN=ALTLinux perlbrew install perl-5.16.1

    This command will apply ALTLinux patches before build and also set necessary flags to Configure script:

    -ders
    -Dusethreads
    -Duseithreads
    -Duselargefiles
    -Duseshrplib
    -DDEBUGGING=maybe
    -Dinc_version_list=none
    -Dpager='/usr/bin/less -isR'
    -Dman1dir=none
    -Dman3dir=none
    -Dcf_by='ALTLinux'
    -Dmyhostname=localhost
    -Dperladmin=root@localhost

    You can unset some of them with -U option

=head1 DESCRIPTION

Devel::PatchPerl::Plugin::ALTLinux plugin allows you simply build Perl in the same way as on ALTLinux platform. This is useful when you want use new Perl on old ALTLinux distro, or vice versa - old Perl on new distro.

=head1 AUTHOR

Vladimir Lettiev, E<lt>crux@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012 by Vladimir Lettiev

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.16.1 or,
at your option, any later version of Perl 5 you may have available.

=cut
