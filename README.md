# TP1 Linux

## 0. Prérequis

Machine 2 et un clone de Machine 1

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
  [serv@node2 ~]$ lsblk
  NAME            MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
  sda               8:0    0    8G  0 disk
  ├─sda1            8:1    0    1G  0 part /boot
  └─sda2            8:2    0    7G  0 part
  ├─centos-root 253:0    0  6.2G  0 lvm  /
  └─centos-swap 253:1    0  820M  0 lvm  [SWAP]
  sdb               8:16   0    5G  0 disk
  ├─data-vol1     253:2    0    2G  0 lvm  /srv/site1
  └─data-vol2     253:3    0    3G  0 lvm  /srv/site2
  sr0              11:0    1 1024M  0 rom
  sr1              11:1    1 1024M  0 rom
  [serv@node2 ~]$
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

  [...]
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
  [serv@node2 ~]$ df -h
  Filesystem               Size  Used Avail Use% Mounted on
  devtmpfs                 232M     0  232M   0% /dev
  tmpfs                    244M     0  244M   0% /dev/shm
  tmpfs                    244M  4.6M  239M   2% /run
  tmpfs                    244M     0  244M   0% /sys/fs/cgroup
  /dev/mapper/centos-root  6.2G  1.6G  4.7G  25% /
  /dev/sda1               1014M  197M  818M  20% /boot
  /dev/mapper/data-vol2    2.9G  8.8M  2.7G   1% /srv/site2
  /dev/mapper/data-vol1    2.0G  6.0M  1.8G   1% /srv/site1
  tmpfs                     49M     0   49M   0% /run/user/1002
  [serv@node2 ~]$
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
  [serv@node2 ~]$ sudo mount -av
  /                        : ignored
  /boot                    : already mounted
  swap                     : ignored
  /srv/site1               : already mounted
  /srv/site2               : already mounted
  [serv@node2 ~]$

  ```

- un accès internet

  carte réseau dédiée

  Machine 1

  ```bash
  [serv@node1 ~]$ dig google.com

  ; <<>> DiG 9.11.4-P2-RedHat-9.11.4-16.P2.el7_8.6 <<>> google.com
  ;; global options: +cmd
  ;; Got answer:
  ;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 12529
  ;; flags: qr rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 1

  ;; OPT PSEUDOSECTION:
  ; EDNS: version: 0, flags:; udp: 4096
  ;; QUESTION SECTION:
  ;google.com. IN A

  ;; ANSWER SECTION:
  google.com. 149 IN A 172.217.22.142

  ;; Query time: 3 msec
  ;; SERVER: 10.33.10.148#53(10.33.10.148)
  ;; WHEN: Thu Sep 24 15:25:25 CEST 2020
  ;; MSG SIZE rcvd: 55

  [serv@node1 ~]\$
  ```

  Machine 2

  ```bash
  [serv@node2 ~]$ dig google.com

  ; <<>> DiG 9.11.4-P2-RedHat-9.11.4-16.P2.el7_8.6 <<>> google.com
  ;; global options: +cmd
  ;; Got answer:
  ;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 33235
  ;; flags: qr rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 1

  ;; OPT PSEUDOSECTION:
  ; EDNS: version: 0, flags:; udp: 4096
  ;; QUESTION SECTION:
  ;google.com.                    IN      A

  ;; ANSWER SECTION:
  google.com.             29      IN      A       172.217.22.142

  ;; Query time: 5 msec
  ;; SERVER: 10.33.10.148#53(10.33.10.148)
  ;; WHEN: Thu Sep 24 15:27:26 CEST 2020
  ;; MSG SIZE  rcvd: 55

  [serv@node2 ~]$
  ```

- un accès à un réseau local (les deux machines peuvent se ping)

  Machine 1

  ```bash
  [serv@node1 ~]$ ping node2.tp1.b2
  PING node2.tp1.b2 (192.168.1.12) 56(84) bytes of data.
  64 bytes from node2.tp1.b2 (192.168.1.12): icmp_seq=1 ttl=64 time=1.27 ms
  64 bytes from node2.tp1.b2 (192.168.1.12): icmp_seq=2 ttl=64 time=1.04 ms
  64 bytes from node2.tp1.b2 (192.168.1.12): icmp_seq=3 ttl=64 time=1.02 ms
  64 bytes from node2.tp1.b2 (192.168.1.12): icmp_seq=4 ttl=64 time=0.957 ms
  ^C
  --- node2.tp1.b2 ping statistics ---
  4 packets transmitted, 4 received, 0% packet loss, time 3006ms
  rtt min/avg/max/mdev = 0.957/1.074/1.274/0.123 ms
  [serv@node1 ~]$
  ```

  Machine 2

  ```bash
  [serv@node2 ~]$ ping node1.tp1.b2
  PING node1.tp1.b2 (192.168.1.11) 56(84) bytes of data.
  64 bytes from node1.tp1.b2 (192.168.1.11): icmp_seq=1 ttl=64 time=0.692 ms
  64 bytes from node1.tp1.b2 (192.168.1.11): icmp_seq=2 ttl=64 time=0.866 ms
  64 bytes from node1.tp1.b2 (192.168.1.11): icmp_seq=3 ttl=64 time=0.823 ms
  ^C
  --- node1.tp1.b2 ping statistics ---
  3 packets transmitted, 3 received, 0% packet loss, time 2003ms
  rtt min/avg/max/mdev = 0.692/0.793/0.866/0.080 ms
  [serv@node2 ~]$
  ```

  route locale

  Machine 1

  ```bash
  [serv@node1 ~]$ ip n s
  10.0.2.2 dev enp0s3 lladdr 52:54:00:12:35:02 STALE
  192.168.1.12 dev enp0s8 lladdr 08:00:27:ff:c0:3f STALE
  192.168.1.10 dev enp0s8 lladdr 0a:00:27:00:00:08 DELAY
  [serv@node1 ~]$
  ```

  Machine 2

  ```bash
  [serv@node2 ~]$ ip n s
  192.168.1.11 dev enp0s8 lladdr 08:00:27:6a:f6:46 STALE
  10.0.2.2 dev enp0s3 lladdr 52:54:00:12:35:02 STALE
  192.168.1.10 dev enp0s8 lladdr 0a:00:27:00:00:08 DELAY
  [serv@node2 ~]$
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
  [serv@node2 ~]$ hostname
  node2.tp1.b2
  [serv@node2 ~]$
  ```

  les machines doivent pouvoir se joindre par leurs noms respectifs

  Machine 1

  ```bash
  [serv@node1 ~]$ ping node2.tp1.b2
  PING node2.tp1.b2 (192.168.1.12) 56(84) bytes of data.
  64 bytes from node2.tp1.b2 (192.168.1.12): icmp_seq=1 ttl=64 time=1.27 ms
  64 bytes from node2.tp1.b2 (192.168.1.12): icmp_seq=2 ttl=64 time=1.04 ms
  64 bytes from node2.tp1.b2 (192.168.1.12): icmp_seq=3 ttl=64 time=1.02 ms
  64 bytes from node2.tp1.b2 (192.168.1.12): icmp_seq=4 ttl=64 time=0.957 ms
  ^C
  --- node2.tp1.b2 ping statistics ---
  4 packets transmitted, 4 received, 0% packet loss, time 3006ms
  rtt min/avg/max/mdev = 0.957/1.074/1.274/0.123 ms
  [serv@node1 ~]$
  ```

  Machine 2

  ```bash
  [serv@node2 ~]$ ping node1.tp1.b2
  PING node1.tp1.b2 (192.168.1.11) 56(84) bytes of data.
  64 bytes from node1.tp1.b2 (192.168.1.11): icmp_seq=1 ttl=64 time=0.692 ms
  64 bytes from node1.tp1.b2 (192.168.1.11): icmp_seq=2 ttl=64 time=0.866 ms
  64 bytes from node1.tp1.b2 (192.168.1.11): icmp_seq=3 ttl=64 time=0.823 ms
  ^C
  --- node1.tp1.b2 ping statistics ---
  3 packets transmitted, 3 received, 0% packet loss, time 2003ms
  rtt min/avg/max/mdev = 0.692/0.793/0.866/0.080 ms
  [serv@node2 ~]$
  ```

- fichier /etc/hosts

  Machine 1

  ```bash
  [serv@node1 ~]$ cat /etc/hosts
  127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
  ::1         localhost localhost.localdomain localhost6 localhost6.localdomain6
  192.168.1.12  node2.tp1.b2
  [serv@node1 ~]$
  ```

  Machine 2

  ```bash
  [serv@node2 ~]$ cat /etc/hosts
  127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
  ::1         localhost localhost.localdomain localhost6 localhost6.localdomain6
  192.168.1.11  node1.tp1.b2
  [serv@node2 ~]$
  ```

  un utilisateur administrateur est créé sur les deux machines (il peut exécuter des commandes sudo en tant que root)

  création d'un user

  Machine 1

  ```bash
  [root@node1 ~]# useradd serv
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
  [root@node2 ~]# visudo
  ```

  ```bash
  ## Allow root to run any commands anywhere
  root    ALL=(ALL)       ALL
  serv    ALL=(ALL)       ALL
  ```

- vous n'utilisez QUE ssh pour administrer les machines

  création d'une paire de clés (sur VOTRE PC)

  ```powershell
  PS C:\Users\arthu\.ssh> cat .\known_hosts
  192.168.1.11 ecdsa-sha2-nistp256 [...]=
  192.168.1.12 ecdsa-sha2-nistp256 [...]=
  ```

  déposer la clé publique sur l'utilisateur de destination

  Machine 1

  ```bash
  PS C:\Users\arthu> ssh serv@192.168.1.11
  serv@192.168.1.11's password:
  Last login: Thu Sep 24 14:10:21 2020 from 192.168.1.10
  Last login: Thu Sep 24 14:10:21 2020 from 192.168.1.10
  [serv@node1 ~]$
  ```

  Machine 2

  ```bash
  PS C:\Users\arthu> ssh serv@192.168.1.12
  serv@192.168.1.12's password:
  Last login: Thu Sep 24 15:09:52 2020 from 192.168.1.10
  Last login: Thu Sep 24 15:09:52 2020 from 192.168.1.10
  [serv@node2 ~]$
  ```

- le pare-feu est configuré pour bloquer toutes les connexions exceptées celles qui sont nécessaires

  commande firewall-cmd ou iptables

  Machine 1

  ```bash
  [serv@node1 ~]$ sudo firewall-cmd --list-all
  Authorization failed.
    Make sure polkit agent is running or run the application as superuser.

  [serv@node1 ~]$ sudo !!
  public (active)
  target: default
  icmp-block-inversion: no
  interfaces: enp0s3 enp0s8
  sources:
  services: dhcpv6-client http https ssh
  ports: 443/tcp 80/tcp
  protocols:
  masquerade: no
  forward-ports:
  source-ports:
  icmp-blocks:
  rich rules:
  [serv@node1 ~]\$
  ```

  Machine 2

  ```bash
  [serv@node2 ~]$ sudo firewall-cmd --list-all
  [sudo] password for serv:
  public (active)
  target: default
  icmp-block-inversion: no
  interfaces: enp0s3 enp0s8
  sources:
  services: dhcpv6-client http https ssh
  ports: 443/tcp 80/tcp
  protocols:
  masquerade: no
  forward-ports:
  source-ports:
  icmp-blocks:
  rich rules:

  [serv@node2 ~]\$
  ```

- désactiver SELinux

  Machine 1

  ```bash
  [serv@node1 ~]$ sestatus
  SELinux status:                 enabled
  SELinuxfs mount:                /sys/fs/selinux
  SELinux root directory:         /etc/selinux
  Loaded policy name:             targeted
  Current mode:                   permissive
  Mode from config file:          permissive
  Policy MLS status:              enabled
  Policy deny_unknown status:     allowed
  Max kernel policy version:      31
  [serv@node1 ~]$
  ```

  Machine 2

  ```bash
  [serv@node2 ~]$ sestatus
  SELinux status:                 enabled
  SELinuxfs mount:                /sys/fs/selinux
  SELinux root directory:         /etc/selinux
  Loaded policy name:             targeted
  Current mode:                   permissive
  Mode from config file:          permissive
  Policy MLS status:              enabled
  Policy deny_unknown status:     allowed
  Max kernel policy version:      31
  [serv@node2 ~]$
  ```

## I. Setup serveur Web

- Installer le serveur web NGINX sur node1.tp1.b2 (avec une commande yum install).

  ```bash
  [serv@node1 ~]$sudo yum install epel-release
  [...]
  Complete!

  [serv@node1 ~]$sudo yum install nginx
  [...]
  Complete!
  ```

- NGINX servent deux sites web, chacun possède un fichier unique index.html, NGINX doit utiliser un utilisateur dédié que vous avez créé à cet effet

  ```bash
  [serv@node1 ~]$ cat /etc/nginx/nginx.conf
  worker_processes 1;
  error_log error_site.log;
  pid /run/nginx.pid;
  events {
        worker_connections 1024;
  }

  user web;

  http {
  server {
  listen 80;
  server_name node1.tp1.b2;

                  location /site1 {
                          alias /srv/site1;
                  }

                  location /site2 {
                          alias /srv/site2;
                  }
          }

  }
  [serv@node1 ~]\$
  ```

- les sites web doivent se trouver dans /srv/site1 et /srv/site2

  ```bash
    [serv@node1 srv]$ sudo tree
    .
    ├── site1
    │   ├── index.html
    │   └── lost+found
    └── site2
      ├── index.html
      └── lost+found

    4 directories, 2 files
    [serv@node1 srv]\$
  ```

- les permissions sur ces dossiers doivent être le plus restrictif possible et, ces dossiers doivent appartenir à un utilisateur et un groupe spécifique

  ```bash
  [serv@node1 ~]$ sudo ls -al /srv/
  total 8
  dr-xr-x---.  4 web  web    32 Sep 23 17:31 .
  dr-xr-xr-x. 17 root root  237 Sep 22 14:21 ..
  dr-xr-xr--.  3 web  web  4096 Sep 24 16:39 site1
  dr-xr-xr--.  3 web  web  4096 Sep 24 16:40 site2
  [serv@node1 ~]
  ```

- NGINX doit utiliser un utilisateur dédié que vous avez créé à cet effet

  ```bash
  [serv@node1 ~]$ sudo useradd web
  ```

- les sites doivent être servis en HTTPS sur le port 443 et en HTTP sur le port 80

  ```bash
  [serv@node1 ~]$ sudo firewall-cmd --zone=public --add-port=443/tcp --permanent
  success

  [serv@node1 ~]$ sudo firewall-cmd --permanent --zone=public --add-service=https
  success

  [serv@node1 ~]$ sudo firewall-cmd --zone=public --add-port=80/tcp --permanent
  success

  [serv@node1 ~]$ sudo firewall-cmd --permanent --zone=public --add-service=http
  success

  [serv@node1 ~]$ sudo firewall-cmd --reload
  success
  [serv@node1 ~]$
  ```

- Faire en sorte que les sites soient disponibles en HTTPS

  ```bash

  ```

- Prouver que la machine node2 peut joindre les deux sites web.

  Site 1

  ```bash
  [serv@node2 ~]$ curl -Lk http://node1.tp1.b2/site1
  <!doctype html>
  <html lang="en">
  <head>
          <meta charset="utf-8">
          <title>Dummy Page</title>
          [...]
  </head>

  <body>
          <div class="pure-g">
                  <div class="pure-u-1">
                          <h1>Stay tuned site 1 <h1>
                          <h2>something new is coming here</h2>
                          [...]
                  </div>
          </div>
  </body>
  <script>
  [...]
  </script>
  </html>
  [serv@node2 ~]$
  ```

  Site 2

  ```bash
  [serv@node2 ~]$ curl -Lk http://node1.tp1.b2/site2
  <!doctype html>
  <html lang="en">
  <head>
          <meta charset="utf-8">
          <title>Dummy Page</title>
          [...]
  </head>

  <body>
          <div class="pure-g">
                  <div class="pure-u-1">
                          <h1>Stay tuned site 2 <h1>
                          <h2>something new is coming here</h2>
                          [...]
                  </div>
          </div>
  </body>
  <script>
  [...]
  </script>
  </html>
  [serv@node2 ~]$
  ```

## II. Script de sauvegarde

[le script](./tp1_backup.sh)

```bash
#!/bin/bash

# LAFOREST Arthur
# 27/09/2020
# Backup script

backup_time=$(date +%Y%m%d_%H%M)

saved_folder_path="${1}"

saved_folder="${saved_folder_path##*/}"

backup_name="${saved_folder}_${backup_time}"

tar -czf $backup_name.tar.gz --absolute-names $saved_folder_path

nbr_site1=`ls -l | grep -c site1_`
nbr_site2=`ls -l | grep -c site2_`

echo $nbr_site1
echo $nbr_site2

if [ "$nbr_site1" > 7 ]; then
        echo "ça marche"

fi
```
