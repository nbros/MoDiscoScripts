#!/bin/bash -x
# This builds an Eclipse Package for developers. The versions and platforms are chosen as parameters.

set -o errexit
set -o nounset

# where to install
#INSTALL_LOC=$(pwd)/install # doesn't work with Cygwin
INSTALL_LOC=D:/devEnvInstall

# To continue installing the same bundle. For example if a previous installation failed partially.
INSTALL_OVER_PREVIOUS_INSTALL=false
# Eclipse SDK. Required, unless continuing a previous install.
INSTALL_SDK=true
# Install the plug-ins required to compile MoDisco and EMF Facet (EMF, EMF Compare, EMF Query, EMF Validation, EMF Ecoretools, Acceleo, CDO, ATL, BIRT, Mylyn Wikitext, JET, Net4j, OCL, QVT OML, UML2, ANTLR runtime, DERBY, Log4j, Apache commons lang & jxpath, nattable, prefuse, swtbot)
INSTALL_REQUIRED_PLUGINS=true
# Install Mylyn
INSTALL_MYLYN=true
# Install Egit team provider for Git
INSTALL_EGIT=true
# The checkstyle plug-in for Eclipse
INSTALL_CHECKSTYLE=true
# Install the Subclipse plug-in for SVN support.
INSTALL_SUBCLIPSE=true
# Java GUI designer
INSTALL_WINDOWBUILDER=true
# Install the version of EMF Facet corresponding to ECLIPSE_VERSION.
INSTALL_EMFFACET=true
# Install the version of MoDisco corresponding to ECLIPSE_VERSION.
INSTALL_MODISCO=true

# Choose from which update site to install. For example, "indigo" means the latest from the indigo update site, whereas "helios/201006230900" means plug-ins from Eclipse 3.6.0 only.
ECLIPSE_VERSION=juno/201204110900 # indigo, indigo/201106030900, helios, europa, galileo...
# Choose which Orbit update site must be used
ORBIT_VERSION=S20120428190502
# Use eclipse.ialto.com for faster downloads (from France). download.eclipse.org (in Canada) is the reference download site, but is much slower (~10KiB/s)
MIRROR=eclipse.ialto.com
# The operating system that will run Eclipse
OS=win32 # linux, macosx
# The window system of the operating system that will run Eclipse
WINDOW_SYSTEM=win32 # wpf, gtk, cocoa, carbon
ARCHITECTURE=x86_64 # x86, ppc, ...

# for the copyright tool
eclipseDrop=R-3.6.2-201102101200
relengZip=org.eclipse.releng.tools-3.6.2.zip
# the Indigo version doesn't work with Subclipse (Bug 354241)
#eclipseDrop=R-3.7-201106131736
#relengZip=org.eclipse.releng.tools-3.7.zip

#MAIN_REPO=http://build.eclipse.org/juno/aggregation/final
MAIN_REPO=http://$MIRROR/releases/$ECLIPSE_VERSION

if [ $INSTALL_OVER_PREVIOUS_INSTALL != "true" ]; then
  rm -rf "$INSTALL_LOC"
fi

if [ ! -e director_latest.zip ]; then
  wget http://$MIRROR/tools/buckminster/products/director_latest.zip
fi

rm -rf director
if [ ! -d director ]; then
  unzip director_latest.zip
  # use a patched equinox.p2.transport.ecf to force the use of mirrors
  cp $(ls -1 libs/org.eclipse.equinox.p2.transport.ecf_*) director/plugins
  sed -ie 's#org\.eclipse\.equinox\.p2\.transport\.ecf,.*\?,plugins/org\.eclipse\.equinox\.p2\.transport\.ecf_.*\?\.jar,4,false#org.eclipse.equinox.p2.transport.ecf,1.0.0.201110191145,plugins/org.eclipse.equinox.p2.transport.ecf_1.0.0.201110191145.jar,4,false#g' director/configuration/org.eclipse.equinox.simpleconfigurator/bundles.info
fi

# Copyright tool
if [ ! -e $relengZip ]; then
  wget http://$MIRROR/eclipse/downloads/drops/$eclipseDrop/$relengZip
fi

director=$(ls -1 director/plugins/org.eclipse.equinox.launcher_*.jar | sort | tail -1 | tr -d '\r')

installCommand="java -jar $director -profile SDKProfile -profileProperties org.eclipse.update.install.features=true -bundlepool $INSTALL_LOC -p2.os $OS -p2.ws $WINDOW_SYSTEM -p2.arch $ARCHITECTURE -roaming -d $INSTALL_LOC"

if [ $INSTALL_SDK = "true" ]; then
  $installCommand \
  -r "$MAIN_REPO" \
  -i org.eclipse.sdk.ide
fi

