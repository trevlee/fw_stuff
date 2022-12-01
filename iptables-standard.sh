#!/usr/bin/env bash

# iptables var
ipt=$(which iptables)

# set filter policies to drop
$ipt -P INPUT DROP
$ipt -P OUTPUT DROP
$ipt -P FORWARD DROP

# flush rules + chains across the various tables
# flush packet counters across the various tables
$ipt -t raw -F
$ipt -t raw -X
$ipt -t raw -Z
$ipt -t mangle -F
$ipt -t mangle -X
$ipt -t mangle -Z
$ipt -t nat -F
$ipt -t nat -X
$ipt -t nat -Z
$ipt -t filter -F
$ipt -t filter -X
$ipt -t filter -Z
$ipt -t security -F
$ipt -t security -X
$ipt -t security -Z

# allow loopback traffic
$ipt -A INPUT -i lo -j ACCEPT
$ipt -A OUTPUT -o lo -j ACCEPT

# drop invalid packets
$ipt -A INPUT -m state --state INVALID -j DROP
$ipt -A OUTPUT -m state --state INVALID -j DROP
$ipt -A FORWARD -m state --state INVALID -j DROP
$ipt -A INPUT -m state --state INVALID -j DROP
$ipt -A OUTPUT -m state --state INVALID -j DROP
$ipt -A FORWARD -m state --state INVALID -j DROP

# input chain
$ipt -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

# output chain
$ipt -A OUTPUT -p tcp --dport 80 -j ACCEPT
$ipt -A OUTPUT -p tcp --dport 443 -j ACCEPT
$ipt -A OUTPUT -p udp --dport 53 -j ACCEPT
$ipt -A OUTPUT -p icmp -j ACCEPT
