# 2025-12-13 13:47:23 by RouterOS 7.20.6
# software id = 36YN-YJRY
#
# model = RB962UiGS-5HacT2HnT
# serial number = 8A770836D09F
/interface bridge
add admin-mac=D4:CA:6D:0D:FD:29 auto-mac=no comment=defconf fast-forward=no \
    name=bridge port-cost-mode=short protocol-mode=none
/interface wireless
set [ find default-name=wlan1 ] antenna-gain=0 band=2ghz-b/g/n channel-width=\
    20/40mhz-Ce country=no_country_set disabled=no distance=indoors \
    frequency=auto frequency-mode=manual-txpower mode=ap-bridge ssid=\
    MikroTik-0DFD2D station-roaming=enabled wireless-protocol=802.11
set [ find default-name=wlan2 ] antenna-gain=0 country=no_country_set \
    frequency-mode=manual-txpower ssid=MikroTik station-roaming=enabled
/interface ethernet
set [ find default-name=ether1 ] mac-address=D4:CA:6D:0D:FD:2C
set [ find default-name=ether5 ] mac-address=D4:CA:6D:0D:FD:2C
/interface wireguard
add disabled=yes listen-port=52281 mtu=1280 name=WARP
add disabled=yes listen-port=13232 mtu=1400 name=to-home
add disabled=yes listen-port=36998 mtu=1280 name=wg-client
add listen-port=10167 mtu=1400 name=wg-to-home
/interface list
add comment=defconf name=WAN
add comment=defconf name=LAN
/interface lte apn
set [ find default=yes ] ip-type=ipv4 use-network-apn=no
/interface wireless security-profiles
set [ find default=yes ] authentication-types=wpa2-psk eap-methods="" mode=\
    dynamic-keys supplicant-identity=MikroTik
add authentication-types=wpa-psk,wpa2-psk eap-methods="" \
    management-protection=allowed mode=dynamic-keys name=profile-Guest \
    supplicant-identity=""
/interface wireless
add default-forwarding=no keepalive-frames=disabled mac-address=\
    CE:2D:E0:AB:40:07 master-interface=wlan1 multicast-buffering=disabled \
    name=wlan-Guest security-profile=profile-Guest ssid=Guest \
    station-roaming=enabled wds-cost-range=0 wds-default-cost=0 wps-mode=\
    disabled
/ip dns forwarders
add doh-servers=https://dns.google/dns-query name=Google
add doh-servers=https://dns.comss.one/mikrotik name=Comss
add doh-servers=https://cloudflare-dns.com/dns-query name=CloudFlare
add doh-servers=https://dns.quad9.net/dns-query name=Quad9
/ip pool
add name=dhcp ranges=192.168.0.10-192.168.0.254
add name=pool-guest ranges=192.168.1.10-192.168.1.254
/ip dhcp-server
add address-pool=dhcp interface=bridge lease-time=10m name=defconf
# Interface not running
add address-pool=pool-guest interface=wlan-Guest lease-time=10m name=\
    server-guest
/ip smb users
set [ find default=yes ] disabled=yes
/routing bgp template
set default disabled=no output.network=bgp-networks
/routing ospf instance
add disabled=no name=default-v2
/routing ospf area
add disabled=yes instance=default-v2 name=backbone-v2
/routing table
add fib name=vpn_table
add disabled=no fib name=WARP
add fib name=wg-home-table
/system logging action
set 3 remote=10.200.200.82 remote-log-format=syslog remote-port=5514 \
    syslog-time-format=iso8601
/user group
add name=ssh policy="ssh,read,write,!local,!telnet,!ftp,!reboot,!policy,!test,\
    !winbox,!password,!web,!sniff,!sensitive,!api,!romon,!rest-api"
/interface bridge port
add bridge=bridge comment=defconf hw=no ingress-filtering=no interface=ether2 \
    internal-path-cost=10 path-cost=10
add bridge=bridge comment=defconf hw=no ingress-filtering=no interface=ether3 \
    internal-path-cost=10 path-cost=10
add bridge=bridge comment=defconf ingress-filtering=no interface=wlan1 \
    internal-path-cost=10 path-cost=10
add bridge=bridge ingress-filtering=no interface=ether5 internal-path-cost=10 \
    path-cost=10
add bridge=bridge ingress-filtering=no interface=ether1 internal-path-cost=10 \
    path-cost=10
/ip firewall connection tracking
set enabled=yes udp-timeout=10s
/ip neighbor discovery-settings
set discover-interface-list=LAN
/ip settings
set max-neighbor-entries=8192
/ipv6 settings
set disable-ipv6=yes max-neighbor-entries=8192
/interface detect-internet
set wan-interface-list=WAN
/interface list member
add comment=defconf interface=bridge list=LAN
add interface=ether4 list=WAN
add interface=WARP list=WAN
add comment="WG client" interface=wg-to-home list=LAN
/interface ovpn-server server
add auth=sha1,md5 mac-address=FE:33:5F:81:03:16 name=ovpn-server1
/interface wireguard peers
add allowed-address=0.0.0.0/0 disabled=yes endpoint-address=176.9.141.234 \
    endpoint-port=51820 interface=wg-client name=peer1 persistent-keepalive=\
    25s preshared-key="NI9eBob7CSlwycifb8Gq6F15lNwZVKyTxFrTlmoDQ6o=" \
    public-key="AchfHoRsXisKH4Fl0/b+QeY/76d4c3LNrphi4jrkVyI="
add allowed-address=0.0.0.0/0 comment=TSPU disabled=yes endpoint-address=\
    162.159.192.8 endpoint-port=3581 interface=WARP name=WARP \
    persistent-keepalive=20s public-key=\
    "bmXOC+F1FxEMF9dyiK2H5/1SUtzH0JuVo51h2wPfgyo="
add allowed-address=0.0.0.0/0 disabled=yes endpoint-address=212.20.46.209 \
    endpoint-port=51820 interface=to-home name=peer3 persistent-keepalive=25s \
    preshared-key="2IuhrP49eSzV/mGxKT9nDAU/1Q5MmJTbnKOEh6zsM0k=" public-key=\
    "PC06mXWYVYfRYW5p8nDHOhyIr8umWdCEwxySBCh8ZAE="
add allowed-address=0.0.0.0/0 endpoint-address=212.20.46.209 endpoint-port=\
    51820 interface=wg-to-home name=peer4 persistent-keepalive=2m \
    preshared-key="UPCYUl+kt/sH/rMlt36JEKXgiCLb9S8FipuZrSMgIVQ=" public-key=\
    "PC06mXWYVYfRYW5p8nDHOhyIr8umWdCEwxySBCh8ZAE="
/interface wireless access-list
add mac-address=B0:CA:68:5F:CA:22 vlan-mode=no-tag
add authentication=no disabled=yes forwarding=no vlan-mode=no-tag
/ip address
add address=192.168.0.1/24 comment=defconf interface=bridge network=\
    192.168.0.0
add address=192.168.1.1/24 disabled=yes interface=wlan-Guest network=\
    192.168.1.0
add address=10.0.0.7/8 interface=wg-client network=10.0.0.0
add address=172.16.0.2 interface=WARP network=172.16.0.2
add address=10.101.101.7/24 interface=wg-to-home network=10.101.101.0
/ip dhcp-client
add comment=defconf disabled=yes interface=bridge
add disabled=yes interface=bridge
# Interface not active
add interface=ether1
add default-route-tables=main interface=ether4 use-peer-dns=no
# Interface not active
add interface=wlan2
/ip dhcp-server lease
add address=192.168.0.95 client-id=1:0:c:29:56:e0:c0 mac-address=\
    00:0C:29:56:E0:C0 server=defconf
add address=192.168.0.16 client-id=1:0:12:17:33:da:1e mac-address=\
    00:12:17:33:DA:1E server=defconf
add address=192.168.0.29 mac-address=00:0C:29:DF:B5:6A server=defconf
add address=192.168.0.32 client-id=1:24:4b:fe:55:7b:e mac-address=\
    24:4B:FE:55:7B:0E server=defconf
add address=192.168.0.197 client-id=1:14:dd:a9:d6:da:47 mac-address=\
    14:DD:A9:D6:DA:47 server=defconf
add address=192.168.0.242 comment="VIdeo Serv" mac-address=70:8B:CD:82:29:60 \
    server=defconf
add address=192.168.0.12 client-id=1:26:5:ca:84:e3:40 comment=\
    "\D5\C7 \F7\F2\EE \F2\E0\EA\EE\E5" mac-address=26:05:CA:84:E3:40 server=\
    defconf
add address=192.168.0.13 client-id=1:0:46:a8:1b:ae:6d comment=\
    "\C2\E8\E4\E5\EE\F0\E5\E3\E8\F1\F2\F0\E0\F2\EE\F0 Tantos" mac-address=\
    00:46:A8:1B:AE:6D server=defconf
/ip dhcp-server network
add address=192.168.0.0/24 comment=defconf dns-server=192.168.0.1 gateway=\
    192.168.0.1 netmask=24 ntp-server=192.168.0.1
add address=192.168.1.0/24 dns-server=192.168.1.1 gateway=192.168.1.1
/ip dns
set allow-remote-requests=yes cache-max-ttl=1d use-doh-server=\
    https://dns.google/dns-query verify-doh-cert=yes
/ip dns static
add address=192.168.88.1 disabled=yes name=router.lan type=A
add address=192.168.0.1 name=router.lan type=A
add address=1.1.1.1 comment="DNS CloudFlare" name=cloudflare-dns.com type=A
add address=1.0.0.1 comment="DNS CloudFlare" name=cloudflare-dns.com type=A
add address=8.8.8.8 comment="DNS Google" name=dns.google type=A
add address=8.8.4.4 comment="DNS Google" name=dns.google type=A
add address=9.9.9.9 comment="DNS Quad9" name=dns.quad9.net type=A
add address=149.112.112.112 comment="DNS Quad9" name=dns.quad9.net type=A
add address=195.133.25.16 comment="DNS Comss" name=dns.comss.one type=A
add address-list=BlackList_RU forward-to=Google match-subdomain=yes name=\
    youtube.ru type=FWD
