# 2026-01-10 19:46:27 by RouterOS 7.20.6
# software id = E05L-801M
#
# model = RB5009UPr+S+
# serial number = HE108XXNBD5
/interface bridge
add name=Bridge-Docker port-cost-mode=short
add admin-mac=48:A9:8A:34:7C:E6 auto-mac=no dhcp-snooping=yes \
    ingress-filtering=no max-learned-entries=1000 name=bridge1 \
    port-cost-mode=short vlan-filtering=yes
/interface ethernet
set [ find default-name=ether1 ] mac-address=D4:CA:6D:0D:FD:28
set [ find default-name=ether6 ] poe-out=off
set [ find default-name=sfp-sfpplus1 ] sfp-rate-select=low
/interface pppoe-client
add add-default-route=yes disabled=no interface=ether1 keepalive-timeout=60 \
    name=pppoe-out1 user=6540820-136-487
/interface veth
add address=192.168.254.3/24 dhcp=no gateway=192.168.254.1 gateway6="" \
    mac-address=56:34:80:8B:67:D7 name=MIHOMO
add address=192.168.254.4/24 dhcp=no gateway=192.168.254.1 gateway6="" \
    mac-address=52:FC:27:EA:A6:97 name=MIHOMO2
add address=192.168.254.5/24 dhcp=no gateway=192.168.254.1 gateway6="" \
    mac-address=62:72:E1:C8:2A:10 name=MIHOMO3
add address=192.168.254.6/24 dhcp=no gateway=192.168.254.1 gateway6="" \
    mac-address=58:BF:5E:20:C5:DD name=NFQWS2
/interface wireguard
add listen-port=51820 mtu=1400 name=WG_Home
/interface vlan
add interface=ether1 name=vlan1 vlan-id=22
add interface=bridge1 name=vlan100-guest vlan-id=100
/container mounts
add dst=/etc/amnezia/amneziawg name=amnezia_wg_conf src=\
    usb1-part1/docker_configs/amnezia_wg_conf
add dst=/etc/mihomo/awg name=MIHOMO_AWG src=\
    usb1/docker_configs/mihomo_mikrotik/awg
add dst=/etc/mihomo name=MIHOMO_CONFIG src=\
    usb1/docker_configs/mihomo_mikrotik
add dst=/etc/mihomo/awg name=proton_wg_conf src=\
    usb1/docker_configs/mihomo_mikrotik/proton
add dst=/etc/mihomo name=test_manual_conf src=usb1/docker_configs/test_manual
add dst=/etc/mihomo name=test_super_test_conf src=\
    usb1/smb_share/docker_configs/test_super_test
/disk
add parent=usb1 partition-number=1 partition-offset=1048576 partition-size=\
    2000397795328 type=partition
/interface list
add comment=defconf name=WAN
add comment=defconf name=LAN
add name=VPN-OUT
add name=GUEST
add name=LAN_and_GUEST
/interface lte apn
set [ find default=yes ] ip-type=ipv4 use-network-apn=no
/interface wireless security-profiles
set [ find default=yes ] supplicant-identity=MikroTik
/ip dns forwarders
add doh-servers=https://dns.google/dns-query name=Google
add doh-servers=https://dns.comss.one/mikrotik name=Comss
add doh-servers=https://cloudflare-dns.com/dns-query name=CloudFlare
add doh-servers=https://dns.quad9.net/dns-query name=Quad9
/ip ipsec proposal
set [ find default=yes ] enc-algorithms=aes-256-cbc,aes-256-ctr,3des
/ip pool
add name=dhcp ranges=192.168.0.11-192.168.0.254
add name=guest-pool ranges=192.168.100.10-192.168.100.254
/ip dhcp-server
add address-pool=dhcp interface=bridge1 lease-script=":if (\$leaseBound =1) do\
    ={\r\
    \n    /ip dhcp-server lease;\r\
    \n\t:foreach i in=[find dynamic=yes] do={\r\
    \n\r\
    \n\r\
    \n:local dhcpip \r\
    \n\t\t:set dhcpip [ get \$i address ];\r\
    \n\t\t:local clientid\r\
    \n\t\t:set clientid [get \$i host-name];\r\
    \n \r\
    \n\t\t:if (\$leaseActIP = \$dhcpip) do={\r\
    \n    # Variables\r\
    \n    :local Time [/system clock get time];\r\
    \n    :local Date [/system clock get date];\r\
    \n    :local Comment [/ip dhcp-server lease get value-name=comment number=\
    [/ip dhcp-server lease find address=\$leaseActIP]]\r\
    \n    :local DeviceName [/system identity get name];\r\
    \n\r\
    \n    # START Send Telegram Module\r\
    \n    :local MessageText \"\\F0\\9F\\9F\\A2 <b>\$DeviceName: New DHCP clie\
    nt</b> %0D%0A <b>Name:</b> \$\"lease-hostname\" %0D%0A <b>Comment:</b> [\$\
    Comment] %0D%0A <b>Interface:</b> \$leaseServerName %0D%0A <b>IP:</b> \$le\
    aseActIP %0D%0A <b>MAC:</b> \$leaseActMAC\";\r\
    \n    :local SendTelegramMessage [:parse [/system script  get MyTGBotSendM\
    essage source]]; \r\
    \n    \$SendTelegramMessage MessageText=\$MessageText;\r\
    \n    #END Send Telegram Module\r\
    \n}\r\
    \n}\r\
    \n}" lease-time=3d10m name=defconf
add address-pool=guest-pool interface=vlan100-guest name=guest-dhcp
/ip smb users
set [ find default=yes ] read-only=no
add name=smbuser
/ppp profile
set *FFFFFFFE local-address=dhcp remote-address=dhcp
/queue type
add kind=fq-codel name=queue1
/routing bgp template
set default disabled=no output.network=bgp-networks
/routing ospf instance
add disabled=no name=default-v2
add disabled=no name=default-v3 version=3
/routing ospf area
add disabled=yes instance=default-v2 name=backbone-v2
add disabled=yes instance=default-v3 name=backbone-v3
/routing table
add fib name=BlackList_EU
add fib name=BlackList_RU
add fib name=RDP-Server
add fib name=vpn-all-table
add disabled=no fib name=to_nfqws2
/snmp community
set [ find default=yes ] addresses=192.168.0.14/32 authentication-protocol=\
    SHA1 security=private
/system logging action
set 3 remote=192.168.0.82 remote-log-format=syslog remote-port=5514 \
    syslog-time-format=iso8601
/user group
add name=ssh-rdp policy="ssh,!local,!telnet,!ftp,!reboot,!read,!write,!policy,\
    !test,!winbox,!password,!web,!sniff,!sensitive,!api,!romon,!rest-api"
/certificate settings
set builtin-trust-anchors=not-trusted
/container
add dns=192.168.254.1 envlists=MIHOMO interface=MIHOMO mounts=MIHOMO_CONFIG \
    name=MIHOMO remote-image=wiktorbgu/mihomo-mikrotik:latest root-dir=\
    usb1/docker/mihomo-mikrotik workdir=/
add dns=192.168.254.1 envlists=MIHOMO2 interface=MIHOMO2 name=\
    mihomo-mikrotik-2 remote-image=wiktorbgu/mihomo-mikrotik:latest root-dir=\
    usb1/docker/mihomo2 workdir=/
add dns=192.168.254.1 envlists=Germany interface=MIHOMO3 mounts=\
    proton_wg_conf name="Proton Only" remote-image=\
    wiktorbgu/mihomo-mikrotik:latest root-dir=usb1/docker/mihomo3 workdir=/
# exited with status 1
add dns=192.168.254.1 interface=NFQWS2 logging=yes name=\
    nfqws2-mikrotik:latest remote-image=wiktorbgu/nfqws2-mikrotik:latest \
    root-dir=usb1-part1/smb_share/docker/NFQWS2 start-on-boot=yes workdir=/
/container config
set registry-url=https://registry-1.docker.io tmpdir=/usb1/docker/pull
/container envs
add key=CONFIG list=Germany value=custom_config.yaml
add key=SRV1 list=Germany value="trojan://BxceQaOe@58.152.30.175:443\?security\
    =tls&sni=58.152.30.175&allowInsecure=1&type=tcp&headerType=none#t.me/v2Lin\
    e | Free | 3097 | Hong Kong"
add key=CONFIG list=MIHOMO value=custom.yaml
add key=SRV1 list=MIHOMO value="vless://b5f4e3a2-9c8d-4f7a-8e6b-1a3d5c7b9f2e@1\
    76.9.141.234:2054\?encryption=none&flow=xtls-rprx-vision&security=reality&\
    sni=www.google.com&fp=chrome&pbk=j92tntLc26sEHfL85mkRJCcrjq9PSbDPzhcYnniM8\
    ys&sid=a1b2c3d4e5f6&type=tcp&headerType=none#RealityGoogle"
add key=CONFIG list=MIHOMO2 value=custom.yaml
add key=SRV1 list=MIHOMO2 value="vless://b5f4e3a2-9c8d-4f7a-8e6b-1a3d5c7b9f2e@\
    176.9.141.234:2054\?encryption=none&flow=xtls-rprx-vision&security=reality\
    &sni=www.google.com&fp=chrome&pbk=j92tntLc26sEHfL85mkRJCcrjq9PSbDPzhcYnniM\
    8ys&sid=a1b2c3d4e5f6&type=tcp&headerType=none#RealityGoogle"
add key=CONFIG list=test_manual_env value=custom_config.yaml
add key=CONFIG list=test_super_test_env value=custom_config.yaml
/ip smb
set enabled=yes interfaces=bridge1
/interface bridge port
add bridge=bridge1 hw=no interface=ether6 internal-path-cost=10 path-cost=10
add bridge=bridge1 hw=no ingress-filtering=no interface=ether7 \
    internal-path-cost=10 path-cost=10
add bridge=bridge1 hw=no interface=ether8 internal-path-cost=10 path-cost=10
add bridge=bridge1 comment=defconf hw=no ingress-filtering=no interface=\
    ether2 internal-path-cost=10 path-cost=10
add bridge=bridge1 comment=defconf hw=no ingress-filtering=no interface=\
    ether3 internal-path-cost=10 path-cost=10
add bridge=bridge1 comment=defconf hw=no ingress-filtering=no interface=\
    ether4 internal-path-cost=10 path-cost=10
add bridge=bridge1 comment=defconf hw=no ingress-filtering=no interface=\
    ether5 internal-path-cost=10 path-cost=10
add bridge=bridge1 disabled=yes interface=ether1 internal-path-cost=10 \
    path-cost=10
add bridge=bridge1 hw=no interface=sfp-sfpplus1 internal-path-cost=10 \
    path-cost=10
add bridge=Bridge-Docker interface=MIHOMO
add bridge=Bridge-Docker interface=MIHOMO2
add bridge=Bridge-Docker interface=MIHOMO3
add bridge=Bridge-Docker interface=NFQWS2
/ip firewall connection tracking
set enabled=yes
/ipv6 settings
set accept-router-advertisements=no disable-ipv6=yes
/interface bridge vlan
add bridge=bridge1 tagged=ether8,bridge1 vlan-ids=100
/interface l2tp-server server
set allow-fast-path=yes authentication=mschap2 default-profile=*1
/interface list member
add interface=pppoe-out1 list=WAN
add interface=bridge1 list=LAN
add interface=WG_Home list=LAN
add disabled=yes interface=MIHOMO list=VPN-OUT
add disabled=yes interface=MIHOMO2 list=VPN-OUT
add interface=Bridge-Docker list=VPN-OUT
add interface=vlan100-guest list=GUEST
add interface=WG_Home list=LAN_and_GUEST
add interface=vlan100-guest list=LAN_and_GUEST
add interface=bridge1 list=LAN_and_GUEST
/interface ovpn-server server
add auth=sha1,md5 mac-address=FE:61:74:1D:82:9D name=ovpn-server1
/interface pptp-server server
# PPTP connections are considered unsafe, it is suggested to use a more modern VP
N protocol instead
set authentication=mschap2 default-profile=*1
/interface wireguard peers
add allowed-address=10.101.101.3/32 client-address=10.101.101.3/32 \
    client-dns=10.101.101.1 client-endpoint=212.20.46.209 client-keepalive=2m \
    interface=WG_Home name=Macbook persistent-keepalive=2m preshared-key=\
    "AMr1/5yyzynmEk1dDrjgJOaCgr6+kkkZsG7w6qCaRmw=" private-key=\
    "WNmdpg/k1BGuMjAjDPGNxDiujKdkLPq4uzeLw0xKbHk=" public-key=\
    "sCMZ+otOZEZodqwJj0mn0ecV+bTY+i5wCAmNxCM7tSI=" responder=yes
add allowed-address=10.101.101.4/32 client-address=10.101.101.4/32 \
    client-dns=10.101.101.1 client-endpoint=212.20.46.209 client-keepalive=2m \
    interface=WG_Home name=Ipod persistent-keepalive=2m preshared-key=\
    "2IuhrP49eSzV/mGxKT9nDAU/1Q5MmJTbnKOEh6zsM0k=" private-key=\
    "kKftCmlPYUuJRB7oYIcMwvNWnurZTSNVXVroWWPSikc=" public-key=\
    "IPrvIaNVSUIymc63RYqJGCbLP2AdHJLhGBaihosTHlM=" responder=yes
add allowed-address=10.101.101.5/32 client-address=10.101.101.5/32 \
    client-dns=10.101.101.1 client-endpoint=212.20.46.209 client-keepalive=2m \
    comment="Mama iphone" interface=WG_Home name="mama iphone" \
    persistent-keepalive=2m private-key=\
    "eJoW38NoDX6tb8pOIFDtypiiWy1eSjivPJhF23FjLHc=" public-key=\
    "DiB4lT88spVG/7JCLVkPBqw7c/G/kBQgJB13GY8+tzA=" responder=yes
add allowed-address=10.101.101.6/32 client-address=10.101.101.6/32 \
    client-dns=10.101.101.1 client-endpoint=212.20.46.209 client-keepalive=2m \
    comment="Mama iphone" interface=WG_Home name="mama ipad" \
    persistent-keepalive=2m private-key=\
    "KHguo9qVJGYTr1r5DOUaGTXx1CJp/l3Gv3Llr2DInlc=" public-key=\
    "tnD3EEm3zrbk7Gj4yqIYOzTRF4tfVKCD+SmGaYdWGDA=" responder=yes
add allowed-address=10.101.101.2/32 client-address=10.101.101.2/32 \
    client-dns=10.101.101.1 client-endpoint=212.20.46.209 client-keepalive=2m \
    interface=WG_Home name="Iphone 14 pro max" persistent-keepalive=2m \
    preshared-key="UPCYUl+kt/sH/rMlt36JEKXgiCLb9S8FipuZrSMgIVQ=" private-key=\
    "EAhS3aqJip7QPTxPBUZGC0cn1dxypBJy52w9wZW3U3A=" public-key=\
    "yx2WIiRTBb0AaJ2b4QLt0gDQk29TigP3x4zRIfWzwlc=" responder=yes
add allowed-address=10.101.101.0/24,10.200.200.0/24 comment="Mama router" \
    interface=WG_Home name=Mama_router_peer persistent-keepalive=2m \
    preshared-key="UPCYUl+kt/sH/rMlt36JEKXgiCLb9S8FipuZrSMgIVQ=" public-key=\
    "VCqD4aQWT7v1p/AhTR8KzyN/SIY0/QsySqAZkfBePBE="
/ip address
add address=192.168.0.1/24 comment=Main1 interface=bridge1 network=\
    192.168.0.0
add address=10.101.101.1/24 interface=WG_Home network=10.101.101.0
add address=192.168.254.1/24 interface=Bridge-Docker network=192.168.254.0
add address=192.168.100.1/24 interface=vlan100-guest network=192.168.100.0
add address=10.101.101.200 comment="Video server access point LOCAL" \
    interface=bridge1 network=10.101.101.200
add address=10.200.200.1/24 comment="NETMAP for WG clients" interface=bridge1 \
    network=10.200.200.0
/ip cloud
set ddns-enabled=yes
/ip dhcp-client
add disabled=yes interface=sfp-sfpplus1
/ip dhcp-server lease
add address=192.168.0.252 mac-address=48:33:DD:00:B6:E6 server=defconf
add address=192.168.0.245 mac-address=54:10:EC:EF:67:0A server=defconf
add address=192.168.0.244 comment=MDT mac-address=00:05:26:82:14:3C server=\
    defconf
add address=192.168.0.241 client-id=1:70:8b:cd:82:29:5f mac-address=\
    70:8B:CD:82:29:5F server=defconf
add address=192.168.0.243 client-id=1:24:4b:fe:55:7b:e comment=\
    "\C2\E8\E4\E5\EE\F1\E5\F0\E2\E5\F0" mac-address=24:4B:FE:55:7B:0E server=\
    defconf
add address=192.168.0.254 client-id=1:0:c:29:7a:a4:1d comment=\
    "\C8\F0\E8\E4\E8\F3\EC" mac-address=00:0C:29:7A:A4:1D server=defconf
add address=192.168.0.238 comment="\CF\E0\F0\EE\E2\E0\F0\EA\E0" mac-address=\
    00:1D:63:26:BB:97 server=defconf
add address=192.168.0.235 comment="\CF\EE\F1\F3\E4\E0\EC\EE\E9\EA\E0" \
    mac-address=00:1D:63:2E:8A:D2 server=defconf
add address=192.168.0.234 comment="\C4\F3\F5\EE\E2\EA\E0" mac-address=\
    00:1D:63:2B:5C:65 server=defconf
add address=192.168.0.233 comment="\D1\F2\E8\F0\E0\EB\EA\E0" mac-address=\
    00:1D:63:30:3E:CC server=defconf
add address=192.168.0.232 comment="\D1\F3\F8\E8\EB\EA\E0" mac-address=\
    00:1D:63:2D:8A:67 server=defconf
add address=192.168.0.231 comment="\D3\EC\FF\E3\F7\E8\F2\E5\EB\FC" \
    mac-address=00:35:FF:08:32:27 server=defconf
add address=192.168.0.253 client-id=1:4c:bb:58:23:3:5b comment=\
    "\CC\EE\E9 \ED\EE\F3\F2" mac-address=4C:BB:58:23:03:5B server=defconf
add address=192.168.0.247 client-id=1:0:30:1b:ba:2:db comment=\
    "\C4\EE\EC\EE\F4\EE\ED" mac-address=00:30:1B:BA:02:DB server=defconf
add address=192.168.0.226 client-id=1:ec:2e:98:66:41:79 comment=\
    "\CD\EE\F3\F2 \F3\EC\ED\FB\E9 \E4\EE\EC" disabled=yes mac-address=\
    EC:2E:98:66:41:79 server=defconf
add address=192.168.0.223 comment="Daikin \EA\E0\E1\E8\ED\E5\F2" mac-address=\
    24:CD:8D:C7:D0:B0 server=defconf
add address=192.168.0.221 comment="Daikin \F1\EF\E0\EB\FC\ED\FF" mac-address=\
    24:CD:8D:C7:F4:92 server=defconf
add address=192.168.0.220 comment="Daikin \E3\EE\F1\F2\E5\E2\E0\FF" \
    mac-address=E8:4F:25:D3:09:DC server=defconf
add address=192.168.0.225 client-id=1:ec:d:e4:eb:fb:fc comment=\
    "\D7\E8\F2\E0\EB\EA\E0 Amazon" mac-address=EC:0D:E4:EB:FB:FC server=\
    defconf
add address=192.168.0.246 client-id=1:0:a:5c:81:1d:52 comment=\
    "\D3\E2\EB\E0\E6\ED\E8\F2\E5\EB\FC Carel" mac-address=00:0A:5C:81:1D:52 \
    server=defconf
add address=192.168.0.216 client-id=1:0:46:a8:1b:ae:55 lease-time=7h \
    mac-address=00:46:A8:1B:AE:55 server=defconf
add address=192.168.0.218 client-id=1:b0:4a:39:58:c4:1c lease-time=7h \
    mac-address=B0:4A:39:58:C4:1C server=defconf
add address=192.168.0.249 client-id=1:f6:64:7f:9b:4a:16 mac-address=\
    F6:64:7F:9B:4A:16 server=defconf
add address=192.168.0.197 client-id=1:14:dd:a9:d6:da:47 mac-address=\
    14:DD:A9:D6:DA:47 server=defconf
add address=192.168.0.33 comment="\D1\E0\E9\F2 \E7\E4\EE\F0\EE\E2\FC\FF" \
    mac-address=00:0C:29:5E:35:32 server=defconf
add address=192.168.0.90 client-id=1:60:a4:4c:d0:3a:54 mac-address=\
    60:A4:4C:D0:3A:54 server=defconf
add address=192.168.0.16 comment="Daikin \C7\E0\EB" mac-address=\
    9C:50:D1:49:E0:5E server=defconf
add address=192.168.0.13 client-id=1:28:2:2e:31:fe:86 comment="iphone 14" \
    mac-address=28:02:2E:31:FE:86 server=defconf
add address=192.168.0.34 client-id=1:0:c:29:12:a1:60 mac-address=\
    00:0C:29:12:A1:60 server=defconf
