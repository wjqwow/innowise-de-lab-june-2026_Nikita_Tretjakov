from enum import unique


raw_sku = "CARROT-001"
raw_regions = ("Minsk", "Warsaw", "Berlin", "Warsaw")
raw_weight_str = "2.5"
raw_stock_str = "150"

weight_kg = float(raw_weight_str)
stock_quantity = int(raw_stock_str)

sku_as_list = list(raw_sku)
regions_list = list(raw_regions)
unique_regions = set(raw_regions)
regions_tuple = tuple(unique_regions)

empty_list_1 = []
empty_list_2 = list()
empty_dict_1 = {}
empty_dict_2 = dict()
empty_tuple_1 = ()
empty_tuple_2 = tuple()
empty_set = set()

print(bool(empty_list_1))
print(bool(empty_dict_1))
print(bool(empty_tuple_1))
print(bool(empty_set))
list_1 = [1, 2, 3, 4, 5]
dict_1 = {"a": 1, "b": 2, "c": 3}
tuple_1 = (1, 2, 3, 4, 5)
set_1 = {1, 2, 3, 4, 5}
print(bool(list_1))
print(bool(dict_1))
print(bool(tuple_1))
print(bool(set_1))

print(weight_kg, type(weight_kg))
print(stock_quantity, type(stock_quantity))
print(sku_as_list, type(sku_as_list))
print(regions_list, type(regions_list))
print(unique_regions, type(unique_regions))
print(regions_tuple, type(regions_tuple))
print(empty_list_1, type(empty_list_1))
print(empty_dict_1, type(empty_dict_1))
print(empty_tuple_1, type(empty_tuple_1))
print(empty_set, type(empty_set))
print(list_1, type(list_1))
print(dict_1, type(dict_1))
print(tuple_1, type(tuple_1))
print(set_1, type(set_1))