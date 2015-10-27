# OTL - Open Transceiver Logic
![alt tag](docs/otl_overview.png)

### Internal Communication Protocol

SIGNAL	     | SOURCE
------------ | ------
wrdata       | MASTER 
wraddr	     | MASTER
wrvalid      | MASTER
wrready      | SLAVE	
rddata       | SLAVE
rdaddr	     | MASTER
rdvalid      | SLAVE
rdready      | MASTER
	
