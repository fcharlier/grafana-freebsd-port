# $FreeBSD$

PORTNAME=	grafana2
PORTVERSION=	2.5.0
DISTVERSIONPREFIX=	v
CATEGORIES=	www

MAINTAINER=	thomas@bartelmess.io
COMMENT=	Dashboard and graph editor for Graphite, InfluxDB & OpenTSDB

LICENSE=	APACHE20

BUILD_DEPENDS=	${LOCALBASE}/bin/go:${PORTSDIR}/lang/go

ONLY_FOR_ARCHS=	i386 amd64

USE_RC_SUBR=	grafana

USES=	compiler

PRECOMPILED_CSS_JS_DESC=	Use pre-generated web assets
COMPILE_JS_CSS_DESC=	Generate web assets

OPTIONS_SINGLE=	ASSESTS
OPTIONS_SINGLE_ASSESTS=	PRECOMPILED_CSS_JS COMPILE_JS_CSS
OPTIONS_DEFAULT=	PRECOMPILED_CSS_JS

USE_GITHUB=	yes
GH_ACCOUNT=	grafana go-bufio:bufio macaron-contrib:binding,session \
	go-redis:redis streadway:amqp smartystreets:goconvey \
	BurntSushi:toml Unknwon:macaron,com rainycape:unidecode \
	go-sql-driver:mysql davecgh:go_spew gosimple:slug vaughan0:go_ini \
	go-xorm:xorm,core go-ini:ini jtolds:gls aws:aws_sdk_go \
	go-asn1-ber:asn1_ber golang:oauth2,net go-ldap:ldap lib:pq \
	mattn:go_sqlite3
GH_PROJECT=	grafana gls:gls goconvey:goconvey mysql:mysql \
	go-sqlite3:go_sqlite3 session:session redis:redis bufio:bufio \
	macaron:macaron go-ini:go_ini slug:slug ini:ini go-spew:go_spew \
	binding:binding oauth2:oauth2 com:com asn1-ber:asn1_ber toml:toml \
	pq:pq net:net aws-sdk-go:aws_sdk_go core:core xorm:xorm \
	unidecode:unidecode ldap:ldap amqp:amqp
GH_TAGNAME=	${DISTVERSIONPREFIX}${PORTVERSION} f1ac7f4:gls \
	1.5.0-356-gfbc0a1c:goconvey v1.2-26-g9543750:mysql \
	836ef0a:unidecode 31e841d:session v2.3.2:redis v1:bufio \
	93de4f3:macaron 8d25846:slug v0-16-g1772191:ini 0fbe4b9:binding \
	c58fcf0:oauth2 2df1748:go_spew d9bcf40:com \
	v0.9.16-3-g4944a94:aws_sdk_go a98ad7e:go_ini \
	v0.1.0-21-g056c9bc:toml go1.0-cutoff-13-g19eeca3:pq v1:asn1_ber \
	972f0c5:net be6e7ac:core v0.4.2-58-ge2889e5:xorm \
	e28cd44:go_sqlite3 v1-19-g83e6542:ldap 150b7f2:amqp

GRAFANA_USER?=	grafana
GRAFANA_GROUP?=	grafana

USERS=	${GRAFANA_USER}
GROUPS=	${GRAFANA_GROUP}

GRAFANAHOMEDIR=	${PREFIX}/share/grafana/
GRAFANADATADIR=	/var/db/${PORTNAME}/
GRAFANALOGDIR=	/var/log/${PORTNAME}/
GRAFANAPIDDIR=	/var/run/${PORTNAME}/

SUB_FILES=	grafana grafana.conf
SUB_LIST+=	GRAFANA_USER=${GRAFANA_USER} \
	GRAFANA_GROUP=${GRAFANA_GROUP} \
	GRAFANADATADIR=${GRAFANADATADIR} \
	GRAFANALOGDIR=${GRAFANALOGDIR} \
	GRAFANAPIDDIR=${GRAFANAPIDDIR} \
	GRAFANAHOMEDIR=${GRAFANAHOMEDIR}

PLIST_SUB+=	GRAFANAHOMEDIR=${GRAFANAHOMEDIR}

.include <bsd.port.options.mk>

