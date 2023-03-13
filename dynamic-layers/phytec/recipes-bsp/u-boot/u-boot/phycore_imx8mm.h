/* SPDX-License-Identifier: GPL-2.0-or-later
 *
 * Copyright (C) 2019-2020 PHYTEC Messtechnik GmbH
 * Author: Teresa Remmet <t.remmet@phytec.de>
 */

#ifndef __PHYCORE_IMX8MM_H
#define __PHYCORE_IMX8MM_H

#include <linux/sizes.h>
#include <linux/stringify.h>
#include <asm/arch/imx-regs.h>

#include <configs/omnect_env.h>

#define CONFIG_SYS_BOOTM_LEN		SZ_64M
#define CONFIG_SPL_MAX_SIZE		(148 * SZ_1K)
#define CONFIG_SYS_MONITOR_LEN		SZ_512K
#define CONFIG_SYS_MMCSD_RAW_MODE_U_BOOT_USE_SECTOR
#define CONFIG_SYS_MMCSD_RAW_MODE_U_BOOT_SECTOR	0x300
#define CONFIG_SYS_UBOOT_BASE \
		(QSPI0_AMBA_BASE + CONFIG_SYS_MMCSD_RAW_MODE_U_BOOT_SECTOR * 512)

#ifdef CONFIG_SPL_BUILD
#define CONFIG_SPL_STACK		0x920000
#define CONFIG_SPL_BSS_START_ADDR	0x910000
#define CONFIG_SPL_BSS_MAX_SIZE		SZ_8K
#define CONFIG_SYS_SPL_MALLOC_START	0x42200000
#define CONFIG_SYS_SPL_MALLOC_SIZE	SZ_512K

/* malloc f used before GD_FLG_FULL_MALLOC_INIT set */
#define CONFIG_MALLOC_F_ADDR		0x912000
/* For RAW image gives a error info not panic */
#define CONFIG_SPL_ABORT_ON_RAW_IMAGE

#define CONFIG_SYS_I2C

#endif

#define CONFIG_EXTRA_ENV_SETTINGS \
	"boot_script=fatload mmc ${devnum}:1 ${script_addr_r} /boot.scr; source ${script_addr_r}\0" \
	"load_fdt_script=fatload mmc ${devnum}:1 ${script_addr_r} /fdt-load.scr; source ${script_addr_r}\0" \
	"bootcmd_pxe=run load_fdt_script; setenv kernel_addr_r ${loadaddr}; dhcp; if pxe get; then pxe boot; fi\0" \
	"bootargs=console=ttymxc2,115200\0" \
	"bootpart=2\0" \
	"devnum=" __stringify(CONFIG_SYS_MMC_ENV_DEV) "\0" \
	"devtype=mmc\0" \
	"distro_bootcmd=mmc dev ${devnum};" \
		"if mmc rescan; then " \
			"env exist kernel_addr || setenv devnum ${mmcdev} && setenv kernel_addr_r ${loadaddr} && saveenv;" \
			"run load_fdt_script;" \
			"run scan_boot_script;" \
		"fi\0" \
	"image=Image\0" \
	"console=ttymxc2\0" \
	"fdt_addr=0x48000000\0" \
	"fdto_addr=0x49000000\0" \
	"pxefile_addr_r=0x4f800000\0" \
	"ramdisk_addr_r=0x49200000\0" \
	"scan_boot_script=if test -e mmc ${devnum}:1 /boot.scr; then echo Found U-Boot script; run boot_script; echo SCRIPT FAILED: continuing...; fi\0" \
	"script_addr_r=0x49100000\0" \
    OMNECT_ENV_UPDATE_WORKFLOW \
	OMNECT_ENV_SETTINGS

/* Link Definitions */
#define CONFIG_LOADADDR			0x40480000
#define CONFIG_SYS_LOAD_ADDR		CONFIG_LOADADDR

#define CONFIG_SYS_INIT_RAM_ADDR	0x40000000
#define CONFIG_SYS_INIT_RAM_SIZE	SZ_512K
#define CONFIG_SYS_INIT_SP_OFFSET \
	(CONFIG_SYS_INIT_RAM_SIZE - GENERATED_GBL_DATA_SIZE)
#define CONFIG_SYS_INIT_SP_ADDR \
	(CONFIG_SYS_INIT_RAM_ADDR + CONFIG_SYS_INIT_SP_OFFSET)

#define CONFIG_MMCROOT			"/dev/mmcblk2p2"  /* USDHC3 */

/* Size of malloc() pool */
#define CONFIG_SYS_MALLOC_LEN		SZ_32M
#define CONFIG_SYS_SDRAM_BASE		0x40000000

#define PHYS_SDRAM			0x40000000
#define PHYS_SDRAM_SIZE                 SZ_2G /* 2GB DDR */

/* UART */
#define CONFIG_MXC_UART_BASE		UART3_BASE_ADDR

/* Monitor Command Prompt */
#define CONFIG_SYS_CBSIZE		SZ_2K
#define CONFIG_SYS_MAXARGS		64
#define CONFIG_SYS_BARGSIZE		CONFIG_SYS_CBSIZE

/* USDHC */
#define CONFIG_FSL_USDHC
#define CONFIG_SYS_FSL_USDHC_NUM	2
#define CONFIG_SYS_FSL_ESDHC_ADDR       0
#define CONFIG_SYS_MMC_IMG_LOAD_PART	1

/* I2C */
#define CONFIG_SYS_I2C_SPEED		100000

/* USB configs */
#define CONFIG_MXC_USB_PORTSC		(PORT_PTS_UTMI | PORT_PTS_PTW)
#define CONFIG_USB_MAX_CONTROLLER_COUNT	2
#define CONFIG_SERIAL_TAG

#endif /* __PHYCORE_IMX8MM_H */
