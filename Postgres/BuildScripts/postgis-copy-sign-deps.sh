#!/bin/bash

set +e

KEYCHAIN_PASSWORD=jenkins78902

ORIG_INSTALL_ROOT="${PROJECT_DIR}/Postgres/Vendor/postgres"
POSTGRES_ENTITLEMENTS="${PROJECT_DIR}/Postgres/Postgres-extras.entitlements"
EXECUTABLE_TARGET_DIR="$BUILT_PRODUCTS_DIR/$EXECUTABLE_FOLDER_PATH"
RESOURCES_TARGET_DIR="$BUILT_PRODUCTS_DIR/$UNLOCALIZED_RESOURCES_FOLDER_PATH"

# copy binaries
cd "${ORIG_INSTALL_ROOT}/bin/"
mkdir -p "$EXECUTABLE_TARGET_DIR/bin/"
# copy postgresql binaries
cp clusterdb createdb createlang createuser dropdb droplang dropuser ecpg initdb oid2name pg_archivecleanup pg_basebackup pg_config pg_controldata pg_ctl pg_dump pg_dumpall pg_receivexlog pg_resetxlog pg_restore pg_standby pg_test_fsync pg_test_timing pg_upgrade pgbench postgres postmaster psql reindexdb vacuumdb vacuumlo "$EXECUTABLE_TARGET_DIR/bin/"

# copy dynamic libraries only (no need for static libraries)
cd "${ORIG_INSTALL_ROOT}/lib/"
mkdir -p "$EXECUTABLE_TARGET_DIR/lib/"
cp -af *.dylib *.so "$EXECUTABLE_TARGET_DIR/lib/"

# copy extension directory to Resources for codesigning
cp -afR pgxs "$RESOURCES_TARGET_DIR/"
ln -sf ../../Resources/pgxs "$EXECUTABLE_TARGET_DIR/lib/pgxs"

#copy share; needs to be in Resources for codesigning
cp -afR "${ORIG_INSTALL_ROOT}/share" "$RESOURCES_TARGET_DIR/"
ln -sf ../Resources/share "$EXECUTABLE_TARGET_DIR/share"

# fix dylib paths
cd "$EXECUTABLE_TARGET_DIR"
prefix="${ORIG_INSTALL_ROOT}"
prefix_length=${#prefix}

# fix library ids
for libfile in "lib/"*
do
    library_id=$(otool -D $libfile | grep "$prefix");
    if [[ -n "$library_id" ]]
    then
        new_library_id="@loader_path/.."${library_id:$prefix_length}
        install_name_tool -id "$new_library_id" "$libfile"
        # fix library references
        for afile in "lib/"*.dylib "lib/"*.so "bin/"*
        do
            install_name_tool -change $library_id $new_library_id $afile 2> /dev/null
        done
    fi
done

# codesign copied Mach-O files and scripts
security unlock -p $KEYCHAIN_PASSWORD $HOME/Library/Keychains/login.keychain
for afile in "lib/pgxs/config/install-sh" "lib/pgxs/src/test/regress/pg_regress" "lib/"*.dylib "lib/"*.so "bin/"*
do
    codesign --force --keychain $HOME/Library/Keychains/login.keychain \
      --timestamp --verbose -s AD305D96B9F8DC4BAD13F046AF063BF8EC6EB8DE "$afile"
done
