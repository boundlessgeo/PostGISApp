# VERSION numbers
POSTGIS_VERSION=2.1.3
POSTGIS_MAJOR_VERSION=2.1
POSTGRES_VERSION=9.3.4
GDAL_VERSION=1.11.1
GEOS_VERSION=3.4.0
LIBEDIT_VERSION=20130611-3.1
LIBUUID_VERSION=1.6.2
LIBXML2_VERSION=2.9.1
OPENSSL_VERSION=1.0.1e
PROJ_VERSION=4.8.0
DATUMGRID_VERSION=1.5
JSONC_VERSION=0.11
LIBTIFF_VERSION=4.0.3
LIBLAS_VERSION=1.7.0
LASZIP_VERSION=2.2.0
GHT_VERSION=0.1.0
POINTCLOUD_VERSION=0.1.0
CGAL_VERSION=4.2
SFCGAL_VERSION=1.0
GMP_VERSION=5.1.2
MPFR_VERSION=3.1.2
BOOST_VERSION=1_54_0

#path configuration
PREFIX=$(PROJECT_DIR)/Postgres/Vendor/postgres
PATH=$(PREFIX)/bin:/bin:/usr/bin:/opt/local/bin

# Force compilers to use OS X 10.7 SDK for better compatibility with older systems
MIN_OSX=10.7
CFLAGS:=$(CFLAGS) -mmacosx-version-min=$(MIN_OSX)
CXXFLAGS:=$(CXXFLAGS) -mmacosx-version-min=$(MIN_OSX)
MACOSX_DEPLOYMENT_TARGET=$(MIN_OSX)

export CFLAGS CXXFLAGS MACOSX_DEPLOYMENT_TARGET

# commands used for downloading and extracting sources
CURL=/usr/bin/curl -L10 --silent --show-error --remote-name
TAR=/usr/bin/tar xzf

all: postgresql postgis pointcloud
clean: clean-postgresql clean-libuuid clean-openssl clean-libxml2 clean-libedit clean-libgdal clean-libproj clean-postgis clean-libgeos clean-libtiff

#########################
###### PostgreSQL #######
#########################

postgresql: $(PREFIX)/bin/psql

$(PREFIX)/bin/psql: postgresql-$(POSTGRES_VERSION)/GNUmakefile
	make -C "postgresql-$(POSTGRES_VERSION)/config"
	make -C "postgresql-$(POSTGRES_VERSION)/src"
	make -C "postgresql-$(POSTGRES_VERSION)/contrib"
	make -C "postgresql-$(POSTGRES_VERSION)/config" install
	make -C "postgresql-$(POSTGRES_VERSION)/contrib" install
	make -C "postgresql-$(POSTGRES_VERSION)/src" install

# setting PATH is to make sure we find the right xml2-config
# the --with-includes and --with-libraries options are necessary so
# that postgres will be compiled and linked against our own versions
# of libraries like openssl, instead of system provided versions
postgresql-$(POSTGRES_VERSION)/GNUmakefile: $(PREFIX)/lib/libssl.dylib $(PREFIX)/lib/libxml2.dylib $(PREFIX)/lib/libedit.dylib ${PREFIX}/include/uuid.h postgresql-$(POSTGRES_VERSION)/configure 
	cd "postgresql-$(POSTGRES_VERSION)" && export PATH="$(PREFIX)/bin:$$PATH" && ./configure --prefix="$(PREFIX)" --with-includes="$(PREFIX)/include" --with-libraries="$(PREFIX)/lib" --enable-thread-safety --with-openssl --with-gssapi --with-bonjour --with-krb5 --with-libxml --with-libxslt --with-perl --with-python --with-libedit-preferred --with-ossp-uuid

# after extracting PostgreSQL sources, we must patch uuid-ossp so it builds on OSX
postgresql-$(POSTGRES_VERSION)/configure: postgresql-$(POSTGRES_VERSION).tar.bz2
	$(TAR) "postgresql-$(POSTGRES_VERSION).tar.bz2"
	echo '#define _XOPEN_SOURCE' >"postgresql-$(POSTGRES_VERSION)/contrib/uuid-ossp/uuid-ossp.c.patched"
	cat "postgresql-$(POSTGRES_VERSION)/contrib/uuid-ossp/uuid-ossp.c" >>"postgresql-$(POSTGRES_VERSION)/contrib/uuid-ossp/uuid-ossp.c.patched"
	mv "postgresql-$(POSTGRES_VERSION)/contrib/uuid-ossp/uuid-ossp.c.patched" "postgresql-$(POSTGRES_VERSION)/contrib/uuid-ossp/uuid-ossp.c"
	touch $@

