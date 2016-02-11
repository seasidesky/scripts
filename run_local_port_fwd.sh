sudo /sbin/iptables -t nat -I PREROUTING -p tcp --dport 80 -j REDIRECT --to-port 8780
sudo /sbin/iptables -t nat -I PREROUTING -p tcp --dport 443 -j REDIRECT --to-port 8743

