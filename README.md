# okd4all
(semi-)automatisierte installation eines okd4-clusters, optional auf proxmox-basis


## ausgangssituation:
- vorhandener dhcp/tftp-server und eingerichtete pxe-installationsumgebung für rockylinux oder rhel (developer-subscription googlen!) oder alma oder whatever. 
- ein auf halbwegs potenter hardware installierter proxmox-ve-server oder ein paar ausgemusterte rechner. mischen geht auch. alles was pxe booten kann, mit ein paar cores, einer kleinen disk und ein bisschen ram (>8gb) gesegnet (und x86_64) ist, kann ein okd-node werden.


## voraussetzungen schaffen:
wer alles nötige bei sich im haus haben will kann die installationsquellen seiner bevorzugten linux-enterprise-distribution sowie das okd-quell-repository bei sich einlagern. das ist noch einige meter von einer fully-airgapped-installation entfernt, aber immerhin ein anfang.

am beispiel rockylinux (cronjob):
```
rsync -a --delete-after rsync://centos.anexia.at/epel/9/Everything/x86_64/* /var/www/pxe/epel9/
rsync -a --delete-after rsync://rockylinux.anexia.at/rockylinux/9/BaseOS/x86_64/os/* /data/www/pxe/rockylinux9/BaseOS/x86_64/os
rsync -a --delete-after rsync://rockylinux.anexia.at/rockylinux/9/AppStream/x86_64/os/* /data/www/pxe/rockylinux9/AppStream/x86_64/os
rsync -a --delete-after rsync://rockylinux.anexia.at/rockylinux/9/CRB/x86_64/os/* /data/www/pxe/rockylinux9/CRB/x86_64/os
```

genug speicherplatz bereitstellen!

ein simpler webserver (kann auch gern der loadbalancer auf einem alternativen port sein) wird für die auslieferung der repo-, kickstart-, ignition- und rootfs-files benötigt. das webroot sollte per ssh von der admin-maschine aus erreichbar sein.

für die einlagerung der okd-images wird eine einfache image-registry benötigt. hier sei das projekt https://github.com/quay/mirror-registry empfohlen. redhat bietet ebenfalls ein entsprechendes installationspaket an. wer etwas mehr funktionalität benötigt bzw. in weiterer folge auch applikationsimages selbst hosten und verwalten möchte, kann z. b. auch https://goharbor.io/ verwenden.

auch hier gilt: genug speicherplatz bereitstellen!

als nächstes den oc client und das oc-mirror-plugin besorgen:
https://mirror.openshift.com/pub/openshift-v4/x86_64/clients/ocp/stable/openshift-client-linux.tar.gz
https://mirror.openshift.com/pub/openshift-v4/x86_64/clients/ocp/latest/oc-mirror.rhel9.tar.gz


in den files dieses projekts liegt ein entsprechendes script zum download und einlagern der installationsimages, konkret der version okd4.15. TODO: auf oc-mirror v2 umstellen

dieses script extrahiert den openshift-installer. dieser (und NUR dieser) ist bei allen weiteren schritten zu verwenden.

überprüfen mit "./openshift-installer version"

benötigte fedora-coreos-version eruieren mit:
./openshift-install coreos print-stream-json | grep -Eo '"https.*(kernel-|initramfs.|rootfs.)\w+(.img)?"'

und download starten. kernel und initramdisk ins tftproot, das live-image vorzugsweise ins webroot.

openshift/okd benötigt ein spezifisches set an dns-einträgen im lokalen dns-server. ein beispiel für eine unbound-zone liegt bei.

ebenso beiliegend sind ein beispielhaftes pxeboot- sowie ein kickstart-file für die installation des loadbalancers/bastionhosts. netzwerk-konfiguration, ssh-pubkey usw. sind selbstverständlich anzupassen.

läuft der loadbalancer ersteinmal ist der haproxy fertig zu konfigurieren - beispielfile liegt bei.

ausserdem folgendes auszuführen:
```
setsebool -P haproxy_connect_any 1
firewall-cmd --add-service=http --permanent
firewall-cmd --add-service=https --permanent
firewall-cmd --add-port=6443/tcp --permanent
firewall-cmd --add-port=22623/tcp --permanent
firewall-cmd --reload
```

und ggf. autoupdate einzuschalten für ein rundum-sorglos-paket.

damit sollte die vom cluster bzw. der installation benötigte infrastruktur komplett sein.

## ansible-tasks und cluster-inventory

die beiliegende ansible-rolle besteht aus schnell und einfach zusammengebastelten tasks mit denen testcluster unkompliziert und ohne grosses händisches eingreifen erstellt/zerstört werden können. kein anspruch auf vollständigkeit und/oder gehobene ansible-eleganz!

als vorarbeit ist das cluster-inventory den eigenen bedürfnissen anzupassen und der extrahierte openshift-installer in das "installer"-unterverzeichnis zu legen sowie die j2-template für die grub-files den eigenen gegebenheit anzugleichen (pfade, filenamen, etc.). in den groupvars sind die basiseinstellungen des clusters sowie die lokale hilfs-infrastruktur zu konfigurieren.

wir starten damit, die pxe-bootfiles zu generieren:

ansible-playbook cluster.yml -t grubfiles

und im anschluss die installation des clusters zu initialisieren:

ansible-playbook cluster.yml -t installer

daraufhin können etwaige physiken in die pxe-umgebung gestartet werden, oder im fall von proxmox-vms diese von ansible erstellt werden mit:

ansible-playbook cluster.yml -t createvms

der rest kommt direkt aus der dokumentation:

./openshift-install wait-for bootstrap-complete --log-level=debug
./openshift-install wait-for install-complete --log-level=debug