add address=192.168.0.14 client-id=\
    ff:29:47:57:93:0:1:0:1:2b:a3:d9:18:0:c:29:dd:eb:fa mac-address=\
    00:0C:29:47:57:93 server=defconf
add address=192.168.0.11 client-id=1:60:22:32:48:28:a0 mac-address=\
    60:22:32:48:28:A0 server=defconf
add address=192.168.0.21 client-id=1:e:17:79:98:2d:38 comment=\
    "Iphone 14 pro max" mac-address=0E:17:79:98:2D:38 server=defconf
add address=192.168.0.22 client-id=1:1e:e4:f6:a3:c:53 mac-address=\
    1E:E4:F6:A3:0C:53 server=defconf
add address=192.168.0.17 client-id=1:0:c:29:8b:83:cf mac-address=\
    00:0C:29:8B:83:CF server=defconf
add address=192.168.0.15 mac-address=A6:4C:5E:E6:37:89 server=defconf
add address=192.168.0.19 client-id=1:1c:57:dc:6b:8e:d4 comment=Macbook \
    mac-address=1C:57:DC:6B:8E:D4 server=defconf
add address=192.168.0.23 client-id=1:0:c:29:e3:c:75 mac-address=\
    00:0C:29:E3:0C:75 server=defconf
add address=192.168.0.32 client-id=1:6c:1c:71:d8:84:e1 comment=Hoz_room_cam \
    mac-address=6C:1C:71:D8:84:E1 server=defconf
add address=192.168.0.26 client-id=1:f0:23:b9:45:b7:e1 comment=\
    "\CA\E0\EC\E5\F0\E0 \E3\E0\F0\E4\E5\F0\EE\E1" mac-address=\
    F0:23:B9:45:B7:E1 server=defconf
add address=192.168.0.248 client-id=1:14:dd:a9:d6:da:46 mac-address=\
    14:DD:A9:D6:DA:46 server=defconf
add address=192.168.0.20 mac-address=A6:4C:5E:E6:77:FD server=defconf
add address=192.168.0.40 client-id=1:c:9a:3c:1b:7c:31 comment=\
    "\D7\E5\F0\ED\E0\FF \EF\E5\F0\E2\E0\FF \F1\EF\E0\EB\FC\ED\FF" \
    mac-address=0C:9A:3C:1B:7C:31 server=defconf
add address=192.168.0.88 client-id=ff:6e:11:fa:24:0:3:0:1:b8:87:6e:11:fa:24 \
    comment="\C3\EE\F1\F2\E5\E2\E0\FF" mac-address=B8:87:6E:11:FA:24 server=\
    defconf
add address=192.168.0.44 client-id=ff:6e:21:d7:a2:0:3:0:1:b8:87:6e:21:d7:a2 \
    comment="\C4\F3\F8" mac-address=B8:87:6E:21:D7:A2 server=defconf
add address=192.168.0.42 comment="\CB\E0\EC\EF\EE\F7\EA\E0 \E4\F3\F87" \
    mac-address=D8:1F:12:59:E1:14 server=defconf
add address=192.168.0.36 comment="\CB\E0\EC\EF\EE\F7\EA\E0 \E4\F3\F88" \
    mac-address=D8:1F:12:59:A8:BA server=defconf
add address=192.168.0.43 comment="\CB\E0\EC\EF\EE\F7\EA\E0 \E4\F3\F86" \
    mac-address=D8:1F:12:59:C1:21 server=defconf
add address=192.168.0.29 client-id=1:3c:b:4f:42:13:f1 comment=\
    "\C1\E5\E6\E5\E2\E0\FF1 \F1\EF\E0\EB\FC\ED\FF" mac-address=\
    3C:0B:4F:42:13:F1 server=defconf
add address=192.168.0.28 client-id=ff:6e:b3:ea:3f:0:3:0:1:b8:87:6e:b3:ea:3f \
    comment="\CA\F3\F5\ED\FF" mac-address=B8:87:6E:B3:EA:3F server=defconf
add address=192.168.0.45 comment="\CB\E0\EC\EF\EE\F7\EA\E0 \E4\F3\F81" \
    mac-address=D8:1F:12:59:E8:FC server=defconf
add address=192.168.0.46 comment="\CB\E0\EC\EF\EE\F7\EA\E0 \E4\F3\F82" \
    mac-address=D8:1F:12:59:B9:9F server=defconf
add address=192.168.0.47 comment="\CB\E0\EC\EF\EE\F7\EA\E0 \E4\F3\F83" \
    mac-address=D8:1F:12:59:D5:64 server=defconf
add address=192.168.0.48 comment="\CB\E0\EC\EF\EE\F7\EA\E0 \E4\F3\F84" \
    mac-address=D8:1F:12:5A:3C:82 server=defconf
add address=192.168.0.49 comment="\CB\E0\EC\EF\EE\F7\EA\E0 \E4\F3\F85" \
    mac-address=D8:1F:12:59:C6:2C server=defconf
add address=192.168.0.50 client-id=1:3c:b:4f:11:e8:aa comment=\
    "\D7\E5\F0\ED\E0\FF1 \EF\F0\EE\E2\EE\E4" mac-address=3C:0B:4F:11:E8:AA \
    server=defconf
add address=192.168.0.30 client-id=1:3c:b:4f:42:0:75 comment=\
    "\C1\E5\E6\E5\E2\E0\FF2 \EF\F0\E0\E2\E0\FF \F1\EF\E0\EB\FC\ED\FF" \
    mac-address=3C:0B:4F:42:00:75 server=defconf
add address=192.168.0.25 client-id=1:7c:70:db:6d:b4:fb comment=\
    "\D7\E5\F0\ED\E0\FF2 wifi" mac-address=7C:70:DB:6D:B4:FB server=defconf
add address=192.168.0.55 client-id=\
    ff:29:b7:44:16:0:1:0:1:2c:88:93:a:0:c:29:b7:44:16 mac-address=\
    00:0C:29:B7:44:16 server=defconf
add address=192.168.0.84 comment="\D1\E2\E5\F2\E8\EB\FC\ED\E8\EA \E4\F3\F8" \
    mac-address=10:D5:61:FE:8B:B1 server=defconf
add address=192.168.0.53 client-id=1:3c:b:4f:12:24:96 comment=\
    "\D7\E5\F0\ED\E0\FF \E2\F0\EE\E4\E5" mac-address=3C:0B:4F:12:24:96 \
    server=defconf
add address=192.168.0.54 client-id=1:3c:b:4f:3c:43:f2 comment=\
    "Yandex Max \E1\E5\E6\E5\E2\E0\FF 90 Wifi" mac-address=3C:0B:4F:3C:43:F2 \
    server=defconf
add address=192.168.0.56 client-id=1:3c:b:4f:3d:2e:2e comment=\
    "Yandex Max \E1\E5\E6\E5\E2\E0\FF Wifi" mac-address=3C:0B:4F:3D:2E:2E \
    server=defconf
add address=192.168.0.61 client-id=1:42:77:96:0:1:86 comment=\
    "\EF\E0\ED\E5\EB\FC P8 \E2\EE\E7\EB\E5 \E2\F5\EE\E4\E0" mac-address=\
    42:77:96:00:01:86 server=defconf
add address=192.168.0.74 comment="Bolid C2000-Eth" mac-address=\
    00:18:BC:05:B9:3D server=defconf
add address=192.168.0.95 comment="\CF\F0\EE\E5\EA\F2\EE\F0" mac-address=\
    E0:DA:DC:17:E8:EB server=defconf
add address=192.168.0.97 comment=\
    "LED \EA\EE\ED\F2\F0\EE\EB\EB\E5\F0 \C2\E0\ED\ED\E0 \F1\F2\E5\ED\E0" \
    mac-address=A8:80:55:85:AB:5D server=defconf
add address=192.168.0.98 comment=\
    "LED \EA\EE\ED\F2\F0\EE\EB\EB\E5\F0 \C2\E0\ED\ED\E0 \F1\F2\E5\ED\E0" \
    mac-address=18:DE:50:02:0E:0C server=defconf
add address=192.168.0.99 comment=\
    "LED \EA\EE\ED\F2\F0\EE\EB\EB\E5\F0 \C2\E0\ED\ED\E0 \F1\F2\E5\ED\E0" \
    mac-address=18:DE:50:02:01:F6 server=defconf
add address=192.168.0.102 comment=\
    "LED \EA\EE\ED\F2\F0\EE\EB\EB\E5\F0 \C2\E0\ED\ED\E0 \F1\F2\E5\ED\E0" \
    mac-address=50:8B:B9:E3:BF:86 server=defconf
add address=192.168.0.108 client-id=1:68:f6:3b:1e:9f:9c comment=\
    "Kindle Scribe" mac-address=68:F6:3B:1E:9F:9C server=defconf
add address=192.168.0.193 comment=\
    "LED \EF\EE\F2\EE\EB\EE\EA \EA\E0\E1\E8\ED\E5\F22" mac-address=\
    50:8B:B9:EF:35:FE server=defconf
add address=192.168.0.192 comment=\
    "LED \EF\EE\F2\EE\EB\EE\EA \EA\E0\E1\E8\ED\E5\F21" mac-address=\
    50:8B:B9:EF:2C:E4 server=defconf
add address=192.168.0.187 client-id=1:de:59:54:27:a0:2b comment="MAMA iphone" \
    mac-address=DE:59:54:27:A0:2B server=defconf
add address=192.168.0.175 client-id=1:8:91:a3:6d:ae:ab comment=\
    "Kindle Scribe" mac-address=08:91:A3:6D:AE:AB server=defconf
add address=192.168.0.242 client-id=1:70:8b:cd:82:29:60 comment=\
    "\CC\E0\EB\E5\ED\FC\EA\E8\E9 \EA\EE\EC\EF mini-STX" disabled=yes \
    mac-address=70:8B:CD:82:29:60 server=defconf
add address=192.168.0.160 client-id=1:f8:1:b4:15:7c:1b comment="TV LG 42" \
    mac-address=F8:01:B4:15:7C:1B server=defconf
add address=192.168.0.154 comment="LED \C7\E0\EB" mac-address=\
    50:8B:B9:EF:2B:06 server=defconf
add address=192.168.0.121 client-id=1:80:a:80:5d:7a:59 comment=\
    "ZIDOO UHD8000" mac-address=80:0A:80:5D:7A:59 server=defconf
add address=192.168.0.240 client-id=1:0:c:29:35:b1:8 mac-address=\
    00:0C:29:35:B1:08 server=defconf
add address=192.168.0.52 comment=Turkov mac-address=58:BF:25:D6:63:77 server=\
    defconf
add address=192.168.0.85 comment=SATEL mac-address=00:1B:9C:0B:0D:BB server=\
    defconf
add address=192.168.0.80 comment="LED \C4\F3\F8 \EF\EE\F2\EE\EB\EE\EA" \
    mac-address=1C:90:FF:C6:8C:BF server=defconf
add address=192.168.0.58 comment="LED \CA\F3\F5\ED\FF" mac-address=\
    50:8B:B9:EF:31:CE server=defconf
add address=192.168.0.73 mac-address=A6:4C:5E:E7:02:15 server=defconf
add address=192.168.0.75 client-id=1:aa:5a:65:9f:4d:ed mac-address=\
    AA:5A:65:9F:4D:ED server=defconf
add address=192.168.0.76 mac-address=A6:4C:5E:E6:FC:56 server=defconf
add address=192.168.0.94 client-id=1:0:c:29:bd:93:ba mac-address=\
    00:0C:29:BD:93:BA server=defconf
add address=192.168.0.100 mac-address=A6:4C:5E:E6:FC:C5 server=defconf
add address=192.168.0.101 mac-address=A6:4C:5E:E6:FF:38 server=defconf
add address=192.168.0.110 comment=\
    "LED \C2\E0\ED\ED\E0 \E7\E5\F0\EA\E0\EB\EE \EB\E5\E2\EE" mac-address=\
    50:8B:B9:E3:C8:33 server=defconf
add address=192.168.0.109 comment=\
    "LED \C2\E0\ED\ED\E0 \E7\E5\F0\EA\E0\EB\EE \EF\F0\E0\E2\EE" mac-address=\
    A8:80:55:7D:B9:61 server=defconf
add address=192.168.0.122 comment="LED \C2\E0\ED\ED\E0 \EF\EE\F2\EE\EB\EE\EA" \
    mac-address=50:8B:B9:EF:30:4C server=defconf
add address=192.168.0.123 comment="LED \C2\E0\ED\ED\E0 \EF\EE\E4" \
    mac-address=18:DE:50:01:F8:BD server=defconf
add address=192.168.0.128 mac-address=D4:AD:20:B3:C1:BD server=defconf
add address=192.168.0.12 client-id=1:d4:1:c3:4f:58:90 mac-address=\
    D4:01:C3:4F:58:90 server=defconf
add address=192.168.0.24 comment=\
    "\CB\E0\EC\EF\EE\F7\EA\E0 \E1\F0\E0 \E3\EE\F1\F2\E5\E2\E0\FF" \
    mac-address=50:8B:B9:3C:09:DF server=defconf
add address=192.168.0.31 comment=\
    "\CB\E0\EC\EF\EE\F7\EA\E0 \E1\F0\E0 \E3\EE\F1\F2\E5\E2\E0\FF" \
    mac-address=50:8B:B9:91:49:C6 server=defconf
add address=192.168.0.37 comment=\
    "\CB\E0\EC\EF\EE\F7\EA\E0 \E1\F0\E0 \E3\EE\F1\F2\E5\E2\E0\FF" \
    mac-address=50:8B:B9:38:6F:E7 server=defconf
add address=192.168.0.124 client-id=1:80:a:80:5d:85:30 comment="Zidoo Z9X 8K" \
    mac-address=80:0A:80:5D:85:30 server=defconf
add address=192.168.0.41 client-id=1:28:77:ff:32:4:a9 comment=\
    "Waveshare RS485 to Ethernet " mac-address=28:77:FF:32:04:A9 server=\
    defconf
add address=192.168.0.63 comment=Nintendo mac-address=94:58:CB:0D:D9:CA \
    server=defconf
add address=192.168.0.60 mac-address=E8:16:56:1C:78:5C server=defconf
add address=192.168.0.159 client-id=1:14:7f:67:24:d8:6 mac-address=\
    14:7F:67:24:D8:06 server=defconf
add address=192.168.0.71 client-id=\
    ff:29:6a:e0:eb:0:1:0:1:2f:f1:8:fc:0:c:29:6a:e0:eb mac-address=\
    00:0C:29:6A:E0:EB server=defconf
add address=192.168.0.79 comment="\CD\EE\F7\ED\E8\EA" mac-address=\
    98:17:3C:1E:57:42 server=defconf
add address=192.168.0.67 client-id=1:28:79:cd:7c:77:b6 comment=\
    "Waveshare RS485 to Ethernet " mac-address=28:79:CD:7C:77:B6 server=\
    defconf
add address=192.168.0.89 client-id=1:44:1d:64:bc:a8:80 comment=ESP32 \
    mac-address=44:1D:64:BC:A8:80 server=defconf
add address=192.168.0.38 client-id=1:e4:b0:63:41:8:8 comment=ESP32-C6-Zero \
    mac-address=E4:B0:63:41:08:08 server=defconf
add address=192.168.0.51 client-id=1:e:1f:43:90:30:ad mac-address=\
    0E:1F:43:90:30:AD server=defconf
add address=192.168.0.69 client-id=1:20:6e:f1:b2:a9:68 comment=\
    "ESP32 CAM SERVERNAIA" mac-address=20:6E:F1:B2:A9:68 server=defconf
add address=192.168.0.78 client-id=\
    ff:29:fa:42:4c:0:1:0:1:30:bd:f:82:0:c:29:fa:42:4c mac-address=\
    00:0C:29:FA:42:4C server=defconf
add address=192.168.0.82 client-id=\
    ff:29:af:36:66:0:1:0:1:30:c1:38:3:0:c:29:af:36:66 comment=ELK \
    mac-address=00:0C:29:AF:36:66 server=defconf
add address=192.168.0.103 client-id=1:0:7d:3b:2c:63:54 comment="Samsung s95f" \
    mac-address=00:7D:3B:2C:63:54 server=defconf
add address=192.168.0.57 client-id=1:e6:30:9c:f8:ae:76 comment=\
    "\D0\90\D0\B9\D1\84\D0\BE\D0\BD" mac-address=E6:30:9C:F8:AE:76 server=\
    defconf
add address=192.168.0.81 client-id=\
    ff:29:d4:19:1c:0:1:0:1:30:f2:21:c7:0:c:29:d4:19:1c comment=zabbix \
    mac-address=00:0C:29:D4:19:1C server=defconf
/ip dhcp-server network
add address=192.168.0.0/24 dns-server=192.168.0.1 gateway=192.168.0.1 \
    netmask=24 ntp-server=192.168.0.1
add address=192.168.100.0/24 dns-server=192.168.0.1 gateway=192.168.100.1 \
    ntp-server=192.168.0.1
/ip dns
set allow-remote-requests=yes cache-max-ttl=1d cache-size=10000KiB \
    use-doh-server=https://dns.google/dns-query verify-doh-cert=yes
/ip dns static
add address=192.168.0.1 name=router.lan type=A
add address=192.168.0.240 name=dimahome27.duckdns.org type=A
add address=1.1.1.1 comment="DNS CloudFlare" name=cloudflare-dns.com type=A
add address=1.0.0.1 comment="DNS CloudFlare" name=cloudflare-dns.com type=A
add address=8.8.8.8 comment="DNS Google" name=dns.google type=A
add address=8.8.4.4 comment="DNS Google" name=dns.google type=A
add address=9.9.9.9 comment="DNS Quad9" name=dns.quad9.net type=A
add address=149.112.112.112 comment="DNS Quad9" name=dns.quad9.net type=A
add address=195.133.25.16 comment="DNS Comss" name=dns.comss.one type=A
add address-list=BlackList_EU forward-to=Google match-subdomain=yes name=\
    meduza.io type=FWD
add address-list=BlackList_EU forward-to=Google match-subdomain=yes name=\
    pornolab.net type=FWD
add address-list=BlackList_EU forward-to=Google match-subdomain=yes name=\
    blueirissoftware.com type=FWD
add address-list=BlackList_EU forward-to=Google match-subdomain=yes name=\
    2ip.ru type=FWD
add address-list=BlackList_EU forward-to=Google match-subdomain=yes name=\
    miele.com type=FWD
add address-list=BlackList_EU forward-to=Google match-subdomain=yes name=\
    linktr.ee type=FWD
add address-list=BlackList_EU forward-to=Google match-subdomain=yes name=\
    cash.app type=FWD
add address-list=BlackList_EU forward-to=Google match-subdomain=yes name=\
    sms-activate.io type=FWD
add address-list=BlackList_RU comment=ProtonVPN forward-to=Google \
    match-subdomain=yes name=protonvpn.com type=FWD
add address-list=BlackList_RU comment=LinkedIn disabled=yes forward-to=Google \
    name=e122475.dscg.akamaiedge.net type=FWD
add address-list=BlackList_RU comment=LinkedIn disabled=yes forward-to=Google \
    name=licdn.cn.cdn20.com type=FWD
add address-list=BlackList_RU comment=LinkedIn disabled=yes forward-to=Google \
    name=linkedin.sc.omtrdc.net type=FWD
add address-list=BlackList_RU comment=LinkedIn disabled=yes forward-to=Google \
    match-subdomain=yes name=bizographics.com type=FWD
add address-list=BlackList_RU comment=LinkedIn disabled=yes forward-to=Google \
    match-subdomain=yes name=licdn.com type=FWD
add address-list=BlackList_RU comment=LinkedIn disabled=yes forward-to=Google \
    match-subdomain=yes name=linkedin.at type=FWD
add address-list=BlackList_RU comment=LinkedIn disabled=yes forward-to=Google \
    match-subdomain=yes name=linkedin.com type=FWD
add address-list=BlackList_RU comment=LinkedIn disabled=yes forward-to=Google \
    match-subdomain=yes name=lnkd.in type=FWD
add address-list=BlackList_RU comment=LinkedIn disabled=yes forward-to=Google \
    match-subdomain=yes name=l-0005.dc-msedge.net type=FWD
add address-list=BlackList_RU comment=LinkedIn disabled=yes forward-to=Google \
    match-subdomain=yes name=l-0005.l-msedge.net type=FWD
add address-list=BlackList_RU comment=LinkedIn disabled=yes forward-to=Google \
    match-subdomain=yes name=licdn.cn type=FWD
add address-list=BlackList_RU comment=LinkedIn disabled=yes forward-to=Google \
    match-subdomain=yes name=linkedin.cn type=FWD
add address-list=BlackList_RU comment=AdGuard disabled=yes forward-to=Google \
    match-subdomain=yes name=adguardaccount.com type=FWD
add address-list=BlackList_RU comment=AdGuard disabled=yes forward-to=Google \
    match-subdomain=yes name=adguard.app type=FWD
add address-list=BlackList_RU comment=AdGuard disabled=yes forward-to=Google \
    match-subdomain=yes name=adguard.com type=FWD
