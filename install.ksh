#!/usr/bin/ksh

#Nom du paquetage
PROJET=mpeg4ip
#Repertoire temporaire utiliser pour preparer les packages
TEMPDIR=/tmp

function svn_export
{
        svn export https://svn.ives.fr/svn-libs-dev/asterisk/libsmedia/${PROJET}-1.5.0.1
}

#Preparation du fichier spec de packaging rpm
function prepare_spec
{
    #Architecture
    SRVARCH=`uname -i`
    #Check Fedora
    rpm -q fedora-release > /dev/null
    fcres=$?
    #Check CentOS
    rpm -q centos-release > /dev/null
    cosres=$?
    #Fedora Core Version
    if [ ${fcres} -eq 0 ]
       then
       FCV=`rpm -q fedora-release | sed s/fedora-release-// | sed s/-.*//`
       sed s/ives_distrib/ives.fc${FCV}/g ${PROJET}.spec.ives > ${PROJET}.spec.tmp
       sed s/ives_archi/${SRVARCH}/g ${PROJET}.spec.tmp > ${PROJET}.spec
       rm ${PROJET}.spec.tmp
    #CentOS Version
    elif [ ${cosres} -eq 0 ]
       then
       COSV=`rpm -q centos-release | sed s/centos-release-// | sed s/-.*//`
       sed s/ives_distrib/ives.el${COSV}/g ${PROJET}.spec.ives > ${PROJET}.spec.tmp
       sed s/ives_archi/${SRVARCH}/g ${PROJET}.spec.tmp > ${PROJET}.spec
       rm ${PROJET}.spec.tmp
    else
       echo "Erreur: On n'a pas trouvé de distribution Fedora, ou CentOS !"
       exit
    fi
}

#Creation de l'environnement de packaging rpm
function create_rpm
{
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
    svn export https://svn.ives.fr/svn-libs-dev/gnupg
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
    cd ./rpmbuild/SPECS/
    cp ../../${PROJET}.spec ${PROJET}.spec
    cd ../../
    #Cree le package
    rpmbuild -bb --sign $PWD/rpmbuild/SPECS/${PROJET}.spec
    echo "************************* fin du rpmbuild ****************************"
    #Recuperation du rpm
    mv -f $PWD/rpmbuild/RPMS/i386/*.rpm $PWD/.
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
                prepare_spec
  		create_rpm;;
  	*)
  		echo "usage: install.ksh [options]" 
  		echo "options :"
  		echo "  rpm		Generation d'un package rpm"
  		echo "  clean		Nettoie tous les fichiers cree par le present script, liens, tar.gz et rpm";;
esac
