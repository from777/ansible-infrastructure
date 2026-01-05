# 2025-12-29 07:54:24 by RouterOS 7.20.6
# software id = RX75-K1VL
#
# model = C53UiG+5HPaxD2HPaxD
# serial number = HG609SR5FKP
/container mounts
add dst=/etc/mihomo name=mamuka_conf src=usb1-part1/smb_share/docker_configs/mamuka
/disk
add parent=usb1 partition-number=1 partition-offset=512 partition-size=62914559488 type=partition
/interface bridge
add name=Bridge-Docker
add name=bridge
/interface veth
add address=192.168.254.2/24 dhcp=no gateway=192.168.254.1 gateway6="" mac-address=28:C9:6B:57:2E:AA name=mamuka
/interface list
add name=WAN
add name=LAN
add name=VPN-OUT
add name=GUEST
add name=LAN_and_GUEST
/ip smb users
set [ find default=yes ] read-only=no
/container config
set registry-url=https://registry-1.docker.io tmpdir=usb1-part1/pull
/interface bridge port
add bridge=bridge interface=ether1
add bridge=bridge interface=ether2
add bridge=bridge interface=ether3
add bridge=bridge interface=ether4
add bridge=bridge interface=ether5
add bridge=Bridge-Docker interface=mamuka
/ip neighbor discovery-settings
set discover-interface-list=!dynamic
/ip address
add address=192.168.0.88/24 interface=bridge network=192.168.0.0
add address=192.168.254.1/24 interface=Bridge-Docker network=192.168.254.0
/ip dns
set allow-remote-requests=yes use-doh-server=https://dns.google/dns-query verify-doh-cert=yes
/ip firewall filter
add action=accept chain=input comment=SAFE-ACCESS src-address=212.20.46.209
add action=drop chain=Brute-force comment="BF Drop blocked" src-address-list=Brute-force-block
add action=add-src-to-address-list address-list=Brute-force-block address-list-timeout=8h chain=Brute-force comment="BF Block after 4th" src-address-list=Brute-force-4
add action=add-src-to-address-list address-list=Brute-force-4 address-list-timeout=30s chain=Brute-force comment="BF 4th attempt" src-address-list=Brute-force-3
add action=add-src-to-address-list address-list=Brute-force-3 address-list-timeout=30s chain=Brute-force comment="BF 3rd attempt" src-address-list=Brute-force-2
add action=add-src-to-address-list address-list=Brute-force-2 address-list-timeout=30s chain=Brute-force comment="BF 2nd attempt" src-address-list=Brute-force-1
add action=add-src-to-address-list address-list=Brute-force-1 address-list-timeout=30s chain=Brute-force comment="BF 1st attempt"
add action=accept chain=Brute-force comment="BF Accept if not blocked"
add action=accept chain=LAN-Input comment="Accept all from LAN"
add action=accept chain=ISP-Input comment="ISP Accept established" connection-state=established
add action=accept chain=ISP-Input comment="ISP Accept related" connection-state=related
add action=accept chain=ISP-Input comment="ISP Accept untracked" connection-state=untracked
add action=drop chain=ISP-Input comment="ISP Drop invalid" connection-state=invalid
add action=jump chain=ISP-Input comment="ISP Jump to allowed" jump-target=ISP-Input-Allow
add action=drop chain=ISP-Input comment="ISP Drop all other"
add action=accept chain=ISP-Input-Allow comment="Allow ICMP" protocol=icmp
add action=jump chain=ISP-Input-Allow comment="SSH via Brute-force" connection-nat-state=dstnat dst-port=22 jump-target=Brute-force protocol=tcp
add action=drop chain=ISP-Input-Allow comment="Drop Winbox from WAN" dst-port=8291 protocol=tcp
add action=accept chain=ISP-Input-Allow comment=WireGuard dst-port=51820 protocol=udp
add action=accept chain=GUEST-Input comment="GUEST Accept established" connection-state=established
add action=accept chain=VPN-Input comment="VPN Accept established" connection-state=established
add action=accept chain=VPN-Input comment="VPN Accept related" connection-state=related
add action=accept chain=VPN-Input comment="VPN Accept untracked" connection-state=untracked
add action=drop chain=VPN-Input comment="VPN Drop invalid" connection-state=invalid
add action=accept chain=VPN-Input comment="Containers DNS to router" dst-port=53 protocol=udp src-address=192.168.254.0/24
add action=drop chain=VPN-Input comment="VPN Drop all other"
add action=accept chain=LAN-Forward comment="LAN-FWD Accept established" connection-state=established
add action=accept chain=LAN-Forward comment="LAN-FWD Accept related" connection-state=related
add action=accept chain=LAN-Forward comment="LAN-FWD Accept untracked" connection-state=untracked
add action=drop chain=LAN-Forward comment="LAN-FWD Drop invalid" connection-state=invalid
add action=accept chain=LAN-Forward comment="LAN-FWD Accept new from LAN"
add action=accept chain=ISP-Forward comment="ISP-FWD Accept established" connection-state=established
add action=accept chain=ISP-Forward comment="ISP-FWD Accept related" connection-state=related
add action=accept chain=ISP-Forward comment="ISP-FWD Accept untracked" connection-state=untracked
add action=drop chain=ISP-Forward comment="ISP-FWD Drop invalid" connection-state=invalid
add action=accept chain=ISP-Forward comment="ISP-FWD Accept DST-NAT" connection-nat-state=dstnat
add action=drop chain=ISP-Forward comment="ISP-FWD Drop all other"
add action=accept chain=GUEST-Forward comment="GUEST-FWD Accept established" connection-state=established
add action=accept chain=GUEST-Forward comment="GUEST-FWD Accept related" connection-state=related
add action=accept chain=GUEST-Forward comment="GUEST-FWD Accept untracked" connection-state=untracked
add action=drop chain=GUEST-Forward comment="GUEST-FWD Drop invalid" connection-state=invalid
add action=drop chain=GUEST-Forward comment="GUEST-FWD Block RFC1918 10.x" dst-address=10.0.0.0/8
add action=drop chain=GUEST-Forward comment="GUEST-FWD Block RFC1918 172.x" dst-address=172.16.0.0/12
add action=drop chain=GUEST-Forward comment="GUEST-FWD Block RFC1918 192.x" dst-address=192.168.0.0/16
add action=accept chain=GUEST-Forward comment="GUEST-FWD Allow to WAN" out-interface-list=WAN
add action=drop chain=GUEST-Forward comment="GUEST-FWD Drop all other"
add action=accept chain=VPN-Forward comment="VPN-FWD Accept established" connection-state=established
add action=accept chain=VPN-Forward comment="VPN-FWD Accept related" connection-state=related
add action=accept chain=VPN-Forward comment="VPN-FWD Accept untracked" connection-state=untracked
add action=drop chain=VPN-Forward comment="VPN-FWD Drop invalid" connection-state=invalid
add action=accept chain=VPN-Forward comment="VPN-FWD Allow new to WAN" connection-state=new out-interface-list=WAN
add action=drop chain=VPN-Forward comment="VPN-FWD Drop new (disabled)" disabled=yes
add action=jump chain=input comment="Jump to LAN-Input" in-interface-list=LAN jump-target=LAN-Input
add action=jump chain=input comment="Jump to ISP-Input" in-interface-list=WAN jump-target=ISP-Input
add action=jump chain=input comment="Jump to VPN-Input" in-interface-list=VPN-OUT jump-target=VPN-Input
add action=jump chain=input comment="Jump to GUEST-Input" in-interface-list=GUEST jump-target=GUEST-Input
add action=jump chain=forward comment="Jump to ISP-Forward" in-interface-list=WAN jump-target=ISP-Forward
add action=jump chain=forward comment="Jump to VPN-Forward" in-interface-list=VPN-OUT jump-target=VPN-Forward
add action=jump chain=forward comment="Jump to LAN-Forward" in-interface-list=LAN jump-target=LAN-Forward
add action=jump chain=forward comment="Jump to GUEST-Forward" in-interface-list=GUEST jump-target=GUEST-Forward
add action=accept chain=GUEST-Input comment="GUEST Accept related" connection-state=related
add action=accept chain=GUEST-Input comment="GUEST Accept untracked" connection-state=untracked
add action=drop chain=GUEST-Input comment="GUEST Drop invalid" connection-state=invalid
add action=accept chain=GUEST-Input comment="GUEST Allow DNS" dst-port=53 protocol=udp
add action=accept chain=GUEST-Input comment="GUEST Allow DHCP" dst-port=67 protocol=udp
add action=drop chain=GUEST-Input comment="GUEST Drop all other"
/ip firewall nat
add action=masquerade chain=srcnat comment="Containers to WAN" src-address=192.168.254.0/24
add action=accept chain=dstnat comment="Allow containers DNS direct" dst-port=53 protocol=udp src-address=192.168.254.0/24
add action=dst-nat chain=dstnat comment="Mihomo UI" dst-address=192.168.0.88 dst-port=9090 protocol=tcp to-addresses=192.168.254.2 to-ports=9090
/ip route
add gateway=192.168.0.1
/ip service
set ftp disabled=yes
set ssh address=192.168.88.0/24,192.168.0.0/24,212.20.46.209/32
set telnet disabled=yes
set www disabled=yes
set winbox address=192.168.88.0/24,192.168.0.0/24,212.20.46.209/32
set api disabled=yes
set api-ssl disabled=yes
/ip smb shares
add directory=usb1-part1/smb_share name=usb1
/tool bandwidth-server
set enabled=no