postgresql-$(POSTGRES_VERSION).tar.bz2:	
	$(CURL) "http://ftp.postgresql.org/pub/source/v$(POSTGRES_VERSION)/postgresql-$(POSTGRES_VERSION).tar.bz2"
	
clean-postgresql:
	rm -Rf postgresql-$(POSTGRES_VERSION)

#########################
####### libuuid #########
#########################

uuid-${LIBUUID_VERSION}.tar.gz:
	$(CURL) "http://www.mirrorservice.org/sites/ftp.ossp.org/pkg/lib/uuid/uuid-${LIBUUID_VERSION}.tar.gz"

uuid-${LIBUUID_VERSION}: uuid-${LIBUUID_VERSION}.tar.gz
	$(TAR) "uuid-${LIBUUID_VERSION}.tar.gz"
	touch "uuid-${LIBUUID_VERSION}"

${PREFIX}/include/uuid.h: uuid-${LIBUUID_VERSION}
	cd uuid-${LIBUUID_VERSION} && ./configure --prefix="${PREFIX}" --disable-debug
	make -C uuid-${LIBUUID_VERSION}
	make -C uuid-${LIBUUID_VERSION} install
	touch ${PREFIX}/include/uuid.h
	
libuuid: ${PREFIX}/include/uuid.h

clean-libuuid:
	rm -Rf "uuid-${LIBUUID_VERSION}"
	
	
#########################
####### OpenSSL #########
#########################

openssl: $(PREFIX)/lib/libssl.dylib

$(PREFIX)/lib/libssl.dylib: openssl-${OPENSSL_VERSION}/Makefile
	make -C openssl-${OPENSSL_VERSION}
	make -C openssl-${OPENSSL_VERSION} install_sw

openssl-${OPENSSL_VERSION}/Makefile: openssl-${OPENSSL_VERSION}/Configure
	cd openssl-${OPENSSL_VERSION} && ./Configure --prefix="${PREFIX}" darwin64-x86_64-cc zlib no-asm no-krb5 shared

openssl-${OPENSSL_VERSION}/Configure: openssl-${OPENSSL_VERSION}.tar.gz
	$(TAR) openssl-${OPENSSL_VERSION}.tar.gz
	touch $@

openssl-${OPENSSL_VERSION}.tar.gz:
	$(CURL) "http://www.openssl.org/source/openssl-${OPENSSL_VERSION}.tar.gz"
	
clean-openssl:
	rm -Rf "openssl-${OPENSSL_VERSION}"

#########################
######## LibXML2 ########
#########################

libxml2: $(PREFIX)/lib/libxml2.dylib

$(PREFIX)/lib/libxml2.dylib: libxml2-${LIBXML2_VERSION}/Makefile
	make -C libxml2-${LIBXML2_VERSION} install-exec
	make -C libxml2-${LIBXML2_VERSION}/include install
	touch $(PREFIX)/lib/libxml2.dylib

libxml2-${LIBXML2_VERSION}/Makefile: libxml2-${LIBXML2_VERSION}/configure
	cd libxml2-${LIBXML2_VERSION} && ./configure --prefix="$(PREFIX)" --disable-dependency-tracking

libxml2-${LIBXML2_VERSION}/configure: libxml2-${LIBXML2_VERSION}.tar.gz
	$(TAR) libxml2-${LIBXML2_VERSION}.tar.gz
	touch $@
	
libxml2-${LIBXML2_VERSION}.tar.gz:
	$(CURL) "ftp://xmlsoft.org/libxml2/libxml2-${LIBXML2_VERSION}.tar.gz"
	
clean-libxml2:
	rm -Rf "libxml2-$(LIBXML2_VERSION)"

#########################
####### LibEdit #########
#########################

libedit: $(PREFIX)/lib/libedit.dylib

$(PREFIX)/lib/libedit.dylib: libedit-$(LIBEDIT_VERSION)/Makefile
	make -C "libedit-$(LIBEDIT_VERSION)" install

libedit-$(LIBEDIT_VERSION)/Makefile: libedit-$(LIBEDIT_VERSION)/configure
	cd libedit-$(LIBEDIT_VERSION) && ./configure --prefix="$(PREFIX)"