add address-list=BlackList_RU forward-to=Google match-subdomain=yes name=\
    ytimg.com type=FWD
add address-list=BlackList_RU forward-to=Google match-subdomain=yes name=\
    withyoutube.com type=FWD
add address-list=BlackList_RU forward-to=Google match-subdomain=yes name=\
    youtu.be type=FWD
add address-list=BlackList_RU forward-to=Google match-subdomain=yes name=\
    youtube-nocookie.com type=FWD
add address-list=BlackList_RU forward-to=Google match-subdomain=yes name=\
    yt.be type=FWD
add address-list=BlackList_RU forward-to=Google match-subdomain=yes name=\
    youtubemobilesupport.com type=FWD
add address-list=BlackList_RU forward-to=Google match-subdomain=yes name=\
    youtubekids.com type=FWD
add address-list=BlackList_RU forward-to=Google match-subdomain=yes name=\
    youtubego.com type=FWD
add address-list=BlackList_RU forward-to=Google match-subdomain=yes name=\
    instagram.com type=FWD
add address-list=BlackList_RU forward-to=Google match-subdomain=yes name=\
    youtubegaming.com type=FWD
add address-list=BlackList_RU forward-to=Google match-subdomain=yes name=\
    youtubefanfest.com type=FWD
add address-list=BlackList_RU forward-to=Google match-subdomain=yes name=\
    youtubeeducation.com type=FWD
add address-list=BlackList_RU forward-to=Google match-subdomain=yes name=\
    ggpht.com type=FWD
add address-list=BlackList_RU forward-to=Google match-subdomain=yes name=\
    ytimg.l.google.com type=FWD
add address-list=BlackList_RU forward-to=Google match-subdomain=yes name=\
    youtube.com type=FWD
add address-list=BlackList_RU forward-to=Google match-subdomain=yes name=\
    googlevideo.com type=FWD
add address-list=BlackList_RU forward-to=Google match-subdomain=yes name=\
    youtube.googleapis.com type=FWD
add address-list=BlackList_RU forward-to=Google match-subdomain=yes name=\
    youtubeembeddedplayer.googleapis.com type=FWD
add address-list=BlackList_RU forward-to=Google match-subdomain=yes name=\
    youtubei.googleapis.com type=FWD
add address-list=BlackList_RU forward-to=Google match-subdomain=yes name=\
    youtube-ui.l.google.com type=FWD
add address-list=BlackList_RU forward-to=Google match-subdomain=yes name=\
    wide-youtube.l.google.com type=FWD
add address-list=BlackList_RU forward-to=Google match-subdomain=yes name=\
    2ip.ru type=FWD
/ip firewall address-list
add address=5.143.224.100/30 list=cyberok-ban
add address=5.143.224.104/30 list=cyberok-ban
add address=185.224.228.0/24 list=cyberok-ban
add address=185.224.230.0/24 list=cyberok-ban
add address=212.192.158.0/24 list=cyberok-ban
add address=85.142.100.0/24 list=cyberok-ban
add address=92.38.153.0/24 list=cyberok-ban
add address=188.68.217.207 list=cyberok-ban
add address=212.41.12.45 list=cyberok-ban
add address=212.41.12.46 list=cyberok-ban
add address=212.41.12.47 list=cyberok-ban
add address=212.41.12.48 list=cyberok-ban
add address=212.41.13.23 list=cyberok-ban
add address=212.41.13.24 list=cyberok-ban
add address=212.41.13.25 list=cyberok-ban
add address=31.131.251.106 list=cyberok-ban
add address=31.131.251.235 list=cyberok-ban
add address=31.131.255.205 list=cyberok-ban
add address=31.131.255.206 list=cyberok-ban
add address=31.131.255.207 list=cyberok-ban
add address=31.131.255.208 list=cyberok-ban
add address=31.131.255.209 list=cyberok-ban
add address=31.131.255.210 list=cyberok-ban
add address=31.131.255.211 list=cyberok-ban
add address=31.131.255.212 list=cyberok-ban
add address=31.131.255.240 list=cyberok-ban
add address=37.9.13.54 list=cyberok-ban
add address=37.9.13.84 list=cyberok-ban
add address=37.9.13.105 list=cyberok-ban
add address=37.9.13.217 list=cyberok-ban
add address=45.146.167.56 list=cyberok-ban
add address=45.146.167.68 list=cyberok-ban
add address=45.146.167.105 list=cyberok-ban
add address=45.146.167.237 list=cyberok-ban
add address=45.92.176.94 list=cyberok-ban
add address=45.92.176.129 list=cyberok-ban
add address=45.92.176.143 list=cyberok-ban
add address=45.92.176.144 list=cyberok-ban
add address=45.92.176.145 list=cyberok-ban
add address=45.92.177.113 list=cyberok-ban
add address=45.92.177.127 list=cyberok-ban
add address=45.92.177.237 list=cyberok-ban
add address=45.93.20.45 list=cyberok-ban
add address=45.93.20.79 list=cyberok-ban
add address=45.93.20.104 list=cyberok-ban
add address=45.93.20.109 list=cyberok-ban
add address=45.93.20.126 list=cyberok-ban
add address=45.93.20.148 list=cyberok-ban
add address=45.93.20.229 list=cyberok-ban
add address=45.93.20.103 list=cyberok-ban
add address=62.84.116.11 list=cyberok-ban
add address=62.84.116.13 list=cyberok-ban
add address=62.84.116.34 list=cyberok-ban
add address=62.84.116.219 list=cyberok-ban
add address=62.84.116.237 list=cyberok-ban
add address=77.223.102.84 list=cyberok-ban
add address=77.223.102.101 list=cyberok-ban
add address=77.223.102.191 list=cyberok-ban
add address=77.223.103.45 list=cyberok-ban
add address=77.223.103.53 list=cyberok-ban
add address=94.26.228.205 list=cyberok-ban
add address=95.143.190.169 list=cyberok-ban
add address=95.143.190.179 list=cyberok-ban
add address=95.143.191.147 list=cyberok-ban
add address=95.143.191.223 list=cyberok-ban
add address=95.143.191.245 list=cyberok-ban
add address=45.141.86.171 list=cyberok-ban
add address=77.223.120.227 list=cyberok-ban
add address=194.26.25.137 list=cyberok-ban
add address=82.148.21.205 list=cyberok-ban
add address=94.26.228.18 list=cyberok-ban
add address=5.188.159.228 list=cyberok-ban
add address=80.249.131.92 list=cyberok-ban
add address=94.25.46.114 list=cyberok-ban
add address=95.167.197.242 list=cyberok-ban
add address=95.167.199.34 list=cyberok-ban
add address=95.167.199.90 list=cyberok-ban
add address=95.167.200.10 list=cyberok-ban
add address=176.208.65.146 list=cyberok-ban
add address=176.208.67.114 list=cyberok-ban
add address=176.211.48.242 list=cyberok-ban
add address=178.185.170.42 list=cyberok-ban
add address=178.185.216.114 list=cyberok-ban
add address=178.185.234.162 list=cyberok-ban
add address=178.185.235.58 list=cyberok-ban
add address=178.185.238.154 list=cyberok-ban
add address=178.185.238.178 list=cyberok-ban
add address=178.185.241.114 list=cyberok-ban
add address=176.211.56.130 list=cyberok-ban
add address=176.211.103.178 list=cyberok-ban
add address=92.124.109.218 list=cyberok-ban
add address=85.175.69.50 list=cyberok-ban
add address=95.167.62.66 list=cyberok-ban
add address=176.100.243.247 list=cyberok-ban
add address=176.208.69.226 list=cyberok-ban
add address=176.208.70.162 list=cyberok-ban
add address=176.208.79.82 list=cyberok-ban
add address=176.210.118.218 list=cyberok-ban
add address=176.211.46.130 list=cyberok-ban
add address=176.211.47.122 list=cyberok-ban
add address=176.211.51.218 list=cyberok-ban
add address=178.185.133.251 list=cyberok-ban
add address=178.185.202.130 list=cyberok-ban
add address=178.185.202.162 list=cyberok-ban
add address=178.185.228.58 list=cyberok-ban
add address=178.185.235.74 list=cyberok-ban
add address=178.185.239.50 list=cyberok-ban
add address=178.185.239.58 list=cyberok-ban
add address=178.185.241.98 list=cyberok-ban
add address=212.164.59.250 list=cyberok-ban
add address=213.59.217.242 list=cyberok-ban
add address=217.65.82.18 list=cyberok-ban
add address=85.175.147.234 list=cyberok-ban
add address=91.122.177.241 list=cyberok-ban
add address=95.167.133.10 list=cyberok-ban
add address=95.167.148.18 list=cyberok-ban
add address=95.167.186.2 list=cyberok-ban
add address=95.167.198.186 list=cyberok-ban
add address=95.167.62.82 list=cyberok-ban
add address=95.167.82.26 list=cyberok-ban
add address=95.167.87.66 list=cyberok-ban
add address=95.189.36.106 list=cyberok-ban
add address=80.93.187.17 list=cyberok-ban
add address=5.178.87.167 list=cyberok-ban
add address=5.159.97.203 list=cyberok-ban
add address=188.246.224.80 list=cyberok-ban
add address=45.92.176.205 list=cyberok-ban
add address=193.168.46.143 list=cyberok-ban
add address=212.67.10.218 list=cyberok-ban
add address=212.67.11.128 list=cyberok-ban
add address=212.67.11.136 list=cyberok-ban
add address=212.67.11.167 list=cyberok-ban
add address=212.67.11.227 list=cyberok-ban
add address=212.67.11.233 list=cyberok-ban
add address=212.67.11.234 list=cyberok-ban
add address=212.67.11.37 list=cyberok-ban
add address=62.113.99.65 list=cyberok-ban
add address=176.211.103.202 list=cyberok-ban
add address=212.41.26.138 list=cyberok-ban
add address=85.142.100.2 list=cyberok-ban
add address=92.223.103.144 list=cyberok-ban
add address=212.41.10.41 list=cyberok-ban
add address=89.169.28.210 list=cyberok-ban
add address=89.169.28.191 list=cyberok-ban
add address=89.169.28.214 list=cyberok-ban
/ip firewall filter
add action=accept chain=input comment=SAFE-ACCESS src-address=212.20.46.209
add action=jump chain=input comment="Jump to LAN-Input" in-interface-list=LAN \
    jump-target=LAN-Input
