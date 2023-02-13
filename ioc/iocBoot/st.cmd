#!/opt/epics-R3.15.9/modules/modbus-R3-2/bin/linux-x86_64/modbusApp

< envPaths

cd ${MODBUS}
dbLoadDatabase("dbd/modbus.dbd")
modbus_registerRecordDeviceDriver(pdbbase)

drvAsynSerialPortConfigure("serialPort1", "/dev/pts/14", 0, 0, 0)
asynSetOption("serialPort1", 0, "baud", "115200")
asynSetOption("serialPort1", 0, "bits", "8")
asynSetOption("serialPort1", 0, "parity", "none")
asynSetOption("serialPort1", 0, "stop", "1")

asynSetTraceIOMask("serialPort1",0,4)

modbusInterposeConfig("serialPort1", 1, 0, 2)

drvModbusAsynConfigure("modbusPort1", "serialPort1", 2, 3, -1, 2, 7, 1000, "ABB M1M20")

cd ${IOC}
dbLoadRecords("st.db", "PORT = modbusPort1")
iocInit
