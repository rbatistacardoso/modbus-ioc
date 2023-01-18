#!/opt/epics-R3.15.8/modules/modbus-R3-2/bin/linux-x86_64/modbusApp

< envPaths

cd ${MODBUS}
dbLoadDatabase("dbd/modbus.dbd")
modbus_registerRecordDeviceDriver(pdbbase)


drvAsynIPPortConfigure("tcpPort","10.1.3.123:5050",0,0,0)

modbusInterposeConfig("tcpPort", 1, 0, 0)

drvModbusAsynConfigure("modbusPort", "tcpPort", 1, 3, -1, 1, 4, 1000, "ABB M1M20")

cd ${IOC}
dbLoadRecords("database/st.db", "PORT=modbusPort, P=RA-ToSIA04, R=RF-ACPanel")
iocInit


