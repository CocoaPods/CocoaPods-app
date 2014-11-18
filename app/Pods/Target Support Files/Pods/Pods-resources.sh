#!/bin/sh
set -e

mkdir -p "${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"

RESOURCES_TO_COPY=${PODS_ROOT}/resources-to-copy-${TARGETNAME}.txt
> "$RESOURCES_TO_COPY"

install_resource()
{
  case $1 in
    *.storyboard)
      echo "ibtool --errors --warnings --notices --output-format human-readable-text --compile ${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename \"$1\" .storyboard`.storyboardc ${PODS_ROOT}/$1 --sdk ${SDKROOT}"
      ibtool --errors --warnings --notices --output-format human-readable-text --compile "${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename \"$1\" .storyboard`.storyboardc" "${PODS_ROOT}/$1" --sdk "${SDKROOT}"
      ;;
    *.xib)
        echo "ibtool --errors --warnings --notices --output-format human-readable-text --compile ${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename \"$1\" .xib`.nib ${PODS_ROOT}/$1 --sdk ${SDKROOT}"
      ibtool --errors --warnings --notices --output-format human-readable-text --compile "${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename \"$1\" .xib`.nib" "${PODS_ROOT}/$1" --sdk "${SDKROOT}"
      ;;
    *.framework)
      echo "mkdir -p ${CONFIGURATION_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}"
      mkdir -p "${CONFIGURATION_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}"
      echo "rsync -av ${PODS_ROOT}/$1 ${CONFIGURATION_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}"
      rsync -av "${PODS_ROOT}/$1" "${CONFIGURATION_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}"
      ;;
    *.xcdatamodel)
      echo "xcrun momc \"${PODS_ROOT}/$1\" \"${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$1"`.mom\""
      xcrun momc "${PODS_ROOT}/$1" "${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$1" .xcdatamodel`.mom"
      ;;
    *.xcdatamodeld)
      echo "xcrun momc \"${PODS_ROOT}/$1\" \"${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$1" .xcdatamodeld`.momd\""
      xcrun momc "${PODS_ROOT}/$1" "${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$1" .xcdatamodeld`.momd"
      ;;
    *.xcassets)
      ;;
    /*)
      echo "$1"
      echo "$1" >> "$RESOURCES_TO_COPY"
      ;;
    *)
      echo "${PODS_ROOT}/$1"
      echo "${PODS_ROOT}/$1" >> "$RESOURCES_TO_COPY"
      ;;
  esac
}
          install_resource "Fragaria/SMLCommandResult.xib"
                    install_resource "Fragaria/SMLDetab.xib"
                    install_resource "Fragaria/SMLEntab.xib"
                    install_resource "Fragaria/SMLGoToLine.xib"
                    install_resource "Fragaria/SMLOpenPanelAccessoryView.xib"
                    install_resource "Fragaria/SMLRegularExpressionHelp.xib"
                    install_resource "Fragaria/Syntax Definitions/actionscript.plist"
                    install_resource "Fragaria/Syntax Definitions/actionscript3.plist"
                    install_resource "Fragaria/Syntax Definitions/active4d.plist"
                    install_resource "Fragaria/Syntax Definitions/ada.plist"
                    install_resource "Fragaria/Syntax Definitions/ampl.plist"
                    install_resource "Fragaria/Syntax Definitions/apache.plist"
                    install_resource "Fragaria/Syntax Definitions/applescript.plist"
                    install_resource "Fragaria/Syntax Definitions/asm-mips.plist"
                    install_resource "Fragaria/Syntax Definitions/asm-x86.plist"
                    install_resource "Fragaria/Syntax Definitions/asp-js.plist"
                    install_resource "Fragaria/Syntax Definitions/asp-vb.plist"
                    install_resource "Fragaria/Syntax Definitions/aspdotnet-cs.plist"
                    install_resource "Fragaria/Syntax Definitions/aspdotnet-vb.plist"
                    install_resource "Fragaria/Syntax Definitions/awk.plist"
                    install_resource "Fragaria/Syntax Definitions/batch.plist"
                    install_resource "Fragaria/Syntax Definitions/c.plist"
                    install_resource "Fragaria/Syntax Definitions/cobol.plist"
                    install_resource "Fragaria/Syntax Definitions/coffeescript.plist"
                    install_resource "Fragaria/Syntax Definitions/coldfusion.plist"
                    install_resource "Fragaria/Syntax Definitions/cpp.plist"
                    install_resource "Fragaria/Syntax Definitions/csharp.plist"
                    install_resource "Fragaria/Syntax Definitions/csound.plist"
                    install_resource "Fragaria/Syntax Definitions/css.plist"
                    install_resource "Fragaria/Syntax Definitions/d.plist"
                    install_resource "Fragaria/Syntax Definitions/dylan.plist"
                    install_resource "Fragaria/Syntax Definitions/eiffel.plist"
                    install_resource "Fragaria/Syntax Definitions/erl.plist"
                    install_resource "Fragaria/Syntax Definitions/eztpl.plist"
                    install_resource "Fragaria/Syntax Definitions/f-script.plist"
                    install_resource "Fragaria/Syntax Definitions/fortran.plist"
                    install_resource "Fragaria/Syntax Definitions/freefem.plist"
                    install_resource "Fragaria/Syntax Definitions/gedcom.plist"
                    install_resource "Fragaria/Syntax Definitions/gnuassembler.plist"
                    install_resource "Fragaria/Syntax Definitions/graphviz.plist"
                    install_resource "Fragaria/Syntax Definitions/haskell.plist"
                    install_resource "Fragaria/Syntax Definitions/header.plist"
                    install_resource "Fragaria/Syntax Definitions/html.plist"
                    install_resource "Fragaria/Syntax Definitions/idl.plist"
                    install_resource "Fragaria/Syntax Definitions/java.plist"
                    install_resource "Fragaria/Syntax Definitions/javafx.plist"
                    install_resource "Fragaria/Syntax Definitions/javascript.plist"
                    install_resource "Fragaria/Syntax Definitions/jsp.plist"
                    install_resource "Fragaria/Syntax Definitions/latex.plist"
                    install_resource "Fragaria/Syntax Definitions/lilypond.plist"
                    install_resource "Fragaria/Syntax Definitions/lisp.plist"
                    install_resource "Fragaria/Syntax Definitions/logtalk.plist"
                    install_resource "Fragaria/Syntax Definitions/lsl.plist"
                    install_resource "Fragaria/Syntax Definitions/lua.plist"
                    install_resource "Fragaria/Syntax Definitions/matlab.plist"
                    install_resource "Fragaria/Syntax Definitions/mel.plist"
                    install_resource "Fragaria/Syntax Definitions/metapost.plist"
                    install_resource "Fragaria/Syntax Definitions/metaslang.plist"
                    install_resource "Fragaria/Syntax Definitions/mysql.plist"
                    install_resource "Fragaria/Syntax Definitions/nemerle.plist"
                    install_resource "Fragaria/Syntax Definitions/none.plist"
                    install_resource "Fragaria/Syntax Definitions/nrnhoc.plist"
                    install_resource "Fragaria/Syntax Definitions/objectivec.plist"
                    install_resource "Fragaria/Syntax Definitions/objectivecaml.plist"
                    install_resource "Fragaria/Syntax Definitions/ox.plist"
                    install_resource "Fragaria/Syntax Definitions/pascal.plist"
                    install_resource "Fragaria/Syntax Definitions/pdf.plist"
                    install_resource "Fragaria/Syntax Definitions/perl.plist"
                    install_resource "Fragaria/Syntax Definitions/php.plist"
                    install_resource "Fragaria/Syntax Definitions/plist.plist"
                    install_resource "Fragaria/Syntax Definitions/postscript.plist"
                    install_resource "Fragaria/Syntax Definitions/prolog.plist"
                    install_resource "Fragaria/Syntax Definitions/python.plist"
                    install_resource "Fragaria/Syntax Definitions/r.plist"
                    install_resource "Fragaria/Syntax Definitions/rhtml.plist"
                    install_resource "Fragaria/Syntax Definitions/ruby.plist"
                    install_resource "Fragaria/Syntax Definitions/scala.plist"
                    install_resource "Fragaria/Syntax Definitions/sgml.plist"
                    install_resource "Fragaria/Syntax Definitions/shell.plist"
                    install_resource "Fragaria/Syntax Definitions/sml.plist"
                    install_resource "Fragaria/Syntax Definitions/sql.plist"
                    install_resource "Fragaria/Syntax Definitions/standard.plist"
                    install_resource "Fragaria/Syntax Definitions/stata.plist"
                    install_resource "Fragaria/Syntax Definitions/supercollider.plist"
                    install_resource "Fragaria/Syntax Definitions/tcltk.plist"
                    install_resource "Fragaria/Syntax Definitions/torquescript.plist"
                    install_resource "Fragaria/Syntax Definitions/udo.plist"
                    install_resource "Fragaria/Syntax Definitions/vb.plist"
                    install_resource "Fragaria/Syntax Definitions/verilog.plist"
                    install_resource "Fragaria/Syntax Definitions/vhdl.plist"
                    install_resource "Fragaria/Syntax Definitions/xml.plist"
                    install_resource "Fragaria/SyntaxDefinitions.plist"
          
rsync -avr --copy-links --no-relative --exclude '*/.svn/*' --files-from="$RESOURCES_TO_COPY" / "${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
if [[ "${ACTION}" == "install" ]]; then
  rsync -avr --copy-links --no-relative --exclude '*/.svn/*' --files-from="$RESOURCES_TO_COPY" / "${INSTALL_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
fi
rm -f "$RESOURCES_TO_COPY"

if [[ -n "${WRAPPER_EXTENSION}" ]] && [ "`xcrun --find actool`" ] && [ `find . -name '*.xcassets' | wc -l` -ne 0 ]
then
  case "${TARGETED_DEVICE_FAMILY}" in
    1,2)
      TARGET_DEVICE_ARGS="--target-device ipad --target-device iphone"
      ;;
    1)
      TARGET_DEVICE_ARGS="--target-device iphone"
      ;;
    2)
      TARGET_DEVICE_ARGS="--target-device ipad"
      ;;
    *)
      TARGET_DEVICE_ARGS="--target-device mac"
      ;;
  esac
  find "${PWD}" -name "*.xcassets" -print0 | xargs -0 actool --output-format human-readable-text --notices --warnings --platform "${PLATFORM_NAME}" --minimum-deployment-target "${IPHONEOS_DEPLOYMENT_TARGET}" ${TARGET_DEVICE_ARGS} --compress-pngs --compile "${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
fi