.if ${PORT_OPTIONS:MPRECOMPILED_CSS_JS}
MASTER_SITES+=	http://files.bartelmess.io/public/:static_assets
DISTFILES+=	grafana-static-${PORTVERSION}.tar.gz:static_assets
.endif

.if ${PORT_OPTIONS:MCOMPILE_JS_CSS}
BUILD_DEPENDS+= npm>=0:${PORTSDIR}/www/npm
.endif
post-extract:
	@${MKDIR} ${WRKSRC}/src/github.com/${GH_ACCOUNT}/grafana
.for src in .bra.toml .jscs.json CHANGELOG.md Gruntfile.js README.md build.go docker main.go pkg tasks \
	.gitignore .jsfmtrc CONTRIBUTING.md LICENSE.md appveyor.yml circle.yml docs package.json public tests \
	.hooks .jshintrc Godeps NOTICE.md benchmarks conf latest.json packaging vendor
	@${MV} ${WRKSRC}/${src} \
	${WRKSRC}/src/github.com/${GH_ACCOUNT}/grafana
.endfor
	@${MKDIR} ${WRKSRC}/src/github.com/jtolds
	@${MKDIR} ${WRKSRC}/src/github.com/macaron-contrib
	@${MKDIR} ${WRKSRC}/src/github.com/go-sql-driver
	@${MKDIR} ${WRKSRC}/src/github.com/mattn
	@${MKDIR} ${WRKSRC}/src/github.com/macaron-contrib
	@${MKDIR} ${WRKSRC}/src/gopkg.in
	@${MKDIR} ${WRKSRC}/src/github.com/smartystreets
	@${MKDIR} ${WRKSRC}/src/github.com/Unknwon
	@${MKDIR} ${WRKSRC}/src/github.com/gosimple
	@${MKDIR} ${WRKSRC}/src/gopkg.in
	@${MKDIR} ${WRKSRC}/src/github.com/davecgh
	@${MKDIR} ${WRKSRC}/src/github.com/go-xorm
	@${MKDIR} ${WRKSRC}/src/golang.org/x
	@${MKDIR} ${WRKSRC}/src/github.com/Unknwon
	@${MKDIR} ${WRKSRC}/src/github.com/aws
	@${MKDIR} ${WRKSRC}/src/gopkg.in
	@${MKDIR} ${WRKSRC}/src/gopkg.in
	@${MKDIR} ${WRKSRC}/src/github.com/BurntSushi
	@${MKDIR} ${WRKSRC}/src/github.com/lib
	@${MKDIR} ${WRKSRC}/src/golang.org/x
	@${MKDIR} ${WRKSRC}/src/github.com/vaughan0
	@${MKDIR} ${WRKSRC}/src/github.com/go-xorm
	@${MKDIR} ${WRKSRC}/src/github.com/rainycape
	@${MKDIR} ${WRKSRC}/src/github.com/go-ldap
	@${MKDIR} ${WRKSRC}/src/github.com/streadway

	@${MV} ${WRKSRC_gls} ${WRKSRC}/src/github.com/jtolds/gls
	@${MV} ${WRKSRC_binding} ${WRKSRC}/src/github.com/macaron-contrib/binding
	@${MV} ${WRKSRC_mysql} ${WRKSRC}/src/github.com/go-sql-driver/mysql
	@${MV} ${WRKSRC_go_sqlite3} ${WRKSRC}/src/github.com/mattn/go-sqlite3
	@${MV} ${WRKSRC_session} ${WRKSRC}/src/github.com/macaron-contrib/session
	@${MV} ${WRKSRC_redis} ${WRKSRC}/src/gopkg.in/redis.v2
	@${MV} ${WRKSRC_goconvey} ${WRKSRC}/src/github.com/smartystreets/goconvey
	@${MV} ${WRKSRC_macaron} ${WRKSRC}/src/github.com/Unknwon/macaron
	@${MV} ${WRKSRC_slug} ${WRKSRC}/src/github.com/gosimple/slug
	@${MV} ${WRKSRC_ini} ${WRKSRC}/src/gopkg.in/ini.v1
	@${MV} ${WRKSRC_go_spew} ${WRKSRC}/src/github.com/davecgh/go-spew
	@${MV} ${WRKSRC_xorm} ${WRKSRC}/src/github.com/go-xorm/xorm
	@${MV} ${WRKSRC_oauth2} ${WRKSRC}/src/golang.org/x/oauth2
	@${MV} ${WRKSRC_com} ${WRKSRC}/src/github.com/Unknwon/com
	@${MV} ${WRKSRC_aws_sdk_go} ${WRKSRC}/src/github.com/aws/aws-sdk-go
	@${MV} ${WRKSRC_bufio} ${WRKSRC}/src/gopkg.in/bufio.v1
	@${MV} ${WRKSRC_asn1_ber} ${WRKSRC}/src/gopkg.in/asn1-ber.v1
	@${MV} ${WRKSRC_toml} ${WRKSRC}/src/github.com/BurntSushi/toml
	@${MV} ${WRKSRC_pq} ${WRKSRC}/src/github.com/lib/pq
	@${MV} ${WRKSRC_net} ${WRKSRC}/src/golang.org/x/net
	@${MV} ${WRKSRC_go_ini} ${WRKSRC}/src/github.com/vaughan0/go-ini
	@${MV} ${WRKSRC_core} ${WRKSRC}/src/github.com/go-xorm/core
	@${MV} ${WRKSRC_unidecode} ${WRKSRC}/src/github.com/rainycape/unidecode
	@${MV} ${WRKSRC_ldap} ${WRKSRC}/src/github.com/go-ldap/ldap
	@${MV} ${WRKSRC_amqp} ${WRKSRC}/src/github.com/streadway/amqp