add address-list=BlackList_RU comment=AdGuard disabled=yes forward-to=Google \
    match-subdomain=yes name=adguard.info type=FWD
add address-list=BlackList_RU comment=AdGuard disabled=yes forward-to=Google \
    match-subdomain=yes name=adguard.io type=FWD
add address-list=BlackList_RU comment=AdGuard disabled=yes forward-to=Google \
    match-subdomain=yes name=adguard.org type=FWD
add address-list=BlackList_RU comment=AdGuard disabled=yes forward-to=Google \
    match-subdomain=yes name=adtidy.net type=FWD
add address-list=BlackList_RU comment=AdGuard disabled=yes forward-to=Google \
    match-subdomain=yes name=adtidy.org type=FWD
add address-list=BlackList_RU comment=AdGuard disabled=yes forward-to=Google \
    match-subdomain=yes name=agrd.eu type=FWD
add address-list=BlackList_RU comment=AdGuard disabled=yes forward-to=Google \
    match-subdomain=yes name=agrd.io type=FWD
add address-list=BlackList_RU comment=AdGuard disabled=yes forward-to=Google \
    match-subdomain=yes name=adguard-dns.com type=FWD
add address-list=BlackList_RU comment=AdGuard disabled=yes forward-to=Google \
    match-subdomain=yes name=adguard-dns.io type=FWD
add address-list=BlackList_RU comment=AdGuard disabled=yes forward-to=Google \
    match-subdomain=yes name=adguard-mail.com type=FWD
add address-list=BlackList_RU comment=AdGuard disabled=yes forward-to=Google \
    match-subdomain=yes name=mask.me type=FWD
add address-list=BlackList_RU comment=AdGuard disabled=yes forward-to=Google \
    match-subdomain=yes name=adguardvpn.com type=FWD
add address-list=BlackList_RU comment=AdGuard disabled=yes forward-to=Google \
    match-subdomain=yes name=adguard-vpn.com type=FWD
add address-list=BlackList_RU comment=AdGuard disabled=yes forward-to=Google \
    match-subdomain=yes name=adguard-vpn.online type=FWD
add address-list=BlackList_EU comment=UA forward-to=Google match-subdomain=\
    yes name=ua type=FWD
add address-list=BlackList_RU comment=YouTube forward-to=Google regexp=\
    youtube type=FWD
add address-list=BlackList_RU comment=YouTube forward-to=Google regexp=youtu \
    type=FWD
add address-list=BlackList_RU comment=YouTube forward-to=Google \
    match-subdomain=yes name=ytimg.com type=FWD
add address-list=BlackList_RU comment=YouTube2 forward-to=Google \
    match-subdomain=yes name=nhacoviet.org type=FWD
add address-list=BlackList_RU comment=YouTube2 forward-to=Google \
    match-subdomain=yes name=gstatic.com type=FWD
add address-list=BlackList_RU comment=YouTube2 forward-to=Google \
    match-subdomain=yes name=googleusercontent.com type=FWD
add address-list=BlackList_RU comment=YouTube forward-to=Google \
    match-subdomain=yes name=youtu.be type=FWD
add address-list=BlackList_RU comment=YouTube forward-to=Google \
    match-subdomain=yes name=google.com type=FWD
add address-list=BlackList_RU comment=YouTube forward-to=Google \
    match-subdomain=yes name=googleapis.com type=FWD
add address-list=BlackList_RU comment=YouTube forward-to=Google \
    match-subdomain=yes name=gvt1.com type=FWD
add address-list=BlackList_RU comment=YouTube forward-to=Google \
    match-subdomain=yes name=gvt2.com type=FWD
add address-list=BlackList_RU comment=YouTube forward-to=Google \
    match-subdomain=yes name=widevine.com type=FWD
add address-list=BlackList_RU comment=YouTube forward-to=Google \
    match-subdomain=yes name=youtu type=FWD
add address-list=BlackList_RU comment=YouTube forward-to=Google \
    match-subdomain=yes name=yt.be type=FWD
add address-list=BlackList_EU comment=jetbrains.com forward-to=Google \
    match-subdomain=yes name=jetbrains.com type=FWD
add address-list=BlackList_RU comment=YouTube forward-to=Google \
    match-subdomain=yes name=ggpht.com type=FWD
add address-list=BlackList_RU comment=YouTube forward-to=Google \
    match-subdomain=yes name=ggpht.cn type=FWD
add address-list=BlackList_RU comment=YouTube forward-to=Google \
    match-subdomain=yes name=googlevideo.com type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google regexp=facebook \
    type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google regexp=instagram \
    type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google regexp=oculus \
    type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google regexp=whatsapp \
    type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google name=\
    fbcdn-a.akamaihd.net type=FWD
add address-list=BlackList_RU comment=Meta disabled=yes forward-to=Google \
    match-subdomain=yes name=meta.ai type=FWD
add address-list=BlackList_RU comment=Meta disabled=yes forward-to=Google \
    match-subdomain=yes name=meta.com type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=bookstagram.com type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=carstagram.com type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=chickstagram.com type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=ig.me type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=igcdn.com type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=igsonar.com type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=igtv.com type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=imstagram.com type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=imtagram.com type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=instaadder.com type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=instachecker.com type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=instafallow.com type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=instafollower.com type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=instagainer.com type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=instagda.com type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=instagify.com type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=instagmania.com type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=instagor.com type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=instagran.com type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=instagranm.com type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=instagrem.com type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=instagrm.com type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=instagtram.com type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=instagy.com type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=instamgram.com type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=instangram.com type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=instanttelegram.com type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=instaplayer.net type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=instastyle.tv type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=instgram.com type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=intagram.com type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=intagrm.com type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=intgram.com type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=kingstagram.com type=FWD
add address-list=BlackList_RU comment=Meta disabled=yes forward-to=Google \
    match-subdomain=yes name=lnstagram-help.com type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=fbmessenger.com type=FWD
add address-list=BlackList_RU comment=Meta disabled=yes forward-to=Google \
    match-subdomain=yes name=m.me type=FWD
add address-list=BlackList_RU comment=Meta disabled=yes forward-to=Google \
    match-subdomain=yes name=messenger.com type=FWD
add address-list=BlackList_RU comment=Meta disabled=yes forward-to=Google \
    match-subdomain=yes name=nbabot.net type=FWD
add address-list=BlackList_RU comment=Meta disabled=yes forward-to=Google \
    match-subdomain=yes name=ocul.us type=FWD
add address-list=BlackList_RU comment=Meta disabled=yes forward-to=Google \
    match-subdomain=yes name=powersunitedvr.com type=FWD
add address-list=BlackList_RU comment=Meta disabled=yes forward-to=Google \
    match-subdomain=yes name=threads.net type=FWD
add address-list=BlackList_RU comment=Meta disabled=yes forward-to=Google \
    match-subdomain=yes name=wa.me type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=acebooik.com type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=acebook.com type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=advancediddetection.com type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=atdmt2.com type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=atlasdmt.com type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=atlasonepoint.com type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=careersatfb.com type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=celebgramme.com type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=click-url.com type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=crowdtangle.com type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=dacebook.com type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=expresswifi.com type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=faacebok.com type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=faacebook.com type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=faasbook.com type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=facbebook.com type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=facbeok.com type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=facboo.com type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=facbook.com type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=facbool.com type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=facboox.com type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=faccebook.com type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=faccebookk.com type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=facdbook.com type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=facdebook.com type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=face-book.com type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=faceabook.com type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=facebboc.com type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=facebbook.com type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=facebboook.com type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=facebcook.com type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=facebdok.com type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=facebgook.com type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=facebhook.com type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=facebkkk.com type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=facebo-ok.com type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=faceboak.com type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=facebock.com type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=facebocke.com type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=facebof.com type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=faceboik.com type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=facebok.com type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=facebokbook.com type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=facebokc.com type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=facebokk.com type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=facebokok.com type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=faceboks.com type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=facebol.com type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=facebolk.com type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=facebomok.com type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=faceboo.com type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=facebooa.com type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=faceboob.com type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=faceboobok.com type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=facebooc.com type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=faceboock.com type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=facebood.com type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=facebooe.com type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=faceboof.com type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=facebooi.com type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=facebooik.com type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=facebooik.org type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=facebooj.com type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=facebool.com type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=facebool.info type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=facebooll.com type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=faceboom.com type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=faceboon.com type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=faceboonk.com type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=faceboooik.com type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=faceboook.com type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=faceboop.com type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=faceboot.com type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=faceboox.com type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=facebopk.com type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=facebpook.com type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=facebuk.com type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=facebuok.com type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=facebvook.com type=FWD
add address-list=BlackList_EU comment=kinopoisk forward-to=Google \
    match-subdomain=yes name=kinopoisk.dev type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=facebyook.com type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=facebzook.com type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=facecbgook.com type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=facecbook.com type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=facecbook.org type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=facecook.com type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=facecook.org type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=facedbook.com type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=faceebok.com type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=faceebook.com type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=faceebot.com type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=facegbok.com type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=facegbook.com type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=faceobk.com type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=faceobok.com type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=faceobook.com type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=faceook.com type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=facerbooik.com type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=facerbook.com type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=facesbooc.com type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=facesounds.com type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=facetook.com type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=facevbook.com type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=facewbook.co type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=facewook.com type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=facfebook.com type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=fackebook.com type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=facnbook.com type=FWD
add address-list=BlackList_EU comment=Meta disabled=yes forward-to=Google \
    match-subdomain=yes name=cloudflareclient.com type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=facrbook.com type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=facvebook.com type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=facwebook.com type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=facxebook.com type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=fadebook.com type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=faebok.com type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=faebook.com type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=faebookc.com type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=faeboook.com type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=faecebok.com type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=faesebook.com type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=faicbooc.com type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=fasebokk.com type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=fasebook.com type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=faseboox.com type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=favebook.com type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=faycbok.com type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=fb.careers type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=fb.com type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=fb.gg type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=fb.me type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=fb.watch type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=fbacebook.com type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=fbbmarket.com type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=fbboostyourbusiness.com type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=fbcdn.com type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=fbcdn.net type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=fbfeedback.com type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=fbhome.com type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=fbidb.io type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=leader.ru type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=fbinc.com type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=fbinnovation.com type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=fbmarketing.com type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=fbreg.com type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=fbrpms.com type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=fbsbx.com type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=fbsbx.net type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=fbsupport-covid.net type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=fbthirdpartypixel.com type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=fbthirdpartypixel.net type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=fbthirdpartypixel.org type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=fburl.com type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=fbwat.ch type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=fbworkmail.com type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=fcacebook.com type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=fcaebook.com type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=fcebook.com type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=fcebookk.com type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=fdacebook.info type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=feacboo.com type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=feacbook.com type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=feacbooke.com type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=feacebook.com type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=fecbbok.com type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=fecbooc.com type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=fecbook.com type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=feceboock.com type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=feceboox.com type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=fececbook.com type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=feook.com type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=ferabook.com type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=fescebook.com type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=fesebook.com type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=fgacebook.com type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=ficeboock.com type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=fmcebook.com type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=fnacebook.com type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=fosebook.com type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=fpacebook.com type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=fqcebook.com type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=fracebook.com type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=freeb.com type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=freebasics.com type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=freebasics.net type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=freebs.com type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=freefblikes.com type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=freindfeed.com type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=friendbook.info type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=friendfed.com type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=friendfeed-api.com type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=friendfeed-media.com type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=friendfeed.com type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=friendfeedmedia.com type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=fsacebok.com type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=fscebook.com type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=futureofbusinesssurvey.org type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=gacebook.com type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=gameroom.com type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=gfacecbook.com type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=groups.com type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=i.org type=FWD
add address-list=BlackList_RU comment=Meta disabled=yes forward-to=Google \
    match-subdomain=yes name=internet.org type=FWD
add address-list=BlackList_RU comment=Meta disabled=yes forward-to=Google \
    match-subdomain=yes name=klik.me type=FWD
add address-list=BlackList_RU comment=Meta disabled=yes forward-to=Google \
    match-subdomain=yes name=liverail.com type=FWD
add address-list=BlackList_RU comment=Meta disabled=yes forward-to=Google \
    match-subdomain=yes name=liverail.tv type=FWD
add address-list=BlackList_RU comment=Meta disabled=yes forward-to=Google \
    match-subdomain=yes name=login-account.net type=FWD
add address-list=BlackList_RU comment=Meta disabled=yes forward-to=Google \
    match-subdomain=yes name=markzuckerberg.com type=FWD
add address-list=BlackList_RU comment=Meta disabled=yes forward-to=Google \
    match-subdomain=yes name=midentsolutions.com type=FWD
add address-list=BlackList_RU comment=Meta disabled=yes forward-to=Google \
    match-subdomain=yes name=myfbfans.com type=FWD
add address-list=BlackList_RU comment=Meta disabled=yes forward-to=Google \
    match-subdomain=yes name=newsfeed.com type=FWD
add address-list=BlackList_RU comment=Meta disabled=yes forward-to=Google \
    match-subdomain=yes name=nextstop.com type=FWD
add address-list=BlackList_RU comment=Meta disabled=yes forward-to=Google \
    match-subdomain=yes name=online-deals.net type=FWD
add address-list=BlackList_RU comment=Meta disabled=yes forward-to=Google \
    match-subdomain=yes name=opencreate.org type=FWD
add address-list=BlackList_RU comment=Meta disabled=yes forward-to=Google \
    match-subdomain=yes name=rocksdb.org type=FWD
add address-list=BlackList_RU comment=Meta disabled=yes forward-to=Google \
    match-subdomain=yes name=sportstream.com type=FWD
add address-list=BlackList_RU comment=Meta disabled=yes forward-to=Google \
    match-subdomain=yes name=terragraph.com type=FWD
add address-list=BlackList_RU comment=Meta disabled=yes forward-to=Google \
    match-subdomain=yes name=thefind.com type=FWD
add address-list=BlackList_RU comment=Meta disabled=yes forward-to=Google \
    match-subdomain=yes name=toplayerserver.com type=FWD
add address-list=BlackList_RU comment=Meta disabled=yes forward-to=Google \
    match-subdomain=yes name=worldhack.com type=FWD
add address-list=BlackList_RU comment=Meta disabled=yes forward-to=Google \
    match-subdomain=yes name=wwwfacebok.com type=FWD
add address-list=BlackList_RU comment=Meta disabled=yes forward-to=Google \
    match-subdomain=yes name=zuckerberg.com type=FWD
add address-list=BlackList_RU comment=Meta disabled=yes forward-to=Google \
    match-subdomain=yes name=zuckerberg.net type=FWD
add address-list=BlackList_RU comment=Meta disabled=yes forward-to=Google \
    match-subdomain=yes name=redkix.com type=FWD
add address-list=BlackList_RU comment=Meta disabled=yes forward-to=Google \
    match-subdomain=yes name=workplace.com type=FWD
add address-list=BlackList_RU comment=Meta disabled=yes forward-to=Google \
    match-subdomain=yes name=workplaceusecases.com type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=accountkit.com type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=atscaleconference.com type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=botorch.org type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=buck.build type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=buckbuild.com type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=componentkit.org type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=draftjs.org type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=f8.com type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=faciometrics.com type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=fasttext.cc type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=fbf8.com type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=fbinfer.com type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=fblitho.com type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=fbredex.com type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=fbrell.com type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=flow.dev type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=flow.org type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=flowtype.org type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=frescolib.org type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=hacklang.org type=FWD
add address-list=BlackList_RU comment=Meta forward-to=Google match-subdomain=\
    yes name=hhvm.com type=FWD
add address-list=BlackList_RU comment=Meta disabled=yes forward-to=Google \
    match-subdomain=yes name=makeitopen.com type=FWD
add address-list=BlackList_RU comment=Meta disabled=yes forward-to=Google \
    match-subdomain=yes name=mcrouter.net type=FWD
add address-list=BlackList_RU comment=Meta disabled=yes forward-to=Google \
    match-subdomain=yes name=mcrouter.org type=FWD
add address-list=BlackList_RU comment=Meta disabled=yes forward-to=Google \
    match-subdomain=yes name=messengerdevelopers.com type=FWD
add address-list=BlackList_RU comment=Meta disabled=yes forward-to=Google \
    match-subdomain=yes name=ogp.me type=FWD
add address-list=BlackList_RU comment=Meta disabled=yes forward-to=Google \
    match-subdomain=yes name=opengraphprotocol.com type=FWD
add address-list=BlackList_RU comment=Meta disabled=yes forward-to=Google \
    match-subdomain=yes name=opengraphprotocol.org type=FWD
add address-list=BlackList_RU comment=Meta disabled=yes forward-to=Google \
    match-subdomain=yes name=parse.com type=FWD
add address-list=BlackList_RU comment=Meta disabled=yes forward-to=Google \
    match-subdomain=yes name=pyrobot.org type=FWD
add address-list=BlackList_RU comment=Meta disabled=yes forward-to=Google \
    match-subdomain=yes name=react.com type=FWD
add address-list=BlackList_RU comment=Meta disabled=yes forward-to=Google \
    match-subdomain=yes name=reactjs.com type=FWD
add address-list=BlackList_RU comment=Meta disabled=yes forward-to=Google \
    match-subdomain=yes name=reactjs.org type=FWD
add address-list=BlackList_RU comment=Meta disabled=yes forward-to=Google \
    match-subdomain=yes name=recoiljs.org type=FWD
add address-list=BlackList_RU comment=Meta disabled=yes forward-to=Google \
    match-subdomain=yes name=rocksdb.com type=FWD
add address-list=BlackList_RU comment=Meta disabled=yes forward-to=Google \
    match-subdomain=yes name=rocksdb.net type=FWD
add address-list=BlackList_RU comment=Meta disabled=yes forward-to=Google \
    match-subdomain=yes name=yogalayout.com type=FWD
add address-list=BlackList_RU comment=Twitter forward-to=Google \
    match-subdomain=yes name=ads-twitter.com type=FWD
add address-list=BlackList_RU comment=Twitter forward-to=Google \
    match-subdomain=yes name=cms-twdigitalassets.com type=FWD
add address-list=BlackList_RU comment=Twitter forward-to=Google \
    match-subdomain=yes name=periscope.tv type=FWD
add address-list=BlackList_RU comment=Twitter forward-to=Google \
    match-subdomain=yes name=pscp.tv type=FWD
add address-list=BlackList_RU comment=Twitter forward-to=Google \
    match-subdomain=yes name=t.co type=FWD
add address-list=BlackList_RU comment=Twitter forward-to=Google \
    match-subdomain=yes name=tellapart.com type=FWD
add address-list=BlackList_RU comment=Twitter forward-to=Google \
    match-subdomain=yes name=tweetdeck.com type=FWD
add address-list=BlackList_RU comment=Twitter forward-to=Google \
    match-subdomain=yes name=twimg.com type=FWD
add address-list=BlackList_RU comment=Twitter forward-to=Google \
    match-subdomain=yes name=twitpic.com type=FWD
add address-list=BlackList_RU comment=Twitter forward-to=Google \
    match-subdomain=yes name=twitter.biz type=FWD
add address-list=BlackList_RU comment=Twitter forward-to=Google \
    match-subdomain=yes name=twitter.com type=FWD
add address-list=BlackList_RU comment=Twitter forward-to=Google \
    match-subdomain=yes name=twitter.jp type=FWD
add address-list=BlackList_RU comment=Twitter forward-to=Google \
    match-subdomain=yes name=twittercommunity.com type=FWD
add address-list=BlackList_RU comment=Twitter forward-to=Google \
    match-subdomain=yes name=twitterflightschool.com type=FWD
add address-list=BlackList_RU comment=Twitter forward-to=Google \
    match-subdomain=yes name=twitterinc.com type=FWD
add address-list=BlackList_RU comment=Twitter forward-to=Google \
    match-subdomain=yes name=twitteroauth.com type=FWD
add address-list=BlackList_RU comment=Twitter forward-to=Google \
    match-subdomain=yes name=twitterstat.us type=FWD
add address-list=BlackList_RU comment=Twitter forward-to=Google \
    match-subdomain=yes name=twtrdns.net type=FWD
add address-list=BlackList_RU comment=Twitter forward-to=Google \
    match-subdomain=yes name=twttr.com type=FWD
add address-list=BlackList_RU comment=Twitter forward-to=Google \
    match-subdomain=yes name=twttr.net type=FWD
add address-list=BlackList_RU comment=Twitter forward-to=Google \
    match-subdomain=yes name=twvid.com type=FWD
add address-list=BlackList_RU comment=Twitter forward-to=Google \
    match-subdomain=yes name=vine.co type=FWD
add address-list=BlackList_EU comment=Twitter forward-to=Google \
    match-subdomain=yes name=x.com type=FWD
add address-list=BlackList_RU comment=Twitter forward-to=Google \
    match-subdomain=yes name=twitter.map.fastly.net type=FWD
add address-list=BlackList_RU comment=Hysteria disabled=yes forward-to=Google \
    match-subdomain=yes name=hysteria.network type=FWD
add address-list=BlackList_RU comment=Sing-box disabled=yes forward-to=Google \
    match-subdomain=yes name=sagernet.org type=FWD
