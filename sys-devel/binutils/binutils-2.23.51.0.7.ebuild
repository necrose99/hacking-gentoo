# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-devel/binutils/binutils-2.23.51.0.7.ebuild,v 1.1 2012/12/20 23:49:40 vapier Exp $

PATCHVER="1.0"
ELF2FLT_VER=""
inherit toolchain-binutils

src_unpack() {
	tc-binutils_unpack
	cp "${FILESDIR}/97_all_binutils-scriptsdir.patch" ${EPATCH_SOURCE}
	tc-binutils_apply_patches
}
