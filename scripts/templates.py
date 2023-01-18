from string import Template

ai_template = Template(
    '''
    record(ai, "$(P):$(R):${pv_property}") {
        field(DESC, "${desc}")
        field(DTYP,"asynInt32")
        field(INP,"@asyn($(PORT), ${register_addr})")
        field(LINR, "NO CONVERSION")
        field(ESLO, "1")
        field(EGUL, "0")
        field(SCAN,".1 second")
    }
    '''
)