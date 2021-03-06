Name:      mpeg4ip
Version:   2.0.0
#Ne pas enlever le .ives a la fin de la release !
#Cela est utilise par les scripts de recherche de package.
Release:   3.ives%{?dist}
Summary:   [IVeS] Open MPEG-4 streaming tools
Vendor:   IVeS
Group:     Applications/Internet
License: GPL
URL:       http://www.ives.fr
BuildArchitectures: x86_64
BuildRoot:  %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)
BuildRequires: automake libtool
Requires:  ivespkg

%description
MPEG4IP provides an end-to-end system to explore streaming multimedia. The
package includes many existing open source packages and the "glue" to
integrate them together. This is a tool for streaming video and audio that
is standards-oriented and free from proprietary protocols and extensions.

%package devel
Summary: Libraries, includes to develop applications with %{name}.
Group: Development/Libraries
Requires: %{name} = %{version}

%description devel
The %{name}-devel package contains the header files and static libraries for
building apps and func which use %{name}.

  
%clean
echo "############################# Clean"
cd $RPM_SOURCE_DIR/%name
make clean
cd ..
rm -f $RPM_SOURCE_DIR/%name
echo Clean du repertoire $RPM_BUILD_ROOT
[ "$RPM_BUILD_ROOT" != "/" ] && rm -rf "$RPM_BUILD_ROOT"

%prep
cd $RPM_SOURCE_DIR/%name
# Shoudl be done once and archived
#if ! type autoconf-1.11
#then
libtoolize -c --force
aclocal
autoconf
automake
#fi
%configure --with-pic

%build
echo "Build"
cd $RPM_SOURCE_DIR/%name
make
# Remove build root from path
# echo $RPM_BUILD_ROOT | sed "s/\//\\\//g"
ESC_ROOT="`echo ${RPM_BUILD_ROOT} | sed 's/\//\\\\\//g'`"
sed -r "s/${ESC_ROOT}//g" libmp4v2.la > libmp4v2.la.new
rm libmp4v2.la
mv libmp4v2.la.new libmp4v2.la
# Recompile mp4 binaries t
rm -f mp4art mp4chaps mp4extract mp4file mp4info mp4subtitle mp4tags mp4track mp4trackdump
make

%install
echo "############################# Install"
cd $RPM_SOURCE_DIR/%name
%makeinstall

%files
%defattr(-,root,root,-)
%{_libdir}/*.so
%{_libdir}/*.so.*
%attr(0755,root,root) /usr/bin/mp4art
%attr(0755,root,root) /usr/bin/mp4chaps
%attr(0755,root,root) /usr/bin/mp4extract
%attr(0755,root,root) /usr/bin/mp4file
%attr(0755,root,root) /usr/bin/mp4info
%attr(0755,root,root) /usr/bin/mp4subtitle
%attr(0755,root,root) /usr/bin/mp4tags
%attr(0755,root,root) /usr/bin/mp4track
%attr(0755,root,root) /usr/bin/mp4trackdump
/usr/share/man/man1/mp4art.1.gz
/usr/share/man/man1/mp4file.1.gz
/usr/share/man/man1/mp4subtitle.1.gz
/usr/share/man/man1/mp4track.1.gz

%files devel
%defattr(-,root,root)
%attr(0755,root,root) /usr/include/mp4v2/
%{_libdir}/*.a
%{_libdir}/*.la


%changelog
* Tue Dec 29 2020 Emmanuel BUU <emmanuel.buu@ives.fr>
- migrated source to Gihub. 
- port to centos 7
- version 2.0.0

* Thu Dec 01 2011 Emmanuel BUU <emmanuel.buu@ives.fr>
- version 1.9.2 from google code trunk
* Thu Dec 01 2011 Emmanuel BUU <emmanuel.buu@ives.fr>
- version 1.9.1 imported from google code for mediaserver

* Fri Apr 03 2009 Emmanuel BUU <emmanuel.buu@ives.fr> 1.5.0-2.ives
- compilation with gcc 4.3.x. Improved packaging
* Mon Mar 09 2009 Didier Chabanol <didier.chabanol@ives.fr> 1.5.0-1.ives
- Initial package

