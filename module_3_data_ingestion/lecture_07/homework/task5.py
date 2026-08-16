import json 
api_response_json = """ 
{ 
	"store": "StoreHub", 
	"orders": [ 
		{"id": 1, "total": 50}, 
		{"id": 2, "total": 200}, 
		{"id": 3, "total": 150} 
		]
 } 
"""
api_response_list = json.loads(api_response_json)
high_value_orders = [order for order in api_response_list["orders"] if order["total"] > 100]
api_response_list.update({"high_value_orders": high_value_orders})
api_response_json = json.dumps(api_response_list)
print(api_response_json)