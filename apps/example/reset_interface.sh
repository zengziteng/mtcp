sudo ip link set dev enp94s0f0 xdp off
sudo ip link set dev enp94s0f0 down
sudo ip link set dev enp94s0f0 up
sudo ethtool -L enp94s0f0 combined 12
sudo ethtool -L enp94s0f0 combined 10
sudo ethtool -N enp94s0f0 rx-flow-hash tcp4 sdfn

