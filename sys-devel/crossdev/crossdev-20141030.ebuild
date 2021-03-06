# Copyright 2013 Hacking Networked Solutions
# Distributed under the terms of the GNU General Public License v3+
# $Header: $

EAPI="4"

if [[ ${PV} == "99999999" ]] ; then
	EGIT_REPO_URI="git://anongit.gentoo.org/proj/crossdev.git"
	inherit eutils git-2
	SRC_URI=""
	#KEYWORDS=""
else
	inherit eutils
	SRC_URI="mirror://gentoo/${P}.tar.xz
		http://dev.gentoo.org/~vapier/dist/${P}.tar.xz"
	KEYWORDS="alpha amd64 arm arm64 hppa ia64 m68k ~mips ppc ppc64 s390 sh sparc x86 ~x86-fbsd"
fi

DESCRIPTION="Gentoo Cross-toolchain generator"
HOMEPAGE="http://www.gentoo.org/"

LICENSE="GPL-2"
SLOT="0"
IUSE=""

RDEPEND=">=sys-apps/portage-2.1
	app-shells/bash
	!sys-devel/crossdev-wrappers"
DEPEND="app-arch/xz-utils"

src_prepare() {
	epatch "${FILESDIR}/crossdev-multilib.patch"
}

src_install() {
	default
	if [[ "${PV}" == "99999999" ]] ; then
		sed -i "s:@CDEVPV@:${EGIT_VERSION}:" "${ED}"/usr/bin/crossdev || die
	fi
}