add action=jump chain=input comment="Jump to ISP-Input" in-interface-list=WAN \
    jump-target=ISP-Input
add action=drop chain=input comment="Drop all other to router" log=yes \
    log-prefix=INPUT-DROP:
add action=jump chain=forward comment="Jump to ISP-Forward" \
    in-interface-list=WAN jump-target=ISP-Forward
add action=jump chain=forward comment="Jump to LAN-Forward" \
    in-interface-list=LAN jump-target=LAN-Forward
add action=drop chain=forward comment="Drop all other"
add action=drop chain=Brute-force comment="BF Drop blocked" src-address-list=\
    Brute-force-block
add action=add-src-to-address-list address-list=Brute-force-block \
    address-list-timeout=8h chain=Brute-force comment="BF Block after 4th" \
    src-address-list=Brute-force-4
add action=add-src-to-address-list address-list=Brute-force-4 \
    address-list-timeout=30s chain=Brute-force comment="BF 4th attempt" \
    src-address-list=Brute-force-3
add action=add-src-to-address-list address-list=Brute-force-3 \
    address-list-timeout=30s chain=Brute-force comment="BF 3rd attempt" \
    src-address-list=Brute-force-2
add action=add-src-to-address-list address-list=Brute-force-2 \
    address-list-timeout=30s chain=Brute-force comment="BF 2nd attempt" \
    src-address-list=Brute-force-1
add action=add-src-to-address-list address-list=Brute-force-1 \
    address-list-timeout=30s chain=Brute-force comment="BF 1st attempt"
add action=accept chain=Brute-force comment="BF Accept if not blocked"
add action=accept chain=LAN-Input comment="Accept all from LAN"
add action=accept chain=LAN-Forward comment="LAN-FWD Accept established" \
    connection-state=established
add action=accept chain=LAN-Forward comment="LAN-FWD Accept related" \
    connection-state=related
add action=accept chain=LAN-Forward comment="LAN-FWD Accept untracked" \
    connection-state=untracked
add action=drop chain=LAN-Forward comment="LAN-FWD Drop invalid" \
    connection-state=invalid
add action=accept chain=LAN-Forward comment="LAN-FWD Accept new from LAN"
add action=accept chain=ISP-Input comment="ISP Accept established" \
    connection-state=established
add action=accept chain=ISP-Input comment="ISP Accept related" \
    connection-state=related
add action=accept chain=ISP-Input comment="ISP Accept untracked" \
    connection-state=untracked
add action=drop chain=ISP-Input comment="ISP Drop invalid" connection-state=\
    invalid
add action=jump chain=ISP-Input comment="ISP Jump to allowed" jump-target=\
    ISP-Input-Allow
add action=drop chain=ISP-Input comment="ISP Drop all other"
add action=accept chain=ISP-Input-Allow comment="Allow ICMP" protocol=icmp
add action=jump chain=ISP-Input-Allow comment="SSH via Brute-force" \
    connection-nat-state=dstnat dst-port=22 jump-target=Brute-force protocol=\
    tcp
add action=drop chain=ISP-Input-Allow comment="Drop Winbox from WAN" \
    dst-port=8291 protocol=tcp
add action=accept chain=ISP-Input-Allow comment=WireGuard dst-port=51820 \
    protocol=udp
add action=accept chain=ISP-Forward comment="ISP-FWD Accept established" \
    connection-state=established
add action=accept chain=ISP-Forward comment="ISP-FWD Accept related" \
    connection-state=related
add action=accept chain=ISP-Forward comment="ISP-FWD Accept untracked" \
    connection-state=untracked
add action=drop chain=ISP-Forward comment="ISP-FWD Drop invalid" \
    connection-state=invalid
add action=accept chain=ISP-Forward comment="ISP-FWD Accept DST-NAT" \
    connection-nat-state=dstnat
add action=drop chain=ISP-Forward comment="ISP-FWD Drop all other"
/ip firewall mangle
add action=log chain=postrouting disabled=yes dst-address=173.194.222.198 \
    log-prefix=POST-YT:
add action=log chain=postrouting disabled=yes log-prefix=TO-TUNNEL: \
    out-interface=wg-to-home
add action=log chain=prerouting disabled=yes dst-port=443 log-prefix=\
    MARKED-443: protocol=tcp routing-mark=wg-home-table
add action=mark-routing chain=prerouting dst-address-list=BlackList_RU \
    in-interface-list=LAN log=yes log-prefix=NEW-RT: new-routing-mark=\
    wg-home-table passthrough=no
add action=change-mss chain=forward new-mss=clamp-to-pmtu protocol=tcp \
    tcp-flags=syn
add action=log chain=prerouting disabled=yes dst-address-list=BlackList_RU \
    log-prefix=MANGLE:
add action=mark-connection chain=prerouting connection-mark=no-mark \
    dst-address-list=BlackList_RU new-connection-mark=BlackList_RU
add action=mark-routing chain=prerouting connection-mark=BlackList_RU \
    in-interface-list=LAN log=yes log-prefix=MARK-RT: new-routing-mark=\
    wg-home-table passthrough=no
add action=log chain=prerouting connection-mark=BlackList_RU disabled=yes \
    log-prefix=CLIENT-MARK:
add action=change-mss chain=forward comment="MSS fix wg-to-home out" new-mss=\
    1300 out-interface=wg-to-home protocol=tcp tcp-flags=syn
add action=change-mss chain=forward comment="MSS fix wg-to-home in" \
    in-interface=wg-to-home new-mss=1300 protocol=tcp tcp-flags=syn
add action=change-mss chain=forward comment="TCP MSS clamp for wg-to-home" \
    new-mss=1360 out-interface=wg-to-home protocol=tcp tcp-flags=syn
add action=change-mss chain=forward comment="MSS clamp for wg-to-home" \
    new-mss=1360 out-interface=wg-to-home protocol=tcp tcp-flags=syn tcp-mss=\
    1201-65535
/ip firewall nat
add action=masquerade chain=srcnat comment="defconf: masquerade" disabled=yes \
    ipsec-policy=out,none out-interface-list=WAN
add action=dst-nat chain=dstnat disabled=yes dst-port=97 in-interface=ether5 \
    protocol=tcp to-addresses=192.168.0.117 to-ports=80
add action=dst-nat chain=dstnat disabled=yes dst-port=9786 in-interface=\
    ether4 protocol=tcp to-addresses=192.168.0.90 to-ports=9786
add action=src-nat chain=dstnat disabled=yes dst-port=3080 in-interface=\
    ether4 protocol=tcp to-addresses=10.101.101.3 to-ports=3080
add action=dst-nat chain=dstnat disabled=yes dst-port=3081 in-interface=\
    ether4 protocol=tcp to-addresses=192.168.0.90 to-ports=3081
add action=dst-nat chain=dstnat disabled=yes dst-port=9779 in-interface=\
    ether4 protocol=tcp to-addresses=192.168.0.90 to-ports=9779
add action=dst-nat chain=dstnat disabled=yes dst-port=9780 in-interface=\
    ether4 protocol=tcp to-addresses=192.168.0.90 to-ports=9780
add action=dst-nat chain=dstnat disabled=yes dst-port=3389 in-interface=\
    all-ethernet protocol=tcp to-addresses=192.168.0.242 to-ports=3389
add action=dst-nat chain=dstnat disabled=yes dst-port=1080 in-interface=\
    all-ethernet log-prefix=kk protocol=tcp to-addresses=192.168.0.242 \
    to-ports=1080
add action=dst-nat chain=dstnat disabled=yes dst-port=22 in-interface=\
    all-ethernet log-prefix=kk protocol=tcp src-address-list=KNOCK-ACCEPT \
    to-addresses=192.168.0.242 to-ports=22
add action=redirect chain=dstnat dst-address-type=!local dst-port=53 \
    in-interface-list=LAN protocol=udp
add action=masquerade chain=srcnat disabled=yes out-interface=WARP
add action=masquerade chain=srcnat comment="WG RDP: SRCNAT" dst-address=\
    192.168.0.242 dst-port=3389 protocol=tcp
add action=masquerade chain=srcnat out-interface-list=WAN src-address=\
    !10.101.101.0/24
add action=accept chain=srcnat connection-mark=BlackList_RU out-interface=\
    wg-to-home
add action=masquerade chain=srcnat comment="NAT for wg-home" out-interface=\
    wg-to-home
add action=dst-nat chain=dstnat comment="WG RDP: DSTNAT" dst-address=\
    10.101.101.242 dst-port=3389 protocol=tcp to-addresses=192.168.0.242
add action=redirect chain=dstnat dst-address-type=!local dst-port=53 \
    in-interface-list=LAN protocol=udp
/ip firewall raw
add action=accept chain=prerouting dst-address=10.101.101.242 dst-port=3389 \
    in-interface=wg-to-home log-prefix=RAW-RDP: protocol=tcp
add action=drop chain=prerouting log-prefix=RAW-CYBEROK-DROP \
    src-address-list=cyberok-ban
add action=drop chain=prerouting comment=\
    "Drop all traffic from RDP bruteforcers" src-address-list=rdp-bruteforce
add action=add-src-to-address-list address-list=rdp-bruteforce \
    address-list-timeout=1w chain=prerouting comment=\
    "Honeypot: catch RDP scanners" dst-port=3389 in-interface-list=!LAN \
    log-prefix=RDP-HONEYPOT protocol=tcp
/ip firewall service-port
set pptp disabled=yes
/ip hotspot profile
set [ find default=yes ] html-directory=hotspot
/ip ipsec profile
set [ find default=yes ] dpd-interval=2m dpd-maximum-failures=5
/ip proxy
set parent-proxy=0.0.0.0 port=305
/ip route
add gateway=wg-client routing-table=vpn_table
add disabled=yes distance=1 dst-address=0.0.0.0/0 gateway=WARP routing-table=\
    WARP scope=30 suppress-hw-offload=no target-scope=10
