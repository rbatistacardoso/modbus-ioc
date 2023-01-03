#!/opt/epics-R3.15.9/modules/modbus-R3-2/bin/linux-x86_64/modbusApp

< envPaths

epicsEnvSet("MODBUS", "/opt/epics-R3.15.9/modules/modbus-R3-2")
epicsEnvSet("IOC", ".")

cd ${MODBUS}
dbLoadDatabase("dbd/modbus.dbd")
modbus_registerRecordDeviceDriver(pdbbase)


drvAsynIPPortConfigure("tcpPort","10.0.28.95:502",0,0,1)

modbusInterposeConfig("tcpPort", 0, 0, 0)

drvModbusAsynConfigure("modbusPort", "tcpPort", 1, 4, -1, 1, 4, 1000, "ABB M1M20")

cd ${TOP}
dbLoadRecords("database/st.db", "PORT=modbusPort, P=RA-ToSIA04, R=RF-ACPanel")
iocInit


