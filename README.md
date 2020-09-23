# TP1 Linux

## 0. Prérequis

- partitionnement

  ajouter un deuxième disque de 5Go à la machine

  Machine 1

  ```bash
  [serv@node1 ~]$ lsblk
  NAME            MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
  sda               8:0    0    8G  0 disk
  ├─sda1            8:1    0    1G  0 part /boot
  └─sda2            8:2    0    7G  0 part
  ├─centos-root 253:0    0  6.2G  0 lvm  /
  └─centos-swap 253:1    0  820M  0 lvm  [SWAP]
  sdb               8:16   0    5G  0 disk
  sr0              11:0    1 1024M  0 rom
  sr1              11:1    1 1024M  0 rom
  [serv@node1 ~]$
  ```

  Machine 2

  ```bash

  ```

- partitionner le nouveau disque avec LVM

  deux partitions, une de 2Go, une de 3Go
  la partition de 2Go sera montée sur /srv/site1

  Machine 1

  Création du PV

  ```bash
  [serv@node1 ~]$ sudo pvcreate /dev/sdb
  Physical volume "/dev/sdb" successfully created.

  [serv@node1 ~]$ sudo pvs
  PV         VG     Fmt  Attr PSize  PFree
  /dev/sda2  centos lvm2 a--  <7.00g    0
  /dev/sdb          lvm2 ---   5.00g 5.00g

  [serv@node1 ~]$ sudo pvdisplay
  --- Physical volume ---
  PV Name               /dev/sda2
  VG Name               centos
  PV Size               <7.00 GiB / not usable 3.00 MiB
  Allocatable           yes (but full)
  PE Size               4.00 MiB
  Total PE              1791
  Free PE               0
  Allocated PE          1791
  PV UUID               I9wLnl-3G2M-2HCe-BcYS-DUjR-F1sS-lyEUHg

  "/dev/sdb" is a new physical volume of "5.00 GiB"
  --- NEW Physical volume ---
  PV Name               /dev/sdb
  VG Name
  PV Size               5.00 GiB
  Allocatable           NO
  PE Size               0
  Total PE              0
  Free PE               0
  Allocated PE          0
  PV UUID               8j4lcy-qeNA-cONj-VQJA-lLGA-HMWg-T3tFR1
  [serv@node1 ~]\$
  ```

  Création du VG

  ```bash
  [serv@node1 ~]$ sudo vgcreate data /dev/sdb
  Volume group "data" successfully created

  [serv@node1 ~]$ sudo vgs
  VG     #PV #LV #SN Attr   VSize  VFree
  centos   1   2   0 wz--n- <7.00g     0
  data     1   0   0 wz--n- <5.00g <5.00g

  [serv@node1 ~]$ sudo vgdisplay
  --- Volume group ---
  VG Name               data
  System ID
  Format                lvm2
  Metadata Areas        1
  Metadata Sequence No  1
  VG Access             read/write
  VG Status             resizable
  MAX LV                0
  Cur LV                0
  Open LV               0
  Max PV                0
  Cur PV                1
  Act PV                1
  VG Size               <5.00 GiB
  PE Size               4.00 MiB
  Total PE              1279
  Alloc PE / Size       0 / 0
  Free  PE / Size       1279 / <5.00 GiB
  VG UUID               Coc8aQ-2vf4-9Bwa-dwJf-TN17-PEAW-lxjYLk

  --- Volume group ---
  VG Name               centos
  System ID
  Format                lvm2
  Metadata Areas        1
  Metadata Sequence No  3
  VG Access             read/write
  VG Status             resizable
  MAX LV                0
  Cur LV                2
  Open LV               2
  Max PV                0
  Cur PV                1
  Act PV                1
  VG Size               <7.00 GiB
  PE Size               4.00 MiB
  Total PE              1791
  Alloc PE / Size       1791 / <7.00 GiB
  Free  PE / Size       0 / 0
  VG UUID               Muj2pT-7Skl-Ujj7-bq0x-lOer-XKgj-Yuhrqh
  [serv@node1 ~]\$
  ```

  Création des LV

  ```bash
  [serv@node1 ~]$ sudo lvcreate -L 2G data -n vol1
  Logical volume "vol1" created.

  [serv@node1 ~]$ sudo lvcreate -L 3000 data -n vol2
  Logical volume "vol2" created.

  [serv@node1 ~]$ sudo lvs
  LV   VG     Attr       LSize   Pool Origin Data%  Meta%  Move Log Cpy%Sync Convert
  root centos -wi-ao----  <6.20g
  swap centos -wi-ao---- 820.00m
  vol1 data   -wi-a-----   2.00g
  vol2 data   -wi-a-----  <2.93g

  [serv@node1 ~]$ sudo lvdisplay
  --- Logical volume ---
  LV Path                /dev/data/vol1
  LV Name                vol1
  VG Name                data
  LV UUID                DASSZL-fI7F-tx4e-ik94-E90O-Ioqp-3E5hML
  LV Write Access        read/write
  LV Creation host, time node1.tp1.b2, 2020-09-23 17:13:55 +0200
  LV Status              available
  # open                 0
  LV Size                2.00 GiB
  Current LE             512
  Segments               1
  Allocation             inherit
  Read ahead sectors     auto
  - currently set to     8192
  Block device           253:2

  --- Logical volume ---
  LV Path                /dev/data/vol2
  LV Name                vol2
  VG Name                data
  LV UUID                R2FWs3-mxft-4oe1-RGzX-8RQH-b69T-jh8GcE
  LV Write Access        read/write
  LV Creation host, time node1.tp1.b2, 2020-09-23 17:17:01 +0200
  LV Status              available
  # open                 0
  LV Size                <2.93 GiB
  Current LE             750
  Segments               1
  Allocation             inherit
  Read ahead sectors     auto
  - currently set to     8192
  Block device           253:3

  --- Logical volume ---
  LV Path                /dev/centos/swap
  LV Name                swap
  VG Name                centos
  LV UUID                Ir0ROd-BWc9-wlmg-axDr-UNCf-591M-Y5l5HP
  LV Write Access        read/write
  LV Creation host, time localhost, 2020-01-30 12:00:37 +0100
  LV Status              available
  # open                 2
  LV Size                820.00 MiB
  Current LE             205
  Segments               1
  Allocation             inherit
  Read ahead sectors     auto
  - currently set to     8192
  Block device           253:1

  --- Logical volume ---
  LV Path                /dev/centos/root
  LV Name                root
  VG Name                centos
  LV UUID                ZIvBAS-Y7Qx-5AK1-3WdU-VNEV-9073-hBiWDD
  LV Write Access        read/write
  LV Creation host, time localhost, 2020-01-30 12:00:38 +0100
  LV Status              available
  # open                 1
  LV Size                <6.20 GiB
  Current LE             1586
  Segments               1
  Allocation             inherit
  Read ahead sectors     auto
  - currently set to     8192
  Block device           253:0
  [serv@node1 ~]\$
  ```

  On formate les partitions

  Volume 1

  ```bash
  [serv@node1 ~]$ sudo mkfs -t ext4 /dev/data/vol1
  mke2fs 1.42.9 (28-Dec-2013)
  Filesystem label=
  OS type: Linux
  Block size=4096 (log=2)
  Fragment size=4096 (log=2)
  Stride=0 blocks, Stripe width=0 blocks
  131072 inodes, 524288 blocks
  26214 blocks (5.00%) reserved for the super user
  First data block=0
  Maximum filesystem blocks=536870912
  16 block groups
  32768 blocks per group, 32768 fragments per group
  8192 inodes per group
  Superblock backups stored on blocks:
      32768, 98304, 163840, 229376, 294912

  Allocating group tables: done
  Writing inode tables: done
  Creating journal (16384 blocks): done
  Writing superblocks and filesystem accounting information: done

  [serv@node1 ~]\$
  ```

  Volume 2

  ```bash
  [serv@node1 ~]$ sudo mkfs -t ext4 /dev/data/vol2
  mke2fs 1.42.9 (28-Dec-2013)
  Filesystem label=
  OS type: Linux
  Block size=4096 (log=2)
  Fragment size=4096 (log=2)
  Stride=0 blocks, Stripe width=0 blocks
  192000 inodes, 768000 blocks
  38400 blocks (5.00%) reserved for the super user
  First data block=0
  Maximum filesystem blocks=786432000
  24 block groups
  32768 blocks per group, 32768 fragments per group
  8000 inodes per group
  Superblock backups stored on blocks:
        32768, 98304, 163840, 229376, 294912

  Allocating group tables: done
  Writing inode tables: done
  Creating journal (16384 blocks): done
  Writing superblocks and filesystem accounting information: done

  [serv@node1 ~]\$
  ```

  On monte la partition 1

  ```bash
  [serv@node1 ~]$ sudo mkdir /srv/site1

  [serv@node1 ~]$ sudo mount /dev/data/vol1 /srv/site1

  [serv@node1 ~]$ mount
    sysfs on /sys type sysfs (rw,nosuid,nodev,noexec,relatime,seclabel)
    proc on /proc type proc (rw,nosuid,nodev,noexec,relatime)
    [...]
    /dev/sda1 on /boot type xfs (rw,relatime,seclabel,attr2,inode64,noquota)
    tmpfs on /run/user/0 type tmpfs (rw,nosuid,nodev,relatime,seclabel,size=49872k,mode=700)
    tmpfs on /run/user/1002 type tmpfs (rw,nosuid,nodev,relatime,seclabel,size=49872k,mode=700,uid=1002,gid=1002)
    /dev/mapper/data-vol1 on /srv/site1 type ext4 (rw,relatime,seclabel,data=ordered)

  [serv@node1 ~]$  df -h
  Filesystem               Size  Used Avail Use% Mounted on
  devtmpfs                 232M     0  232M   0% /dev
  tmpfs                    244M     0  244M   0% /dev/shm
  tmpfs                    244M  4.6M  239M   2% /run
  tmpfs                    244M     0  244M   0% /sys/fs/cgroup
  /dev/mapper/centos-root  6.2G  1.6G  4.7G  25% /
  /dev/sda1               1014M  197M  818M  20% /boot
  tmpfs                     49M     0   49M   0% /run/user/0
  tmpfs                     49M     0   49M   0% /run/user/1002
  /dev/mapper/data-vol1    2.0G  6.0M  1.8G   1% /srv/site1
  [serv@node1 ~]$
  ```

  Machine 2

  ```bash

  ```

  la partition de 3Go sera montée sur /srv/site2

  Machine 1

  ```bash
  [serv@node1 ~]$ sudo mkdir /srv/site2

  [serv@node1 ~]$ sudo mount /dev/data/vol2 /srv/site2

  [serv@node1 ~]$ mount
  sysfs on /sys type sysfs (rw,nosuid,nodev,noexec,relatime,seclabel)
  proc on /proc type proc (rw,nosuid,nodev,noexec,relatime)
  [...]
  /dev/mapper/data-vol1 on /srv/site1 type ext4 (rw,relatime,seclabel,data=ordered)
  /dev/mapper/data-vol2 on /srv/site2 type ext4 (rw,relatime,seclabel,data=ordered)

  [serv@node1 ~]$ df -h
  Filesystem               Size  Used Avail Use% Mounted on
  devtmpfs                 232M     0  232M   0% /dev
  tmpfs                    244M     0  244M   0% /dev/shm
  tmpfs                    244M  4.6M  239M   2% /run
  tmpfs                    244M     0  244M   0% /sys/fs/cgroup
  /dev/mapper/centos-root  6.2G  1.6G  4.7G  25% /
  /dev/sda1               1014M  197M  818M  20% /boot
  tmpfs                     49M     0   49M   0% /run/user/0
  tmpfs                     49M     0   49M   0% /run/user/1002
  /dev/mapper/data-vol1    2.0G  6.0M  1.8G   1% /srv/site1
  /dev/mapper/data-vol2    2.9G  8.8M  2.7G   1% /srv/site2
  [serv@node1 ~]$
  ```

  Machine 2

  ```bash

  ```

  les partitions doivent être montées automatiquement au démarrage (fichier /etc/fstab)

  Machine 1

  ```bash
  [serv@node1 ~]$ cat /etc/fstab
  [...]
  /dev/mapper/centos-root /                       xfs     defaults        0 0
  UUID=503e3dc1-c14b-4439-a013-3d14b2d99b4a /boot                   xfs     defaults        0 0
  /dev/mapper/centos-swap swap                    swap    defaults        0 0

  /dev/data/vol1 /srv/site1 ext4 defaults 0 0
  /dev/data/vol2 /srv/site2 ext4 defaults 0 0

  [serv@node1 ~]$ sudo mount -av
  /                        : ignored
  /boot                    : already mounted
  swap                     : ignored
  /srv/site1               : already mounted
  /srv/site2               : already mounted
  [serv@node1 ~]$
  ```

  Machine 2

  ```bash

  ```

