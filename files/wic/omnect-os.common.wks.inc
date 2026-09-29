part --fixed-size ${OMNECT_PART_SIZE_ROOTFS}K    --fstype=ext4 --align 4096 --label rootA   --mkfs-extraopts "-F -i 8192 -O ^has_journal,^orphan_file" --source rootfs
part --fixed-size ${OMNECT_PART_SIZE_ROOTFS}K    --fstype=ext4 --align 4096 --label rootB   --mkfs-extraopts "-F -i 8192 -O ^has_journal,^orphan_file"
part --fixed-size ${OMNECT_PART_SIZE_FACTORY}K   --fstype=ext4 --align 4096 --label factory --mkfs-extraopts "-F -i 8192 -O ^has_journal,^orphan_file"
part --fixed-size ${OMNECT_PART_SIZE_CERT}K      --fstype=ext4 --align 4096 --label cert
part --fixed-size ${OMNECT_PART_SIZE_ETC}K       --fstype=ext4 --align 4096 --label etc
part --fixed-size ${OMNECT_PART_SIZE_DATA}K      --fstype=ext4 --align 4096 --label data
