part --fixed-size ${OMNECT_PART_SIZE_BOOT}K      --fstype=vfat --align 4096 --label boot   --source bootimg-partition --active
part --fixed-size ${OMNECT_PART_SIZE_UBOOT_ENV}K --no-table --offset ${OMNECT_PART_OFFSET_UBOOT_ENV1} --source rawcopy --sourceparams="file=omnect_uboot_env_ff.img"
part --fixed-size ${OMNECT_PART_SIZE_UBOOT_ENV}K --no-table --offset ${OMNECT_PART_OFFSET_UBOOT_ENV2} --source rawcopy --sourceparams="file=omnect_uboot_env_ff.img"

include omnect-os.common.wks.inc