libedit-$(LIBEDIT_VERSION)/configure: libedit-$(LIBEDIT_VERSION).tar.gz
	$(TAR) "libedit-${LIBEDIT_VERSION}.tar.gz"
	touch $@

libedit-$(LIBEDIT_VERSION).tar.gz:
	$(CURL) "http://www.thrysoee.dk/editline/libedit-$(LIBEDIT_VERSION).tar.gz"

clean-libedit:
	rm -Rf "libedit-$(LIBEDIT_VERSION)"

#########################
#######  libgeos  #######
#########################

# Depends on postgresql

libgeos: $(PREFIX)/lib/libgeos.dylib

$(PREFIX)/lib/libgeos.dylib: geos-${GEOS_VERSION}/Makefile
	make -C geos-${GEOS_VERSION} install

geos-${GEOS_VERSION}/Makefile: geos-${GEOS_VERSION}/configure $(PREFIX)/bin/psql
	cd geos-${GEOS_VERSION} && ./configure --prefix="$(PREFIX)"

#geos needs to be patched
geos-${GEOS_VERSION}/configure: geos-${GEOS_VERSION}.tar.bz2
	$(TAR) geos-${GEOS_VERSION}.tar.bz2
	/usr/bin/sed -i -e 's/@CFLAGS@$$/@CFLAGS@ -O1/g' geos-${GEOS_VERSION}/src/geom/Makefile.in
	/usr/bin/sed -i -e 's/@CXXFLAGS@$$/@CXXFLAGS@ -O1/g' geos-${GEOS_VERSION}/src/geom/Makefile.in
	touch $@

geos-${GEOS_VERSION}.tar.bz2:
	$(CURL) "http://download.osgeo.org/geos/geos-${GEOS_VERSION}.tar.bz2"

clean-libgeos:
	rm -Rf geos-${GEOS_VERSION}

#########################
#######  libgdal  #######
#########################

# Depends on libproj, postgresql, libtiff

libgdal: $(PREFIX)/lib/libgdal.dylib

$(PREFIX)/lib/libgdal.dylib: gdal-$(GDAL_VERSION)/GNUMakefile
	make -C gdal-$(GDAL_VERSION) install

gdal-$(GDAL_VERSION)/GNUMakefile: gdal-$(GDAL_VERSION)/autogen.sh $(PREFIX)/lib/libproj.dylib $(PREFIX)/bin/psql  $(PREFIX)/lib/libgeos.dylib # $(PREFIX)/lib/libtiff.dylib
	cd gdal-$(GDAL_VERSION) && ./autogen.sh && ./configure --prefix="$(PREFIX)" --with-pg="$(PREFIX)/bin/pg_config" --with-libgeotiff=internal --with-libjson-c=$(PREFIX)
	touch $@

gdal-$(GDAL_VERSION)/autogen.sh: gdal-${GDAL_VERSION}.tar.gz
	$(TAR) gdal-${GDAL_VERSION}.tar.gz
	touch $@	

gdal-${GDAL_VERSION}.tar.gz:
	$(CURL) "http://download.osgeo.org/gdal/${GDAL_VERSION}/gdal-${GDAL_VERSION}.tar.gz"

clean-libgdal:
	rm -Rf gdal-$(GDAL_VERSION)


#########################
###### proj4 ############
#########################

# Depends on postgresql

libproj: $(PREFIX)/lib/libproj.dylib

$(PREFIX)/lib/libproj.dylib: proj-$(PROJ_VERSION)/Makefile
	make -C proj-$(PROJ_VERSION) install

proj-$(PROJ_VERSION)/Makefile: proj-$(PROJ_VERSION)/configure $(PREFIX)/bin/psql
	cd proj-$(PROJ_VERSION) && ./configure --prefix="$(PREFIX)"

proj-${PROJ_VERSION}/configure: proj-${PROJ_VERSION}.tar.gz proj-datumgrid-$(DATUMGRID_VERSION).zip
	$(TAR) "proj-${PROJ_VERSION}.tar.gz"
	unzip -o "proj-datumgrid-${DATUMGRID_VERSION}.zip" -d "./proj-${PROJ_VERSION}/nad"
	touch $@

proj-${PROJ_VERSION}.tar.gz:
	$(CURL) "http://download.osgeo.org/proj/proj-${PROJ_VERSION}.tar.gz"