- un accès internet

  carte réseau dédiée

  Machine 1

  ```bash

  ```

  Machine 2

  ```bash

  ```

  route par défaut

  Machine 1

  ```bash

  ```

  Machine 2

  ```bash

  ```

  un accès à un réseau local (les deux machines peuvent se ping)

  Machine 1

  ```bash

  ```

  Machine 2

  ```bash

  ```

  carte réseau dédiée

  Machine 1

  ```bash

  ```

  Machine 2

  ```bash

  ```

  route locale

  Machine 1

  ```bash

  ```

  Machine 2

  ```bash

  ```

- les machines doivent avoir un nom

  /etc/hostname (commande hostname)

  Machine 1

  ```bash
  [serv@node1 ~]$ hostname
  node1.tp1.b2
  [serv@node1 ~]$
  ```

  Machine 2

  ```bash

  ```

  les machines doivent pouvoir se joindre par leurs noms respectifs

  Machine 1

  ```bash

  ```

  Machine 2

  ```bash

  ```

  fichier /etc/hosts

  Machine 1

  ```bash

  ```

  Machine 2

  ```bash

  ```

- un utilisateur administrateur est créé sur les deux machines (il peut exécuter des commandes sudo en tant que root)

  création d'un user

  Machine 1

  ```bash
  [root@node1 ~]# useradd serv
  ```

  Machine 2

  ```bash

  ```

  modification de la conf sudo

  Machine 1

  ```bash
  [root@node1 ~]# visudo
  ```

  ```bash
  ## Allow root to run any commands anywhere
  root    ALL=(ALL)       ALL
  serv    ALL=(ALL)       ALL
  ```

  Machine 2

  ```bash

  ```

  ```bash

  ```

- vous n'utilisez QUE ssh pour administrer les machines

  création d'une paire de clés (sur VOTRE PC)

  ```bash

  ```

  déposer la clé publique sur l'utilisateur de destination

  ```bash

  ```

- le pare-feu est configuré pour bloquer toutes les connexions exceptées celles qui sont nécessaires

  commande firewall-cmd ou iptables

  ```bash

  ```
