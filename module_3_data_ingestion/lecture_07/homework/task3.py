suppliers_log = [ 
	"FreshFarm Inc", 
	"GreenFields Ltd", 
	"AgroWorld Co", 
	"FreshFarm Inc", 
	"GreenFields Ltd" 
]

unique_suppliers = set(suppliers_log)
unique_suppliers.add("GreenFields Ltd")
print(f'{"FreshFarm Inc" in unique_suppliers}\n{unique_suppliers}\n{len(unique_suppliers)}')