add disabled=yes distance=1 dst-address=0.0.0.0/0 gateway=to-home \
    routing-table=WARP scope=30 suppress-hw-offload=no target-scope=10
add dst-address=0.0.0.0/0 gateway=wg-to-home routing-table=wg-home-table
add comment="Main office LAN via WG" disabled=no distance=1 dst-address=\
    192.168.0.0/24 gateway=10.101.101.1 routing-table=main scope=30 \
    suppress-hw-offload=no target-scope=10
add comment="Video server via WG gateway" dst-address=10.101.101.200/32 \
    gateway=10.101.101.1
add comment="NETMAP access to main LAN" dst-address=10.200.200.0/24 gateway=\
    wg-to-home
/ip service
set ftp disabled=yes
set telnet disabled=yes
set www disabled=yes
set api disabled=yes
set api-ssl address=212.20.46.209/32
/ip smb shares
set [ find default=yes ] directory=/flash/pub
/ip socks
set port=8081
/ip upnp interfaces
add interface=ether5 type=external
add interface=ether2 type=internal
add interface=ether3 type=internal
add interface=ether4 type=internal
add interface=ether1 type=internal
add interface=bridge type=internal
/routing bfd configuration
add disabled=no interfaces=all min-rx=200ms min-tx=200ms multiplier=5
/routing igmp-proxy
set query-interval=1m quick-leave=yes
/routing igmp-proxy interface
add alternative-subnets=0.0.0.0/0 interface=ether5 upstream=yes
add interface=bridge
/routing rule
add action=lookup-only-in-table disabled=no routing-mark=vpn_table table=\
    vpn_table
add action=lookup-only-in-table routing-mark=WARP table=WARP
add action=lookup disabled=no routing-mark=wg-home-table table=wg-home-table
/system clock
set time-zone-name=Asia/Novosibirsk
/system identity
set name=Mik_mom
/system logging
add action=remote topics=info
add action=remote topics=warning
add action=remote topics=error
add action=remote topics=critical
/system ntp client
set enabled=yes
/system ntp server
set enabled=yes
/system ntp client servers
add address=0.ru.pool.ntp.org
add address=1.ru.pool.ntp.org
add address=2.ru.pool.ntp.org
add address=3.ru.pool.ntp.org
/system scheduler
add interval=1h name=Monitoring on-event=\
    "/system script run Monitoring_izmeneniy_script" policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    start-date=2022-10-23 start-time=19:12:03
add interval=1d name="Backup And Update" on-event=\
    "/system script run BackupAndUpdate;" policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    start-date=2022-10-25 start-time=16:46:48
add disabled=yes interval=5m name=TSPU on-event=WG_TSPU3 policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    start-date=2025-05-07 start-time=01:38:11
add interval=1w name=auto-update-cyberok on-event=update-cyberok-list policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    start-date=2025-12-09 start-time=04:00:00
/system script
add dont-require-permissions=no name=Monitoring_izmeneniy_script owner=admin \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=":local Url \"http://192.168.0.33/mik/api/\"\r\
    \n/tool fetch http-method=get url=\$Url output=none;\r\
    \n:log info \"Send Url\";"
