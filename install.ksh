#!/bin/bash

#Nom du paquetage
PROJET=mpeg4ip
#Repertoire temporaire utiliser pour preparer les packages
TEMPDIR=/tmp

function svn_export
{
        svn export https://svn.ives.fr/svn-libs-dev/asterisk/libsmedia/${PROJET}-1.5.0.1
}

#Preparation du fichier spec de packaging rpm
function create_rpm
{
    # Mise a jour libtool
    if ! type autoconf-1.11
    then
        aclocal
        autoconf
        libtoolize -c
    fi
    #Cree l'environnement de creation de package
    #Creation des macros rpmbuild
    rm ~/.rpmmacros
    touch ~/.rpmmacros
    echo "%_prefix" "/usr" >> ~/.rpmmacros
    echo "%_topdir" $PWD"/rpmbuild" >> ~/.rpmmacros
    echo "%_tmppath %{_topdir}/TMP" >> ~/.rpmmacros
    echo "%_signature gpg" >> ~/.rpmmacros
    echo "%_gpg_name IVeSkey" >> ~/.rpmmacros
    echo "%_gpg_path" $PWD"/gnupg" >> ~/.rpmmacros
    echo "%vendor IVeS" >> ~/.rpmmacros
    #Import de la clef gpg IVeS
    if [ "$1" != "nosign" ]
    then
        svn export https://svn.ives.fr/svn-libs-dev/gnupg
    fi
    mkdir -p rpmbuild
    mkdir -p rpmbuild/SOURCES
    mkdir -p rpmbuild/SPECS
    mkdir -p rpmbuild/BUILD
    mkdir -p rpmbuild/SRPMS
    mkdir -p rpmbuild/TMP
    mkdir -p rpmbuild/RPMS
    mkdir -p rpmbuild/RPMS/noarch
    mkdir -p rpmbuild/RPMS/i386
    mkdir -p rpmbuild/RPMS/i686
    mkdir -p rpmbuild/RPMS/i586
    #Recuperation de la description du package 
    
    cp ${PROJET}.spec $PWD/rpmbuild/SPECS/${PROJET}.spec
    ln -s $PWD $PWD/rpmbuild/SOURCES/${PROJET}
    #Cree le package
    if [ "$1" == "nosign" ]
    then
        rpmbuild -bb $PWD/rpmbuild/SPECS/${PROJET}.spec
    else
        rpmbuild -bb --sign $PWD/rpmbuild/SPECS/${PROJET}.spec
    fi

    echo "************************* fin du rpmbuild ****************************"
    #Recuperation du rpm
#    mv -f $PWD/rpmbuild/RPMS/i386/*.rpm $PWD/.
    mv -f $PWD/rpmbuild/RPMS/x86_64/*.rpm $PWD/.
    clean
}

function clean
{
  	# On efface les liens ainsi que le package precedemment créé
  	echo Effacement des fichiers et liens gnupg rpmbuild ${PROJET}.rpm ${TEMPDIR}/${PROJET}
  	rm -rf gnupg rpmbuild ${PROJET}.rpm ${TEMPDIR}/${PROJET}
}

case $1 in
  	"clean")
  		echo "Nettoyage des liens et du package crees par la cible dev"
  		clean ;;
  	"rpm")
  		echo "Creation du rpm"
  		create_rpm $2;;
  	*)
  		echo "usage: install.ksh [options]" 
  		echo "options :"
  		echo "  rpm		Generation d'un package rpm"
  		echo "  clean		Nettoie tous les fichiers cree par le present script, liens, tar.gz et rpm";;
esac
