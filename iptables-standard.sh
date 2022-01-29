#!/usr/bin/env bash

# ref: https://www.bytefish.de/blog/iptables.html + GOOGLE

# set default policies to drop
iptables -P INPUT DROP
iptables -P OUTPUT DROP
iptables -P FORWARD DROP

# flush old rules across the various tables
iptables -F
iptables -X
iptables -Z
iptables -t nat -F
iptables -t nat -X
iptables -t nat -Z
iptables -t mangle -F
iptables -t mangle -X
iptables -t mangle -Z

# allow all loopback traffic
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT

# drop invalid packets
iptables -A INPUT  -m state --state INVALID -j DROP
iptables -A OUTPUT -m state --state INVALID -j DROP
iptables -A FORWARD -m state --state INVALID -j DROP

# allow established, related packets we've already seen
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A OUTPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

# input chain
iptables -A INPUT -p tcp -m tcp --dport 22 -m comment --comment "SSH" -j ACCEPT
iptables -A INPUT -p tcp -m tcp --dport 80 -m comment --comment "HTTP" -j ACCEPT
iptables -A INPUT -p tcp -m tcp --dport 443 -m comment --comment "HTTPS" -j ACCEPT

# output chain
iptables -A OUTPUT -p tcp -m tcp --dport 22 -m comment --comment "SSH" -j ACCEPT
iptables -A OUTPUT -p tcp -m tcp --dport 53 -m comment --comment "DNS-TCP" -j ACCEPT
iptables -A OUTPUT -p udp -m udp --dport 53 -m comment --comment "DNS-UDP" -j ACCEPT
iptables -A OUTPUT -p udp -m udp --dport 67:68 -m comment --comment "DHCP" -j ACCEPT
iptables -A OUTPUT -p tcp -m tcp --dport 80 -m comment --comment "HTTP" -j ACCEPT
iptables -A OUTPUT -p tcp -m tcp --dport 443 -m comment --comment "HTTPS" -j ACCEPT

# allow incoming icmp packets
iptables -A INPUT -p icmp --icmp-type 8 -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT
iptables -A OUTPUT -p icmp --icmp-type 0 -m state --state ESTABLISHED,RELATED -j ACCEPT

# allow outgoing icmp packets
iptables -A OUTPUT -p icmp --icmp-type 8 -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT
iptables -A INPUT -p icmp --icmp-type 0 -m state --state ESTABLISHED,RELATED -j ACCEPT

# explicit drop
iptables -A INPUT -j DROP
iptables -A OUTPUT -j DROP
iptables -A FORWARD -j DROP
