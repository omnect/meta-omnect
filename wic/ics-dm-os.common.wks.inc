part --ondisk mmc --fixed-size ${ICS_DM_PART_SIZE_ROOTFS}K    --fstype=ext4 --align 4096 --label rootA  --source rootfs --exclude-path mnt/data/
part --ondisk mmc --fixed-size ${ICS_DM_PART_SIZE_ROOTFS}K    --fstype=ext4 --align 4096 --label rootB
part --ondisk mmc --fixed-size ${ICS_DM_PART_SIZE_FACTORY}K   --fstype=ext4 --align 4096 --label factory
part --ondisk mmc --fixed-size ${ICS_DM_PART_SIZE_CERT}K      --fstype=ext4 --align 4096 --label cert
part --ondisk mmc --fixed-size ${ICS_DM_PART_SIZE_ETC}K       --fstype=ext4 --align 4096 --label etc
part --ondisk mmc --fixed-size ${ICS_DM_PART_SIZE_DATA}K      --fstype=ext4 --align 4096 --label data   --source rootfs --change-directory mnt/data
