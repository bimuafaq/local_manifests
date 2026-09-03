#!/usr/bin/env bash

# List of patches in format DIRECTORY:PATCH_FILE
list_patches() {
    cat <<EOF
external/conscrypt:constify_external_conscrypt.patch
external/icu:constify_external_icu.patch
external/neven:constify_external_neven.patch
frameworks/rs:constify_frameworks_rs.patch
frameworks/ex:constify_frameworks_ex.patch
frameworks/opt/net/voip:constify_frameworks_opt_net_voip.patch
hardware/qcom-caf/common:constify_hardware_qcom-caf_common.patch
lineage-sdk:constify_lineage-sdk.patch
packages/apps/FMRadio:constify_packages_apps_FMRadio.patch
packages/apps/Gallery2:constify_packages_apps_Gallery2.patch
vendor/qcom/opensource/fm-commonsys:constify_vendor_qcom_opensource_fm-commonsys.patch
vendor/nxp/opensource/commonsys/packages/apps/Nfc:constify_vendor_nxp_opensource_commonsys_packages_apps_Nfc.patch
vendor/qcom/opensource/libfmjni:constify_vendor_qcom_opensource_libfmjni.patch
art:constify_art.patch
frameworks/base:constify_frameworks_base.patch
libcore:constify_libcore.patch
packages/apps/Bluetooth:constify_packages_apps_Bluetooth.patch
packages/apps/Nfc:constify_packages_apps_Nfc.patch
build/make:build.patch
system/core:core.patch
external/selinux:selinux.patch
system/sepolicy:sepolicy.patch
frameworks/base:lteca-base.patch
frameworks/opt/telephony:lteca-telephony.patch
packages/apps/Settings:lteca-settings.patch
EOF
}

apply_patches() {
    local scriptdir="$(cd "$(dirname "$0")" && pwd)"

    list_patches | while IFS=: read -r dir patch; do
        [ -z "$dir" ] && continue

        if [[ -d "$dir" ]]; then
            pushd "$dir" > /dev/null || continue

            local src=
            [[ -f "$scriptdir/$patch" ]] && src="$scriptdir/$patch"
            [[ -f "$scriptdir/constify/$patch" ]] && src="$scriptdir/constify/$patch"

            if [[ -z "$src" ]]; then
                echo "Error: Patch file not found: $patch"
                continue
            fi

            if git apply --reverse --check "$src" &>/dev/null; then
                echo "Skipping $patch - already applied"
            elif ! git am --3way < "$src"; then
                echo "Error: Failed to apply $patch to $dir"
                git am --abort 2>/dev/null
            fi

            popd > /dev/null 2>&1 || true
        else
            echo "Warning: Directory not found: $dir"
        fi
    done
}

# Main execution
apply_patches