proj-datumgrid-${DATUMGRID_VERSION}.zip:
	$(CURL) "http://download.osgeo.org/proj/proj-datumgrid-${DATUMGRID_VERSION}.zip"
	
clean-libproj:
	rm -Rf proj-${PROJ_VERSION}



#########################
###### JSON-c ###########
#########################

json-c: $(PREFIX)/lib/libjson.dylib

$(PREFIX)/lib/libjson.dylib: json-c-$(JSONC_VERSION)/Makefile
	make -C json-c-$(JSONC_VERSION) install
	cp json-c-$(JSONC_VERSION)/json_object_iterator.h "$(PREFIX)/include/json/json_object_iterator.h"


json-c-$(JSONC_VERSION)/Makefile: json-c-$(JSONC_VERSION)/configure
	cd json-c-$(JSONC_VERSION) && ./configure --prefix="$(PREFIX)" --disable-dependency-tracking

json-c-$(JSONC_VERSION)/configure: json-c-$(JSONC_VERSION).tar.gz
	$(TAR) json-c-$(JSONC_VERSION).tar.gz
	touch $@

json-c-$(JSONC_VERSION).tar.gz:
	$(CURL) "https://s3.amazonaws.com/json-c_releases/releases/json-c-$(JSONC_VERSION).tar.gz"


#########################
####### libtiff #########
#########################

libtiff: $(PREFIX)/lib/libtiff.dylib

$(PREFIX)/lib/libtiff.dylib: tiff-$(LIBTIFF_VERSION)/Makefile
	make -C tiff-$(LIBTIFF_VERSION) install

tiff-$(LIBTIFF_VERSION)/Makefile: tiff-$(LIBTIFF_VERSION)/configure
	cd tiff-$(LIBTIFF_VERSION) && ./configure --prefix="$(PREFIX)" --disable-dependency-tracking

tiff-$(LIBTIFF_VERSION)/configure: tiff-$(LIBTIFF_VERSION).tar.gz
	$(TAR) tiff-$(LIBTIFF_VERSION).tar.gz
	touch $@

tiff-$(LIBTIFF_VERSION).tar.gz:
	$(CURL) ftp://ftp.remotesensing.org/pub/libtiff/tiff-4.0.3.tar.gz

clean-libtiff:
	rm -Rf tiff-$(LIBTIFF_VERSION)

#########################
####### GMP #############
#########################

gmp: $(PREFIX)/lib/libgmp.dylib

$(PREFIX)/lib/libgmp.dylib: gmp-$(GMP_VERSION)/Makefile
	make -C gmp-$(GMP_VERSION) install

gmp-$(GMP_VERSION)/Makefile: gmp-$(GMP_VERSION)/configure
	cd gmp-$(GMP_VERSION) && ./configure --prefix=$(PREFIX)

gmp-$(GMP_VERSION)/configure: gmp-$(GMP_VERSION).tar.bz2
	$(TAR) gmp-$(GMP_VERSION).tar.bz2
	touch $@

gmp-$(GMP_VERSION).tar.bz2:
	$(CURL) ftp://ftp.gmplib.org/pub/gmp-5.1.2/gmp-$(GMP_VERSION).tar.bz2

clean-gmp:
	rm -Rf gmp-$(GMP_VERSION)

#########################
####### MPFR ############
#########################

mpfr: $(PREFIX)/lib/libmpfr.dylib

$(PREFIX)/lib/libmpfr.dylib: mpfr-$(MPFR_VERSION)/Makefile
	make -C mpfr-$(MPFR_VERSION) install

mpfr-$(MPFR_VERSION)/Makefile: mpfr-$(MPFR_VERSION)/configure
	cd mpfr-$(MPFR_VERSION) && ./configure --prefix=$(PREFIX) --with-gmp=$(PREFIX)

mpfr-$(MPFR_VERSION)/configure: mpfr-$(MPFR_VERSION).tar.bz2
	$(TAR) mpfr-$(MPFR_VERSION).tar.bz2
	touch $@

mpfr-$(MPFR_VERSION).tar.bz2:
	$(CURL) http://www.mpfr.org/mpfr-current/mpfr-$(MPFR_VERSION).tar.bz2

clean-mpfr:
	rm -Rf mpfr-$(MPFR_VERSION)
	
#########################
####### BOOST ###########
#########################

boost: $(PREFIX)/lib/libboost_system.a