add address-list=BlackList_RU comment=WARP-generation forward-to=Google \
    match-subdomain=yes name=api.cloudflareclient.com type=FWD
add address-list=BlackList_RU comment=Livejournal disabled=yes forward-to=\
    Google match-subdomain=yes name=livejournal.net type=FWD
add address-list=BlackList_RU comment=MasterCoin disabled=yes forward-to=\
    Google match-subdomain=yes name=mscoin.finance type=FWD
add address-list=BlackList_RU comment=RockBlack disabled=yes forward-to=\
    Google match-subdomain=yes name=rockblack.su type=FWD
add address-list=BlackList_RU comment=Amnezia forward-to=Google \
    match-subdomain=yes name=amnezia.org type=FWD
add address-list=BlackList_RU comment=Anime disabled=yes forward-to=Google \
    match-subdomain=yes name=anidub.com type=FWD
add address-list=BlackList_RU comment=Anime disabled=yes forward-to=Google \
    match-subdomain=yes name=anilibria.tv type=FWD
add address-list=BlackList_RU comment=Anime disabled=yes forward-to=Google \
    match-subdomain=yes name=animakima.ru type=FWD
add address-list=BlackList_RU comment=Torrent forward-to=Google \
    match-subdomain=yes name=booktracker.org type=FWD
add address-list=BlackList_RU comment=Torrent forward-to=Google \
    match-subdomain=yes name=radarr.video type=FWD
add address-list=BlackList_RU comment=Torrent forward-to=Google \
    match-subdomain=yes name=dugtor.ru type=FWD
add address-list=BlackList_RU comment=Torrent forward-to=Google \
    match-subdomain=yes name=rustorka.com type=FWD
add address-list=BlackList_RU comment=Torrent forward-to=Google \
    match-subdomain=yes name=rutor.info type=FWD
add address-list=BlackList_RU comment=Torrent forward-to=Google \
    match-subdomain=yes name=rutor.lib type=FWD
add address-list=BlackList_RU comment=Torrent forward-to=Google \
    match-subdomain=yes name=rutor.is type=FWD
add address-list=BlackList_RU comment=Torrent forward-to=Google \
    match-subdomain=yes name=rutor.org type=FWD
add address-list=BlackList_EU comment=Torrent forward-to=Google \
    match-subdomain=yes name=rutracker.cc type=FWD
add address-list=BlackList_EU comment=Torrent forward-to=Google \
    match-subdomain=yes name=rutracker.net type=FWD
add address-list=BlackList_EU comment=Torrent forward-to=Google \
    match-subdomain=yes name=rutracker.org type=FWD
add address-list=BlackList_EU comment=Torrent forward-to=Google \
    match-subdomain=yes name=deepl.com type=FWD
add address-list=BlackList_EU comment=Torrent forward-to=Google \
    match-subdomain=yes name=rutracker.ru type=FWD
add address-list=BlackList_RU comment=Torrent forward-to=Google \
    match-subdomain=yes name=ahoy.yohoho.cc type=FWD
add address-list=BlackList_RU comment=Torrent forward-to=Google \
    match-subdomain=yes name=ahoy.yohoho.online type=FWD
add address-list=BlackList_RU comment=Torrent disabled=yes forward-to=Google \
    match-subdomain=yes name=apad.top type=FWD
add address-list=BlackList_RU comment=Torrent forward-to=Google \
    match-subdomain=yes name=bitru.org type=FWD
add address-list=BlackList_RU comment=Torrent forward-to=Google \
    match-subdomain=yes name=new.torkino.ru type=FWD
add address-list=BlackList_RU comment=Torrent forward-to=Google \
    match-subdomain=yes name=torrnado.space type=FWD
add address-list=BlackList_RU comment=Torrent forward-to=Google \
    match-subdomain=yes name=vkino.lafa.site type=FWD
add address-list=BlackList_RU comment=Torrent forward-to=Google \
    match-subdomain=yes name=nnmclub.to type=FWD
add address-list=BlackList_RU comment=Torrent forward-to=Google \
    match-subdomain=yes name=pb.wtf type=FWD
add address-list=BlackList_RU comment=Torrent forward-to=Google \
    match-subdomain=yes name=piratbit.fun type=FWD
add address-list=BlackList_RU comment=Torrent forward-to=Google \
    match-subdomain=yes name=piratbit.top type=FWD
add address-list=BlackList_RU comment=Torrent disabled=yes forward-to=Google \
    match-subdomain=yes name=apibay.org type=FWD
add address-list=BlackList_RU comment=Torrent forward-to=Google \
    match-subdomain=yes name=megapeer.ru type=FWD
add address-list=BlackList_RU comment=Torrent forward-to=Google \
    match-subdomain=yes name=megapeer.vip type=FWD
add address-list=BlackList_RU comment=Film disabled=yes forward-to=Google \
    match-subdomain=yes name=lostfilm.run type=FWD
add address-list=BlackList_RU comment=Film disabled=yes forward-to=Google \
    match-subdomain=yes name=lostfilm.top type=FWD
add address-list=BlackList_RU comment=Film disabled=yes forward-to=Google \
    match-subdomain=yes name=lostfilm.win type=FWD
add address-list=BlackList_RU comment=Film disabled=yes forward-to=Google \
    match-subdomain=yes name=lostfilm.tv type=FWD
add address-list=BlackList_RU comment=Film disabled=yes forward-to=Google \
    match-subdomain=yes name=lostfilmtv2.site type=FWD
add address-list=BlackList_RU comment=Film disabled=yes forward-to=Google \
    match-subdomain=yes name=lostfilmtv5.site type=FWD
add address-list=BlackList_RU comment=Film disabled=yes forward-to=Google \
    match-subdomain=yes name=kino.pub type=FWD
add address-list=BlackList_RU comment=Film disabled=yes forward-to=Google \
    match-subdomain=yes name=kinobase.org type=FWD
add address-list=BlackList_RU comment=Film disabled=yes forward-to=Google \
    match-subdomain=yes name=kinogo.la type=FWD
add address-list=BlackList_RU comment=Film disabled=yes forward-to=Google \
    match-subdomain=yes name=kinokopilka.pro type=FWD
add address-list=BlackList_RU comment=Film disabled=yes forward-to=Google \
    match-subdomain=yes name=kinovod.net type=FWD
add address-list=BlackList_RU comment=Film forward-to=Google match-subdomain=\
    yes name=kinozal.guru type=FWD
add address-list=BlackList_RU comment=Film forward-to=Google match-subdomain=\
    yes name=kinozal.me type=FWD
add address-list=BlackList_RU comment=Film forward-to=Google match-subdomain=\
    yes name=kinozal.tv type=FWD
add address-list=BlackList_RU comment=Film disabled=yes forward-to=Google \
    regexp=rezka type=FWD
add address-list=BlackList_RU comment=Film disabled=yes forward-to=Google \
    match-subdomain=yes name=stream.voidboost.cc type=FWD
add address-list=BlackList_RU comment=Film disabled=yes forward-to=Google \
    match-subdomain=yes name=zerocdn.com type=FWD
add address-list=BlackList_RU comment=Film disabled=yes forward-to=Google \
    match-subdomain=yes name=static.voidboost.com type=FWD
add address-list=BlackList_RU comment=Film disabled=yes forward-to=Google \
    match-subdomain=yes name=sambray.org type=FWD
add address-list=BlackList_RU comment=Discord disabled=yes forward-to=Google \
    regexp=discord type=FWD
add address-list=BlackList_RU comment=Discord disabled=yes forward-to=Google \
    name=hammerandchisel.ssl.zendesk.com type=FWD
add address-list=BlackList_RU comment=Discord disabled=yes forward-to=Google \
    match-subdomain=yes name=dis.gd type=FWD
add address-list=BlackList_RU comment=Discord disabled=yes forward-to=Google \
    match-subdomain=yes name=gcs-blue-download-eu.l.googleusercontent.com \
    type=FWD
add address-list=BlackList_RU comment=Discord disabled=yes forward-to=Google \
    match-subdomain=yes name=airhorn.solutions type=FWD
add address-list=BlackList_RU comment=Discord disabled=yes forward-to=Google \
    match-subdomain=yes name=airhornbot.com type=FWD
add address-list=BlackList_RU comment=Discord disabled=yes forward-to=Google \
    match-subdomain=yes name=bigbeans.solutions type=FWD
add address-list=BlackList_RU comment=Discord disabled=yes forward-to=Google \
    match-subdomain=yes name=watchanimeattheoffice.com type=FWD
add address-list=BlackList_EU comment=Tidal disabled=yes forward-to=Google \
    match-subdomain=yes name=tidal.com type=FWD
add address-list=BlackList_EU comment=Tidal disabled=yes forward-to=Google \
    match-subdomain=yes name=tidalhifi.com type=FWD
add address-list=BlackList_EU comment=Tidal disabled=yes forward-to=Google \
    match-subdomain=yes name=wimpmusic.com type=FWD
add address-list=BlackList_EU comment=XAI forward-to=Google match-subdomain=\
    yes name=grok.com type=FWD
add address-list=BlackList_EU comment=XAI forward-to=Google match-subdomain=\
    yes name=grokipedia.com type=FWD
add address-list=BlackList_EU comment=XAI forward-to=Google match-subdomain=\
    yes name=x.ai type=FWD
add address-list=BlackList_EU comment=OpanAI forward-to=Google name=\
    openaiapi-site.azureedge.net type=FWD
add address-list=BlackList_EU comment=OpanAI forward-to=Google name=\
    openaicom-api-bdcpf8c6d2e9atf6.z01.azurefd.net type=FWD
add address-list=BlackList_EU comment=OpanAI forward-to=Google name=\
    openaicomproductionae4b.blob.core.windows.net type=FWD
add address-list=BlackList_EU comment=OpanAI forward-to=Google name=\
    production-openaicom-storage.azureedge.net type=FWD
add address-list=BlackList_EU comment=OpanAI forward-to=Google name=\
    o33249.ingest.sentry.io type=FWD
add address-list=BlackList_EU comment=OpanAI forward-to=Google name=\
    openaicom.imgix.net type=FWD
add address-list=BlackList_EU comment=OpanAI forward-to=Google name=\
    browser-intake-datadoghq.com type=FWD
add address-list=BlackList_EU comment=OpanAI forward-to=Google \
    match-subdomain=yes name=chatgpt.com type=FWD
add address-list=BlackList_EU comment=OpanAI forward-to=Google \
    match-subdomain=yes name=chat.com type=FWD
add address-list=BlackList_EU comment=OpanAI forward-to=Google \
    match-subdomain=yes name=oaistatic.com type=FWD
add address-list=BlackList_EU comment=OpanAI forward-to=Google \
    match-subdomain=yes name=oaiusercontent.com type=FWD
add address-list=BlackList_EU comment=OpanAI forward-to=Google \
    match-subdomain=yes name=openai.com type=FWD
add address-list=BlackList_EU comment=OpanAI forward-to=Google \
    match-subdomain=yes name=sora.com type=FWD
add address-list=BlackList_EU comment=OpanAI forward-to=Google \
    match-subdomain=yes name=chatgpt.livekit.cloud type=FWD
add address-list=BlackList_EU comment=OpanAI forward-to=Google \
    match-subdomain=yes name=host.livekit.cloud type=FWD
add address-list=BlackList_EU comment=OpanAI forward-to=Google \
    match-subdomain=yes name=turn.livekit.cloud type=FWD
add address-list=BlackList_EU comment=OpanAI forward-to=Google \
    match-subdomain=yes name=openai.com.cdn.cloudflare.net type=FWD
add address-list=BlackList_EU comment=OpanAI forward-to=Google regexp="^chatgp\
    t-async-webps-prod-\\\\S+-\\\\d+\\\\.webpubsub\\\\.azure\\\\.com\$" type=\
    FWD
add address-list=BlackList_EU comment=Netflix disabled=yes forward-to=Google \
    name=netflix.com.edgesuite.net type=FWD
add address-list=BlackList_EU comment=Netflix disabled=yes forward-to=Google \
    match-subdomain=yes name=fast.com type=FWD
add address-list=BlackList_EU comment=Netflix disabled=yes forward-to=Google \
    match-subdomain=yes name=netflix.ca type=FWD
add address-list=BlackList_EU comment=Netflix disabled=yes forward-to=Google \
    match-subdomain=yes name=netflix.com type=FWD
add address-list=BlackList_EU comment=Netflix disabled=yes forward-to=Google \
    match-subdomain=yes name=netflix.net type=FWD
add address-list=BlackList_EU comment=Netflix disabled=yes forward-to=Google \
    match-subdomain=yes name=netflixinvestor.com type=FWD
add address-list=BlackList_EU comment=Netflix disabled=yes forward-to=Google \
    match-subdomain=yes name=netflixtechblog.com type=FWD
add address-list=BlackList_EU comment=Netflix disabled=yes forward-to=Google \
    match-subdomain=yes name=nflxext.com type=FWD
add address-list=BlackList_EU comment=Netflix disabled=yes forward-to=Google \
    match-subdomain=yes name=nflximg.com type=FWD
add address-list=BlackList_EU comment=Netflix disabled=yes forward-to=Google \
    match-subdomain=yes name=nflximg.net type=FWD
add address-list=BlackList_EU comment=Netflix disabled=yes forward-to=Google \
    match-subdomain=yes name=nflxsearch.net type=FWD
add address-list=BlackList_EU comment=Netflix disabled=yes forward-to=Google \
    match-subdomain=yes name=nflxso.net type=FWD
add address-list=BlackList_EU comment=Netflix disabled=yes forward-to=Google \
    match-subdomain=yes name=notebooklm.google type=FWD
add address-list=BlackList_EU comment=Netflix disabled=yes forward-to=Google \
    match-subdomain=yes name=nflxvideo.net type=FWD
add address-list=BlackList_EU comment=Netflix disabled=yes forward-to=Google \
    match-subdomain=yes name=netflixdnstest0.com type=FWD
add address-list=BlackList_EU comment=Netflix disabled=yes forward-to=Google \
    match-subdomain=yes name=netflixdnstest1.com type=FWD
add address-list=BlackList_EU comment=Netflix disabled=yes forward-to=Google \
    match-subdomain=yes name=netflixdnstest2.com type=FWD
add address-list=BlackList_EU comment=Netflix disabled=yes forward-to=Google \
    match-subdomain=yes name=netflixdnstest3.com type=FWD
add address-list=BlackList_EU comment=Netflix disabled=yes forward-to=Google \
    match-subdomain=yes name=netflixdnstest4.com type=FWD
add address-list=BlackList_EU comment=Netflix disabled=yes forward-to=Google \
    match-subdomain=yes name=netflixdnstest5.com type=FWD
add address-list=BlackList_EU comment=Netflix disabled=yes forward-to=Google \
    match-subdomain=yes name=netflixdnstest6.com type=FWD
add address-list=BlackList_EU comment=Netflix disabled=yes forward-to=Google \
    match-subdomain=yes name=netflixdnstest7.com type=FWD
add address-list=BlackList_EU comment=Netflix disabled=yes forward-to=Google \
    match-subdomain=yes name=netflixdnstest8.com type=FWD
add address-list=BlackList_EU comment=Netflix disabled=yes forward-to=Google \
    match-subdomain=yes name=netflixdnstest9.com type=FWD
add address-list=BlackList_EU comment=Netflix disabled=yes forward-to=Google \
    match-subdomain=yes name=netflixdnstest10.com type=FWD
add address-list=BlackList_EU comment=Netflix disabled=yes forward-to=Google \
    regexp="(^|\\\\.)apiproxy-device-prod-nlb-.+\\\\.amazonaws\\\\.com\$" \
    type=FWD
add address-list=BlackList_EU comment=Netflix disabled=yes forward-to=Google \
    regexp="(^|\\\\.)apiproxy-website-nlb-prod-.+\\\\.amazonaws\\\\.com\$" \
    type=FWD
add address-list=BlackList_EU comment=Netflix disabled=yes forward-to=Google \
    regexp="(^|\\\\.)dualstack\\\\.apiproxy-.+\\\\.amazonaws\\\\.com\$" type=\
    FWD
add address-list=BlackList_EU comment=Netflix disabled=yes forward-to=Google \
    regexp="(^|\\\\.)dualstack\\\\.ichnaea-web-.+\\\\.amazonaws\\\\.com\$" \
    type=FWD
add address-list=BlackList_EU comment=Intel disabled=yes forward-to=Google \
    regexp=intel type=FWD
add address-list=BlackList_EU comment=Intel disabled=yes forward-to=Google \
    match-subdomain=yes name=saffrontech.com type=FWD
add address-list=BlackList_EU comment=Intel disabled=yes forward-to=Google \
    match-subdomain=yes name=ospray.org type=FWD
add address-list=BlackList_EU comment=Intel disabled=yes forward-to=Google \
    match-subdomain=yes name=ospray.net type=FWD
add address-list=BlackList_EU comment=Intel disabled=yes forward-to=Google \
    match-subdomain=yes name=clearlinux.org type=FWD
add address-list=BlackList_EU comment=Intel disabled=yes forward-to=Google \
    match-subdomain=yes name=acpica.com type=FWD
add address-list=BlackList_EU comment=Intel disabled=yes forward-to=Google \
    match-subdomain=yes name=snap-telemetry.io type=FWD
add address-list=BlackList_EU comment=Intel disabled=yes forward-to=Google \
    match-subdomain=yes name=openvinotoolkit.org type=FWD
add address-list=BlackList_EU comment=Intel disabled=yes forward-to=Google \
    match-subdomain=yes name=oneapi.com type=FWD
add address-list=BlackList_EU comment=Intel forward-to=Google \
    match-subdomain=yes name=coomer.su type=FWD
add address-list=BlackList_EU comment=Intel forward-to=Google \
    match-subdomain=yes name=coomer.st type=FWD
add address=160.79.104.1 address-list=BlackList_EU comment=AI disabled=yes \
    match-subdomain=yes name=anthropic.com type=A
add address-list=BlackList_EU comment=Intel disabled=yes forward-to=Google \
    match-subdomain=yes name=hyperscan.io type=FWD
add address-list=BlackList_EU comment=Intel disabled=yes forward-to=Google \
    match-subdomain=yes name=intel.tt type=FWD
add address-list=BlackList_EU comment=Intel disabled=yes forward-to=Google \
    match-subdomain=yes name=barefootnetworks.com type=FWD
add address-list=BlackList_EU comment=Intel disabled=yes forward-to=Google \
    match-subdomain=yes name=xscale.com type=FWD
add address-list=BlackList_EU comment=Intel disabled=yes forward-to=Google \
    match-subdomain=yes name=xn--ztsq84g.cn type=FWD
add address-list=BlackList_EU comment=Intel disabled=yes forward-to=Google \
    match-subdomain=yes name=xeon.com type=FWD
add address-list=BlackList_EU comment=Intel disabled=yes forward-to=Google \
    match-subdomain=yes name=vpro.net type=FWD
add address-list=BlackList_EU comment=Intel disabled=yes forward-to=Google \
    match-subdomain=yes name=vpro.com type=FWD
add address-list=BlackList_EU comment=Intel disabled=yes forward-to=Google \
    match-subdomain=yes name=vokevr.com type=FWD
add address-list=BlackList_EU comment=Intel disabled=yes forward-to=Google \
    match-subdomain=yes name=trustedanalytics.net type=FWD
add address-list=BlackList_EU comment=Intel disabled=yes forward-to=Google \
    match-subdomain=yes name=trustedanalytics.com type=FWD
add address-list=BlackList_EU comment=Intel disabled=yes forward-to=Google \
    match-subdomain=yes name=thunderbolttechnology.net type=FWD
add address-list=BlackList_EU comment=Intel disabled=yes forward-to=Google \
    match-subdomain=yes name=01.org type=FWD
add address-list=BlackList_EU comment=Intel disabled=yes forward-to=Google \
    match-subdomain=yes name=altera.com type=FWD
add address-list=BlackList_EU forward-to=Google match-subdomain=yes name=\
    artificialanalysis.ai type=FWD
add address-list=BlackList_EU comment=Intel disabled=yes forward-to=Google \
    match-subdomain=yes name=alteraforum.com type=FWD
add address-list=BlackList_EU comment=Intel disabled=yes forward-to=Google \
    match-subdomain=yes name=alteraforums.com type=FWD
add address-list=BlackList_EU comment=Intel disabled=yes forward-to=Google \
    match-subdomain=yes name=alteraforums.net type=FWD
add address-list=BlackList_EU comment=Intel disabled=yes forward-to=Google \
    match-subdomain=yes name=alterauserforum.com type=FWD
add address-list=BlackList_EU comment=Intel disabled=yes forward-to=Google \
    match-subdomain=yes name=alterauserforum.net type=FWD
add address-list=BlackList_EU comment=Intel disabled=yes forward-to=Google \
    match-subdomain=yes name=alterauserforums.com type=FWD
add address-list=BlackList_EU comment=Intel disabled=yes forward-to=Google \
    match-subdomain=yes name=alterauserforums.net type=FWD
