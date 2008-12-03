# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"

NEED_KDE=":4.1"
KDE_LINGUAS="ar be bg ca da de el en_GB eo es et eu fi fr ga gl hi hu it ja km
lt lv nb nds nl nn oc pl pt pt_BR ro ru se sk sl sv tr uk zh_CN zh_TW"
inherit eutils kde4-base subversion
SLOT="4.1"

#KMNAME="extragear/multimedia"

DESCRIPTION="K3b, KDE CD Writing Software"
HOMEPAGE="http://www.k3b.org/"

LICENSE="GPL-2"
KEYWORDS="~x86"
IUSE="css debug dvdr dvdread encode -ffmpeg flac hal htmlhandbook mp3 musepack
	sndfile vcd vorbis emovix"
ESVN_REPO_URI="svn://anonsvn.kde.org/home/kde/trunk/extragear/multimedia/${PN}/@{${PV/2.0_pre/}}"

# FIXME: Needed?
# app-doc/doxygen
#find_package(Doxygen)
#laurent: removes this line when Doxyfile.cmake will add to svn
#set(DOXYGEN_EXECUTABLE FALSE)
#if(DOXYGEN_EXECUTABLE)

DEPEND="
	kde-base/libkcddb:${SLOT}
	kde-base/libkcompactdisc:${SLOT}
	media-libs/libsamplerate
	media-libs/musicbrainz:1
	media-libs/taglib
	x11-libs/qt-webkit:4
	dvdread? ( media-libs/libdvdread )
	encode? ( media-sound/lame )
	ffmpeg? ( media-video/ffmpeg )
	flac? ( >=media-libs/flac-1.2.1-r2 )
	mp3? ( media-libs/libmad )
	musepack? ( media-libs/libmpcdec )
	sndfile? ( media-libs/libsndfile )
	vorbis? ( media-libs/libvorbis )
	"

RDEPEND="${DEPEND}
	>=app-cdr/cdrdao-1.1.7-r3
	>=media-sound/cdparanoia-3.9.8
	media-sound/normalize
	virtual/cdrtools
	css? ( media-libs/libdvdcss )
	dvdr? ( >=app-cdr/dvd+rw-tools-7.0 )
	emovix? ( media-video/emovix )
	encode? ( media-sound/sox
	dvdread? ( media-video/transcode ) )
	vcd? ( media-video/vcdimager )
	"

pkg_setup() {
	use ffmpeg && ewarn "FFMpeg seems to be badly broken in this snapshot. Use it at your own risk!"
	if use flac && ! built_with_use media-libs/flac cxx ; then
		eerror "In order to build "
		eerror "you need media-libs/flac built with cxx USE flag enabled."
		die "no cxx support in flac"
	fi
	if use encode && use dvdread && ! built_with_use media-video/transcode dvdread ; then
		eerror "In order to build "
		eerror "you need media-video/transcode built with dvdread USE flag"
		die "no dvdread support in transcode"
	fi
}

src_compile() {
	if use debug; then
		mycmakeargs="${mycmakeargs} -DADD_K3B_DEBUG=On"
	else
		mycmakeargs="${mycmakeargs} -DADD_K3B_DEBUG=Off"
	fi

	mycmakeargs="${mycmakeargs} -DK3BSETUP_BUILD=Off
		-DWITH_Samplerate=On
		-DNEWFFMPEGAVCODECPATH
		$(cmake-utils_use_with dvdread DvdRead)
		$(cmake-utils_use_with ffmpeg FFmpeg)
		$(cmake-utils_use_with flac Flac)
		$(cmake-utils_use_with flac Flac++)
		$(cmake-utils_use_with encode Lame)
		$(cmake-utils_use_with mp3 Mad)
		$(cmake-utils_use_with musepack Muse)
		$(cmake-utils_use_with sndfile Sndfile)
		$(cmake-utils_use_with vorbis OggVorbis)"

	# Build process of K3b
	kde4-base_src_compile
}

src_install() {
	kde4-base_src_install
	dodoc "${S}"/{FAQ,KNOWNBUGS,PERMISSIONS} || die "Installing additional docs failed."
#	dodoc "${S}"/${PN}/{FAQ,KNOWNBUGS,PERMISSIONS} || die "Installing additional docs failed."
}

pkg_postinst() {
	echo
	elog "We don't install k3bsetup anymore because Gentoo doesn't need it."
	elog "If you get warnings on start-up, uncheck the \"Check system"
	elog "configuration\" option in the \"Misc\" settings window."
	echo

	local group=cdrom
	use kernel_linux || group=operator
	elog "Make sure you have proper read/write permissions on the cdrom device(s)."
	elog "Usually, it is sufficient to be in the ${group} group."
	echo
	kde4-base_pkg_postinst
}