if [ $INSTALL_REQUIRED_PLUGINS = "true" ]; then
  $installCommand \
  -r "$MAIN_REPO" \
  -r http://$MIRROR/tools/orbit/downloads/drops/$ORBIT_VERSION/repository/ \
  -r http://$MIRROR/technology/swtbot/helios/dev-build/update-site \
  -r jar:file:$relengZip!/ \
  -i org.eclipse.birt.feature.group \
  -i org.eclipse.mylyn.wikitext_feature.feature.group \
  -i org.eclipse.acceleo.sdk.feature.group \
  -i org.eclipse.m2m.atl.sdk.feature.group \
  -i org.eclipse.emf.cdo.sdk.feature.group \
  -i org.eclipse.emf.ecoretools.sdk.feature.group \
  -i org.eclipse.emf.sdk.feature.group \
  -i org.eclipse.emf.compare.sdk.feature.group \
  -i org.eclipse.emf.query.sdk.feature.group \
  -i org.eclipse.emf.validation.sdk.feature.group \
  -i org.eclipse.net4j.sdk.feature.group \
  -i org.eclipse.ocl.all.sdk.feature.group \
  -i org.eclipse.m2m.qvt.oml.sdk.feature.group \
  -i org.eclipse.uml2.sdk.feature.group \
  -i org.antlr.runtime \
  -i org.apache.derby \
  -i org.apache.derby.source \
  -i org.apache.log4j \
  -i org.apache.log4j.source \
  -i org.apache.commons.lang \
  -i org.apache.commons.lang.source \
  -i org.apache.commons.jxpath \
  -i org.apache.commons.jxpath.source \
  -i net.sourceforge.nattable.core \
  -i net.sourceforge.nattable.core.source \
  -i org.prefuse \
  -i org.prefuse.source \
  -i org.eclipse.swtbot.eclipse.feature.group \
  -i org.eclipse.swtbot.feature.group \
  -i org.eclipse.swtbot.ide.feature.group \
  -i org.eclipse.releng.tools.feature.group
fi

if [ $INSTALL_MYLYN = "true" ]; then
  $installCommand \
  -r "$MAIN_REPO" \
  -i org.eclipse.mylyn.hudson.feature.group \
  -i org.eclipse.mylyn.ide_feature.feature.group \
  -i org.eclipse.mylyn.java_feature.feature.group \
  -i org.eclipse.mylyn.pde_feature.feature.group \
  -i org.eclipse.mylyn.team_feature.feature.group \
  -i org.eclipse.mylyn_feature.feature.group \
  -i org.eclipse.mylyn.context_feature.feature.group \
  -i org.eclipse.mylyn.bugzilla_feature.feature.group \
  -i org.eclipse.mylyn.trac_feature.feature.group
fi
 
#  -i org.eclipse.mylyn.cvs.feature.group \
#  -i org.eclipse.mylyn.git.feature.group

 
if [ $INSTALL_EGIT = "true" ]; then
  $installCommand \
  -r "$MAIN_REPO" \
  -i org.eclipse.egit.feature.group \
  -i org.eclipse.jgit.feature.group \
  -i org.eclipse.egit.mylyn.feature.group
fi

checkstyleZip="net.sf.eclipsecs-updatesite_5.5.0.201111092104-bin.zip"
if [ $INSTALL_CHECKSTYLE = "true" ]; then
  if [ ! -e "$checkstyleZip" ]; then
    wget http://sourceforge.net/projects/eclipse-cs/files/Eclipse%20Checkstyle%20Plug-in/5.5.0/$checkstyleZip/download -O "$checkstyleZip"
  fi

  $installCommand \
  -r "$MAIN_REPO" \
  -r "jar:file:$checkstyleZip!/" \
  -i net.sf.eclipsecs.feature.group
fi

if [ $INSTALL_SUBCLIPSE = "true" ]; then
  $installCommand \
  -r "$MAIN_REPO" \
  -r http://subclipse.tigris.org/update_1.6.x/ \
  -i org.tmatesoft.svnkit.feature.group \
  -i com.sun.jna.feature.group \
  -i com.collabnet.subversion.merge.feature.feature.group \
  -i org.tigris.subversion.subclipse.feature.group \
  -i org.tigris.subversion.subclipse.mylyn.feature.group \
  -i org.tigris.subversion.clientadapter.feature.feature.group \
  -i org.tigris.subversion.subclipse.graph.feature.feature.group \
  -i org.tigris.subversion.clientadapter.svnkit.feature.feature.group
fi

if [ $INSTALL_WINDOWBUILDER = "true" ]; then
  $installCommand \
  -r "$MAIN_REPO" \
  -i org.eclipse.wb.core.feature.feature.group \
  -i org.eclipse.wb.doc.user.feature.feature.group \
  -i org.eclipse.wb.core.ui.feature.feature.group \
  -i org.eclipse.wb.layout.group.feature.feature.group \
  -i org.eclipse.wb.core.xml.feature.feature.group \
  -i org.eclipse.wb.rcp.feature.feature.group \
  -i org.eclipse.wb.swt.feature.feature.group \
  -i org.eclipse.wb.rcp.SWT_AWT_support.feature.group \
  -i org.eclipse.wb.xwt.feature.feature.group \
  -i org.eclipse.wb.swing.feature.feature.group
fi

if [ $INSTALL_EMFFACET = "true" ]; then
  $installCommand \
  -r "$MAIN_REPO" \
  -r http://$MIRROR/tools/orbit/downloads/drops/$ORBIT_VERSION/repository/ \
  -i org.eclipse.emf.facet.sdk.feature.feature.group
fi

if [ $INSTALL_MODISCO = "true" ]; then
  $installCommand \
  -r http://$MIRROR/facet/updates/milestones/0.2/ \
  -r http://$MIRROR/modeling/mdt/modisco/updates/milestones/0.10/ \
  -r "$MAIN_REPO" \
  -r http://$MIRROR/tools/orbit/downloads/drops/$ORBIT_VERSION/repository/ \
  -i org.eclipse.modisco.sdk.feature.feature.group \
  -i org.eclipse.modisco.dev.feature.feature.group
fi