add address-list=BlackList_EU comment=Intel disabled=yes forward-to=Google \
    match-subdomain=yes name=ai.google.dev type=FWD
add address-list=BlackList_EU comment=Intel disabled=yes forward-to=Google \
    match-subdomain=yes name=notion.so type=FWD
add address-list=BlackList_EU comment=Intel disabled=yes forward-to=Google \
    match-subdomain=yes name=klarna.com type=FWD
add address-list=BlackList_EU comment=Intel disabled=yes forward-to=Google \
    match-subdomain=yes name=buyaltera.com type=FWD
add address-list=BlackList_EU comment=Intel disabled=yes forward-to=Google \
    match-subdomain=yes name=celeron.com type=FWD
add address-list=BlackList_EU comment=Intel disabled=yes forward-to=Google \
    match-subdomain=yes name=celeron.net type=FWD
add address-list=BlackList_EU comment=Intel disabled=yes forward-to=Google \
    match-subdomain=yes name=centrino.com type=FWD
add address-list=BlackList_EU comment=Intel disabled=yes forward-to=Google \
    match-subdomain=yes name=centrino.net type=FWD
add address-list=BlackList_EU comment=Intel disabled=yes forward-to=Google \
    match-subdomain=yes name=chips.com type=FWD
add address-list=BlackList_EU comment=Intel disabled=yes forward-to=Google \
    match-subdomain=yes name=cilk.com type=FWD
add address-list=BlackList_EU comment=Intel disabled=yes forward-to=Google \
    match-subdomain=yes name=cilk.net type=FWD
add address-list=BlackList_EU comment=Intel disabled=yes forward-to=Google \
    match-subdomain=yes name=cloudinsights.com type=FWD
add address-list=BlackList_EU comment=Intel disabled=yes forward-to=Google \
    match-subdomain=yes name=clusterconnection.com type=FWD
add address-list=BlackList_EU comment=Intel disabled=yes forward-to=Google \
    match-subdomain=yes name=coreduo.com type=FWD
add address-list=BlackList_EU comment=Intel disabled=yes forward-to=Google \
    match-subdomain=yes name=coreextreme.com type=FWD
add address-list=BlackList_EU comment=Intel disabled=yes forward-to=Google \
    match-subdomain=yes name=crosswalk-project.com type=FWD
add address-list=BlackList_EU comment=Intel disabled=yes forward-to=Google \
    match-subdomain=yes name=crosswalk-project.net type=FWD
add address-list=BlackList_EU comment=Intel disabled=yes forward-to=Google \
    match-subdomain=yes name=doceapower.com type=FWD
add address-list=BlackList_EU comment=Intel disabled=yes forward-to=Google \
    match-subdomain=yes name=easic.com type=FWD
add address-list=BlackList_EU comment=Intel disabled=yes forward-to=Google \
    match-subdomain=yes name=enpirion.com type=FWD
add address-list=BlackList_EU comment=Intel disabled=yes forward-to=Google \
    match-subdomain=yes name=exascale-tech.com type=FWD
add address-list=BlackList_EU comment=Intel disabled=yes forward-to=Google \
    match-subdomain=yes name=gordonmoore.com type=FWD
add address-list=BlackList_EU comment=Intel forward-to=Google \
    match-subdomain=yes name=insidefilms.com type=FWD
add address-list=BlackList_EU comment=Intel disabled=yes forward-to=Google \
    match-subdomain=yes name=intc.com type=FWD
add address-list=BlackList_EU comment=Intel disabled=yes forward-to=Google \
    match-subdomain=yes name=itnel.com type=FWD
add address-list=BlackList_EU comment=Intel disabled=yes forward-to=Google \
    match-subdomain=yes name=latencytop.com type=FWD
add address-list=BlackList_EU comment=Intel disabled=yes forward-to=Google \
    match-subdomain=yes name=lookinside.com type=FWD
add address-list=BlackList_EU comment=Intel disabled=yes forward-to=Google \
    match-subdomain=yes name=makebettercode.com type=FWD
add address-list=BlackList_EU comment=Intel disabled=yes forward-to=Google \
    match-subdomain=yes name=makesenseofdata.com type=FWD
add address-list=BlackList_EU comment=Intel disabled=yes forward-to=Google \
    match-subdomain=yes name=movidius.com type=FWD
add address-list=BlackList_EU comment=Intel disabled=yes forward-to=Google \
    match-subdomain=yes name=movidius.net type=FWD
add address-list=BlackList_EU comment=Intel disabled=yes forward-to=Google \
    match-subdomain=yes name=nervanasys.com type=FWD
add address-list=BlackList_EU comment=Intel disabled=yes forward-to=Google \
    match-subdomain=yes name=nevex.com type=FWD
add address-list=BlackList_EU comment=Intel disabled=yes forward-to=Google \
    match-subdomain=yes name=nextgenerationcenter.com type=FWD
add address-list=BlackList_EU comment=Intel disabled=yes forward-to=Google \
    match-subdomain=yes name=niosii.com type=FWD
add address-list=BlackList_EU comment=Intel disabled=yes forward-to=Google \
    match-subdomain=yes name=niosii.net type=FWD
add address-list=BlackList_EU comment=Intel disabled=yes forward-to=Google \
    match-subdomain=yes name=omekinteractive.com type=FWD
add address-list=BlackList_EU comment=Intel disabled=yes forward-to=Google \
    match-subdomain=yes name=omnitek.tv type=FWD
add address-list=BlackList_EU comment=Intel disabled=yes forward-to=Google \
    match-subdomain=yes name=openamt.com type=FWD
add address-list=BlackList_EU comment=Intel forward-to=Google \
    match-subdomain=yes name=iherb.com type=FWD
add address-list=BlackList_EU comment=Intel disabled=yes forward-to=Google \
    match-subdomain=yes name=opendroneid.org type=FWD
add address-list=BlackList_EU comment=Intel disabled=yes forward-to=Google \
    match-subdomain=yes name=optanedifference.com type=FWD
add address-list=BlackList_EU comment=Intel disabled=yes forward-to=Google \
    match-subdomain=yes name=pc.com type=FWD
add address-list=BlackList_EU comment=Intel disabled=yes forward-to=Google \
    match-subdomain=yes name=pentium.com type=FWD
add address-list=BlackList_EU comment=Intel disabled=yes forward-to=Google \
    match-subdomain=yes name=pentium.net type=FWD
add address-list=BlackList_EU comment=Intel disabled=yes forward-to=Google \
    match-subdomain=yes name=pintool.com type=FWD
add address-list=BlackList_EU comment=Intel disabled=yes forward-to=Google \
    match-subdomain=yes name=reconinstruments.com type=FWD
add address-list=BlackList_EU comment=Intel disabled=yes forward-to=Google \
    match-subdomain=yes name=reconjet.com type=FWD
add address-list=BlackList_EU comment=Intel disabled=yes forward-to=Google \
    match-subdomain=yes name=sensorynetworks.com type=FWD
add address-list=BlackList_EU comment=Intel disabled=yes forward-to=Google \
    match-subdomain=yes name=siport.com type=FWD
add address-list=BlackList_EU comment=Intel disabled=yes forward-to=Google \
    match-subdomain=yes name=smart-edge.com type=FWD
add address-list=BlackList_EU comment=Gemini forward-to=Google \
    match-subdomain=yes name=gemini.google.com type=FWD
add address-list=BlackList_EU comment=arduino forward-to=Google \
    match-subdomain=yes name=arduino.cc type=FWD
add address-list=BlackList_EU comment=Gemini forward-to=Google \
    match-subdomain=yes name=hashicorp.com type=FWD
add address-list=BlackList_EU comment=Gemini forward-to=Google \
    match-subdomain=yes name=hashicorp.cloud type=FWD
add address-list=BlackList_EU comment=Gemini forward-to=Google \
    match-subdomain=yes name=vagrantcloud.com type=FWD
add address-list=BlackList_EU comment=Gemini forward-to=Google \
    match-subdomain=yes name=onlinesim.ru type=FWD
add address-list=BlackList_EU comment=Gemini forward-to=Google \
    match-subdomain=yes name=https://vagrantcloud.com/ type=FWD
add address-list=BlackList_EU comment=TMDB disabled=yes forward-to=Quad9 \
    match-subdomain=yes name=tmdb-image-prod.b-cdn.net type=FWD
add address-list=BlackList_EU comment=TMDB disabled=yes forward-to=Quad9 \
    match-subdomain=yes name=themoviedb.org type=FWD
add address-list=BlackList_EU comment=TMDB disabled=yes forward-to=Quad9 \
    match-subdomain=yes name=tmdb.org type=FWD
add address-list=BlackList_EU comment=Canva disabled=yes forward-to=Google \
    match-subdomain=yes name=canva.com type=FWD
add address-list=BlackList_EU comment=Spotify disabled=yes forward-to=Google \
    name=audio-ak-spotify-com.akamaized.net type=FWD
add address-list=BlackList_EU comment=Spotify disabled=yes forward-to=Google \
    name=audio4-ak-spotify-com.akamaized.net type=FWD
add address-list=BlackList_EU comment=Spotify disabled=yes forward-to=Google \
    name=cdn-spotify-experiments.conductrics.com type=FWD
add address-list=BlackList_EU comment=Spotify disabled=yes forward-to=Google \
    name=heads-ak-spotify-com.akamaized.net type=FWD
add address-list=BlackList_EU comment=Spotify disabled=yes forward-to=Google \
    name=heads4-ak-spotify-com.akamaized.net type=FWD
add address-list=BlackList_EU comment=Spotify disabled=yes forward-to=Google \
    name=spotify.com.edgesuite.net type=FWD
add address-list=BlackList_EU comment=Spotify disabled=yes forward-to=Google \
    name=spotify.map.fastly.net type=FWD
add address-list=BlackList_EU comment=Spotify disabled=yes forward-to=Google \
    name=spotify.map.fastlylb.net type=FWD
add address-list=BlackList_EU comment=Spotify disabled=yes forward-to=Google \
    match-subdomain=yes name=byspotify.com type=FWD
add address-list=BlackList_EU comment=Spotify disabled=yes forward-to=Google \
    match-subdomain=yes name=pscdn.co type=FWD
add address-list=BlackList_EU comment=Spotify disabled=yes forward-to=Google \
    match-subdomain=yes name=scdn.co type=FWD
add address-list=BlackList_EU comment=Spotify disabled=yes forward-to=Google \
    match-subdomain=yes name=spoti.fi type=FWD
add address-list=BlackList_EU comment=Spotify disabled=yes forward-to=Google \
    match-subdomain=yes name=spotify-everywhere.com type=FWD
add address-list=BlackList_EU comment=Spotify disabled=yes forward-to=Google \
    match-subdomain=yes name=spotify.com type=FWD
add address-list=BlackList_EU comment=Spotify disabled=yes forward-to=Google \
    match-subdomain=yes name=spotify.design type=FWD
add address-list=BlackList_EU forward-to=Google match-subdomain=yes name=\
    bestchange.ru type=FWD
add address-list=BlackList_EU forward-to=Google match-subdomain=yes name=\
    hetzner.com type=FWD
add address-list=BlackList_EU forward-to=Google match-subdomain=yes name=\
    bestchange.com type=FWD
add address-list=BlackList_EU comment=Spotify disabled=yes forward-to=Google \
    match-subdomain=yes name=spotifycdn.com type=FWD
add address-list=BlackList_EU comment=Spotify disabled=yes forward-to=Google \
    match-subdomain=yes name=spotifycdn.net type=FWD
add address-list=BlackList_EU comment=Spotify disabled=yes forward-to=Google \
    match-subdomain=yes name=spotifycharts.com type=FWD
add address-list=BlackList_EU comment=Spotify disabled=yes forward-to=Google \
    match-subdomain=yes name=spotifycodes.com type=FWD
add address-list=BlackList_EU comment=Spotify disabled=yes forward-to=Google \
    match-subdomain=yes name=spotifyforbrands.com type=FWD
add address-list=BlackList_EU comment=Spotify disabled=yes forward-to=Google \
    match-subdomain=yes name=spotifyjobs.com type=FWD
add address-list=BlackList_EU comment=Spotify disabled=yes forward-to=Google \
    match-subdomain=yes name=spotify.link type=FWD
add address-list=BlackList_EU comment=TikTok disabled=yes forward-to=Google \
    name=p16-tiktokcdn-com.akamaized.net type=FWD
add address-list=BlackList_EU comment=TikTok disabled=yes forward-to=Google \
    match-subdomain=yes name=byteoversea.com type=FWD
add address-list=BlackList_EU comment=TikTok disabled=yes forward-to=Google \
    match-subdomain=yes name=muscdn.com type=FWD
add address-list=BlackList_EU comment=TikTok disabled=yes forward-to=Google \
    match-subdomain=yes name=musical.ly type=FWD
add address-list=BlackList_EU comment=TikTok disabled=yes forward-to=Google \
    match-subdomain=yes name=tik-tokapi.com type=FWD
add address-list=BlackList_EU comment=TikTok disabled=yes forward-to=Google \
    match-subdomain=yes name=tiktok.com type=FWD
add address-list=BlackList_EU comment=TikTok disabled=yes forward-to=Google \
    match-subdomain=yes name=tiktokcdn-eu.com type=FWD
add address-list=BlackList_EU comment=TikTok disabled=yes forward-to=Google \
    match-subdomain=yes name=tiktokcdn-us.com type=FWD
add address-list=BlackList_EU comment=TikTok disabled=yes forward-to=Google \
    match-subdomain=yes name=tiktokcdn.com type=FWD
add address-list=BlackList_EU comment=TikTok disabled=yes forward-to=Google \
    match-subdomain=yes name=tiktokd.net type=FWD
add address-list=BlackList_EU comment=TikTok disabled=yes forward-to=Google \
    match-subdomain=yes name=tiktokd.org type=FWD
add address-list=BlackList_EU comment=TikTok disabled=yes forward-to=Google \
    match-subdomain=yes name=tiktokeu-cdn.com type=FWD
add address-list=BlackList_EU comment=TikTok disabled=yes forward-to=Google \
    match-subdomain=yes name=tiktokrow-cdn.com type=FWD
add address-list=BlackList_EU comment=TikTok disabled=yes forward-to=Google \
    match-subdomain=yes name=tiktokv.com type=FWD
add address-list=BlackList_EU comment=TikTok disabled=yes forward-to=Google \
    match-subdomain=yes name=tiktokv.eu type=FWD
add address-list=BlackList_EU comment=TikTok disabled=yes forward-to=Google \
    match-subdomain=yes name=tiktokv.us type=FWD
add address-list=BlackList_EU comment=TikTok disabled=yes forward-to=Google \
    match-subdomain=yes name=tiktokw.eu type=FWD
add address-list=BlackList_EU comment=TikTok disabled=yes forward-to=Google \
    match-subdomain=yes name=tiktokw.us type=FWD
add address-list=BlackList_EU comment=TikTok disabled=yes forward-to=Google \
    match-subdomain=yes name=ttlivecdn.com type=FWD
add address-list=BlackList_EU comment=TikTok disabled=yes forward-to=Google \
    match-subdomain=yes name=ttoverseaus.net type=FWD
add address-list=BlackList_EU comment=Habr forward-to=Google match-subdomain=\
    yes name=habr.com type=FWD
add address-list=BlackList_EU comment=Habr disabled=yes forward-to=Google \
    match-subdomain=yes name=yandex.ru type=FWD
add address-list=BlackList_EU comment=Habr disabled=yes forward-to=Google \
    match-subdomain=yes name=yandex.net type=FWD
add address-list=BlackList_EU comment=Habr disabled=yes forward-to=Google \
    match-subdomain=yes name=vidaa.com type=FWD
add address-list=BlackList_EU comment=Habr disabled=yes forward-to=Google \
    match-subdomain=yes name=ya.ru type=FWD
add address-list=BlackList_EU comment=TikTok disabled=yes forward-to=Google \
    match-subdomain=yes name=ttwstatic.com type=FWD
add address-list=BlackList_EU comment=Habr forward-to=Google match-subdomain=\
    yes name=notebooklm.google.com type=FWD
add address-list=BlackList_EU comment=Habr forward-to=Google match-subdomain=\
    yes name=waybig.com type=FWD
add address-list=BlackList_EU comment=apple.com forward-to=Google \
    match-subdomain=yes name=apple.com type=FWD
add address-list=BlackList_EU comment=osboxes.org forward-to=Google \
    match-subdomain=yes name=osboxes.org type=FWD
add address-list=BlackList_EU comment=dw.com forward-to=Google \
    match-subdomain=yes name=dw.com type=FWD
add address-list=BlackList_EU comment=eneba.com forward-to=Google \
    match-subdomain=yes name=eneba.com type=FWD
add address-list=BlackList_EU comment=spotify.com forward-to=Google \
    match-subdomain=yes name=spotify.com type=FWD
add address-list=BlackList_EU comment=yahoo.com forward-to=Google \
    match-subdomain=yes name=yahoo.com type=FWD
add address-list=BlackList_EU comment=yahoo.com forward-to=Google \
    match-subdomain=yes name=elastic.co type=FWD
add address-list=BlackList_EU comment=yahoo.com forward-to=Google \
    match-subdomain=yes name=broadcom.com type=FWD
add address-list=BlackList_EU comment=megachange.ru forward-to=Google \
    match-subdomain=yes name=megachange.ru type=FWD
add address-list=BlackList_EU comment=bitkovskiy.io forward-to=Google \
    match-subdomain=yes name=bitkovskiy.io type=FWD
add address-list=BlackList_EU comment=microsoft.com forward-to=Google \
    match-subdomain=yes name=microsoft.com type=FWD
add address-list=BlackList_EU comment=nnm-club-me.ru forward-to=Google \
    match-subdomain=yes name=nnm-club-me.ru type=FWD
add address-list=BlackList_EU comment=claude.com forward-to=Google \
    match-subdomain=yes name=claude.com type=FWD
add address-list=BlackList_EU comment=justproxy.biz forward-to=Google \
    match-subdomain=yes name=justproxy.biz type=FWD
add address-list=BlackList_EU comment=ntfy.sh forward-to=Google \
    match-subdomain=yes name=ntfy.sh type=FWD
add address-list=BlackList_EU comment=terraform.io forward-to=Google \
    match-subdomain=yes name=terraform.io type=FWD
add address-list=BlackList_EU comment=redd.it forward-to=Google \
    match-subdomain=yes name=redd.it type=FWD
add address-list=BlackList_EU comment=redditstatic.com forward-to=Google \
    match-subdomain=yes name=redditstatic.com type=FWD
add address-list=BlackList_EU comment=reddit.com forward-to=Google \
    match-subdomain=yes name=reddit.com type=FWD
add address-list=BlackList_EU comment=xhamster.com forward-to=Google \
    match-subdomain=yes name=xhamster.com type=FWD
add address-list=BlackList_EU comment=redditmedia.com forward-to=Google \
    match-subdomain=yes name=redditmedia.com type=FWD
add address-list=BlackList_EU comment=redgifs.com forward-to=Google \
    match-subdomain=yes name=redgifs.com type=FWD
add address=198.18.1.1 disabled=yes name=2ip.ru ttl=1h type=A
add address=198.18.1.1 disabled=yes name=leader.ru ttl=1h type=A
add address=160.79.104.10 address-list=BlackList_EU disabled=yes name=\
    api.anthropic.com type=A
add address-list=BlackList_EU disabled=yes forward-to=Google match-subdomain=\
    yes name=anthropic.com type=FWD
add address=::ffff:160.79.104.10 address-list=BlackList_EU disabled=yes name=\
    api.anthropic.com type=AAAA
add address-list=BlackList_EU disabled=yes forward-to=Google match-subdomain=\
    yes name=claude.ai type=FWD
add address=160.79.104.10 address-list=BlackList_EU disabled=yes name=\
    console.anthropic.com type=A
add address-list=BlackList_EU forward-to=Google match-subdomain=yes name=\
    mobatek.net type=FWD
add address-list=BlackList_EU comment=WhatsApp forward-to=Google \
    match-subdomain=yes name=whatsapp.com type=FWD
add address-list=BlackList_EU comment=WhatsApp forward-to=Google \
    match-subdomain=yes name=whatsapp.net type=FWD
