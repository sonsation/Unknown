#!/bin/bash
# kernel build script by Tkkg1994(optimized from apq8084 kernel source)

export ARCH=arm64
export BUILD_CROSS_COMPILE=/media/jh/12383f82-a79b-47ba-aac9-d9d05d0fc0fe/toolchain/gcc-7.x/bin/aarch64-gnu-linux-gnueabi-
export BUILD_JOB_NUMBER=`grep processor /proc/cpuinfo|wc -l`

RDIR=$(pwd)
OUTDIR=$RDIR/arch/$ARCH/boot
DTSDIR=$RDIR/arch/$ARCH/boot/dts
DTBDIR=$OUTDIR/dtb
DTCTOOL=$RDIR/scripts/dtc/dtc
INCDIR=$RDIR/include

PAGE_SIZE=2048
DTB_PADDING=0

VERSION=1.0.3
ZIP_NAME=UnknownKernel_SM-G920XX_v$VERSION.zip
ZIP_FILE_DIR=$RDIR/output

FUNC_CLEAN_FILE()
{
                
	if ! [ -d $RDIR/arch/$ARCH/boot/dts ] ; then
		echo "No directory"
	else
		echo "rm files in : "$RDIR/arch/$ARCH/boot/dts/*.dtb""
		rm $RDIR/arch/$ARCH/boot/dts/*.dtb
		rm $RDIR/arch/$ARCH/boot/dtb/*.dtb
		rm $RDIR/arch/$ARCH/boot/boot.img-dtb
		rm $RDIR/arch/$ARCH/boot/boot.img-zImage
	fi

        if ! [ -d $RDIR/build/boot ] ; then
		echo "No directory"
	else
		echo "rm files in : "$RDIR/build/boot/$MODEL.img""
		rm $RDIR/build/boot/*.img
	fi
}

FUNC_CLEAN()
{

        ##build cache clear
        find . -type f -name "*~" -exec rm -f {} \;
        find . -type f -name "*orig" -exec rm -f {} \;
        find . -type f -name "*rej" -exec rm -f {} \;
        ccache -C
        xterm -e make clean
        xterm -e make mrproper   

}

FUNC_BUILD_DTIMAGE_TARGET()
{
	[ -f "$DTCTOOL" ] || {
		echo "You need to run ./build.sh first!"
		exit 1
	}

	case $MODEL in
	zeroflte)
		DTSFILES="exynos7420-zeroflte_kor_06"
		;;
	zerolte)
		DTSFILES="exynos7420-zerolte_eur_open_06"
		;;
	*)
		echo "Unknown device: $MODEL"
		exit 1

		;;
	esac

	mkdir -p $OUTDIR $DTBDIR

	cd $DTBDIR || {
		echo "Unable to cd to $DTBDIR!"
		exit 1
	}

	rm -f ./*

	echo ""
        echo "Processing dts files"
        echo "" 

		for dts in $DTSFILES; do
		echo "=> Processing: ${dts}.dts"
		${CROSS_COMPILE}cpp -nostdinc -undef -x assembler-with-cpp -I "$INCDIR" "$DTSDIR/${dts}.dts" > "${dts}.dts"
		echo "=> Generating: ${dts}.dtb"
		$DTCTOOL -p $DTB_PADDING -i "$DTSDIR" -O dtb -o "${dts}.dtb" "${dts}.dts"
	done

	echo "Generating dtb.img..."
        $RDIR/scripts/dtbTool/dtbTool -o "$OUTDIR/dtb.img" -d "$DTBDIR/" -s $PAGE_SIZE

	echo "Done."
}

FUNC_BUILD_KERNEL()
{
        echo "Loading configuration..."
        echo ""

	FUNC_CLEAN_FILE

	make -j$BUILD_JOB_NUMBER ARCH=$ARCH \
			CROSS_COMPILE=$BUILD_CROSS_COMPILE \
			$KERNEL_DEFCONFIG || exit -1

        echo ""
        echo "Compiling Kernel..."
        echo "" 

	make -j$BUILD_JOB_NUMBER ARCH=$ARCH \
			CROSS_COMPILE=$BUILD_CROSS_COMPILE || exit -1
	
	echo ""

}


FUNC_BUILD_RAMDISK()
{
	mv $RDIR/arch/$ARCH/boot/Image $RDIR/arch/$ARCH/boot/boot.img-zImage
	mv $RDIR/arch/$ARCH/boot/dtb.img $RDIR/arch/$ARCH/boot/boot.img-dtb

	case $MODEL in

	zeroflte)
		rm -f $RDIR/ramdisk/SM-G920F/split_img/boot.img-zImage
		mv -f $RDIR/arch/$ARCH/boot/boot.img-zImage $RDIR/ramdisk/SM-G920F/split_img/boot.img-zImage
                rm -f $RDIR/ramdisk/SM-G920F/split_img/boot.img-dtb
		mv -f $RDIR/arch/$ARCH/boot/boot.img-dtb $RDIR/ramdisk/SM-G920F/split_img/boot.img-dtb
		cd $RDIR/ramdisk/SM-G920F
		./repackimg.sh
		echo SEANDROIDENFORCE >> image-new.img
		;;
	zerolte)
		rm -f $RDIR/ramdisk/SM-G925F/split_img/boot.img-zImage
		mv -f $RDIR/arch/$ARCH/boot/boot.img-zImage $RDIR/ramdisk/SM-G925F/split_img/boot.img-zImage
                rm -f $RDIR/ramdisk/SM-G925F/split_img/boot.img-dtb
		mv -f $RDIR/arch/$ARCH/boot/boot.img-dtb $RDIR/ramdisk/SM-G925F/split_img/boot.img-dtb 
		cd $RDIR/ramdisk/SM-G925F
		./repackimg.sh
		echo SEANDROIDENFORCE >> image-new.img
		;;
	*)
		echo "Unknown device: $MODEL"
		exit 1
		;;
	esac
}

FUNC_BUILD_ZIP()
{

	case $MODEL in

	zeroflte)

		mv -f $RDIR/ramdisk/SM-G920F/image-new.img $RDIR/build/boot/$MODEL.img
		;;

	zerolte)

		mv -f $RDIR/ramdisk/SM-G925F/image-new.img $RDIR/build/boot/$MODEL.img
		;;
	
	*)
		echo "Unknown device: $MODEL"
		exit 1
		;;
	esac

        echo ""
        echo "Building Zip File"

        cd $RDIR/build
        zip -r BUILD *
        mv -f $RDIR/build/BUILD.zip $ZIP_FILE_DIR/$ZIP_NAME

}

FUNC_MAIN()
{
	FUNC_BUILD_KERNEL
        FUNC_BUILD_DTIMAGE_TARGET
	FUNC_BUILD_RAMDISK
        FUNC_BUILD_ZIP 	
}

OPTION_1()
{
MODEL=zeroflte
KERNEL_DEFCONFIG=exynos7420-zeroflte_defconfig
(
  FUNC_MAIN
) 

echo ""
echo "####################FINSH########################"
echo "You can now find your Kernel in the Output folder"
echo ""
echo ""
exit
}

OPTION_2()
{
MODEL=zerolte
KERNEL_DEFCONFIG=exynos7420-zerolte_defconfig
(
  FUNC_MAIN
) 

echo ""
echo "####################FINSH########################"
echo "You can now find your Kernel in the Output folder"
echo ""
exit
}

OPTION_0()
{
FUNC_CLEAN
exit
}

# -------------
# MAIN START
# -------------
clear
echo "UnknownKernel Build Script"
echo "Kernel Version: v$VERSION"
echo " 0) Clean Workspace"
echo " 1) Build UnknownKernel for S6(F/K/S/L)"
echo " 2) Build UnknownKernel for S6 Edge(F/K/S/L)"
echo " 3) Exit"
echo ""
read -p "Please select an option " select
echo ""

   case $select in

	0)
		OPTION_0
		;;

	1)
		OPTION_1
		;;
	2)
		OPTION_2
		;;
	3)
		OPTION_3
		;;
	
	*)
		exit 1
		;;
	esac

