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

  ```bash

  ```

  Machine 2

  ```bash

  ```

  Machine 1

  ```bash

  ```

  Machine 2

  ```bash

  ```

  la partition de 3Go sera montée sur /srv/site2

  Machine 1

  ```bash

  ```

  Machine 2

  ```bash

  ```

  les partitions doivent être montées automatiquement au démarrage (fichier /etc/fstab)

  Machine 1

  ```bash

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