/ip firewall address-list
add address=31.13.24.0/21 comment=FaceBook list=BlackList_RU
add address=31.13.64.0/18 comment=FaceBook list=BlackList_RU
add address=45.64.40.0/22 comment=FaceBook list=BlackList_RU
add address=57.141.0.0/24 comment=FaceBook list=BlackList_RU
add address=57.141.2.0/24 comment=FaceBook list=BlackList_RU
add address=57.141.4.0/24 comment=FaceBook list=BlackList_RU
add address=57.141.6.0/24 comment=FaceBook list=BlackList_RU
add address=57.141.8.0/24 comment=FaceBook list=BlackList_RU
add address=57.141.10.0/24 comment=FaceBook list=BlackList_RU
add address=57.141.12.0/24 comment=FaceBook list=BlackList_RU
add address=57.144.0.0/14 comment=FaceBook list=BlackList_RU
add address=66.220.144.0/20 comment=FaceBook list=BlackList_RU
add address=69.63.176.0/20 comment=FaceBook list=BlackList_RU
add address=69.171.224.0/19 comment=FaceBook list=BlackList_RU
add address=74.119.76.0/22 comment=FaceBook list=BlackList_RU
add address=102.132.96.0/20 comment=FaceBook list=BlackList_RU
add address=102.132.112.0/24 comment=FaceBook list=BlackList_RU
add address=102.132.114.0/23 comment=FaceBook list=BlackList_RU
add address=102.132.116.0/23 comment=FaceBook list=BlackList_RU
add address=102.132.119.0/24 comment=FaceBook list=BlackList_RU
add address=102.132.120.0/23 comment=FaceBook list=BlackList_RU
add address=102.132.123.0/24 comment=FaceBook list=BlackList_RU
add address=102.132.125.0/24 comment=FaceBook list=BlackList_RU
add address=102.132.126.0/23 comment=FaceBook list=BlackList_RU
add address=102.221.188.0/22 comment=FaceBook list=BlackList_RU
add address=103.4.96.0/22 comment=FaceBook list=BlackList_RU
add address=129.134.0.0/17 comment=FaceBook list=BlackList_RU
add address=129.134.130.0/23 comment=FaceBook list=BlackList_RU
add address=129.134.132.0/24 comment=FaceBook list=BlackList_RU
add address=129.134.135.0/24 comment=FaceBook list=BlackList_RU
add address=129.134.136.0/22 comment=FaceBook list=BlackList_RU
add address=129.134.140.0/24 comment=FaceBook list=BlackList_RU
add address=129.134.143.0/24 comment=FaceBook list=BlackList_RU
add address=129.134.144.0/24 comment=FaceBook list=BlackList_RU
add address=129.134.147.0/24 comment=FaceBook list=BlackList_RU
add address=129.134.148.0/23 comment=FaceBook list=BlackList_RU
add address=129.134.150.0/24 comment=FaceBook list=BlackList_RU
add address=129.134.154.0/23 comment=FaceBook list=BlackList_RU
add address=129.134.156.0/22 comment=FaceBook list=BlackList_RU
add address=129.134.160.0/22 comment=FaceBook list=BlackList_RU
add address=129.134.164.0/23 comment=FaceBook list=BlackList_RU
add address=129.134.168.0/24 comment=FaceBook list=BlackList_RU
add address=129.134.170.0/23 comment=FaceBook list=BlackList_RU
add address=129.134.172.0/22 comment=FaceBook list=BlackList_RU
add address=129.134.176.0/20 comment=FaceBook list=BlackList_RU
add address=157.240.0.0/17 comment=FaceBook list=BlackList_RU
add address=157.240.128.0/23 comment=FaceBook list=BlackList_RU
add address=157.240.131.0/24 comment=FaceBook list=BlackList_RU
add address=157.240.156.0/22 comment=FaceBook list=BlackList_RU
add address=157.240.169.0/24 comment=FaceBook list=BlackList_RU
add address=157.240.170.0/24 comment=FaceBook list=BlackList_RU
add address=157.240.175.0/24 comment=FaceBook list=BlackList_RU
add address=157.240.177.0/24 comment=FaceBook list=BlackList_RU
add address=157.240.179.0/24 comment=FaceBook list=BlackList_RU
add address=157.240.181.0/24 comment=FaceBook list=BlackList_RU
add address=157.240.182.0/23 comment=FaceBook list=BlackList_RU
add address=157.240.184.0/21 comment=FaceBook list=BlackList_RU
add address=157.240.192.0/18 comment=FaceBook list=BlackList_RU
add address=163.70.128.0/17 comment=FaceBook list=BlackList_RU
add address=163.114.128.0/20 comment=FaceBook list=BlackList_RU
add address=173.252.64.0/18 comment=FaceBook list=BlackList_RU
add address=179.60.192.0/22 comment=FaceBook list=BlackList_RU
add address=185.60.216.0/22 comment=FaceBook list=BlackList_RU
add address=185.89.216.0/22 comment=FaceBook list=BlackList_RU
add address=199.201.64.0/22 comment=FaceBook list=BlackList_RU
add address=204.15.20.0/22 comment=FaceBook list=BlackList_RU
add address=8.25.194.0/23 comment=Twitter list=BlackList_RU
add address=8.25.196.0/23 comment=Twitter list=BlackList_RU
add address=64.63.0.0/18 comment=Twitter list=BlackList_RU
add address=69.12.56.0/21 comment=Twitter list=BlackList_RU
add address=69.195.160.0/19 comment=Twitter list=BlackList_RU
add address=103.252.112.0/22 comment=Twitter list=BlackList_RU
add address=104.244.40.0/23 comment=Twitter list=BlackList_RU
add address=104.244.42.0/24 comment=Twitter list=BlackList_RU
add address=104.244.44.0/22 comment=Twitter list=BlackList_RU
add address=185.45.4.0/22 comment=Twitter list=BlackList_RU
add address=188.64.224.0/21 comment=Twitter list=BlackList_RU
add address=192.48.236.0/23 comment=Twitter list=BlackList_RU
add address=192.133.76.0/22 comment=Twitter list=BlackList_RU
add address=199.16.156.0/22 comment=Twitter list=BlackList_RU
add address=199.59.148.0/22 comment=Twitter list=BlackList_RU
add address=199.96.56.0/23 comment=Twitter list=BlackList_RU
add address=202.160.128.0/22 comment=Twitter list=BlackList_RU
add address=209.237.192.0/19 comment=Twitter list=BlackList_RU
add address=23.246.0.0/18 comment=Netflix list=BlackList_EU
add address=37.77.184.0/21 comment=Netflix list=BlackList_EU
add address=45.57.0.0/17 comment=Netflix list=BlackList_EU
add address=64.120.128.0/17 comment=Netflix list=BlackList_EU
add address=66.197.128.0/19 comment=Netflix list=BlackList_EU
add address=66.197.160.0/20 comment=Netflix list=BlackList_EU
add address=66.197.182.0/23 comment=Netflix list=BlackList_EU
add address=66.197.186.0/23 comment=Netflix list=BlackList_EU
add address=66.197.188.0/22 comment=Netflix list=BlackList_EU
add address=66.197.192.0/18 comment=Netflix list=BlackList_EU
add address=69.53.224.0/20 comment=Netflix list=BlackList_EU
add address=69.53.240.0/21 comment=Netflix list=BlackList_EU
add address=69.53.248.0/23 comment=Netflix list=BlackList_EU
add address=69.53.250.0/24 comment=Netflix list=BlackList_EU
add address=69.53.252.0/22 comment=Netflix list=BlackList_EU
add address=108.175.32.0/20 comment=Netflix list=BlackList_EU
add address=185.2.220.0/22 comment=Netflix list=BlackList_EU
add address=185.9.188.0/22 comment=Netflix list=BlackList_EU
add address=192.173.64.0/18 comment=Netflix list=BlackList_EU
add address=198.38.96.0/19 comment=Netflix list=BlackList_EU
add address=198.45.48.0/20 comment=Netflix list=BlackList_EU
add address=207.45.72.0/22 comment=Netflix list=BlackList_EU
add address=208.75.76.0/22 comment=Netflix list=BlackList_EU
add address=160.79.104.0/23 comment="Anthropic API" list=BlackList_EU
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
add action=jump chain=input in-interface-list=LAN jump-target=LAN-Input
add action=jump chain=input in-interface-list=WAN jump-target=ISP-Input
add action=jump chain=input in-interface-list=VPN-OUT jump-target=VPN-Input
add action=jump chain=input in-interface-list=GUEST jump-target=GUEST-Input \
    log=yes log-prefix=GUEST-Input:
add action=accept chain=input comment="Allow NetBIOS on loopback" dst-port=\
    137-138 in-interface=lo protocol=udp
add action=drop chain=input comment="Drop all other to router" log=yes \
    log-prefix=INPUT-DROP:
add action=accept chain=LAN-Input comment="Accept all from LAN"
add action=accept chain=ISP-Input connection-state=established
add action=accept chain=ISP-Input connection-state=related
add action=accept chain=ISP-Input connection-state=untracked
add action=drop chain=ISP-Input connection-state=invalid
add action=jump chain=ISP-Input jump-target=ISP-Input-Allow
add action=drop chain=ISP-Input comment="Drop all other"
add action=accept chain=ISP-Input-Allow protocol=icmp
add action=jump chain=ISP-Input-Allow comment=SSH connection-nat-state=dstnat \
    dst-port=22 jump-target=Brute-force protocol=tcp
add action=drop chain=ISP-Input-Allow comment="Drop Winbox from WAN" \
    dst-port=8291 protocol=tcp
add action=jump chain=ISP-Input-Allow comment=Winbox dst-port=8291 \
    jump-target=Brute-force protocol=tcp
add action=drop chain=Brute-force src-address-list=Brute-force-block
add action=add-src-to-address-list address-list=Brute-force-block \
    address-list-timeout=8h chain=Brute-force src-address-list=Brute-force-4
add action=add-src-to-address-list address-list=Brute-force-4 \
    address-list-timeout=30s chain=Brute-force src-address-list=Brute-force-3
add action=add-src-to-address-list address-list=Brute-force-3 \
    address-list-timeout=30s chain=Brute-force src-address-list=Brute-force-2
add action=add-src-to-address-list address-list=Brute-force-2 \
    address-list-timeout=30s chain=Brute-force src-address-list=Brute-force-1
add action=add-src-to-address-list address-list=Brute-force-1 \
    address-list-timeout=30s chain=Brute-force
add action=accept chain=Brute-force
add action=jump chain=forward in-interface-list=WAN jump-target=ISP-Forward
add action=jump chain=forward in-interface-list=VPN-OUT jump-target=\
    VPN-Forward
add action=jump chain=forward in-interface-list=LAN jump-target=LAN-Forward
add action=jump chain=forward in-interface-list=GUEST jump-target=\
    GUEST-Forward
add action=drop chain=forward comment="Drop all other"
add action=accept chain=LAN-Forward connection-state=established
add action=accept chain=LAN-Forward connection-state=related
add action=accept chain=LAN-Forward connection-state=untracked
add action=drop chain=LAN-Forward connection-state=invalid
add action=accept chain=LAN-Forward comment="Accept new from LAN"
add action=accept chain=ISP-Forward connection-state=established
add action=accept chain=ISP-Forward connection-state=related
add action=accept chain=ISP-Forward connection-state=untracked
add action=drop chain=ISP-Forward connection-state=invalid
add action=accept chain=ISP-Forward comment="Accept DST-NAT" \
    connection-nat-state=dstnat
add action=drop chain=ISP-Forward comment="Drop all other from WAN"
add action=accept chain=ISP-Input-Allow comment="WireGuard WG_Home" dst-port=\
    51820 protocol=udp
add action=accept chain=GUEST-Forward comment="GUEST-FWD Accept established" \
    connection-state=established
add action=accept chain=GUEST-Forward comment="GUEST-FWD Accept related" \
    connection-state=related
add action=accept chain=GUEST-Forward comment="GUEST-FWD Accept untracked" \
    connection-state=untracked
add action=drop chain=GUEST-Forward comment="GUEST-FWD Drop invalid" \
    connection-state=invalid
add action=accept chain=GUEST-Forward comment=\
    "GUEST-FWD Allow BlackList_RU VPN" connection-mark=BlackList_RU
add action=accept chain=GUEST-Forward comment=\
    "GUEST-FWD Allow BlackList_EU VPN" connection-mark=BlackList_EU
add action=drop chain=GUEST-Forward comment="GUEST-FWD Block RFC1918 10.x" \
    dst-address=10.0.0.0/8
add action=drop chain=GUEST-Forward comment="GUEST-FWD Block RFC1918 172.x" \
    dst-address=172.16.0.0/12
add action=drop chain=GUEST-Forward comment="GUEST-FWD Block RFC1918 192.x" \
    dst-address=192.168.0.0/16
add action=accept chain=GUEST-Forward comment="GUEST-FWD Allow to WAN" \
    out-interface-list=WAN
add action=drop chain=GUEST-Forward comment="GUEST-FWD Drop all other"
add action=accept chain=VPN-Input comment="VPN Accept established" \
    connection-state=established
add action=accept chain=VPN-Input comment="VPN Accept related" \
    connection-state=related
add action=accept chain=VPN-Input comment="VPN Accept untracked" \
    connection-state=untracked
add action=drop chain=VPN-Input comment="VPN Drop invalid" connection-state=\
    invalid
add action=accept chain=VPN-Input comment="Allow containers DNS to router" \
    dst-port=53 protocol=udp src-address=192.168.254.0/24
add action=drop chain=VPN-Input comment="VPN Drop all other"
add action=accept chain=VPN-Forward comment="VPN-FWD Accept established" \
    connection-state=established
add action=accept chain=VPN-Forward comment="VPN-FWD Accept related" \
    connection-state=related
add action=accept chain=VPN-Forward comment="VPN-FWD Accept untracked" \
    connection-state=untracked
add action=drop chain=VPN-Forward comment="VPN-FWD Drop invalid" \
    connection-state=invalid
add action=accept chain=VPN-Forward comment="VPN-FWD Allow new to WAN" \
    connection-state=new out-interface-list=WAN
add action=drop chain=VPN-Forward comment="VPN-FWD Drop new (disabled)" \
    disabled=yes
add action=accept chain=GUEST-Input comment="GUEST Accept established" \
    connection-state=established
add action=accept chain=GUEST-Input comment="GUEST Accept related" \
    connection-state=related
add action=accept chain=GUEST-Input comment="GUEST Accept untracked" \
    connection-state=untracked
add action=drop chain=GUEST-Input comment="GUEST Drop invalid" \
    connection-state=invalid
add action=accept chain=GUEST-Input comment="GUEST Allow DNS" dst-port=53 \
    protocol=udp
add action=accept chain=GUEST-Input comment="GUEST Allow DHCP" dst-port=67 \
    protocol=udp
add action=drop chain=GUEST-Input comment="GUEST Drop all other"
/ip firewall mangle
add action=accept chain=prerouting comment=\
    "Skip NETMAP from BlackList marking" dst-address=10.200.200.0/24 \
    src-address=10.101.101.7
add action=mark-routing chain=prerouting dst-address=!10.101.101.0/24 \
    in-interface=WG_Home new-routing-mark=BlackList_RU passthrough=no \
    src-address=10.101.101.7
add action=accept chain=prerouting comment="Skip marking for containers" \
    src-address=192.168.254.0/24
add action=change-mss chain=postrouting new-mss=clamp-to-pmtu protocol=tcp \
    tcp-flags=syn
add action=mark-connection chain=prerouting connection-mark=no-mark \
    dst-address-list=BlackList_EU in-interface-list=LAN_and_GUEST \
    new-connection-mark=BlackList_EU
add action=mark-routing chain=prerouting comment="VPN-ALL: mark traffic" \
    disabled=yes dst-address=!192.168.0.1 in-interface-list=LAN_and_GUEST \
    new-routing-mark=vpn-all-table passthrough=no src-address=\
    !192.168.254.0/24
add action=mark-routing chain=prerouting comment=\
    "Route BlackList_EU via mihomo" connection-mark=BlackList_EU \
    in-interface-list=LAN_and_GUEST new-routing-mark=BlackList_EU \
    passthrough=no
add action=mark-connection chain=prerouting connection-mark=no-mark \
    dst-address-list=BlackList_RU in-interface-list=LAN_and_GUEST \
    new-connection-mark=BlackList_RU
add action=mark-routing chain=prerouting comment=\
    "Route BlackList_RU via mihomo" connection-mark=BlackList_RU \
    in-interface-list=LAN_and_GUEST new-routing-mark=BlackList_RU \
    passthrough=no
add action=mark-connection chain=prerouting comment=Discord_RTC \
    connection-bytes=102 connection-mark=no-mark content="\00\00\00\00\00\00\
    \00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\
    \00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\
    \00\00\00\00\00\00\00\00\00\00" dst-address-type=!local dst-port=\
    50000-50100 in-interface=!WG_Home in-interface-list=LAN \
    new-connection-mark=BlackList_RU protocol=udp
add action=change-mss chain=forward comment="MSS fix from WG_Home" \
    in-interface=WG_Home new-mss=1300 protocol=tcp tcp-flags=syn
add action=change-mss chain=forward comment="MSS fix to WG_Home" new-mss=1300 \
    out-interface=WG_Home protocol=tcp tcp-flags=syn
add action=passthrough chain=prerouting
/ip firewall nat
add action=masquerade chain=srcnat comment="WG to video server hairpin" \
    dst-address=192.168.0.243 log-prefix=SRC-NAT: src-address=10.101.101.0/24
add action=src-nat chain=srcnat out-interface=pppoe-out1 to-addresses=\
    212.20.46.209
add action=src-nat chain=srcnat comment="NAT for mihomo" out-interface=\
    Bridge-Docker to-addresses=192.168.254.1
add action=masquerade chain=srcnat comment="Hairpin NAT for 192.168.0.71" \
    dst-address=192.168.0.71 src-address=192.168.0.0/24
add action=masquerade chain=srcnat comment="Hairpin NAT for 192.168.0.243" \
    dst-address=192.168.0.243 log-prefix="NAT " src-address=192.168.0.0/24
add action=masquerade chain=srcnat comment="Hairpin NAT for 192.168.0.82" \
    dst-address=192.168.0.82 src-address=192.168.0.0/24
add action=accept chain=dstnat comment="Allow containers DNS direct" \
    dst-port=53 protocol=udp src-address=192.168.254.0/24
add action=redirect chain=dstnat dst-address-type=!local dst-port=53 \
    in-interface-list=!WAN protocol=udp src-address-type=!local
add action=dst-nat chain=dstnat disabled=yes dst-port=8080 protocol=tcp \
    to-addresses=192.168.0.243 to-ports=8080
add action=dst-nat chain=dstnat disabled=yes dst-port=555 protocol=tcp \
    to-addresses=192.168.0.243 to-ports=555
add action=masquerade chain=srcnat disabled=yes dst-address=192.168.0.243 \
    dst-port=8080 protocol=tcp
add action=masquerade chain=srcnat disabled=yes dst-address=192.168.0.243 \
    dst-port=555 protocol=tcp
add action=src-nat chain=srcnat comment="WG RDP: SNAT to VPN IP" dst-address=\
    10.101.101.242 to-addresses=10.101.101.1
add action=netmap chain=dstnat comment="NETMAP allow 192.168.0.71 for WG" \
    dst-address=10.200.200.71 to-addresses=192.168.0.71
add action=netmap chain=dstnat comment="NETMAP allow 192.168.0.243 for WG" \
    dst-address=10.200.200.243 to-addresses=192.168.0.243
add action=netmap chain=dstnat comment="NETMAP allow 192.168.0.78 for WG" \
    dst-address=10.200.200.82 to-addresses=192.168.0.82
add action=masquerade chain=srcnat comment="Containers to WAN" src-address=\
    192.168.254.0/24
add action=accept chain=dstnat comment="Allow containers DNS direct" \
    dst-port=53 protocol=udp src-address=192.168.254.0/24
add action=masquerade chain=srcnat comment="Containers to WAN" src-address=\
    192.168.254.0/24
add action=accept chain=dstnat comment="Allow containers DNS direct" \
    dst-port=53 protocol=udp src-address=192.168.254.0/24
add action=masquerade chain=srcnat comment="Containers to WAN" src-address=\
    192.168.254.0/24
add action=accept chain=dstnat comment="Allow containers DNS direct" \
    dst-port=53 protocol=udp src-address=192.168.254.0/24
add action=masquerade chain=srcnat comment="Containers to WAN" src-address=\
    192.168.254.0/24
add action=accept chain=dstnat comment="Allow containers DNS direct" \
    dst-port=53 protocol=udp src-address=192.168.254.0/24
add action=masquerade chain=srcnat comment="Containers to WAN" src-address=\
    192.168.254.0/24
add action=accept chain=dstnat comment="Allow containers DNS direct" \
    dst-port=53 protocol=udp src-address=192.168.254.0/24
add action=masquerade chain=srcnat comment="Containers to WAN" src-address=\
    192.168.254.0/24
add action=accept chain=dstnat comment="Allow containers DNS direct" \
    dst-port=53 protocol=udp src-address=192.168.254.0/24
add action=masquerade chain=srcnat comment="Containers to WAN" src-address=\
    192.168.254.0/24
add action=accept chain=dstnat comment="Allow containers DNS direct" \
    dst-port=53 protocol=udp src-address=192.168.254.0/24
add action=masquerade chain=srcnat comment="Containers to WAN" src-address=\
    192.168.254.0/24
add action=accept chain=dstnat comment="Allow containers DNS direct" \
    dst-port=53 protocol=udp src-address=192.168.254.0/24
add action=masquerade chain=srcnat comment="Containers to WAN" src-address=\
    192.168.254.0/24
add action=accept chain=dstnat comment="Allow containers DNS direct" \
    dst-port=53 protocol=udp src-address=192.168.254.0/24
add action=masquerade chain=srcnat comment="Containers to WAN" src-address=\
    192.168.254.0/24
