{ disks ? [ "/dev/vdb" "/dev/vdc" "/dev/vdd" ], ... }: {
  disko.devices = {
    disk = {
      disk0 = {
        type = "disk";
        device = builtins.elemAt disks 0;
        content = {
          type = "table";
          format = "gpt";
          partitions = [
            {
              name = "ESP";
              start = "1MiB";
              end = "128MiB";
              fs-type = "fat32";
              bootable = true;
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
              };
            }
          ];
        };
      };
      disk1 = {
        type = "disk";
        device = builtins.elemAt disks 1;
        content = {
          type = "table";
          format = "gpt";
          partitions = [
            {
              start = "1M";
              end = "100%";
              name = "luks";
              content = {
                type = "luks";
                name = "crypted1";
                keyFile = "/tmp/secret.key";
                extraFormatArgs = [
                  "--iter-time 1"
                ];
                content = {
                  type = "lvm_pv";
                  vg = "pool";
                };
              };
            }
          ];
        };
      };
      disk2 = {
        type = "disk";
        device = builtins.elemAt disks 2;
        content = {
          type = "table";
          format = "gpt";
          partitions = [
            {
              start = "1M";
              end = "100%";
              name = "luks";
              content = {
                type = "luks";
                name = "crypted2";
                keyFile = "/tmp/secret.key";
                extraFormatArgs = [
                  "--iter-time 1"
                ];
                content = {
                  type = "lvm_pv";
                  vg = "pool";
                };
              };
            }
          ];
        };
      };
    };
    mdadm = {
      raid1 = {
        type = "mdadm";
        level = 1;
        content = {
          type = "table";
          format = "gpt";
          partitions = [
            {
              name = "bla";
              start = "1MiB";
              end = "100%";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/ext4_mdadm_lvm";
              };
            }
          ];
        };
      };
    };
    lvm_vg = {
      pool = {
        type = "lvm_vg";
        lvs = {
          root = {
            size = "10M";
            lvm_type = "mirror";
            content = {
              type = "filesystem";
              format = "ext4";
              mountpoint = "/ext4_on_lvm";
              mountOptions = [
                "defaults"
              ];
            };
          };
          raid1 = {
            size = "30M";
            lvm_type = "raid0";
            content = {
              type = "mdraid";
              name = "raid1";
            };
          };
          raid2 = {
            size = "30M";
            lvm_type = "raid0";
            content = {
              type = "mdraid";
              name = "raid1";
            };
          };
          zfs1 = {
            size = "128M";
            lvm_type = "raid0";
            content = {
              type = "zfs";
              pool = "zroot";
            };
          };
          zfs2 = {
            size = "128M";
            lvm_type = "raid0";
            content = {
              type = "zfs";
              pool = "zroot";
            };
          };
        };
      };
    };
    zpool = {
      zroot = {
        type = "zpool";
        mode = "mirror";
        rootFsOptions = {
          compression = "lz4";
          "com.sun:auto-snapshot" = "false";
        };
        mountpoint = "/";

        datasets = {
          zfs_fs = {
            type = "zfs_fs";
            mountpoint = "/zfs_fs";
            options."com.sun:auto-snapshot" = "true";
          };
          zfs_unmounted_fs = {
            type = "zfs_fs";
            options.mountpoint = "none";
          };
          zfs_legacy_fs = {
            type = "zfs_fs";
            options.mountpoint = "legacy";
            mountpoint = "/zfs_legacy_fs";
          };
          zfs_testvolume = {
            type = "zfs_volume";
            size = "10M";
            content = {
              type = "filesystem";
              format = "ext4";
              mountpoint = "/ext4onzfs";
            };
          };
        };
      };
    };
  };
}
