part --fixed-size ${ICS_DM_PART_SIZE_ROOTFS}K    --fstype=ext4 --align 4096 --label rootA  --source rootfs
part --fixed-size ${ICS_DM_PART_SIZE_ROOTFS}K    --fstype=ext4 --align 4096 --label rootB
part --fixed-size ${ICS_DM_PART_SIZE_FACTORY}K   --fstype=ext4 --align 4096 --label factory
part --fixed-size ${ICS_DM_PART_SIZE_CERT}K      --fstype=ext4 --align 4096 --label cert
part --fixed-size ${ICS_DM_PART_SIZE_ETC}K       --fstype=ext4 --align 4096 --label etc
part --fixed-size ${ICS_DM_PART_SIZE_DATA}K      --fstype=ext4 --align 4096 --label data
