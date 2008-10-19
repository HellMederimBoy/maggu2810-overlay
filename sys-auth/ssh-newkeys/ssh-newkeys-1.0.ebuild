# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit eutils

# short description
DESCRIPTION="Creates and exchanges DSA SSH keys between two machines"

# link to homepage
HOMEPAGE="https://darknrg.dyndns.org:28514"

# license(s)
LICENSE="GPL-2"

# slot (0 for none)
SLOT="0"

# platform keywords
KEYWORDS="~amd64 ~x86"

# restrict downloading from mirror
RESTRICT="mirror"

# use flags
IUSE=""

# common dependencies
COMMONDEP="
	app-shells/bash
	sys-apps/coreutils
	sys-apps/grep
	sys-apps/sed
"

DEPEND="${COMMONDEP}"
RDEPEND="${COMMONDEP}"


src_install() {
	cd ${FILESDIR}
	tocp=""
	for f in *.sh; do
		f2=${T}/${f%.sh}
		tocp="$tocp $f2"
		cp $f $f2
	done

	[ -e ${PF}.patch ] && {
		cp ${PF}.patch ${T}
		cd ${T}
		sed -i "s:/usr/bin/::" ${PF}.patch
		epatch ${PF}.patch
	}

	cd ${T}
	for f in $tocp; do
		dobin $f
	done
	cd -

	insinto /etc
	doins ssh-newkeys.cfg
}