add dont-require-permissions=no name=BackupAndUpdate owner=admin policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source="#\
    \_Script name: BackupAndUpdate\r\
    \n#\r\
    \n#----------SCRIPT INFORMATION-------------------------------------------\
    --------\r\
    \n#\r\
    \n# Script:  Mikrotik RouterOS automatic backup & update\r\
    \n# Version: 22.07.15\r\
    \n# Created: 07/08/2018\r\
    \n# Updated: 15/07/2022\r\
    \n# Author:  Alexander Tebiev\r\
    \n# Website: https://github.com/beeyev\r\
    \n# You can contact me by e-mail at tebiev@mail.com\r\
    \n#\r\
    \n# IMPORTANT!\r\
    \n# Minimum supported RouterOS version is v6.43.7\r\
    \n#\r\
    \n#----------MODIFY THIS SECTION AS NEEDED--------------------------------\
    --------\r\
    \n## Notification e-mail\r\
    \n## (Make sure you have configurated Email settings in Tools -> Email)\r\
    \n:local emailAddress \"nill777nill@gmail.com\";\r\
    \n\r\
    \n## Script mode, possible values: backup, osupdate, osnotify.\r\
    \n# backup     -     Only backup will be performed. (default value, if non\
    e provided)\r\
    \n#\r\
    \n# osupdate     -     The Script will install a new RouterOS if it is ava\
    ilable.\r\
    \n#                It will also create backups before and after update pro\
    cess (does not matter what value is set to `forceBackup`)\r\
    \n#                Email will be sent only if a new RouterOS version is av\
    ailable.\r\
    \n#                Change parameter `forceBackup` if you need the script t\
    o create backups every time when it runs (even when no updates were found)\
    .\r\
    \n#\r\
    \n# osnotify     -     The script will send email notification only (witho\
    ut backups) if a new RouterOS is available.\r\
    \n#                Change parameter `forceBackup` if you need the script t\
    o create backups every time when it runs.\r\
    \n:local scriptMode \"osupdate\";\r\
    \n\r\
    \n## Additional parameter if you set `scriptMode` to `osupdate` or `osnoti\
    fy`\r\
    \n# Set `true` if you want the script to perform backup every time it's fi\
    red, whatever script mode is set.\r\
    \n:local forceBackup false;\r\
    \n\r\
    \n## Backup encryption password, no encryption if no password.\r\
    \n:local backupPassword \"B&UFVG76fefrvbw456#@\$ghy5383r7gq237e2e2e2r32r\"\
    \r\
    \n\r\
    \n## If true, passwords will be included in exported config.\r\
    \n:local sensetiveDataInConfig true;\r\
    \n\r\
    \n## Update channel. Possible values: stable, long-term, testing, developm\
    ent\r\
    \n:local updateChannel \"stable\";\r\
    \n\r\
    \n## Install only patch versions of RouterOS updates.\r\
    \n## Works only if you set scriptMode to \"osupdate\"\r\
    \n## Means that new update will be installed only if MAJOR and MINOR versi\
    on numbers remained the same as currently installed RouterOS.\r\
    \n## Example: v6.43.6 => major.minor.PATCH\r\
    \n## Script will send information if new version is greater than just patc\
    h.\r\
    \n:local installOnlyPatchUpdates    false;\r\
    \n\r\
    \n##----------------------------------------------------------------------\
    --------------------##\r\
    \n#  !!!! DO NOT CHANGE ANYTHING BELOW THIS LINE, IF YOU ARE NOT SURE WHAT\
    \_YOU ARE DOING !!!!  #\r\
    \n##----------------------------------------------------------------------\
    --------------------##\r\
    \n\r\
    \n#Script messages prefix\r\
    \n:local SMP \"Bkp&Upd:\"\r\
    \n\r\
    \n:log info \"\\r\\n\$SMP script \\\"Mikrotik RouterOS automatic backup & \
    update\\\" started.\";\r\
    \n:log info \"\$SMP Script Mode: \$scriptMode, forceBackup: \$forceBackup\
    \";\r\
    \n\r\
    \n#Check proper email config\r\
    \n:if ([:len \$emailAddress] = 0 or [:len [/tool e-mail get address]] = 0 \
    or [:len [/tool e-mail get from]] = 0) do={\r\
    \n    :log error (\"\$SMP Email configuration is not correct, please check\
    \_Tools -> Email. Script stopped.\");   \r\
    \n    :error \"\$SMP bye!\";\r\
    \n}\r\
    \n\r\
    \n#Check if proper identity name is set\r\
    \nif ([:len [/system identity get name]] = 0 or [/system identity get name\
    ] = \"MikroTik\") do={\r\
    \n    :log warning (\"\$SMP Please set identity name of your device (Syste\
    m -> Identity), keep it short and informative.\");  \r\
    \n};\r\
    \n\r\
    \n############### vvvvvvvvv GLOBALS vvvvvvvvv ###############\r\
    \n# Function converts standard mikrotik build versions to the number.\r\
    \n# Possible arguments: paramOsVer\r\
    \n# Example:\r\
    \n# :put [\$buGlobalFuncGetOsVerNum paramOsVer=[/system routerboard get cu\
    rrent-RouterOS]];\r\
    \n# result will be: 64301, because current RouterOS version is: 6.43.1\r\
    \n:global buGlobalFuncGetOsVerNum do={\r\
    \n    :local osVer \$paramOsVer;\r\
    \n    :local osVerNum;\r\
    \n    :local osVerMicroPart;\r\
    \n    :local zro 0;\r\
    \n    :local tmp;\r\
    \n    \r\
    \n    # Replace word `beta` with dot\r\
    \n    :local isBetaPos [:tonum [:find \$osVer \"beta\" 0]];\r\
    \n    :if (\$isBetaPos > 1) do={\r\
    \n        :set osVer ([:pick \$osVer 0 \$isBetaPos] . \".\" . [:pick \$osV\
    er (\$isBetaPos + 4) [:len \$osVer]]);\r\
    \n    }\r\
    \n    # Replace word `rc` with dot\r\
    \n    :local isRcPos [:tonum [:find \$osVer \"rc\" 0]];\r\
    \n    :if (\$isRcPos > 1) do={\r\
    \n        :set osVer ([:pick \$osVer 0 \$isRcPos] . \".\" . [:pick \$osVer\
    \_(\$isRcPos + 2) [:len \$osVer]]);\r\
    \n    }\r\
    \n    \r\
    \n    :local dotPos1 [:find \$osVer \".\" 0];\r\
    \n\r\
    \n    :if (\$dotPos1 > 0) do={ \r\
    \n\r\
    \n        # AA\r\
    \n        :set osVerNum  [:pick \$osVer 0 \$dotPos1];\r\
    \n        \r\
    \n        :local dotPos2 [:find \$osVer \".\" \$dotPos1];\r\
    \n                #Taking minor version, everything after first dot\r\
    \n        :if ([:len \$dotPos2] = 0)     do={:set tmp [:pick \$osVer (\$do\
    tPos1+1) [:len \$osVer]];}\r\
    \n        #Taking minor version, everything between first and second dots\
    \r\
    \n        :if (\$dotPos2 > 0)             do={:set tmp [:pick \$osVer (\$d\
    otPos1+1) \$dotPos2];}\r\
    \n        \r\
    \n        # AA 0B\r\
    \n        :if ([:len \$tmp] = 1)     do={:set osVerNum \"\$osVerNum\$zro\$\
    tmp\";}\r\
    \n        # AA BB\r\
    \n        :if ([:len \$tmp] = 2)     do={:set osVerNum \"\$osVerNum\$tmp\"\
    ;}\r\
    \n        \r\
    \n        :if (\$dotPos2 > 0) do={ \r\
    \n            :set tmp [:pick \$osVer (\$dotPos2+1) [:len \$osVer]];\r\
    \n            # AA BB 0C\r\
    \n            :if ([:len \$tmp] = 1) do={:set osVerNum \"\$osVerNum\$zro\$\
    tmp\";}\r\
    \n            # AA BB CC\r\
    \n            :if ([:len \$tmp] = 2) do={:set osVerNum \"\$osVerNum\$tmp\"\
    ;}\r\
    \n        } else={\r\
    \n            # AA BB 00\r\
    \n            :set osVerNum \"\$osVerNum\$zro\$zro\";\r\
    \n        }\r\
    \n    } else={\r\
    \n        # AA 00 00\r\
    \n        :set osVerNum \"\$osVer\$zro\$zro\$zro\$zro\";\r\
    \n    }\r\
    \n\r\
    \n    :return \$osVerNum;\r\
    \n}\r\
    \n\r\
    \n\r\
    \n# Function creates backups (system and config) and returns array with na\
    mes\r\
    \n# Possible arguments: \r\
    \n#    `backupName`             | string    | backup file name, without ex\
    tension!\r\
    \n#    `backupPassword`        | string     |\r\
    \n#    `sensetiveDataInConfig`    | boolean     |\r\
    \n# Example:\r\
    \n# :put [\$buGlobalFuncCreateBackups name=\"daily-backup\"];\r\
    \n:global buGlobalFuncCreateBackups do={\r\
    \n    :log info (\"\$SMP Global function \\\"buGlobalFuncCreateBackups\\\"\
    \_was fired.\");  \r\
    \n    \r\
    \n    :local backupFileSys \"\$backupName.backup\";\r\
    \n    :local backupFileConfig \"\$backupName.rsc\";\r\
    \n    :local backupNames {\$backupFileSys;\$backupFileConfig};\r\
    \n\r\
    \n    ## Make system backup\r\
    \n    :if ([:len \$backupPassword] = 0) do={\r\
    \n        /system backup save dont-encrypt=yes name=\$backupName;\r\
    \n    } else={\r\
    \n        /system backup save password=\$backupPassword name=\$backupName;\
    \r\
    \n    }\r\
    \n    :log info (\"\$SMP System backup created. \$backupFileSys\");   \r\
    \n\r\
    \n    ## Export config file\r\
    \n    :if (\$sensetiveDataInConfig = true) do={\r\
    \n        # since RouterOS v7 it needs to be set precise that we want to e\
    xport sensitive data\r\
    \n        :if ([:pick [/system package update get installed-version] 0 1] \
    < 7) do={\r\
    \n            :execute \"/export compact terse file=\$backupName\";\r\
    \n        } else={\r\
    \n            :execute \"/export compact show-sensitive terse file=\$backu\
    pName\";\r\
    \n        }\r\
    \n    } else={\r\
    \n        /export compact hide-sensitive terse file=\$backupName;\r\
    \n    }\r\
    \n    :log info (\"\$SMP Config file was exported. \$backupFileConfig, the\
    \_script execution will be paused for a moment.\");   \r\
    \n\r\
    \n    #Delay after creating backups\r\
    \n    :delay 20s;    \r\
    \n    :return \$backupNames;\r\
    \n}\r\
    \n\r\
    \n:global buGlobalVarUpdateStep;\r\
    \n############### ^^^^^^^^^ GLOBALS ^^^^^^^^^ ###############\r\
    \n\r\
    \n:local scriptVersion    \"22.07.15\";\r\
    \n\r\
    \n#Current date time in format: 2020jan15-221324 \r\
    \n:local dateTime ([:pick [/system clock get date] 7 11] . [:pick [/system\
    \_clock get date] 0 3] . [:pick [/system clock get date] 4 6] . \"-\" . [:\
    pick [/system clock get time] 0 2] . [:pick [/system clock get time] 3 5] \
    . [:pick [/system clock get time] 6 8]);\r\
    \n\r\
    \n:local deviceOsVerInst             [/system package update get installed\
    -version];\r\
    \n:local deviceOsVerInstNum         [\$buGlobalFuncGetOsVerNum paramOsVer=\
    \$deviceOsVerInst];\r\
    \n:local deviceOsVerAvail         \"\";\r\
    \n:local deviceOsVerAvailNum         0;\r\
    \n:local deviceRbModel            [/system routerboard get model];\r\
    \n:local deviceRbSerialNumber     [/system routerboard get serial-number];\
    \r\
    \n:local deviceRbCurrentFw         [/system routerboard get current-firmwa\
    re];\r\
    \n:local deviceRbUpgradeFw         [/system routerboard get upgrade-firmwa\
    re];\r\
    \n:local deviceIdentityName         [/system identity get name];\r\
    \n:local deviceIdentityNameShort     [:pick \$deviceIdentityName 0 18]\r\
    \n:local deviceUpdateChannel         [/system package update get channel];\
    \r\
    \n\r\
    \n:local isOsUpdateAvailable     false;\r\
    \n:local isOsNeedsToBeUpdated    false;\r\
    \n\r\
    \n:local isSendEmailRequired    true;\r\
    \n\r\
    \n:local mailSubject           \"\$SMP Device - \$deviceIdentityNameShort.\
    \";\r\
    \n:local mailBody              \"\";\r\
    \n\r\
    \n:local mailBodyDeviceInfo    \"\\r\\n\\r\\nDevice information: \\r\\nIde\
    ntity: \$deviceIdentityName \\r\\nModel: \$deviceRbModel \\r\\nSerial numb\
    er: \$deviceRbSerialNumber \\r\\nCurrent RouterOS: \$deviceOsVerInst (\$[/\
    system package update get channel]) \$[/system resource get build-time] \\\
    r\\nCurrent routerboard FW: \$deviceRbCurrentFw \\r\\nDevice uptime: \$[/s\
    ystem resource get uptime]\";\r\
    \n:local mailBodyCopyright     \"\\r\\n\\r\\nMikrotik RouterOS automatic b\
    ackup & update (ver. \$scriptVersion) \\r\\nhttps://github.com/beeyev/Mikr\
    otik-RouterOS-automatic-backup-and-update\";\r\
    \n:local changelogUrl            (\"Check RouterOS changelog: https://mikr\
    otik.com/download/changelogs/\" . \$updateChannel . \"-release-tree\");\r\
    \n\r\
    \n:local backupName         \"v\$deviceOsVerInst_\$deviceUpdateChannel_\$d\
    ateTime\";\r\
    \n:local backupNameBeforeUpd    \"backup_before_update_\$backupName\";\r\
    \n:local backupNameAfterUpd    \"backup_after_update_\$backupName\";\r\
    \n\r\
    \n:local backupNameFinal        \$backupName;\r\
    \n:local mailAttachments        [:toarray \"\"];\r\
    \n\r\
    \n\r\
    \n:local updateStep \$buGlobalVarUpdateStep;\r\
    \n:do {/system script environment remove buGlobalVarUpdateStep;} on-error=\
    {}\r\
    \n:if ([:len \$updateStep] = 0) do={\r\
    \n    :set updateStep 1;\r\
    \n}\r\
    \n\r\
    \n\r\
    \n##     STEP ONE: Creating backups, checking for new RouterOs version and\
    \_sending email with backups,\r\
    \n##     steps 2 and 3 are fired only if script is set to automatically up\
    date device and if new RouterOs is available.\r\
    \n:if (\$updateStep = 1) do={\r\
    \n    :log info (\"\$SMP Performing the first step.\");   \r\
    \n\r\
    \n    # Checking for new RouterOS version\r\
    \n    if (\$scriptMode = \"osupdate\" or \$scriptMode = \"osnotify\") do={\
    \r\
    \n        log info (\"\$SMP Checking for new RouterOS version. Current ver\
    sion is: \$deviceOsVerInst\");\r\
    \n        /system package update set channel=\$updateChannel;\r\
    \n        /system package update check-for-updates;\r\
    \n        :delay 5s;\r\
    \n        :set deviceOsVerAvail [/system package update get latest-version\
    ];\r\
    \n\r\
    \n        # If there is a problem getting information about available Rout\
    erOS from server\r\
    \n        :if ([:len \$deviceOsVerAvail] = 0) do={\r\
    \n            :log warning (\"\$SMP There is a problem getting information\
    \_about new RouterOS from server.\");\r\
    \n            :set mailSubject    (\$mailSubject . \" Error: No data about\
    \_new RouterOS!\")\r\
    \n            :set mailBody         (\$mailBody . \"Error occured! \\r\\nM\
    ikrotik couldn't get any information about new RouterOS from server! \\r\\\
    nWatch additional information in device logs.\")\r\
    \n        } else={\r\
    \n            #Get numeric version of OS\r\
    \n            :set deviceOsVerAvailNum [\$buGlobalFuncGetOsVerNum paramOsV\
    er=\$deviceOsVerAvail];\r\
    \n\r\
    \n            # Checking if OS on server is greater than installed one.\r\
    \n            :if (\$deviceOsVerAvailNum > \$deviceOsVerInstNum) do={\r\
    \n                :set isOsUpdateAvailable true;\r\
    \n                :log info (\"\$SMP New RouterOS is available! \$deviceOs\
    VerAvail\");\r\
    \n            } else={\r\
    \n                :set isSendEmailRequired false;\r\
    \n                :log info (\"\$SMP System is already up to date.\");\r\
    \n                :set mailSubject (\$mailSubject . \" No new OS updates.\
    \");\r\
    \n                :set mailBody      (\$mailBody . \"Your system is up to \
    date.\");\r\
    \n            }\r\
    \n        };\r\
    \n    } else={\r\
    \n        :set scriptMode \"backup\";\r\
    \n    };\r\
    \n\r\
    \n    if (\$forceBackup = true) do={\r\
    \n        # In this case the script will always send email, because it has\
    \_to create backups\r\
    \n        :set isSendEmailRequired true;\r\
    \n    }\r\
    \n\r\
    \n    # if new OS version is available to install\r\
    \n    if (\$isOsUpdateAvailable = true and \$isSendEmailRequired = true) d\
    o={\r\
    \n        # If we only need to notify about new available version\r\
    \n        if (\$scriptMode = \"osnotify\") do={\r\
    \n            :set mailSubject     (\$mailSubject . \" New RouterOS is ava\
    ilable! v.\$deviceOsVerAvail.\")\r\
    \n            :set mailBody         (\$mailBody . \"New RouterOS version i\
    s available to install: v.\$deviceOsVerAvail (\$updateChannel) \\r\\n\$cha\
    ngelogUrl\")\r\
    \n        }\r\
    \n\r\
    \n        # if we need to initiate RouterOs update process\r\
    \n        if (\$scriptMode = \"osupdate\") do={\r\
    \n            :set isOsNeedsToBeUpdated true;\r\
    \n            # if we need to install only patch updates\r\
    \n            :if (\$installOnlyPatchUpdates = true) do={\r\
    \n                #Check if Major and Minor builds are the same.\r\
    \n                :if ([:pick \$deviceOsVerInstNum 0 ([:len \$deviceOsVerI\
    nstNum]-2)] = [:pick \$deviceOsVerAvailNum 0 ([:len \$deviceOsVerAvailNum]\
    -2)]) do={\r\
    \n                    :log info (\"\$SMP New patch version of RouterOS fir\
    mware is available.\");   \r\
    \n                } else={\r\
    \n                    :log info (\"\$SMP New major or minor version of Rou\
    terOS firmware is available. You need to update it manually.\");\r\
    \n                    :set mailSubject     (\$mailSubject . \" New RouterO\
    S: v.\$deviceOsVerAvail needs to be installed manually.\");\r\
    \n                    :set mailBody         (\$mailBody . \"New major or m\
    inor RouterOS version is available to install: v.\$deviceOsVerAvail (\$upd\
    ateChannel). \\r\\nYou chose to automatically install only patch updates, \
    so this major update you need to install manually. \\r\\n\$changelogUrl\")\
    ;\r\
    \n                    :set isOsNeedsToBeUpdated false;\r\
    \n                }\r\
    \n            }\r\
    \n\r\
    \n            #Check again, because this variable could be changed during \
    checking for installing only patch updats\r\
    \n            if (\$isOsNeedsToBeUpdated = true) do={\r\
    \n                :log info (\"\$SMP New RouterOS is going to be installed\
    ! v.\$deviceOsVerInst -> v.\$deviceOsVerAvail\");\r\
    \n                :set mailSubject    (\$mailSubject . \" New RouterOS is \
    going to be installed! v.\$deviceOsVerInst -> v.\$deviceOsVerAvail.\");\r\
    \n                :set mailBody         (\$mailBody . \"Your Mikrotik will\
    \_be updated to the new RouterOS version from v.\$deviceOsVerInst to v.\$d\
    eviceOsVerAvail (Update channel: \$updateChannel) \\r\\nFinal report with \
    the detailed information will be sent when update process is completed. \\\
    r\\nIf you have not received second email in the next 5 minutes, then prob\
    ably something went wrong. (Check your device logs)\");\r\
    \n                #!! There is more code connected to this part and first \
    step at the end of the script.\r\
    \n            }\r\
    \n        \r\
    \n        }\r\
    \n    }\r\
    \n\r\
    \n    ## Checking If the script needs to create a backup\r\
    \n    :log info (\"\$SMP Checking If the script needs to create a backup.\
    \");\r\
    \n    if (\$forceBackup = true or \$scriptMode = \"backup\" or \$isOsNeeds\
    ToBeUpdated = true) do={\r\
    \n        :log info (\"\$SMP Creating system backups.\");\r\
    \n        if (\$isOsNeedsToBeUpdated = true) do={\r\
    \n            :set backupNameFinal \$backupNameBeforeUpd;\r\
    \n        };\r\
    \n        if (\$scriptMode != \"backup\") do={\r\
    \n            :set mailBody (\$mailBody . \"\\r\\n\\r\\n\");\r\
    \n        };\r\
    \n\r\
    \n        :set mailSubject    (\$mailSubject . \" Backup was created.\");\
    \r\
    \n        :set mailBody        (\$mailBody . \"System backups were created\
    \_and attached to this email.\");\r\
    \n\r\
    \n        :set mailAttachments [\$buGlobalFuncCreateBackups backupName=\$b\
    ackupNameFinal backupPassword=\$backupPassword sensetiveDataInConfig=\$sen\
    setiveDataInConfig];\r\
    \n    } else={\r\
    \n        :log info (\"\$SMP There is no need to create a backup.\");\r\
    \n    }\r\
    \n\r\
    \n    # Combine fisrst step email\r\
    \n    :set mailBody (\$mailBody . \$mailBodyDeviceInfo . \$mailBodyCopyrig\
    ht);\r\
    \n}\r\
    \n\r\
    \n##     STEP TWO: (after first reboot) routerboard firmware upgrade\r\
    \n##     steps 2 and 3 are fired only if script is set to automatically up\
    date device and if new RouterOs is available.\r\
    \n:if (\$updateStep = 2) do={\r\
    \n    :log info (\"\$SMP Performing the second step.\");   \r\
    \n    ## RouterOS is the latest, let's check for upgraded routerboard firm\
    ware\r\
    \n    if (\$deviceRbCurrentFw != \$deviceRbUpgradeFw) do={\r\
    \n        :set isSendEmailRequired false;\r\
    \n        :delay 10s;\r\
    \n        :log info \"\$SMP Upgrading routerboard firmware from v.\$device\
    RbCurrentFw to v.\$deviceRbUpgradeFw\";\r\
    \n        ## Start the upgrading process\r\
    \n        /system routerboard upgrade;\r\
    \n        ## Wait until the upgrade is completed\r\
    \n        :delay 5s;\r\
    \n        :log info \"\$SMP routerboard upgrade process was completed, goi\
    ng to reboot in a moment!\";\r\
    \n        ## Set scheduled task to send final report on the next boot, tas\
    k will be deleted when is is done. (That is why you should keep original s\
    cript name)\r\
    \n        /system scheduler add name=BKPUPD-FINAL-REPORT-ON-NEXT-BOOT on-e\
    vent=\":delay 5s; /system scheduler remove BKPUPD-FINAL-REPORT-ON-NEXT-BOO\
    T; :global buGlobalVarUpdateStep 3; :delay 10s; /system script run BackupA\
    ndUpdate;\" start-time=startup interval=0;\r\
    \n        ## Reboot system to boot with new firmware\r\
    \n        /system reboot;\r\
    \n    } else={\r\
    \n        :log info \"\$SMP It appers that your routerboard is already up \
    to date, skipping this step.\";\r\
    \n        :set updateStep 3;\r\
    \n    };\r\
    \n}\r\
    \n\r\
    \n##     STEP THREE: Last step (after second reboot) sending final report\
    \r\
    \n##     steps 2 and 3 are fired only if script is set to automatically up\
    date device and if new RouterOs is available.\r\
    \n:if (\$updateStep = 3) do={\r\
    \n    :log info (\"\$SMP Performing the third step.\");   \r\
    \n    :log info \"Bkp&Upd: RouterOS and routerboard upgrade process was co\
    mpleted. New RouterOS version: v.\$deviceOsVerInst, routerboard firmware: \
    v.\$deviceRbCurrentFw.\";\r\
    \n    ## Small delay in case mikrotik needs some time to initialize connec\
    tions\r\
    \n    :log info \"\$SMP The final email with report and backups of upgrade\
    d system will be sent in a minute.\";\r\
    \n    :delay 1m;\r\
    \n    :set mailSubject    (\$mailSubject . \" RouterOS Upgrade is complete\
    d, new version: v.\$deviceOsVerInst!\");\r\
    \n    :set mailBody           \"RouterOS and routerboard upgrade process w\
    as completed. \\r\\nNew RouterOS version: v.\$deviceOsVerInst, routerboard\
    \_firmware: v.\$deviceRbCurrentFw. \\r\\n\$changelogUrl \\r\\n\\r\\nBackup\
    s of the upgraded system are in the attachment of this email.  \$mailBodyD\
    eviceInfo \$mailBodyCopyright\";\r\
    \n    :set mailAttachments [\$buGlobalFuncCreateBackups backupName=\$backu\
    pNameAfterUpd backupPassword=\$backupPassword sensetiveDataInConfig=\$sens\
    etiveDataInConfig];\r\
    \n}\r\
    \n\r\
    \n# Remove functions from global environment to keep it fresh and clean.\r\
    \n:do {/system script environment remove buGlobalFuncGetOsVerNum;} on-erro\
    r={}\r\
    \n:do {/system script environment remove buGlobalFuncCreateBackups;} on-er\
    ror={}\r\
    \n\r\
    \n##\r\
    \n## SENDING EMAIL\r\
    \n##\r\
    \n# Trying to send email with backups in attachment.\r\
    \n\r\
    \n:if (\$isSendEmailRequired = true) do={\r\
    \n    :log info \"\$SMP Sending email message, it will take around half a \
    minute...\";\r\
    \n    :do {/tool e-mail send to=\$emailAddress subject=\$mailSubject body=\
    \$mailBody file=\$mailAttachments;} on-error={\r\
    \n        :delay 5s;\r\
    \n        :log error \"\$SMP could not send email message (\$[/tool e-mail\
    \_get last-status]). Going to try it again in a while.\"\r\
    \n\r\
    \n        :delay 5m;\r\
    \n\r\
    \n        :do {/tool e-mail send to=\$emailAddress subject=\$mailSubject b\
    ody=\$mailBody file=\$mailAttachments;} on-error={\r\
    \n            :delay 5s;\r\
    \n            :log error \"\$SMP could not send email message (\$[/tool e-\
    mail get last-status]) for the second time.\"\r\
    \n\r\
    \n            if (\$isOsNeedsToBeUpdated = true) do={\r\
    \n                :set isOsNeedsToBeUpdated false;\r\
    \n                :log warning \"\$SMP script is not going to initialise u\
    pdate process due to inability to send backups to email.\"\r\
    \n            }\r\
    \n        }\r\
    \n    }\r\
    \n\r\
    \n    :delay 30s;\r\
    \n    \r\
    \n    :if ([:len \$mailAttachments] > 0 and [/tool e-mail get last-status]\
    \_= \"succeeded\") do={\r\
    \n        :log info \"\$SMP File system cleanup.\"\r\
    \n        /file remove \$mailAttachments; \r\
    \n        :delay 2s;\r\
    \n    }\r\
    \n    \r\
    \n}\r\
    \n\r\
    \n\r\
    \n# Fire RouterOs update process\r\
    \nif (\$isOsNeedsToBeUpdated = true) do={\r\
    \n\r\
    \n    ## Set scheduled task to upgrade routerboard firmware on the next bo\
    ot, task will be deleted when upgrade is done. (That is why you should kee\
    p original script name)\r\
    \n    /system scheduler add name=BKPUPD-UPGRADE-ON-NEXT-BOOT on-event=\":d\
    elay 5s; /system scheduler remove BKPUPD-UPGRADE-ON-NEXT-BOOT; :global buG\
    lobalVarUpdateStep 2; :delay 10s; /system script run BackupAndUpdate;\" st\
    art-time=startup interval=0;\r\
    \n   \r\
    \n   :log info \"\$SMP everything is ready to install new RouterOS, going \
    to reboot in a moment!\"\r\
    \n    ## command is reincarnation of the \"upgrade\" command - doing exact\
    ly the same but under a different name\r\
    \n    /system package update install;\r\
    \n}\r\
    \n\r\
    \n:log info \"\$SMP script \\\"Mikrotik RouterOS automatic backup & update\
    \\\" completed it's job.\\r\\n\";"
