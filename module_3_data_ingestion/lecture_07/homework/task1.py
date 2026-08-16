center_coords = (40.7128, -74.0060)
# center_coords[0] = 41.0 # Ошибка!!! Exception has occurred: TypeError 'tuple' object does not support item assignment
print(f'Coordinates of the location of the central warehouse: {center_coords[0]}, {center_coords[1]}\n{type(center_coords)}\n{len(center_coords)}')