$(PREFIX)/lib/libboost_system.a: boost_$(BOOST_VERSION)/b2
	cd boost_$(BOOST_VERSION) && ./bjam toolset=darwin link=static threading=multi runtime-link=static variant=release address-model=64 -mmacosx-version=$(MIN_OSX) -mmacosx-version-min=$(MIN_OSX) --dll-path=$(PREFIX) install

boost_$(BOOST_VERSION)/b2: boost_$(BOOST_VERSION)/bootstrap.sh
	cd boost_$(BOOST_VERSION) && ./bootstrap.sh --prefix=$(PREFIX) --libdir=$(PREFIX)/lib --with-libraries=system,thread,serialization,date_time,program_options

boost_$(BOOST_VERSION)/bootstrap.sh: boost_$(BOOST_VERSION).tar.bz2
	$(TAR) boost_$(BOOST_VERSION).tar.bz2
	touch $@

boost_$(BOOST_VERSION).tar.bz2:
	$(CURL) http://downloads.sourceforge.net/project/boost/boost/1.54.0/boost_$(BOOST_VERSION).tar.bz2

clean-boost:
	rm -Rf boost_$(BOOST_VERSION)

#########################
####### CGAL ############
#########################

cgal: $(PREFIX)/lib/libcgal.dylib

$(PREFIX)/lib/libcgal.dylib: CGAL-$(CGAL_VERSION)/Makefile
	make -C CGAL-$(CGAL_VERSION) install
	install_name_tool -change $(PROJECT_DIR)/src/CGAL-$(CGAL_VERSION)/lib/libCGAL.10.dylib $(PREFIX)/lib/libCGAL.10.dylib CGAL-$(CGAL_VERSION)/lib/libCGAL_Core.10.dylib
	install_name_tool -change $(PROJECT_DIR)/src/CGAL-$(CGAL_VERSION)/lib/libCGAL.10.dylib $(PREFIX)/lib/libCGAL.10.dylib CGAL-$(CGAL_VERSION)/lib/libCGAL_ImageIO.10.dylib
	cp CGAL-$(CGAL_VERSION)/lib/libCGAL_Core*.dylib $(PREFIX)/lib/
	cp CGAL-$(CGAL_VERSION)/lib/libCGAL_ImageIO*.dylib $(PREFIX)/lib/

CGAL-$(CGAL_VERSION)/Makefile: CGAL-$(CGAL_VERSION)/CMakeLists.txt $(PREFIX)/lib/libgmp.dylib $(PREFIX)/lib/libmpfr.dylib $(PREFIX)/lib/libboost_system.a
	cd CGAL-$(CGAL_VERSION) && cmake -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX="$(PREFIX)" -DCMAKE_OSX_SYSROOT=/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.7.sdk/ -DCMAKE_OSX_ARCHITECTURES="x86_64" -DCMAKE_CXX_FLAGS="$(CXXFLAGS)" -DCMAKE_INSTALL_NAME_DIR=$(PREFIX)/lib

CGAL-$(CGAL_VERSION)/CMakeLists.txt: CGAL-$(CGAL_VERSION).tar.bz2
	$(TAR) CGAL-$(CGAL_VERSION).tar.bz2
	touch $@

CGAL-$(CGAL_VERSION).tar.bz2:
	$(CURL) https://gforge.inria.fr/frs/download.php/32360/CGAL-$(CGAL_VERSION).tar.bz2

clean-cgal:
	rm -Rf CGAL-$(CGAL_VERSION)

#########################
####### SFCGAL ##########
#########################

sfcgal: $(PREFIX)/lib/libsfcgal.dylib

$(PREFIX)/lib/libsfcgal.dylib: SFCGAL-$(SFCGAL_VERSION)/Makefile
	make -C SFCGAL-$(SFCGAL_VERSION) install
	install_name_tool -change $(PROJECT_DIR)/src/CGAL-$(CGAL_VERSION)/lib/libCGAL_Core.10.dylib $(PREFIX)/lib/libCGAL_Core.10.dylib SFCGAL-$(SFCGAL_VERSION)/src/libSFCGAL.dylib
	cp SFCGAL-$(SFCGAL_VERSION)/src/libSFCGAL.dylib $(PREFIX)/lib/

SFCGAL-$(SFCGAL_VERSION)/Makefile: SFCGAL-$(SFCGAL_VERSION)/CMakeLists.txt $(PREFIX)/lib/libcgal.dylib
	cd SFCGAL-$(SFCGAL_VERSION) && cmake -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX="$(PREFIX)" -DCMAKE_OSX_SYSROOT=/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.7.sdk/ -DCMAKE_OSX_ARCHITECTURES="x86_64" -DCMAKE_CXX_FLAGS="$(CXXFLAGS)" -DCMAKE_INSTALL_NAME_DIR=$(PREFIX)/lib

