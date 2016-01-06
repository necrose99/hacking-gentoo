# Copyright 2013 Hacking Networked Solutions
# Distributed under the terms of the GNU General Public License v3+
# $Header: $

EAPI=5

inherit linux-mod eutils

DESCRIPTION="r8168 driver for Realtek 8111/8168 PCI-E NICs"
HOMEPAGE="http://www.realtek.com.tw"
SRC_URI="http://12244.wpc.azureedge.net/8012244/drivers/rtdrivers/cn/nic/0003-${P}.tar.bz2 -> ${P}.tar.bz2"
LICENSE="GPL-2"
SLOT="0"
IUSE=""

KEYWORDS="~amd64 ~x86"

MODULE_NAMES="r8168(net:${S}/src)"
BUILD_TARGETS="modules"

ERROR_R8169="${P} requires Realtek 8169 PCI Gigabit Ethernet adapter (CONFIG_R8169) to be DISABLED or configured as a MODULE"

pkg_pretend() {
	linux_config_exists || die "You do not appear to have configured your kernel!"
	linux_chkconfig_builtin "R8169" && die "${ERROR_R8169}"
}

pkg_setup() {
	linux-mod_pkg_setup
	BUILD_PARAMS="KERNELDIR=${KV_DIR}"
}

src_install() {
	linux-mod_src_install
	dodoc README
	
	insinto /etc/modprobe.d/
	doins "${FILESDIR}/r8168.conf"
}
