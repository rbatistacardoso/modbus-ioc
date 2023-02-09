from openpyxl import load_workbook
from templates import *

SHEET = load_workbook(filename='../etc/M1MMODBUSMAPV1.0102856.XLSX')['Map']

## Create a dictionary of column names
ColNames = {}
Current  = 0
for COL in SHEET.iter_cols(1, SHEET.max_column):
    ColNames[COL[0].value] = Current
    Current += 1

# Create db file
file = open('../ioc/database/st.db', 'w')
for row_cells in SHEET.iter_rows(2, SHEET.max_row):
    if row_cells[ColNames['PV property']].value != None:
        file.write(ai_template.safe_substitute(pv_property=row_cells[ColNames['PV property']].value,\
            register_addr=row_cells[ColNames['Reg (Dec)']].value,\
                desc=row_cells[ColNames['Quantity/Functionality']].value))

file.close()