SFCGAL-$(SFCGAL_VERSION)/CMakeLists.txt: sfcgal-$(SFCGAL_VERSION).tar.gz
	$(TAR) sfcgal-$(SFCGAL_VERSION).tar.gz
	touch $@

sfcgal-$(SFCGAL_VERSION).tar.gz:
	$(CURL) https://github.com/Oslandia/SFCGAL/archive/v$(SFCGAL_VERSION).tar.gz
	mv v$(SFCGAL_VERSION).tar.gz sfcgal-$(SFCGAL_VERSION).tar.gz

clean-sfcgal:
	rm -Rf sfcgal-$(CGAL_VERSION)



#########################
###### PostGIS ##########
#########################

#depends on libgdal, libgeos, postgresql, jsonc

postgis: $(PREFIX)/lib/postgis-$(POSTGIS_MAJOR_VERSION).so $(PREFIX)/lib/liblwgeom.dylib

$(PREFIX)/lib/liblwgeom.dylib: postgis-${POSTGIS_VERSION}/GNUMakefile $(PREFIX)/lib/postgis-$(POSTGIS_MAJOR_VERSION).so
	make -C postgis-${POSTGIS_VERSION}/liblwgeom
	make -C postgis-${POSTGIS_VERSION}/liblwgeom install
	install_name_tool -change $(PROJECT_DIR)/src/SFCGAL-$(SFCGAL_VERSION)/src/libSFCGAL.dylib $(PREFIX)/lib/libSFCGAL.dylib $(PREFIX)/lib/liblwgeom.dylib

$(PREFIX)/lib/postgis-$(POSTGIS_MAJOR_VERSION).so: postgis-${POSTGIS_VERSION}/GNUMakefile
	make -C postgis-${POSTGIS_VERSION}
	make -C postgis-${POSTGIS_VERSION} install
	install_name_tool -change $(PROJECT_DIR)/src/SFCGAL-$(SFCGAL_VERSION)/src/libSFCGAL.dylib $(PREFIX)/lib/libSFCGAL.dylib $(PREFIX)/lib/postgis-2.1.so

postgis-${POSTGIS_VERSION}/GNUMakefile: postgis-${POSTGIS_VERSION}/autogen.sh $(PREFIX)/lib/libgdal.dylib $(PREFIX)/lib/libgeos.dylib $(PREFIX)/bin/psql $(PREFIX)/lib/libjson.dylib
	cd postgis-${POSTGIS_VERSION} && ./autogen.sh && ./configure --prefix="$(PREFIX)" --with-pgconfig="$(PREFIX)/bin/pg_config" --with-geosconfig="$(PREFIX)/bin/geos-config" --with-projdir="$(PREFIX)" --with-gdaldir="$(PREFIX)" --with-jsondir="$(PREFIX)"
	/usr/bin/sed -i -e 's#/usr/local$$#"$(PREFIX)"#g' postgis-${POSTGIS_VERSION}/liblwgeom/Makefile
	touch $@

postgis-${POSTGIS_VERSION}/autogen.sh: postgis-${POSTGIS_VERSION}.tar.gz
	$(TAR) $<
	touch $@

postgis-${POSTGIS_VERSION}.tar.gz:
	$(CURL) "http://download.osgeo.org/postgis/source/postgis-${POSTGIS_VERSION}.tar.gz"

clean-postgis:
	rm -Rf postgis-${POSTGIS_VERSION}

#########################
###### PointCloud #######
#########################

#depends on postgresql, libxml2, GHT

pointcloud: $(PREFIX)/lib/pointcloud.so

$(PREFIX)/lib/pointcloud.so: pointcloud-${POINTCLOUD_VERSION}/GNUMakefile
	make -C pointcloud-${POINTCLOUD_VERSION}
	make -C pointcloud-${POINTCLOUD_VERSION} install

pointcloud-${POINTCLOUD_VERSION}/GNUMakefile: pointcloud-${POINTCLOUD_VERSION}/autogen.sh $(PREFIX)/bin/psql $(PREFIX)/lib/libxml2.dylib #$(PREFIX)/lib/libght.${GHT_VERSION}.dylib
	cd pointcloud-${POINTCLOUD_VERSION} && ./autogen.sh && ./configure --prefix="$(PREFIX)" --with-pgconfig="$(PREFIX)/bin/pg_config" #--with-libght=${PREFIX}
	touch $@

