# Copyright 2013 Hacking Networked Solutions
# Distributed under the terms of the GNU General Public License v3+
# $Header: $

EAPI=5
inherit autotools eutils multilib systemd

MY_PV=${PV/_/}
DESCRIPTION="syslog replacement with advanced filtering features"
HOMEPAGE="http://www.balabit.com/network-security/syslog-ng"
SRC_URI="http://www.balabit.com/downloads/files/syslog-ng/sources/${MY_PV}/source/syslog-ng_${MY_PV}.tar.gz"

LICENSE="GPL-2+ LGPL-2.1+"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~x86-fbsd"
IUSE="caps dbi geoip ipv6 json mongodb +pcre smtp spoof-source ssl tcpd"
RESTRICT="test"

RDEPEND="
	pcre? ( dev-libs/libpcre )
	spoof-source? ( net-libs/libnet:1.1 )
	ssl? ( dev-libs/openssl:= )
	smtp? ( net-libs/libesmtp )
	tcpd? ( >=sys-apps/tcp-wrappers-7.6 )
	>=dev-libs/eventlog-0.2.12
	>=dev-libs/glib-2.10.1:2
	json? ( >=dev-libs/json-c-0.9 )
	caps? ( sys-libs/libcap )
	geoip? ( >=dev-libs/geoip-1.5.0 )
	dbi? ( >=dev-db/libdbi-0.8.3 )"
DEPEND="${RDEPEND}
	virtual/pkgconfig
	sys-devel/flex"

S=${WORKDIR}/${PN}-${MY_PV}

src_prepare() {
	epatch \
		"${FILESDIR}"/${PV%.*}/${P}-rollup.patch \
		"${FILESDIR}"/${PV%.*}/${P}-autotools.patch
	mv configure.in configure.ac || die
	eautoreconf
}

src_configure() {
	econf \
		--with-ivykis=internal \
		--with-libmongo-client=internal \
		--sysconfdir=/etc/syslog-ng \
		--localstatedir=/var/lib/misc/syslog-ng \
		--with-pidfile-dir=/var/run/syslog-ng \
		--with-module-dir=/usr/$(get_libdir)/syslog-ng \
		$(systemd_with_unitdir) \
		$(use_enable caps linux-caps) \
		$(use_enable geoip) \
		$(use_enable ipv6) \
		$(use_enable json) \
		$(use_enable mongodb) \
		$(use_enable pcre) \
		$(use_enable smtp) \
		$(use_enable spoof-source) \
		$(use_enable dbi sql) \
		$(use_enable ssl) \
		$(use_enable tcpd tcp-wrapper)
}

src_install() {
	emake DESTDIR="${D}" install

	dodoc AUTHORS ChangeLog NEWS contrib/syslog-ng.conf* contrib/syslog2ng \
		"${FILESDIR}/${PV%.*}/syslog-ng.conf.gentoo.hardened" \
		"${FILESDIR}/syslog-ng.logrotate.hardened" \
		"${FILESDIR}/README.hardened"

	# Install default configuration
	insinto /etc/syslog-ng
	if use userland_BSD ; then
		newins "${FILESDIR}/${PV%.*}/syslog-ng.conf.gentoo.fbsd" syslog-ng.conf
	else
		newins "${FILESDIR}/${PV%.*}/syslog-ng.conf.gentoo" syslog-ng.conf
	fi

	insinto /etc/logrotate.d
	newins "${FILESDIR}/syslog-ng.logrotate" syslog-ng

	newinitd "${FILESDIR}/${PV%.*}/syslog-ng.rc6" syslog-ng
	newconfd "${FILESDIR}/${PV%.*}/syslog-ng.confd" syslog-ng
	keepdir /etc/syslog-ng/patterndb.d /var/lib/syslog-ng
	prune_libtool_files --modules
}

pkg_preinst() {
	enewgroup syslog 514
	enewuser syslog 514 -1 -1 "syslog,tty"
	gpasswd -a root syslog

	keepdir /var/run/syslog-ng
	fperms 0770 /var/run/syslog-ng
	fowners syslog:syslog /var/run/syslog-ng

	keepdir /var/lib/misc/syslog-ng
	fperms 0770 /var/lib/misc/syslog-ng
	fowners syslog:syslog /var/lib/misc/syslog-ng
}

pkg_postinst() {
	elog "For detailed documentation please see the upstream website:"
	elog "http://www.balabit.com/sites/default/files/documents/syslog-ng-ose-3.4-guides/en/syslog-ng-ose-v3.4-guide-admin/html/index.html"
 	echo
	ewarn "Please note that the standard location of the socket and PID file has changed from"
	ewarn "/var/run/syslog-ng.* to /var/run/syslog-ng/syslog-ng.* and you have to be in the"
	ewarn "'syslog' group to access the control socket or /var/log/messages."
	ewarn "This can break applications which have the standard location hard-coded."
	echo
	if [[ $(stat -c %U /var/log) != "syslog" ]]; then
		ewarn "Forcing new permissions on /var/log and /var/log/messages"
		chown syslog:syslog /var/log
		[[ -e /var/log/messages ]] && chown syslog:syslog /var/log/messages
		echo
	fi 

	# bug #355257
	if ! has_version app-admin/logrotate ; then
		echo
		elog "It is highly recommended that app-admin/logrotate be emerged to"
		elog "manage the log files.  ${PN} installs a file in /etc/logrotate.d"
		elog "for logrotate to use."
		echo
	fi
}