add action=accept chain=dstnat comment="Allow containers DNS direct" \
    dst-port=53 protocol=udp src-address=192.168.254.0/24
add action=masquerade chain=srcnat comment="Containers to WAN" src-address=\
    192.168.254.0/24
add action=accept chain=dstnat comment="Allow containers DNS direct" \
    dst-port=53 protocol=udp src-address=192.168.254.0/24
add action=masquerade chain=srcnat comment="Containers to WAN" src-address=\
    192.168.254.0/24
add action=accept chain=dstnat comment="Allow containers DNS direct" \
    dst-port=53 protocol=udp src-address=192.168.254.0/24
add action=masquerade chain=srcnat comment="Containers to WAN" src-address=\
    192.168.254.0/24
add action=accept chain=dstnat comment="Allow containers DNS direct" \
    dst-port=53 protocol=udp src-address=192.168.254.0/24
add action=masquerade chain=srcnat comment="Containers to WAN" src-address=\
    192.168.254.0/24
add action=accept chain=dstnat comment="Allow containers DNS direct" \
    dst-port=53 protocol=udp src-address=192.168.254.0/24
add action=masquerade chain=srcnat comment="Containers to WAN" src-address=\
    192.168.254.0/24
add action=accept chain=dstnat comment="Allow containers DNS direct" \
    dst-port=53 protocol=udp src-address=192.168.254.0/24
/ip firewall raw
add action=drop chain=prerouting log-prefix=RAW-CYBEROK-DROP \
    src-address-list=cyberok-ban
add action=drop chain=prerouting comment=\
    "Drop all traffic from RDP bruteforcers" src-address-list=rdp-bruteforce
add action=add-src-to-address-list address-list=rdp-bruteforce \
    address-list-timeout=1w chain=prerouting comment=\
    "Honeypot: catch RDP scanners" dst-port=3389 in-interface-list=!LAN \
    log-prefix=RDP-HONEYPOT protocol=tcp
/ip firewall service-port
set ftp disabled=yes
set sip disabled=yes
/ip ipsec profile
set [ find default=yes ] dh-group=modp1024 dpd-interval=2m \
    dpd-maximum-failures=5 enc-algorithm=aes-256,3des
/ip route
add disabled=no distance=1 dst-address=0.0.0.0/0 gateway=192.168.254.4 \
    routing-table=BlackList_EU scope=30 suppress-hw-offload=no target-scope=\
    10
add disabled=no distance=1 dst-address=0.0.0.0/0 gateway=192.168.254.3 \
    routing-table=BlackList_RU scope=30 suppress-hw-offload=no target-scope=\
    10
add disabled=yes distance=1 dst-address=0.0.0.0/0 gateway=192.168.254.5 \
    routing-table=RDP-Server scope=30 suppress-hw-offload=no target-scope=10
add disabled=yes distance=1 dst-address=0.0.0.0/0 gateway=192.168.254.3 \
    routing-table=vpn-all-table
add check-gateway=ping comment="nfqws2 gateway" gateway=192.168.254.6 \
    routing-table=to_nfqws2
/ip service
set ftp disabled=yes
set ssh address=192.168.0.0/24
set telnet disabled=yes
set www disabled=yes
set winbox address=192.168.0.0/24
set api disabled=yes
/ip smb shares
set [ find default=yes ] directory=/pub
add directory=usb1-part1/smb_share name=usb1
add directory=usb1/docker_configs name=docker_configs
/ip ssh
set always-allow-password-login=yes forwarding-enabled=local
/ipv6 firewall address-list
add address=::/128 comment="defconf: unspecified address" list=bad_ipv6
add address=::1/128 comment="defconf: lo" list=bad_ipv6
add address=fec0::/10 comment="defconf: site-local" list=bad_ipv6
add address=::ffff:0.0.0.0/96 comment="defconf: ipv4-mapped" list=bad_ipv6
add address=::/96 comment="defconf: ipv4 compat" list=bad_ipv6
add address=100::/64 comment="defconf: discard only " list=bad_ipv6
add address=2001:db8::/32 comment="defconf: documentation" list=bad_ipv6
add address=2001:10::/28 comment="defconf: ORCHID" list=bad_ipv6
add address=3ffe::/16 comment="defconf: 6bone" list=bad_ipv6
add address=::224.0.0.0/100 comment="defconf: other" list=bad_ipv6
add address=::127.0.0.0/104 comment="defconf: other" list=bad_ipv6
add address=::/104 comment="defconf: other" list=bad_ipv6
add address=::255.0.0.0/104 comment="defconf: other" list=bad_ipv6
add address=2607:6bc0::/48 comment="Anthropic IPv6" list=BlackList_EU
/ipv6 firewall filter
add action=accept chain=input comment=\
    "defconf: accept established,related,untracked" connection-state=\
    established,related,untracked
add action=drop chain=input comment="defconf: drop invalid" connection-state=\
    invalid
add action=accept chain=input comment="defconf: accept ICMPv6" protocol=\
    icmpv6
add action=accept chain=input comment="defconf: accept UDP traceroute" port=\
    33434-33534 protocol=udp
add action=accept chain=input comment=\
    "defconf: accept DHCPv6-Client prefix delegation." dst-port=546 protocol=\
    udp src-address=fe80::/16
add action=accept chain=input comment="defconf: accept IKE" dst-port=500,4500 \
    protocol=udp
add action=accept chain=input comment="defconf: accept ipsec AH" protocol=\
    ipsec-ah
add action=accept chain=input comment="defconf: accept ipsec ESP" protocol=\
    ipsec-esp
add action=accept chain=input comment=\
    "defconf: accept all that matches ipsec policy" ipsec-policy=in,ipsec
add action=drop chain=input comment=\
    "defconf: drop everything else not coming from LAN" in-interface-list=\
    !LAN
add action=accept chain=forward comment=\
    "defconf: accept established,related,untracked" connection-state=\
    established,related,untracked
add action=drop chain=forward comment="defconf: drop invalid" \
    connection-state=invalid
add action=drop chain=forward comment=\
    "defconf: drop packets with bad src ipv6" src-address-list=bad_ipv6
add action=drop chain=forward comment=\
    "defconf: drop packets with bad dst ipv6" dst-address-list=bad_ipv6
add action=drop chain=forward comment="defconf: rfc4890 drop hop-limit=1" \
    hop-limit=equal:1 protocol=icmpv6
add action=accept chain=forward comment="defconf: accept ICMPv6" protocol=\
    icmpv6
add action=accept chain=forward comment="defconf: accept HIP" protocol=139
add action=accept chain=forward comment="defconf: accept IKE" dst-port=\
    500,4500 protocol=udp
add action=accept chain=forward comment="defconf: accept ipsec AH" protocol=\
    ipsec-ah
add action=accept chain=forward comment="defconf: accept ipsec ESP" protocol=\
    ipsec-esp
add action=accept chain=forward comment=\
    "defconf: accept all that matches ipsec policy" ipsec-policy=in,ipsec
add action=drop chain=forward comment=\
    "defconf: drop everything else not coming from LAN" in-interface-list=\
    !LAN
/ipv6 nd
set [ find default=yes ] advertise-dns=no
/queue simple
add disabled=yes max-limit=100M/100M name=queue1 queue=queue1/queue1 target=\
    *F
/routing igmp-proxy interface
add alternative-subnets=0.0.0.0/0 interface=ether1 upstream=yes
add
/routing rule
add action=lookup disabled=yes routing-mark=*406 table=*406
add action=lookup disabled=yes routing-mark=*404 table=*404
add action=lookup disabled=yes routing-mark=vpn-all-table table=vpn-all-table
/snmp
set enabled=yes engine-id-suffix=D4:CA:6D:0D:FD:28 trap-generators=interfaces \
    trap-target=192.168.0.14 trap-version=3
/system clock
set time-zone-name=Asia/Novosibirsk
/system identity
set name=Mik_Tim
/system logging
add disabled=yes topics=dns
add action=disk topics=container,system
add topics=firewall
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
/system package update
set channel=testing
/system scheduler
add disabled=yes interval=1d name="Backup And Update" on-event=\
    "/system script run BackupAndUpdate;" policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    start-date=2022-10-14 start-time=03:53:08
add disabled=yes interval=1m name=Zigby on-event="/system script run Zigby;" \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    start-date=2023-08-14 start-time=02:27:41
add disabled=yes interval=1m name=iridium on-event=\
    "/system script run iridium;" policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    start-date=2023-08-14 start-time=02:27:41
add disabled=yes interval=3s name=run_scenarios on-event=\
    "/system script run run_scenarios;" policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    start-date=2023-09-30 start-time=00:59:13
add name=start-singbox on-event=\
    "/execute script-file=usb1-part1/containers/sing-box/start.sh" policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    start-time=startup
