sudo tee -a /etc/modules-load.d/ipvs.conf > /dev/null <<EOT
ip_vs
ip_vs_rr
ip_vs_sed
ip_vs_wrr
ip_vs_sh
nf_conntrack
EOT
