# how to use
## setup of subscriber
### setup of node-red
	in case of raspberry pi, it is possible to start node-red as daemon.
	sudo systemctl start nodered
	if it is not supported, copy "nodered.service" to "/etc/systemd/system/".
### check parameters
	edit node-red-flow-ctrl.service
		check WorkingDirectory, User and so on...

### install 
	copy node-red-flow-ctrl.service /etc/systemd/system/

### command
	sudo systemctl start node-red-flow-ctrl
	sudo systemctl stop node-red-flow-ctrl
	sudo systemctl status node-red-flow-ctrl

### auto start
	sudo systemctl enable node-red-flow-ctrl

	edit node-red.service
		check WorkingDirectory, User and so on...