add disabled=yes interval=2m name=TSPU on-event=WG_TSPU policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    start-date=2025-05-01 start-time=17:51:42
add interval=1w name=auto-update-cyberok on-event=update-cyberok-list policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    start-date=2025-11-12 start-time=04:00:00
/system script
add dont-require-permissions=yes name=MyTGBotSendMessage owner=admin policy=\
    read,test source=":local BotToken \"5618230805:AAFAIcZme9nBm_TUPnmhgdG3_gT\
    T3eLP1Bs\";\r\
    \n:local ChatID \"1009377001\";\r\
    \n:local ParseMode \"html\";\r\
    \n:local DisableWebPagePreview True;\r\
    \n:local SendText\r\
    \n:local SendText \$MessageText;\r\
    \n\r\
    \n\r\
    \n:local tgUrl \"https://api.telegram.org/bot\$BotToken/sendMessage\?chat_\
    id=\$ChatID&text=\$SendText&parse_mode=\$ParseMode&disable_web_page_previe\
    w=\$DisableWebPagePreview\";\r\
    \n#:log info \$tgUrl;\r\
    \n/tool fetch http-method=get url=\$tgUrl output=none;\r\
    \n\r\
    \n:log info \"Send Telegram Message: \$MessageText\";"
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
    \n:local backupPassword \"B&UFVG76fefrvbw8fvb83r7gq237e2e2e2r32r\"\r\
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
add dont-require-permissions=no name=Zigby owner=admin policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    "/tool fetch url=http://192.168.0.33/zigby.php"
add dont-require-permissions=no name=iridium owner=admin policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    "/tool fetch url=http://192.168.0.33/iridium/refresh_values.php"
add dont-require-permissions=no name=run_scenarios owner=admin policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    "/tool fetch url=http://192.168.0.33/iridium/run_scenarios.php"
add dont-require-permissions=no name=BackupAndUpdate2 owner=admin policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source="#\
    \_Script name: BackupAndUpdate\r\
    \n#\r\
    \n#----------SCRIPT INFORMATION-------------------------------------------\
    --------\r\
    \n#\r\
    \n# Script:  Mikrotik RouterOS automatic backup & update\r\
    \n# Version: 24.06.04\r\
    \n# Created: 07/08/2018\r\
    \n# Updated: 04/06/2024\r\
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
    \n# backup    -   Only backup will be performed. (default value, if none p\
    rovided)\r\
    \n#\r\
    \n# osupdate  -   The script will install a new RouterOS version if it is \
    available.\r\
    \n#               It will also create backups before and after update proc\
    ess (it does not matter what value `forceBackup` is set to)\r\
    \n#               Email will be sent only if a new RouterOS version is ava\
    ilable.\r\
    \n#               Change parameter `forceBackup` if you need the script to\
    \_create backups every time when it runs (even when no updates were found)\
    .\r\
    \n#\r\
    \n# osnotify  -   The script will send email notifications only (without b\
    ackups) if a new RouterOS update is available.\r\
    \n#               Change parameter `forceBackup` if you need the script to\
    \_create backups every time when it runs.\r\
    \n:local scriptMode \"osnotify\";\r\
    \n\r\
    \n## Additional parameter if you set `scriptMode` to `osupdate` or `osnoti\
    fy`\r\
    \n# Set `true` if you want the script to perform backup every time it's fi\
    red, whatever script mode is set.\r\
    \n:local forceBackup false;\r\
    \n\r\
    \n## Backup encryption password, no encryption if no password.\r\
    \n:local backupPassword \"B&UFVG76fefrvbw8fvb83r7gq237e2e2e2r32r\"\r\
    \n\r\
    \n## If true, passwords will be included in exported config.\r\
    \n:local sensitiveDataInConfig true;\r\
    \n\r\
    \n## Update channel. Possible values: stable, long-term, testing, developm\
    ent\r\
    \n:local updateChannel \"testing\";\r\
    \n\r\
    \n## Installs only patch versions of RouterOS updates.\r\
    \n## Works only if you set scriptMode to \"osupdate\"\r\
    \n## Means that new update will be installed only if MAJOR and MINOR versi\
    on numbers remained the same as currently installed RouterOS.\r\
    \n## Example: v6.43.6 => major.minor.PATCH\r\
    \n## Script will send information if new version is greater than just patc\
    h.\r\
    \n:local installOnlyPatchUpdates false;\r\
    \n\r\
    \n## If true, device public IP address information will be included into t\
    he email message\r\
    \n:local detectPublicIpAddress true;\r\
    \n\r\
    \n## Allow anonymous statistics collection. (script mode, device model, OS\
    \_version)\r\
    \n:local allowAnonymousStatisticsCollection true;\r\
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
    \n# Check email settings\r\
    \n:if ([:len \$emailAddress] = 0) do={\r\
    \n    :log error (\"\$SMP \\\$emailAddress variable is empty. Script stopp\
    ed.\");\r\
    \n    :error \"\$SMP bye!\";\r\
    \n}\r\
    \n:local emailServer \"\"\r\
    \n:do {\r\
    \n    :set emailServer [/tool e-mail get server];\r\
    \n} on-error={\r\
    \n    # Old of getting email server before the RouterOS v7.12\r\
    \n    :log info \"\$SMP Checking email server using old command `/tool e-m\
    ail get address`\";\r\
    \n    :set emailServer [/tool e-mail get address];\r\
    \n}\r\
    \n:if (\$emailServer = \"0.0.0.0\") do={\r\
    \n    :log error (\"\$SMP Email server address is not correct, please chec\
    k Tools -> Email. Script stopped.\");\r\
    \n    :error \"\$SMP bye!\";\r\
    \n}\r\
    \n:if ([:len [/tool e-mail get from]] = 0 or [/tool e-mail get from] = \"<\
    >\") do={\r\
    \n    :log error (\"\$SMP Email configuration FROM address is not correct,\
    \_please check Tools -> Email. Script stopped.\");\r\
    \n    :error \"\$SMP bye!\";\r\
    \n}\r\
    \n\r\
    \n\r\
    \n#Check if proper identity name is set\r\
    \nif ([:len [/system identity get name]] = 0 or [/system identity get name\
    ] = \"MikroTik\") do={\r\
    \n    :log warning (\"\$SMP Please set identity name of your device (Syste\
    m -> Identity), keep it short and informative.\");\r\
    \n};\r\
    \n\r\
    \n############### vvvvvvvvv GLOBALS vvvvvvvvv ###############\r\
    \n# Function converts standard mikrotik build versions to the number.\r\
    \n# Possible arguments: paramOsVer\r\
    \n# Example:\r\
    \n# :put [\$buGlobalFuncGetOsVerNum paramOsVer=[/system routerboard get cu\
    rrent-RouterOS]];\r\
    \n# Result will be: 64301, because current RouterOS version is: 6.43.1\r\
    \n:global buGlobalFuncGetOsVerNum do={\r\
    \n    :local osVer \$paramOsVer;\r\
    \n    :local osVerNum;\r\
    \n    :local osVerMicroPart;\r\
    \n    :local zro 0;\r\
    \n    :local tmp;\r\
    \n\r\
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
    \n\r\
    \n    :local dotPos1 [:find \$osVer \".\" 0];\r\
    \n\r\
    \n    :if (\$dotPos1 > 0) do={\r\
    \n\r\
    \n        # AA\r\
    \n        :set osVerNum  [:pick \$osVer 0 \$dotPos1];\r\
    \n\r\
    \n        :local dotPos2 [:find \$osVer \".\" \$dotPos1];\r\
    \n                #Taking minor version, everything after first dot\r\
    \n        :if ([:len \$dotPos2] = 0) do={:set tmp [:pick \$osVer (\$dotPos\
    1+1) [:len \$osVer]];}\r\
    \n        #Taking minor version, everything between first and second dots\
    \r\
    \n        :if (\$dotPos2 > 0) do={:set tmp [:pick \$osVer (\$dotPos1+1) \$\
    dotPos2];}\r\
    \n\r\
    \n        # AA 0B\r\
    \n        :if ([:len \$tmp] = 1) do={:set osVerNum \"\$osVerNum\$zro\$tmp\
    \";}\r\
    \n        # AA BB\r\
    \n        :if ([:len \$tmp] = 2) do={:set osVerNum \"\$osVerNum\$tmp\";}\r\
    \n\r\
    \n        :if (\$dotPos2 > 0) do={\r\
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
    \n# Possible arguments:\r\
    \n#    `backupName`               | string    | backup file name, without \
    extension!\r\
    \n#    `backupPassword`           | string    |\r\
    \n#    `sensitiveDataInConfig`    | boolean   |\r\
    \n# Example:\r\
    \n# :put [\$buGlobalFuncCreateBackups name=\"daily-backup\"];\r\
    \n:global buGlobalFuncCreateBackups do={\r\
    \n    :log info (\"\$SMP Global function \\\"buGlobalFuncCreateBackups\\\"\
    \_was fired.\");\r\
    \n\r\
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
    \n    :log info (\"\$SMP System backup created. \$backupFileSys\");\r\
    \n\r\
    \n    ## Export config file\r\
    \n    :if (\$sensitiveDataInConfig = true) do={\r\
    \n        # Since RouterOS v7 it needs to be explicitly set that we want t\
    o export sensitive data\r\
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
    \_script execution will be paused for a moment.\");\r\
    \n\r\
    \n    #Delay after creating backups\r\
    \n    :delay 20s;\r\
    \n    :return \$backupNames;\r\
    \n}\r\
    \n\r\
    \n:global buGlobalVarUpdateStep;\r\
    \n############### ^^^^^^^^^ GLOBALS ^^^^^^^^^ ###############\r\
    \n\r\
    \n:local scriptVersion \"24.06.04\";\r\
    \n\r\
    \n# Current time `hh-mm-ss`\r\
    \n:local currentTime ([:pick [/system clock get time] 0 2] . \"-\" . [:pic\
    k [/system clock get time] 3 5] . \"-\" . [:pick [/system clock get time] \
    6 8]);\r\
    \n\r\
    \n:local currentDateTime (\"-\" . \$currentTime);\r\
    \n\r\
    \n# Detect old date format, Example: `nov/11/2023`\r\
    \n:if ([:len [:tonum [:pick [/system clock get date] 0 1]]] = 0) do={\r\
    \n    :set currentDateTime ([:pick [/system clock get date] 7 11] . [:pick\
    \_[/system clock get date] 0 3] . [:pick [/system clock get date] 4 6] . \
    \"-\" . \$currentTime);\r\
    \n} else={\r\
    \n    # New date format, Example: `2023-11-11`\r\
    \n    :set currentDateTime ([/system clock get date] . \"-\" . \$currentTi\
    me);\r\
    \n};\r\
    \n\r\
    \n:local isSoftBased false;\r\
    \n:if ([:pick [/system resource get board-name] 0 3] = \"CHR\" or [:pick [\
    /system resource get board-name] 0 3] = \"x86\") do={\r\
    \n    :set isSoftBased true;\r\
    \n};\r\
    \n\r\
    \n:local deviceOsVerInst          [/system package update get installed-ve\
    rsion];\r\
    \n:local deviceOsVerInstNum       [\$buGlobalFuncGetOsVerNum paramOsVer=\$\
    deviceOsVerInst];\r\
    \n:local deviceOsVerAvail         \"\";\r\
    \n:local deviceOsVerAvailNum      0;\r\
    \n:local deviceIdentityName       [/system identity get name];\r\
    \n:local deviceIdentityNameShort  [:pick \$deviceIdentityName 0 18]\r\
    \n:local deviceUpdateChannel      [/system package update get channel];\r\
    \n\r\
    \n\r\
    \n:local deviceRbModel            \"CloudHostedRouter\";\r\
    \n:local deviceRbSerialNumber     \"--\";\r\
    \n:local deviceRbCurrentFw        \"--\";\r\
    \n:local deviceRbUpgradeFw        \"--\";\r\
    \n\r\
    \n:if (\$isSoftBased = false) do={\r\
    \n    :set deviceRbModel          [/system routerboard get model];\r\
    \n    :set deviceRbSerialNumber   [/system routerboard get serial-number];\
    \r\
    \n    :set deviceRbCurrentFw      [/system routerboard get current-firmwar\
    e];\r\
    \n    :set deviceRbUpgradeFw      [/system routerboard get upgrade-firmwar\
    e];\r\
    \n};\r\
    \n\r\
    \n:local isOsUpdateAvailable false;\r\
    \n:local isOsNeedsToBeUpdated false;\r\
    \n\r\
    \n:local isSendEmailRequired true;\r\
    \n\r\
    \n:local mailSubject  \"\$SMP Device - \$deviceIdentityNameShort.\";\r\
    \n:local mailBody     \"\";\r\
    \n\r\
    \n:local mailBodyDeviceInfo   \"\\r\\n\\r\\nDevice information: \\r\\nIden\
    tity: \$deviceIdentityName \\r\\nModel: \$deviceRbModel \\r\\nSerial numbe\
    r: \$deviceRbSerialNumber \\r\\nCurrent RouterOS: \$deviceOsVerInst (\$[/s\
    ystem package update get channel]) \$[/system resource get build-time] \\r\
    \\nCurrent routerboard FW: \$deviceRbCurrentFw \\r\\nDevice uptime: \$[/sy\
    stem resource get uptime]\";\r\
    \n:local mailBodyCopyright    \"\\r\\n\\r\\nMikrotik RouterOS automatic ba\
    ckup & update (ver. \$scriptVersion) \\r\\nhttps://github.com/beeyev/Mikro\
    tik-RouterOS-automatic-backup-and-update\";\r\
    \n:local changelogUrl         (\"Check RouterOS changelog: https://mikroti\
    k.com/download/changelogs/\" . \$updateChannel . \"-release-tree\");\r\
    \n\r\
    \n:local backupName           \"v\$deviceOsVerInst_\$deviceUpdateChannel_\
    \$currentDateTime\";\r\
    \n:local backupNameBeforeUpd  \"backup_before_update_\$backupName\";\r\
    \n:local backupNameAfterUpd   \"backup_after_update_\$backupName\";\r\
    \n\r\
    \n:local backupNameFinal  \$backupName;\r\
    \n:local mailAttachments  [:toarray \"\"];\r\
    \n\r\
    \n\r\
    \n:local ipAddressDetectServiceDefault \"https://ipv4.mikrotik.ovh/\"\r\
    \n:local ipAddressDetectServiceFallback \"https://api.ipify.org/\"\r\
    \n:local publicIpAddress \"not detected\";\r\
    \n:local telemetryDataQuery \"\";\r\
    \n\r\
    \n:local updateStep \$buGlobalVarUpdateStep;\r\
    \n:do {/system script environment remove buGlobalVarUpdateStep;} on-error=\
    {}\r\
    \n:if ([:len \$updateStep] = 0) do={\r\
    \n    :set updateStep 1;\r\
    \n}\r\
    \n\r\
    \n## IP address detection & anonymous statistics collection\r\
    \n:if (\$updateStep = 1 or \$updateStep = 3) do={\r\
    \n    :if (\$updateStep = 3) do={\r\
    \n        :log info (\"\$SMP Waiting for one minute before continuing to t\
    he final step.\");\r\
    \n        :delay 1m;\r\
    \n    }\r\
    \n\r\
    \n    :if (\$detectPublicIpAddress = true or \$allowAnonymousStatisticsCol\
    lection = true) do={\r\
    \n        :if (\$allowAnonymousStatisticsCollection = true) do={\r\
    \n            :set telemetryDataQuery (\"\\\?mode=\" . \$scriptMode . \"&o\
    sver=\" . \$deviceOsVerInst . \"&model=\" . \$deviceRbModel);\r\
    \n        }\r\
    \n\r\
    \n        :do {:set publicIpAddress ([/tool fetch http-method=\"get\" url=\
    (\$ipAddressDetectServiceDefault . \$telemetryDataQuery) output=user as-va\
    lue]->\"data\");} on-error={\r\
    \n\r\
    \n            :if (\$detectPublicIpAddress = true) do={\r\
    \n                :log warning \"\$SMP Could not detect public IP address \
    using default detection service.\"\r\
    \n                :log warning \"\$SMP Trying to detect public ip using fa\
    llback detection service.\"\r\
    \n\r\
    \n                :do {:set publicIpAddress ([/tool fetch http-method=\"ge\
    t\" url=\$ipAddressDetectServiceFallback output=user as-value]->\"data\");\
    } on-error={\r\
    \n                    :log warning \"\$SMP Could not detect public IP addr\
    ess using fallback detection service.\"\r\
    \n                }\r\
    \n            }\r\
    \n        }\r\
    \n\r\
    \n        :if (\$detectPublicIpAddress = true) do={\r\
    \n            # Always truncate the string for safety measures\r\
    \n            :set publicIpAddress ([:pick \$publicIpAddress 0 15])\r\
    \n            :set mailBodyDeviceInfo (\$mailBodyDeviceInfo . \"\\r\\nPubl\
    ic IP address: \" . \$publicIpAddress);\r\
    \n        }\r\
    \n    }\r\
    \n}\r\
    \n\r\
    \n\r\
    \n## STEP ONE: Creating backups, checking for new RouterOs version and sen\
    ding email with backups,\r\
    \n## Steps 2 and 3 are fired only if script is set to automatically update\
    \_device and if a new RouterOs version is available.\r\
    \n:if (\$updateStep = 1) do={\r\
    \n    :log info (\"\$SMP Performing the first step.\");\r\
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
    erOS versions from server\r\
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
    \n        # In this case the script will always send an email, because it \
    has to create backups\r\
    \n        :set isSendEmailRequired true;\r\
    \n    }\r\
    \n\r\
    \n    # If a new OS version is available to install\r\
    \n    if (\$isOsUpdateAvailable = true and \$isSendEmailRequired = true) d\
    o={\r\
    \n        # If we only need to notify about a new available version\r\
    \n        if (\$scriptMode = \"osnotify\") do={\r\
    \n            :set mailSubject    (\$mailSubject . \" New RouterOS is avai\
    lable! v.\$deviceOsVerAvail.\")\r\
    \n            :set mailBody       (\$mailBody . \"New RouterOS version is \
    available to install: v.\$deviceOsVerAvail (\$updateChannel) \\r\\n\$chang\
    elogUrl\")\r\
    \n        }\r\
    \n\r\
    \n        # If we need to initiate RouterOS update process\r\
    \n        if (\$scriptMode = \"osupdate\") do={\r\
    \n            :set isOsNeedsToBeUpdated true;\r\
    \n            # If we need to install only patch updates\r\
    \n            :if (\$installOnlyPatchUpdates = true) do={\r\
    \n                #Check if Major and Minor builds are the same.\r\
    \n                :if ([:pick \$deviceOsVerInstNum 0 ([:len \$deviceOsVerI\
    nstNum]-2)] = [:pick \$deviceOsVerAvailNum 0 ([:len \$deviceOsVerAvailNum]\
    -2)]) do={\r\
    \n                    :log info (\"\$SMP New patch version of RouterOS fir\
    mware is available.\");\r\
    \n                } else={\r\
    \n                    :log info           (\"\$SMP New major or minor vers\
    ion of RouterOS firmware is available. You need to update it manually.\");\
    \r\
    \n                    :set mailSubject    (\$mailSubject . \" New RouterOS\
    : v.\$deviceOsVerAvail needs to be installed manually.\");\r\
    \n                    :set mailBody       (\$mailBody . \"New major or min\
    or RouterOS version is available to install: v.\$deviceOsVerAvail (\$updat\
    eChannel). \\r\\nYou chose to automatically install only patch updates, so\
    \_this major update you need to install manually. \\r\\n\$changelogUrl\");\
    \r\
    \n                    :set isOsNeedsToBeUpdated false;\r\
    \n                }\r\
    \n            }\r\
    \n\r\
    \n            #Check again, because this variable could be changed during \
    checking for installing only patch updats\r\
    \n            if (\$isOsNeedsToBeUpdated = true) do={\r\
    \n                :log info           (\"\$SMP New RouterOS is going to be\
    \_installed! v.\$deviceOsVerInst -> v.\$deviceOsVerAvail\");\r\
    \n                :set mailSubject    (\$mailSubject . \" New RouterOS is \
    going to be installed! v.\$deviceOsVerInst -> v.\$deviceOsVerAvail.\");\r\
    \n                :set mailBody       (\$mailBody . \"Your Mikrotik will b\
    e updated to the new RouterOS version from v.\$deviceOsVerInst to v.\$devi\
    ceOsVerAvail (Update channel: \$updateChannel) \\r\\nA final report with d\
    etailed information will be sent once the update process is completed. \\r\
    \\nIf you do not receive a second email within the next 10 minutes, there \
    may be an issue. Please check your device logs for further information.\")\
    ;\r\
    \n                #!! There is more code connected to this part and first \
    step at the end of the script.\r\
    \n            }\r\
    \n\r\
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
    \n        :set mailBody       (\$mailBody . \"System backups were created \
    and attached to this email.\");\r\
    \n\r\
    \n        :set mailAttachments [\$buGlobalFuncCreateBackups backupName=\$b\
    ackupNameFinal backupPassword=\$backupPassword sensitiveDataInConfig=\$sen\
    sitiveDataInConfig];\r\
    \n    } else={\r\
    \n        :log info (\"\$SMP Creating a backup is not necessary.\");\r\
    \n    }\r\
    \n\r\
    \n    # Combine first step email\r\
    \n    :set mailBody (\$mailBody . \$mailBodyDeviceInfo . \$mailBodyCopyrig\
    ht);\r\
    \n}\r\
    \n\r\
    \n## STEP TWO: (after first reboot) routerboard firmware upgrade\r\
    \n## Steps 2 and 3 are fired only if script is set to automatically update\
    \_device and if new RouterOs is available.\r\
    \n:if (\$updateStep = 2) do={\r\
    \n    :log info (\"\$SMP Performing the second step.\");\r\
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
    k will be deleted when it is done. (That is why you should keep original s\
    cript name)\r\
    \n        /system scheduler add name=BKPUPD-FINAL-REPORT-ON-NEXT-BOOT on-e\
    vent=\":delay 5s; /system scheduler remove BKPUPD-FINAL-REPORT-ON-NEXT-BOO\
    T; :global buGlobalVarUpdateStep 3; :delay 10s; /system script run BackupA\
    ndUpdate;\" start-time=startup interval=0;\r\
    \n        ## Reboot system to boot with new firmware\r\
    \n        /system reboot;\r\
    \n    } else={\r\
    \n        :log info \"\$SMP It appears that your routerboard is already up\
    \_to date, skipping this step.\";\r\
    \n        :set updateStep 3;\r\
    \n    };\r\
    \n}\r\
    \n\r\
    \n## STEP THREE: Last step (after second reboot) sending final report\r\
    \n## Steps 2 and 3 are fired only if script is set to automatically update\
    \_device and if new RouterOs is available.\r\
    \n## This step is executed after some delay\r\
    \n:if (\$updateStep = 3) do={\r\
    \n    :log info (\"\$SMP Performing the third step.\");\r\
    \n    :log info \"Bkp&Upd: RouterOS and routerboard upgrade process was co\
    mpleted. New RouterOS version: v.\$deviceOsVerInst, routerboard firmware: \
    v.\$deviceRbCurrentFw.\";\r\
    \n    ## Small delay in case mikrotik needs some time to initialize connec\
    tions\r\
    \n    :log info \"\$SMP Sending the final email with report and backups.\"\
    ;\r\
    \n    :set mailSubject    (\$mailSubject . \" RouterOS Upgrade is complete\
    d, new version: v.\$deviceOsVerInst!\");\r\
    \n    :set mailBody       \"RouterOS and routerboard upgrade process was c\
    ompleted. \\r\\nNew RouterOS version: v.\$deviceOsVerInst, routerboard fir\
    mware: v.\$deviceRbCurrentFw. \\r\\n\$changelogUrl \\r\\n\\r\\nBackups of \
    the upgraded system are in the attachment of this email.  \$mailBodyDevice\
    Info \$mailBodyCopyright\";\r\
    \n    :set mailAttachments [\$buGlobalFuncCreateBackups backupName=\$backu\
    pNameAfterUpd backupPassword=\$backupPassword sensitiveDataInConfig=\$sens\
    itiveDataInConfig];\r\
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
    \n# Trying to send email with backups as attachments.\r\
    \n:log warning \"\$emailAddress email!!!!!!!!!.\"\r\
    \n:log warning \"\$mailBody email!!!!!!!!!.\"\r\
    \n\r\
    \n:if (\$isSendEmailRequired = true) do={\r\
    \n    :log info \"\$SMP Dispatching email message; estimated completion wi\
    thin 30 seconds.\";\r\
    \n    :do {/tool e-mail send to=\$emailAddress subject=\$mailSubject body=\
    \"kkk\" file=\$mailAttachments;} on-error={\r\
    \n        :delay 5s;\r\
    \n        :log error \"\$SMP could not send email message (\$[/tool e-mail\
    \_get last-status]). Will attempt redelivery shortly.\"\r\
    \n\r\
    \n        :delay 5m;\r\
    \n\r\
    \n        :do {/tool e-mail send to=\$emailAddress subject=\$mailSubject b\
    ody=\"fff\" file=\$mailAttachments;} on-error={\r\
    \n            :delay 5s;\r\
    \n            :log error \"\$SMP failed to send email message (\$[/tool e-\
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
    \n\r\
    \n    :if ([:len \$mailAttachments] > 0 and [/tool e-mail get last-status]\
    \_= \"succeeded\") do={\r\
    \n        :log info \"\$SMP File system cleanup.\"\r\
    \n        /file remove \$mailAttachments;\r\
    \n        :delay 2s;\r\
    \n    }\r\
    \n\r\
    \n}\r\
    \n\r\
    \n\r\
    \n# Fire RouterOS update process\r\
    \nif (\$isOsNeedsToBeUpdated = true) do={\r\
    \n\r\
    \n    :if (\$isSoftBased = false) do={\r\
    \n        ## Set scheduled task to upgrade routerboard firmware on the nex\
    t boot, task will be deleted when upgrade is done. (That is why you should\
    \_keep original script name)\r\
    \n        /system scheduler add name=BKPUPD-UPGRADE-ON-NEXT-BOOT on-event=\
    \":delay 5s; /system scheduler remove BKPUPD-UPGRADE-ON-NEXT-BOOT; :global\
    \_buGlobalVarUpdateStep 2; :delay 10s; /system script run BackupAndUpdate;\
    \" start-time=startup interval=0;\r\
    \n    } else= {\r\
    \n        ## If the script is executed on CHR, step 2 will be skipped\r\
    \n        /system scheduler add name=BKPUPD-UPGRADE-ON-NEXT-BOOT on-event=\
    \":delay 5s; /system scheduler remove BKPUPD-UPGRADE-ON-NEXT-BOOT; :global\
    \_buGlobalVarUpdateStep 3; :delay 10s; /system script run BackupAndUpdate;\
    \" start-time=startup interval=0;\r\
    \n    };\r\
    \n\r\
    \n\r\
    \n    :log info \"\$SMP everything is ready to install new RouterOS, going\
    \_to reboot in a moment!\"\r\
    \n    ## Command is reincarnation of the \"upgrade\" command - doing exact\
    ly the same but under a different name\r\
    \n    /system package update install;\r\
    \n}\r\
    \n\r\
    \n:log info \"\$SMP script \\\"Mikrotik RouterOS automatic backup & update\
    \\\" completed it's job.\\r\\n\";"
add dont-require-permissions=no name=WG_TSPU owner=admin policy=\
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
add dont-require-permissions=no name=vpn-all-enable owner=admin policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source="\
    \r\
    \n/ip firewall mangle enable [find comment=\"VPN-ALL: mark traffic\"]\r\
    \n/ip route enable [find routing-table=vpn-all-table]\r\
    \n/routing rule enable [find routing-mark=vpn-all]\r\
    \n:log info \"VPN-ALL: enabled - all traffic goes through VPN\"\r\
    \n"
add dont-require-permissions=no name=vpn-all-disable owner=admin policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source="\
    \r\
    \n/ip firewall mangle disable [find comment=\"VPN-ALL: mark traffic\"]\r\
    \n/ip route disable [find routing-table=vpn-all-table]\r\
    \n/routing rule disable [find routing-mark=vpn-all]\r\
    \n:log info \"VPN-ALL: disabled - back to normal routing\"\r\
    \n"
add dont-require-permissions=no name=update-cyberok-list owner=admin policy=\
    ftp,read,write,test source=":local listName \"cyberok-ban\"\
    \n:local url \"https://raw.githubusercontent.com/tread-lightly/CyberOK_Ski\
    pa_ips/main/lists/skipa_cidr.txt\"\
    \n:local fileName \"cyberok-temp.txt\"\
    \n\
    \n:log info \"CyberOK: Start update\"\
    \n\
    \n:do {\
    \n    /tool fetch url=\$url mode=https dst-path=\$fileName\
    \n    :log info \"CyberOK: File downloaded\"\
    \n} on-error={\
    \n    :log error \"CyberOK: Download failed\"\
    \n    :error \"Download failed\"\
    \n}\
    \n\
    \n:delay 3s\
    \n\
    \n:if ([:len [/file find name=\$fileName]] = 0) do={\
    \n    :log error \"CyberOK: File not found\"\
    \n    :error \"File not found\"\
    \n}\
    \n\
    \n:log info \"CyberOK: Removing old list\"\
    \n/ip firewall address-list remove [find where list=\$listName]\
    \n\
    \n:log info \"CyberOK: Adding new IPs\"\
    \n:local content [/file get \$fileName contents]\
    \n:local lineStart 0\
    \n:local lineEnd 0\
    \n:local line \"\"\
    \n:local countAdded 0\
    \n\
    \n:for i from=0 to=([:len \$content] - 1) do={\
    \n    :local char [:pick \$content \$i]\
    \n    :if (\$char = \"\\n\") do={\
    \n        :set lineEnd \$i\
    \n        :set line [:pick \$content \$lineStart \$lineEnd]\
    \n        :if ([:pick \$line ([:len \$line] - 1)] = \"\\r\") do={\
    \n            :set line [:pick \$line 0 ([:len \$line] - 1)]\
    \n        }\
    \n        :if ([:len \$line] > 7) do={\
    \n            :do {\
    \n                /ip firewall address-list add list=\$listName address=\$\
    line\
    \n                :set countAdded (\$countAdded + 1)\
    \n            } on-error={}\
    \n        }\
    \n        :set lineStart (\$i + 1)\
    \n    }\
    \n}\
    \n\
    \n:if (\$lineStart < [:len \$content]) do={\
    \n    :set line [:pick \$content \$lineStart [:len \$content]]\
    \n    :if ([:len \$line] > 7) do={\
    \n        :do {\
    \n            /ip firewall address-list add list=\$listName address=\$line\
    \n            :set countAdded (\$countAdded + 1)\
    \n        } on-error={}\
    \n    }\
    \n}\
    \n\
    \n/file remove \$fileName\
    \n\
    \n:local logMsg (\"CyberOK: Update done. Added: \" . \$countAdded)\
    \n:log info \$logMsg"
/tool e-mail
set from="\D2\E8\EC\E8\F0\FF\E7\E5\E2\E0 \EC\E8\EA\F0\EE\F2\E8\EA <ivaalex56@y\
    andex.ru>" port=587 server=smtp.yandex.ru tls=starttls user=\
    ivaalex56@yandex.ru
/tool mac-server
set allowed-interface-list=LAN
/tool mac-server mac-winbox
set allowed-interface-list=LAN
/tool netwatch
add disabled=no down-script="  # Variables \r\
    \n    :local Time [/system clock get time];\r\
    \n    :local Date [/system clock get date]; \r\
    \n    :local DeviceName [/system identity get name];\r\
    \n\r\
    \n    # START Send Telegram Module\r\
    \n    :local MessageText \"\\F0\\9F\\9F\\A2 <b>\$DeviceName: VideoServer d\
    own</b>\";\r\
    \n    :local SendTelegramMessage [:parse [/system script  get MyTGBotSendM\
    essage source]]; \r\
    \n    \$SendTelegramMessage MessageText=\$MessageText;\r\
    \n    #END Send Telegram Module" host=192.168.0.243 interval=20s timeout=\
    1s type=simple up-script="  # Variables\r\
    \n    :local Time [/system clock get time];\r\
    \n    :local Date [/system clock get date]; \r\
    \n    :local DeviceName [/system identity get name];\r\
    \n\r\
    \n    # START Send Telegram Module\r\
    \n    :local MessageText \"\\F0\\9F\\9F\\A2 <b>\$DeviceName: VideoServer U\
    P </b>\";\r\
    \n    :local SendTelegramMessage [:parse [/system script  get MyTGBotSendM\
    essage source]]; \r\
    \n    \$SendTelegramMessage MessageText=\$MessageText;\r\
    \n    #END Send Telegram Module"
add host=192.168.254.4 interval=10s type=simple
/tool sniffer
set filter-dst-ip-address=192.168.0.71/32 filter-ip-address=\
    192.168.100.254/32 filter-src-ip-address=192.168.100.0/24 \
    streaming-server=192.168.0.248
/tool traffic-generator packet-template
add header-stack=mac,ip,udp,raw name=packet-template-wg raw-header=f1c6 \
    special-footer=no udp-dst-port=0 udp-src-port=52566
/tool traffic-generator stream
add id=3 mbps=1 name=stream1 packet-size=1450 tx-template=*2
add id=10 mbps=1 name=stream-wg packet-size=1153 tx-template=\
    packet-template-wg