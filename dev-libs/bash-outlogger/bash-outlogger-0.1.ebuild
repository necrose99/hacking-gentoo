# Copyright 2010 Hacking Networked Solutions
# Distributed under the terms of the GNU General Public License v3
# $Header$

EAPI="3"

DESCRIPTION="A library script to log output and manage the generated log files"
HOMEPAGE="http://www.mad-hacking.net/software/linux/bash-outlogger/index.xml"
SRC_URI="http://downloads.mad-hacking.net/software/${P}.tar.bz2"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~alpha amd64 ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~sparc-fbsd x86 ~x86-fbsd"
IUSE=""

src_install() {
	insinto /usr/lib
	doins lib/outlogger.sh
}