add dont-require-permissions=no name=WG_TSPU owner=admin policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=":\
    global Tx\r\
    \n:global Rx\r\
    \n/interface wireguard peers\r\
    \n:foreach i in=[find where disabled=yes and comment=TSPU] do={set \$i dis\
    abled=no}\r\
    \n:delay 1\r\
    \n/interface wireguard peers\r\
    \n:foreach i in=[find where disabled=no and comment=TSPU] do={\r\
    \n    :local LocalTx [get \$i tx]\r\
    \n    :local LocalRx [get \$i rx]\r\
    \n    :local LastHandshake [get \$i last-handshake]\r\
    \n    :if (([:tostr \$LastHandshake] = \"\") or ((\$LastHandshake > [:toti\
    me \"3m20s\"]) and (\$Rx->[:tostr \$i] = \$LocalRx))) do={\r\
    \n        :local PeerName [get \$i name]\r\
    \n        :local Interface [get \$i interface]\r\
    \n        :local EndpointAddress [get \$i endpoint-address]\r\
    \n        :local EndpointIP [get \$i current-endpoint-address]\r\
    \n        :local DstPort [get \$i current-endpoint-port]\r\
    \n        :local RawHeader [:rndstr length=4 from=123456789abcdef]\r\
    \n        \r\
    \n        #Reset source port\r\
    \n        /interface wireguard set \$Interface listen-port=0\r\
    \n        :local SrcPort [/interface wireguard get \$Interface listen-port\
    ]\r\
    \n        \r\
    \n        #Log peer info\r\
    \n        :log warning (\"Peer: \$PeerName, Interface: \$Interface\")\r\
    \n        :log warning (\"Endpoint Address: \$EndpointAddress, Endpoint IP\
    : \$EndpointIP\")\r\
    \n        :log warning (\"Src Port: \$SrcPort, Dst Port: \$DstPort, Last H\
    andshake: \$LastHandshake\")\r\
    \n        :log warning (\"Last Rx: \" . \$Rx->[:tostr \$i] . \", Current R\
    x: \$LocalRx\")\r\
    \n        :log warning (\"Last Tx: \" . \$Tx->[:tostr \$i] . \", Current T\
    x: \$LocalTx\")\r\
    \n        \r\
    \n        #Disable peer\r\
    \n        :log warning (\"Disable peer: \$PeerName\")\r\
    \n        set \$i disabled=yes\r\
    \n        :delay 1\r\
    \n        \r\
    \n        #Generating spam\r\
    \n        :log warning (\"Generating spam\")\r\
    \n        /tool traffic-generator stream remove [find]\r\
    \n        /tool traffic-generator packet-template remove [find]\r\
    \n        :delay 1\r\
    \n        /tool traffic-generator packet-template add header-stack=mac,ip,\
    udp,raw ip-dst=\$EndpointIP name=packet-template-wg raw-header=\$RawHeader\
    \_special-footer=no udp-dst-port=\$DstPort udp-src-port=\$SrcPort\r\
    \n        :delay 1\r\
    \n        /tool traffic-generator stream add disabled=no mbps=1 name=strea\
    m1 id=3 packet-size=1450 pps=0 tx-template=packet-template-wg\r\
    \n        :delay 1\r\
    \n        /tool traffic-generator quick duration=4\r\
    \n        \r\
    \n        #Enable peer\r\
    \n        :log warning (\"Enable peer: \$PeerName\")\r\
    \n        set \$i disabled=no\r\
    \n    }\r\
    \n    :set (\$Tx->[:tostr \$i]) \$LocalTx\r\
    \n    :set (\$Rx->[:tostr \$i]) \$LocalRx\r\
    \n}\r\
    \n"
