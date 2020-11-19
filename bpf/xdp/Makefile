build:
	 clang -Wall -target bpf -c drop.c -o drop.o

run-test:
	docker run -P -d nginx

attach:
	sudo ip link set dev lo xdp obj drop.o

remove:
	 sudo ip link set dev lo xdp off