.if ${PORT_OPTIONS:MPRECOMPILED_CSS_JS}
	@${RM} -rf ${WRKSRC}/src/github.com/${GH_ACCOUNT}/grafana/public
	@${MV} ${WRKDIR}/public  ${WRKSRC}/src/github.com/${GH_ACCOUNT}/grafana/
.endif

do-build:
	@cd ${WRKSRC}/src/github.com/${GH_ACCOUNT}/grafana; \
	${SETENV} ${BUILD_ENV} GOPATH=${WRKSRC} go run build.go build

.if ${PORT_OPTIONS:MCOMPILE_JS_CSS}
	cd ${WRKSRC}/src/github.com/${GH_ACCOUNT}/grafana; npm install
	cd ${WRKSRC}/src/github.com/${GH_ACCOUNT}/grafana; \
	${WRKSRC}/src/github.com/${GH_ACCOUNT}/grafana/node_modules/grunt-cli/bin/grunt
.endif

do-install:
	${INSTALL_PROGRAM} ${WRKSRC}/src/github.com/${GH_ACCOUNT}/grafana/bin/grafana-server \
	${STAGEDIR}${PREFIX}/bin/grafana-server
	@cd ${WRKSRC}/src/github.com/${GH_ACCOUNT}/grafana && \
	${COPYTREE_SHARE} public ${STAGEDIR}${PREFIX}/share/grafana
	@${MKDIR} ${STAGEDIR}${GRAFANAPIDDIR}
	@${MKDIR} ${STAGEDIR}${GRAFANALOGDIR}
	@${MKDIR} ${STAGEDIR}${GRAFANAHOMEDIR}
	@${MKDIR} ${STAGEDIR}${GRAFANADATADIR}
	@${MKDIR} ${STAGEDIR}${GRAFANAHOMEDIR}/conf
	${INSTALL_DATA} ${WRKSRC}/src/github.com/${GH_ACCOUNT}/grafana/conf/defaults.ini \
	${STAGEDIR}${GRAFANAHOMEDIR}/conf/defaults.ini
	${INSTALL_DATA} ${WRKDIR}/grafana.conf ${STAGEDIR}${PREFIX}/etc/grafana.conf

.include <bsd.port.pre.mk>

.if ${OPSYS} == FreeBSD && ${OSVERSION} < 900044 && ${ARCH} == i386
BROKEN= Does not build
.endif

# golang assumes that if clang is in use, it is called "clang" and not "cc". If
# it's called "cc", go fails.
.if ${COMPILER_TYPE} == clang
BUILD_ENV=	CC=clang
.endif

.include <bsd.port.post.mk>