add dont-require-permissions=no name=WG_TSPU2 owner=admin policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=":\
    local Jc 10\r\
    \n:local Jmin 50\r\
    \n:local Jmax 1280\r\
    \n:global Tx\r\
    \n:global Rx\r\
    \n/interface wireguard peers\r\
    \n:foreach i in=[find where disabled=yes and comment=TSPU] do={set \$i dis\
    abled=no}\r\
    \n:delay 100ms\r\
    \n/interface wireguard peers\r\
    \n:foreach i in=[find where comment=TSPU] do={\r\
    \n    :local LocalTx [get \$i tx]\r\
    \n    :local LocalRx [get \$i rx]\r\
    \n    :local LastHandshake [get \$i last-handshake]\r\
    \n    :if (([:tostr \$LastHandshake] = \"\") or ((\$LastHandshake > [:toti\
    me \"3m20s\"]) and (\$Rx->[:tostr \$i] = \$LocalRx))) do={\r\
    \n        :local PeerName [get \$i name]\r\
    \n        :local Interface [get \$i interface]\r\
    \n        :local EndpointAddress [get \$i endpoint-address]\r\
    \n        :local EndpointIP [get \$i current-endpoint-address]\r\
    \n        :local DstPort [get \$i current-endpoint-port]\r\
    \n        \r\
    \n        #Reset source port\r\
    \n        :local rndport [:rndnum from=49000 to=59999]\r\
    \n        /interface wireguard set \$Interface listen-port=\$rndport\r\
    \n        :local SrcPort [/interface wireguard get \$Interface listen-port\
    ]\r\
    \n        \r\
    \n        #Log peer info\r\
    \n        :log warning (\"Peer: \$PeerName, Interface: \$Interface\")\r\
    \n        :log warning (\"Endpoint Address: \$EndpointAddress, Endpoint IP\
    : \$EndpointIP\")\r\
    \n        :log warning (\"Src Port: \$SrcPort, Dst Port: \$DstPort, Last H\
    andshake: \$LastHandshake\")\r\
    \n        :log warning (\"Last Rx: \" . \$Rx->[:tostr \$i] . \", Current R\
    x: \$LocalRx\")\r\
    \n        :log warning (\"Last Tx: \" . \$Tx->[:tostr \$i] . \", Current T\
    x: \$LocalTx\")\r\
    \n        \r\
    \n        #Disable peer\r\
    \n        :log warning (\"Disable peer: \$PeerName\")\r\
    \n        set \$i disabled=yes\r\
    \n        :delay 100ms\r\
    \n        \r\
    \n        #Generating spam\r\
    \n        :log warning (\"Generating spam\")\r\
    \n        /tool/traffic-generator/stream/remove [find where name=stream-wg\
    \_or id=10]\r\
    \n        /tool traffic-generator packet-template remove [find where name=\
    packet-template-wg]\r\
    \n        :delay 1\r\
    \n        /tool traffic-generator packet-template add header-stack=mac,ip,\
    udp,raw ip-dst=\$EndpointIP name=packet-template-wg raw-header=1111 specia\
    l-footer=no udp-dst-port=\$DstPort udp-src-port=\$SrcPort\r\
    \n        :delay 1\r\
    \n        /tool traffic-generator stream add disabled=no mbps=1 name=strea\
    m-wg id=10 packet-size=100 pps=0 tx-template=packet-template-wg\r\
    \n        :for y from=1 to=\$Jc do={ \r\
    \n        :local rndsize [:rndnum from=\$Jmin to=\$Jmax]\r\
    \n        :local rnddelay [:rndnum from=50 to=300]\r\
    \n        :set \$rnddelay (\$rnddelay/1000);\r\
    \n        :local rndcountpacket [:rndnum from=1 to=5]\r\
    \n        :local RawHeader [:rndstr length=4 from=123456789abcdef]\r\
    \n        :delay 10ms\r\
    \n        /tool traffic-generator packet-template set packet-template-wg r\
    aw-header=\$RawHeader\r\
    \n        :delay 10ms\r\
    \n        /tool traffic-generator stream set stream-wg packet-size=\$rndsi\
    ze\r\
    \n        :delay 10ms\r\
    \n        /tool traffic-generator quick stream=stream-wg duration=\$rndcou\
    ntpacket\r\
    \n        :delay \$rnddelay\r\
    \n        }\r\
    \n        \r\
    \n        #Enable peer\r\
    \n        :log warning (\"Enable peer: \$PeerName\")\r\
    \n        set \$i disabled=no\r\
    \n    }\r\
    \n    :set (\$Tx->[:tostr \$i]) \$LocalTx\r\
    \n    :set (\$Rx->[:tostr \$i]) \$LocalRx\r\
    \n}\r\
    \n"