pointcloud-${POINTCLOUD_VERSION}/autogen.sh: pointcloud-${POINTCLOUD_VERSION}.tar.gz
	$(TAR) $<
	touch $@

pointcloud-${POINTCLOUD_VERSION}.tar.gz:
	$(CURL) "https://github.com/pramsey/pointcloud/archive/v${POINTCLOUD_VERSION}.tar.gz"
	mv v${POINTCLOUD_VERSION}.tar.gz pointcloud-${POINTCLOUD_VERSION}.tar.gz

clean-pointcloud:
	rm -Rf pointcloud-${POINTCLOUD_VERSION}

#########################
###### GHT ##############
#########################

ght: $(PREFIX)/lib/libght.${GHT_VERSION}.dylib

$(PREFIX)/lib/libght.${GHT_VERSION}.dylib: libght-${GHT_VERSION}/Makefile
	make -C libght-${GHT_VERSION} install

libght-${GHT_VERSION}/Makefile: libght-${GHT_VERSION}/CMakeLists.txt $(PREFIX)/lib/liblas.${LIBLAS_VERSION}.dylib
	cd libght-${GHT_VERSION} && cmake -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX="$(PREFIX)"

libght-${GHT_VERSION}/CMakeLists.txt: libght-${GHT_VERSION}.tar.gz
	$(TAR) libght-${GHT_VERSION}.tar.gz
	touch $@

libght-${GHT_VERSION}.tar.gz:
	$(CURL) "https://github.com/pramsey/libght/archive/v${GHT_VERSION}.tar.gz"
	mv v${GHT_VERSION}.tar.gz libght-${GHT_VERSION}.tar.gz

clean-ght:
	rm -Rf libght-${GHT_VERSION}

#########################
###### LibLAS ###########
#########################

liblas: $(PREFIX)/lib/liblas.${LIBLAS_VERSION}.dylib

$(PREFIX)/lib/liblas.${LIBLAS_VERSION}.dylib: libLAS-${LIBLAS_VERSION}/Makefile
	make -C libLAS-${LIBLAS_VERSION} install

libLAS-${LIBLAS_VERSION}/Makefile: libLAS-${LIBLAS_VERSION}/CMakeLists.txt $(PREFIX)/lib/liblaszip.dylib
	cd libLAS-${LIBLAS_VERSION} && cmake -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX="$(PREFIX)" \
	-DWITH_LASZIP=yes -DLASZIP_INCLUDE_DIR=../laszip-src-2.2.0/include/ -DLASZIP_LIBRARY=$(PREFIX)/lib/liblaszip.dylib
	

libLAS-${LIBLAS_VERSION}/CMakeLists.txt: libLAS-${LIBLAS_VERSION}.tar.gz
	$(TAR) libLAS-${LIBLAS_VERSION}.tar.gz
	touch $@

libLAS-${LIBLAS_VERSION}.tar.gz:
	$(CURL) "http://download.osgeo.org/liblas/libLAS-${LIBLAS_VERSION}.tar.gz"

clean-liblas:
	rm -Rf libLAS-${LIBLAS_VERSION}.tar.gz

#########################
###### LASzip ###########
#########################

laszip: $(PREFIX)/lib/liblaszip.dylib

$(PREFIX)/lib/liblaszip.dylib: laszip-src-${LASZIP_VERSION}/Makefile
	make -C laszip-src-${LASZIP_VERSION} install

laszip-src-${LASZIP_VERSION}/Makefile: laszip-src-${LASZIP_VERSION}/configure
	cd laszip-src-${LASZIP_VERSION} && ./configure --prefix="$(PREFIX)"

laszip-src-${LASZIP_VERSION}/configure: laszip-src-${LASZIP_VERSION}.tar.gz
	$(TAR) laszip-src-${LASZIP_VERSION}.tar.gz
	touch $@

laszip-src-${LASZIP_VERSION}.tar.gz:
	$(CURL) "https://github.com/LASzip/LASzip/releases/download/v${LASZIP_VERSION}/laszip-src-${LASZIP_VERSION}.tar.gz"

clean-laszip:
	rm -Rf laszip-src-${LASZIP_VERSION}.tar.gz