add dont-require-permissions=no name=WG_TSPU3 owner=admin policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=":\
    global Tx\r\
    \n:global Rx\r\
    \n/interface wireguard peers\r\
    \n:foreach i in=[find where disabled=yes and comment=TSPU] do={set \$i dis\
    abled=no}\r\
    \n:delay 1\r\
    \n/interface wireguard peers\r\
    \n:foreach i in=[find where disabled=no and comment=TSPU] do={\r\
    \n    :local LocalTx [get \$i tx]\r\
    \n    :local LocalRx [get \$i rx]\r\
    \n    :local LastHandshake [get \$i last-handshake]\r\
    \n    :if (([:tostr \$LastHandshake] = \"\") or ((\$LastHandshake > [:toti\
    me \"3m20s\"]) and (\$Rx->[:tostr \$i] = \$LocalRx))) do={\r\
    \n        :local PeerName [get \$i name]\r\
    \n        :local Interface [get \$i interface]\r\
    \n        :local EndpointAddress [get \$i endpoint-address]\r\
    \n        :local EndpointIP [get \$i current-endpoint-address]\r\
    \n        :local DstPort [get \$i current-endpoint-port]\r\
    \n        \r\
    \n        # \CC\E0\F1\F1\E8\E2 IP \E0\E4\F0\E5\F1\EE\E2 WARP\r\
    \n        :local WarpIPs {\"162.159.192.1\";\"162.159.192.2\";\"162.159.19\
    2.3\";\"162.159.192.4\";\"162.159.192.5\";\"162.159.192.6\";\"162.159.192.\
    7\";\"162.159.192.8\";\"162.159.192.9\";\"162.159.192.10\";\"162.159.193.1\
    \";\"162.159.193.2\";\"162.159.193.3\";\"162.159.193.4\";\"162.159.193.5\"\
    }\r\
    \n        \r\
    \n        # \CC\E0\F1\F1\E8\E2 \EF\EE\F0\F2\EE\E2 WARP\r\
    \n        :local WarpPorts {500;854;859;864;878;880;890;891;894;903;908;92\
    8;934;939;942;943;945;946;955;968;987;988;1002;1010;1014;1018;1070;1074;11\
    80;1387;1843;2371;2408;2506;3138;3476;3581;3854;4177;4198;4233;5279;5956;7\
    103;7152;7156;7281;7559;8319;8742;8854;8886}\r\
    \n        \r\
    \n        # \C2\FB\E1\E8\F0\E0\E5\EC \F1\EB\F3\F7\E0\E9\ED\FB\E9 IP \E8 \
    \EF\EE\F0\F2\r\
    \n        :local RandomIP [:pick \$WarpIPs [:rndnum from=0 to=[:len \$Warp\
    IPs]]]\r\
    \n        :local RandomPort [:pick \$WarpPorts [:rndnum from=0 to=[:len \$\
    WarpPorts]]]\r\
    \n        \r\
    \n        :local RawHeader [:rndstr length=4 from=123456789abcdef]\r\
    \n        \r\
    \n        #Reset source port\r\
    \n        /interface wireguard set \$Interface listen-port=0\r\
    \n        :local SrcPort [/interface wireguard get \$Interface listen-port\
    ]\r\
    \n        \r\
    \n        #Log peer info\r\
    \n        :log warning (\"Peer: \$PeerName, Interface: \$Interface\")\r\
    \n        :log warning (\"Endpoint Address: \$EndpointAddress, Endpoint IP\
    : \$EndpointIP\")\r\
    \n        :log warning (\"Switching to IP: \$RandomIP, Port: \$RandomPort\
    \")\r\
    \n        :log warning (\"Src Port: \$SrcPort, Dst Port: \$DstPort, Last H\
    andshake: \$LastHandshake\")\r\
    \n        :log warning (\"Last Rx: \" . \$Rx->[:tostr \$i] . \", Current R\
    x: \$LocalRx\")\r\
    \n        :log warning (\"Last Tx: \" . \$Tx->[:tostr \$i] . \", Current T\
    x: \$LocalTx\")\r\
    \n        \r\
    \n        #Disable peer\r\
    \n        :log warning (\"Disable peer: \$PeerName\")\r\
    \n        set \$i disabled=yes\r\
    \n        :delay 1\r\
    \n        \r\
    \n        # \CC\E5\ED\FF\E5\EC endpoint\r\
    \n        /interface wireguard peers set \$i endpoint-address=\$RandomIP e\
    ndpoint-port=\$RandomPort\r\
    \n        :delay 2\r\
    \n        :set EndpointIP \$RandomIP\r\
    \n        :set DstPort \$RandomPort\r\
    \n        \r\
    \n        #Generating spam\r\
    \n        :log warning (\"Generating spam\")\r\
    \n        /tool traffic-generator stream remove [find]\r\
    \n        /tool traffic-generator packet-template remove [find]\r\
    \n        :delay 1\r\
    \n        /tool traffic-generator packet-template add header-stack=mac,ip,\
    udp,raw ip-dst=\$EndpointIP name=packet-template-wg raw-header=\$RawHeader\
    \_special-footer=no udp-dst-port=\$DstPort udp-src-port=\$SrcPort\r\
    \n        :delay 1\r\
    \n        /tool traffic-generator stream add disabled=no mbps=2 name=strea\
    m1 id=3 packet-size=1450 pps=0 tx-template=packet-template-wg\r\
    \n        :delay 1\r\
    \n        /tool traffic-generator quick duration=6\r\
    \n        \r\
    \n        #Enable peer\r\
    \n        :log warning (\"Enable peer: \$PeerName\")\r\
    \n        set \$i disabled=no\r\
    \n    }\r\
    \n    :set (\$Tx->[:tostr \$i]) \$LocalTx\r\
    \n    :set (\$Rx->[:tostr \$i]) \$LocalRx\r\
    \n}"
add dont-require-permissions=no name=update-cyberok-list owner=admin policy=\
    ftp,read,write,test source="\r\
    \n:local listName \"cyberok-ban\"\r\
    \n:local url \"https://raw.githubusercontent.com/tread-lightly/CyberOK_Ski\
    pa_ips/main/lists/skipa_cidr.txt\"\r\
    \n:local fileName \"cyberok-temp.txt\"\r\
    \n\r\
    \n:log info \"CyberOK: Start update\"\r\
    \n\r\
    \n:do {\r\
    \n/tool fetch url=\$url mode=https dst-path=\$fileName\r\
    \n:log info \"CyberOK: File downloaded\"\r\
    \n} on-error={\r\
    \n:log error \"CyberOK: Download failed\"\r\
    \n:error \"Download failed\"\r\
    \n}\r\
    \n\r\
    \n:delay 3s\r\
    \n\r\
    \n:if ([:len [/file find name=\$fileName]] = 0) do={\r\
    \n:log error \"CyberOK: File not found\"\r\
    \n:error \"File not found\"\r\
    \n}\r\
    \n\r\
    \n:log info \"CyberOK: Removing old list\"\r\
    \n/ip firewall address-list remove [find where list=\$listName]\r\
    \n\r\
    \n:log info \"CyberOK: Adding new IPs\"\r\
    \n:local content [/file get \$fileName contents]\r\
    \n:local lineStart 0\r\
    \n:local lineEnd 0\r\
    \n:local line \"\"\r\
    \n:local countAdded 0\r\
    \n\r\
    \n:for i from=0 to=([:len \$content] - 1) do={\r\
    \n:local char [:pick \$content \$i]\r\
    \n:if (\$char = \"\\n\") do={\r\
    \n:set lineEnd \$i\r\
    \n:set line [:pick \$content \$lineStart \$lineEnd]\r\
    \n:if ([:pick \$line ([:len \$line] - 1)] = \"\\r\") do={\r\
    \n:set line [:pick \$line 0 ([:len \$line] - 1)]\r\
    \n}\r\
    \n:if ([:len \$line] > 7) do={\r\
    \n:do {\r\
    \n/ip firewall address-list add list=\$listName address=\$line\r\
    \n:set countAdded (\$countAdded + 1)\r\
    \n} on-error={}\r\
    \n}\r\
    \n:set lineStart (\$i + 1)\r\
    \n}\r\
    \n}\r\
    \n\r\
    \n:if (\$lineStart < [:len \$content]) do={\r\
    \n:set line [:pick \$content \$lineStart [:len \$content]]\r\
    \n:if ([:len \$line] > 7) do={\r\
    \n:do {\r\
    \n/ip firewall address-list add list=\$listName address=\$line\r\
    \n:set countAdded (\$countAdded + 1)\r\
    \n} on-error={}\r\
    \n}\r\
    \n}\r\
    \n\r\
    \n/file remove \$fileName\r\
    \n\r\
    \n:local logMsg (\"CyberOK: Update done. Added: \" . \$countAdded)\r\
    \n:log info \$logMsg\r\
    \n"
/tool e-mail
set from="\CC\E0\EC\E0 \EC\E8\EA\F0\EE\F2\E8\EA <dddhub@mail.ru>" port=587 \
    server=smtp.mail.ru tls=starttls user=dddhub@mail.ru
/tool mac-server
set allowed-interface-list=LAN
/tool mac-server mac-winbox
set allowed-interface-list=LAN
/tool sniffer
set filter-interface=bridge filter-ip-protocol=tcp filter-port=ms-wbt-server
/tool traffic-generator packet-template
add header-stack=mac,ip,udp,raw ip-dst=162.159.192.8 name=packet-template-wg \
    raw-header=1214 special-footer=no udp-dst-port=3581 udp-src-port=52281
/tool traffic-generator stream
add id=3 mbps=2 name=stream1 packet-size=1450 tx-template=packet-template-wg